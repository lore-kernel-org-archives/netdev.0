From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 03/11] bnx2x: use prandom_bytes()
Date: Tue, 13 Nov 2012 22:37:02 +0900
Message-ID: <1352813830-4624-4-git-send-email-akinobu.mita@gmail.com>
References: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352813830-4624-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use prandom_bytes() to fill rss key with pseudo-random bytes.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
* v3
- rename random32_get_bytes to prandom_bytes

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4833b6a..257d38b 100644
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
+		prandom_bytes(params.rss_key, sizeof(params.rss_key));
 		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
 	}
 
-- 
1.7.11.7
