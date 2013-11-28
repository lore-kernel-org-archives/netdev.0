From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: packet: use macro GET_PBDQC_FROM_RB to simplify the codes
Date: Thu, 28 Nov 2013 17:53:43 +0800
Message-ID: <529712A7.3010604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:32751 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab3K1J4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 04:56:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/packet/af_packet.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..955611f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -430,7 +430,8 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 {
 	struct tpacket_kbdq_core *pkc;
 
-	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring)
+		      : GET_PBDQC_FROM_RB(&po->rx_ring);
 
 	spin_lock(&rb_queue->lock);
 	pkc->delete_blk_timer = 1;
@@ -456,7 +457,8 @@ static void prb_setup_retire_blk_timer(struct packet_sock *po, int tx_ring)
 	if (tx_ring)
 		BUG();
 
-	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
+	pkc = tx_ring ? GET_PBDQC_FROM_RB(&po->tx_ring)
+		      : GET_RBDQC_FROM_RB(&po->rx_ring);
 	prb_init_blk_timer(po, pkc, prb_retire_rx_blk_timer_expired);
 }
 
@@ -514,7 +516,7 @@ static void init_prb_bdqc(struct packet_sock *po,
 			struct pgv *pg_vec,
 			union tpacket_req_u *req_u, int tx_ring)
 {
-	struct tpacket_kbdq_core *p1 = &rb->prb_bdqc;
+	struct tpacket_kbdq_core *p1 = GET_PBDQC_FROM_RB(rb);
 	struct tpacket_block_desc *pbd;
 
 	memset(p1, 0x0, sizeof(*p1));
@@ -578,7 +580,7 @@ static void _prb_refresh_rx_retire_blk_timer(struct tpacket_kbdq_core *pkc)
 static void prb_retire_rx_blk_timer_expired(unsigned long data)
 {
 	struct packet_sock *po = (struct packet_sock *)data;
-	struct tpacket_kbdq_core *pkc = &po->rx_ring.prb_bdqc;
+	struct tpacket_kbdq_core *pkc = GET_PBDQC_FROM_RB(&po->rx_ring);
 	unsigned int frozen;
 	struct tpacket_block_desc *pbd;
 
-- 
1.8.3.1
