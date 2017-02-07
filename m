From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 0/2] Fixes for header length truncation
Date: Tue,  7 Feb 2017 15:57:19 -0500
Message-ID: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
        sowmini.varadhan@oracle.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35261 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932357AbdBGU5f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:57:35 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so20736785qtc.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 12:57:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Packets should not enter the stack with truncated link layer headers
and link layer headers should always be stored in the skb linear
segment.

Patch 1 ensures the first for PF_PACKET sockets
Patch 2 ensures the second for PF_PACKET GSO sockets without tx_ring

Willem de Bruijn (2):
  net: introduce device min_header_len
  packet: round up linear to header len

 drivers/net/loopback.c    | 1 +
 include/linux/netdevice.h | 4 ++++
 net/ethernet/eth.c        | 1 +
 net/packet/af_packet.c    | 7 ++++---
 4 files changed, 10 insertions(+), 3 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
