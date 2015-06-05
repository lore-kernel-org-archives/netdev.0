From: Antonio Murdaca <antoniomurdaca@gmail.com>
Subject: [PATCH] ethernet: micrel: use time_is_before_eq_jiffies
Date: Fri,  5 Jun 2015 18:58:38 +0200
Message-ID: <1433523518-5992-1-git-send-email-antonio.murdaca@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, julia.lawall@lip6.fr, akpm@linux-foundation.org,
	Antonio Murdaca <antonio.murdaca@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use time_is_before_eq_jiffies macro for time comparison

Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 48d2aec..75dc46c 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6689,7 +6689,7 @@ static void mib_monitor(unsigned long ptr)
 
 	/* This is used to verify Wake-on-LAN is working. */
 	if (hw_priv->pme_wait) {
-		if (hw_priv->pme_wait <= jiffies) {
+		if (time_is_before_eq_jiffies(hw_priv->pme_wait)) {
 			hw_clr_wol_pme_status(&hw_priv->hw);
 			hw_priv->pme_wait = 0;
 		}
-- 
2.4.2
