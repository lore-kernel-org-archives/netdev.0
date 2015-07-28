From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] packet: remove handling of tx_ring from prb_shutdown_retire_blk_timer()
Date: Tue, 28 Jul 2015 14:21:26 +0200
Message-ID: <1438086086-10014-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:54032 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932173AbbG1M0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 08:26:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow e8e85cc5eb57 ("packet: remove handling of tx_ring") and remove
the tx_ring parameter from prb_shutdown_retire_blk_timer() as it is only
called with tx_ring = 0.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/packet/af_packet.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c9e8741..2af8590 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -518,13 +518,11 @@ static void prb_del_retire_blk_timer(struct tpacket_kbdq_core *pkc)
 }
 
 static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
-		int tx_ring,
 		struct sk_buff_head *rb_queue)
 {
 	struct tpacket_kbdq_core *pkc;
 
-	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring) :
-			GET_PBDQC_FROM_RB(&po->rx_ring);
+	pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
 
 	spin_lock_bh(&rb_queue->lock);
 	pkc->delete_blk_timer = 1;
@@ -4044,7 +4042,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 	if (closing && (po->tp_version > TPACKET_V2)) {
 		/* Because we don't support block-based V3 on tx-ring */
 		if (!tx_ring)
-			prb_shutdown_retire_blk_timer(po, tx_ring, rb_queue);
+			prb_shutdown_retire_blk_timer(po, rb_queue);
 	}
 	release_sock(sk);
 
-- 
2.2.2
