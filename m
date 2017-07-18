From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] net/packet: remove unused PGV_FROM_VMALLOC definition.
Date: Tue, 18 Jul 2017 22:23:30 +0300
Message-ID: <1500405810-20611-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, loke.chetan@gmail.com, xiaosuo@gmail.com,
        shanwei@cn.fujitsu.com, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14928 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751513AbdGRTXX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 15:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the definition of PGV_FROM_VMALLOC from af_packet.c.
The PGV_FROM_VMALLOC definition was already removed by 
commit 441c793a5650 ("net: cleanup unused macros in net directory"),
and its usage was removed even before by commit c56b4d90123b 
("af_packet: remove pgv.flags"); but it was added back by mistake later on,
in commit f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer implementation").

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/packet/af_packet.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e3beb28203eb..ee035cbe5621 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -177,8 +177,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 #define BLK_PLUS_PRIV(sz_of_priv) \
 	(BLK_HDR_LEN + ALIGN((sz_of_priv), V3_ALIGNMENT))
 
-#define PGV_FROM_VMALLOC 1
-
 #define BLOCK_STATUS(x)	((x)->hdr.bh1.block_status)
 #define BLOCK_NUM_PKTS(x)	((x)->hdr.bh1.num_pkts)
 #define BLOCK_O2FP(x)		((x)->hdr.bh1.offset_to_first_pkt)
-- 
2.7.4
