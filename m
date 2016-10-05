From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH] net: bgmac: Fix errant feature flag check
Date: Wed,  5 Oct 2016 15:36:49 -0400
Message-ID: <1475696209-17799-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, zajec5@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During the conversion to the feature flags, a check against
ci->id != BCMA_CHIP_ID_BCM47162
became
bgmac->feature_flags & BGMAC_FEAT_CLKCTLS
instead of
!(bgmac->feature_flags & BGMAC_FEAT_CLKCTLS)

Reported-by: Rafał Miłecki <zajec5@gmail.com>
Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index c4751ec..87d00ea 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1024,7 +1024,7 @@ static void bgmac_enable(struct bgmac *bgmac)
 
 	mode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
 		BGMAC_DS_MM_SHIFT;
-	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode != 0)
+	if (!(bgmac->feature_flags & BGMAC_FEAT_CLKCTLST) || mode != 0)
 		bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
 	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode == 2)
 		bgmac_cco_ctl_maskset(bgmac, 1, ~0,
-- 
2.7.4
