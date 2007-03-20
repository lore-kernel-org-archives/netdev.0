From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 19/31] [CCID3]: More verbose debugging
Date: Tue, 20 Mar 2007 20:15:30 -0300
Message-ID: <20070320231530.GH17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:39497 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbXCTXPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:15:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66936wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:15:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a few debugging statements to ccid3.c

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 52dae40..26ab73d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -99,6 +99,11 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
+
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%llu\n",
+		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
+		       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
+
 }
 /*
  * Update X by
@@ -141,8 +146,13 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x)
+	if (hctx->ccid3hctx_x != old_x) {
+		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
+			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
+			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
+
 		ccid3_update_send_time(hctx);
+	}
 }
 
 /*
@@ -339,6 +349,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
-- 
1.5.0.3

