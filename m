From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v2 03/11] bnx2x: use random32_get_bytes()
Date: Sun,  4 Nov 2012 00:43:34 +0900
Message-ID: <1351957422-23243-4-git-send-email-akinobu.mita@gmail.com>
References: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45412 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756434Ab2KCPoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 11:44:23 -0400
In-Reply-To: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use random32_get_bytes() to fill rss key with pseudo-random bytes.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
new patch from v2

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4833b6a..9a25658 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1741,7 +1741,6 @@ int bnx2x_config_rss_pf(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 			bool config_hash)
 {
 	struct bnx2x_config_rss_params params = {NULL};
-	int i;
 
 	/* Although RSS is meaningless when there is a single HW queue we
 	 * still need it enabled in order to have HW Rx hash generated.
@@ -1773,9 +1772,7 @@ int bnx2x_config_rss_pf(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 
 	if (config_hash) {
 		/* RSS keys */
-		for (i = 0; i < sizeof(params.rss_key) / 4; i++)
-			params.rss_key[i] = random32();
-
+		random32_get_bytes(params.rss_key, sizeof(params.rss_key));
 		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
 	}
 
-- 
1.7.11.7
