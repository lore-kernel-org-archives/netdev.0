From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 0/4] packet: tpacket gso and csum offload
Date: Wed,  3 Feb 2016 18:02:13 -0500
Message-ID: <1454540537-6884-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34446 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730AbcBCXJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 18:09:36 -0500
Received: by mail-qg0-f67.google.com with SMTP id 94so1746878qgt.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 15:09:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Extend PACKET_VNET_HDR socket option support to packet sockets with
memory mapped rings.

Patches 2 and 4 add support to tpacket_rcv and tpacket_snd.

Patch 1 prepares for this by moving the relevant virtio_net_hdr
logic out of packet_snd and packet_rcv into helper functions.

GSO transmission requires all headers in the skb linear section.
Patch 3 moves parsing of tx_ring slot headers before skb allocation
to enable allocation with sufficient linear size.

Changes
  v1->v2:
    - fix bounds checks:
      - subtract sizeof(vnet_hdr) before comparing tp_len to size_max
      - compare tp_len to size_max also with GSO, just do not truncate to MTU

Willem de Bruijn (4):
  packet: move vnet_hdr code to helper functions
  packet: vnet_hdr support for tpacket_rcv
  packet: parse tpacket header before skb alloc
  packet: tpacket_snd gso and checksum offload

 net/packet/af_packet.c | 440 +++++++++++++++++++++++++++++--------------------
 1 file changed, 263 insertions(+), 177 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
