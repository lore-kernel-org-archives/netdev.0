From: akpm@linux-foundation.org
Subject: [patch 2/2] dccp: ccid2.c, ccid3.c use clamp(), clamp_t()
Date: Fri, 02 May 2008 13:39:28 -0700
Message-ID: <200805022039.m42KdTeq013605@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com, acme@ghostprotocols.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46030 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756194AbYEBUkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:40:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Makes the intention of the nested min/max clear.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/ccids/ccid2.c |    2 +-
 net/dccp/ccids/ccid3.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN net/dccp/ccids/ccid2.c~dccp-ccid2c-ccid3c-use-clamp-clamp_t net/dccp/ccids/ccid2.c
--- a/net/dccp/ccids/ccid2.c~dccp-ccid2c-ccid3c-use-clamp-clamp_t
+++ a/net/dccp/ccids/ccid2.c
@@ -716,7 +716,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	 * packets for new connections, following the rules from [RFC3390]".
 	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
 	 */
-	hctx->ccid2hctx_cwnd = min(4U, max(2U, 4380U / dp->dccps_mss_cache));
+	hctx->ccid2hctx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
 	max_ratio = DIV_ROUND_UP(hctx->ccid2hctx_cwnd, 2);
diff -puN net/dccp/ccids/ccid3.c~dccp-ccid2c-ccid3c-use-clamp-clamp_t net/dccp/ccids/ccid3.c
--- a/net/dccp/ccids/ccid3.c~dccp-ccid2c-ccid3c-use-clamp-clamp_t
+++ a/net/dccp/ccids/ccid3.c
@@ -88,8 +88,8 @@ static void ccid3_hc_tx_set_state(struct
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
-				   max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
+	const __u32 w_init = clamp_t(__u32, 4380U,
+			2 * hctx->ccid3hctx_s, 4 * hctx->ccid3hctx_s);
 
 	return scaled_div(w_init << 6, hctx->ccid3hctx_rtt);
 }
_
