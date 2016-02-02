From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 0/4] packet: tpacket gso and csum offload
Date: Tue,  2 Feb 2016 10:56:45 -0500
Message-ID: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:36270 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093AbcBBP4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:56:53 -0500
Received: by mail-qg0-f65.google.com with SMTP id u30so1067269qge.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:56:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Extend PACKET_VNET_HDR socket option support to packet sockets with
memory mapped rings (PACKET_RX_RING, PACKET_TX_RING).

Patches 2 and 4 add support to tpacket_rcv and tpacket_snd.

Patch 1 prepares for this by moving the relevant virtio_net_hdr
logic out of packet_snd and packet_rcv into helper functions.

GSO transmission requires all headers in the skb linear section.
Patch 3 moves parsing of tx_ring slot headers before skb allocation
to enable allocation with sufficient linear size.

Willem de Bruijn (4):
  packet: move vnet_hdr code to helper functions
  packet: vnet_hdr support for tpacket_rcv
  packet: parse tpacket header before skb alloc
  packet: tpacket_snd gso and checksum offload

 net/packet/af_packet.c | 438 +++++++++++++++++++++++++++++--------------------
 1 file changed, 262 insertions(+), 176 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
