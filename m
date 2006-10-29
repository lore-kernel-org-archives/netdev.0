From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] DCCP: fix printk format warnings
Date: Sun, 29 Oct 2006 13:24:40 -0800
Message-ID: <20061029132440.4bb93676.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@mandriva.com, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14066 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1030208AbWJ2V30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 16:29:26 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format warnings:
build2.out:net/dccp/ccids/ccid2.c:355: warning: long long unsigned int format, u64 arg (arg 3)
build2.out:net/dccp/ccids/ccid2.c:360: warning: long long unsigned int format, u64 arg (arg 3)
build2.out:net/dccp/ccids/ccid2.c:482: warning: long long unsigned int format, u64 arg (arg 5)
build2.out:net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 3)
build2.out:net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 4)
build2.out:net/dccp/ccids/ccid2.c:674: warning: long long unsigned int format, u64 arg (arg 3)
build2.out:net/dccp/ccids/ccid2.c:720: warning: long long unsigned int format, u64 arg (arg 3)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---

 net/dccp/ccids/ccid2.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff -Naurp linux-2.6.19-rc3-git5/net/dccp/ccids/ccid2.c~net_dccp_ccids_printk linux-2.6.19-rc3-git5/net/dccp/ccids/ccid2.c
--- linux-2.6.19-rc3-git5/net/dccp/ccids/ccid2.c~net_dccp_ccids_printk	2006-10-28 21:06:32.298965000 -0700
+++ linux-2.6.19-rc3-git5/net/dccp/ccids/ccid2.c	2006-10-29 13:23:45.211141000 -0800
@@ -352,14 +352,14 @@ static void ccid2_hc_tx_packet_sent(stru
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
-	ccid2_pr_debug("Sent: seq=%llu\n", seq);
+	ccid2_pr_debug("Sent: seq=%llu\n", (unsigned long long)seq);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
 
 		while (seqp != hctx->ccid2hctx_seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
-			       	       seqp->ccid2s_seq, seqp->ccid2s_acked,
-				       seqp->ccid2s_sent);
+			       	       (unsigned long long)seqp->ccid2s_seq,
+				       seqp->ccid2s_acked, seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
 		}
 	} while (0);
@@ -480,7 +480,8 @@ static inline void ccid2_new_ack(struct 
 		/* first measurement */
 		if (hctx->ccid2hctx_srtt == -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
-			       	       r, jiffies, seqp->ccid2s_seq);
+			       	       r, jiffies,
+				       (unsigned long long)seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
 			hctx->ccid2hctx_rttvar = r >> 1;
 		} else {
@@ -636,8 +637,9 @@ static void ccid2_hc_tx_packet_recv(stru
 			u64 ackno_end_rl;
 
 			dccp_set_seqno(&ackno_end_rl, ackno - rl);
-			ccid2_pr_debug("ackvec start:%llu end:%llu\n", ackno,
-				       ackno_end_rl);
+			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
+				       (unsigned long long)ackno,
+				       (unsigned long long)ackno_end_rl);
 			/* if the seqno we are analyzing is larger than the
 			 * current ackno, then move towards the tail of our
 			 * seqnos.
@@ -672,7 +674,7 @@ static void ccid2_hc_tx_packet_recv(stru
 
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
-					       	       seqp->ccid2s_seq);
+						       (unsigned long long)seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
 				if (seqp == hctx->ccid2hctx_seqt) {
@@ -718,7 +720,7 @@ static void ccid2_hc_tx_packet_recv(stru
 		while (1) {
 			if (!seqp->ccid2s_acked) {
 				ccid2_pr_debug("Packet lost: %llu\n",
-					       seqp->ccid2s_seq);
+					       (unsigned long long)seqp->ccid2s_seq);
 				/* XXX need to traverse from tail -> head in
 				 * order to detect multiple congestion events in
 				 * one ack vector.


---
