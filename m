From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] net/packet: remove unused parameter in prb_curr_blk_in_use().
Date: Wed, 24 May 2017 18:34:11 +0300
Message-ID: <1495640051-39181-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:5759 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937333AbdEXPeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 11:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes unused parameter from prb_curr_blk_in_use() method
in net/packet/af_packet.c.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/packet/af_packet.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e3eeed1..82ca49f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -196,8 +196,7 @@ static void *packet_previous_frame(struct packet_sock *po,
 		struct packet_ring_buffer *rb,
 		int status);
 static void packet_increment_head(struct packet_ring_buffer *buff);
-static int prb_curr_blk_in_use(struct tpacket_kbdq_core *,
-			struct tpacket_block_desc *);
+static int prb_curr_blk_in_use(struct tpacket_block_desc *);
 static void *prb_dispatch_next_block(struct tpacket_kbdq_core *,
 			struct packet_sock *);
 static void prb_retire_current_block(struct tpacket_kbdq_core *,
@@ -721,7 +720,7 @@ static void prb_retire_rx_blk_timer_expired(unsigned long data)
 			/* Case 1. Queue was frozen because user-space was
 			 *	   lagging behind.
 			 */
-			if (prb_curr_blk_in_use(pkc, pbd)) {
+			if (prb_curr_blk_in_use(pbd)) {
 				/*
 				 * Ok, user-space is still behind.
 				 * So just refresh the timer.
@@ -972,8 +971,7 @@ static void prb_retire_current_block(struct tpacket_kbdq_core *pkc,
 	}
 }
 
-static int prb_curr_blk_in_use(struct tpacket_kbdq_core *pkc,
-				      struct tpacket_block_desc *pbd)
+static int prb_curr_blk_in_use(struct tpacket_block_desc *pbd)
 {
 	return TP_STATUS_USER & BLOCK_STATUS(pbd);
 }
@@ -1064,7 +1062,7 @@ static void *__packet_lookup_frame_in_block(struct packet_sock *po,
 		 * Check if that last block which caused the queue to freeze,
 		 * is still in_use by user-space.
 		 */
-		if (prb_curr_blk_in_use(pkc, pbd)) {
+		if (prb_curr_blk_in_use(pbd)) {
 			/* Can't record this packet */
 			return NULL;
 		} else {
-- 
2.7.4
