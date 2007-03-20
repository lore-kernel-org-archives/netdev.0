From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 15/31] [CCID3]: Remove redundant `len' test
Date: Tue, 20 Mar 2007 20:14:04 -0300
Message-ID: <20070320231404.GD17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:38396 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbXCTXOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:14:08 -0400
Received: by wx-out-0506.google.com with SMTP id h31so66486wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:14:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since CCID3 avoids  sending 0-byte data packets (cf. ccid3_hc_tx_send_packet),
testing for zero-payload length, as performed by ccid3_hc_tx_update_s, is
redundant - hence removed by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 746f79d..4be62a9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -149,11 +149,8 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	if (unlikely(len == 0))
-		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
-	else
-		hctx->ccid3hctx_s = hctx->ccid3hctx_s == 0 ? len :
-				    (9 * hctx->ccid3hctx_s + len) / 10;
+	hctx->ccid3hctx_s = hctx->ccid3hctx_s == 0 ? len :
+			    (9 * hctx->ccid3hctx_s + len) / 10;
 	/*
 	 * Note: We could do a potential optimisation here - when `s' changes,
 	 *	 recalculate sending rate and consequently t_ipi, t_delta, and
-- 
1.5.0.3

