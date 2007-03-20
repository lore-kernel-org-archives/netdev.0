From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 25/31] [CCID3]: Remove build warnings for 64bit
Date: Tue, 20 Mar 2007 20:17:25 -0300
Message-ID: <20070320231725.GN17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:44890 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932684AbXCTXRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:17:33 -0400
Received: by wr-out-0506.google.com with SMTP id 41so79208wry
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:17:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This clears the following sparc64 build warnings:
 1) warning: format "%ld" expects type "long int", but argument 3 has type "suseconds_t"
 2) warning: format "%llu" expects type "long long unsigned int", but argument 3 has type "__u64"
Fixed by using typecast to unsigned. This is argued to be safe, since the quantities, after
de-scaling (factor 2^6) fit all in u32.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 95eca99..dc6e418 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -94,9 +94,9 @@ static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%llu\n",
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
 		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
-		       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
+		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
 
 }
 /*
@@ -139,9 +139,11 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 	}
 
 	if (hctx->ccid3hctx_x != old_x) {
-		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
-			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
-			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
+		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
+			       "X_recv=%u\n", (unsigned)(old_x >> 6),
+			       (unsigned)(hctx->ccid3hctx_x >> 6),
+			       hctx->ccid3hctx_x_calc,
+			       (unsigned)(hctx->ccid3hctx_x_recv >> 6));
 
 		ccid3_update_send_interval(hctx);
 	}
-- 
1.5.0.3

