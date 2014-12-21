From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: brcm80211: brcmsmac: phy: phy_n.c:  Remove unused function
Date: Sun, 21 Dec 2014 01:37:24 +0100
Message-ID: <1419122244-14765-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@adurom.com>,
	Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function wlc_phy_txpwr_idx_get_nphy() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h   |    1 -
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c |   19 -------------------
 2 files changed, 20 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
index 4960f7d..c3d4f17 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
@@ -1104,7 +1104,6 @@ void wlc_phy_txpwrctrl_enable_nphy(struct brcms_phy *pi, u8 ctrl_type);
 void wlc_phy_txpwr_fixpower_nphy(struct brcms_phy *pi);
 void wlc_phy_txpwr_apply_nphy(struct brcms_phy *pi);
 void wlc_phy_txpwr_papd_cal_nphy(struct brcms_phy *pi);
-u16 wlc_phy_txpwr_idx_get_nphy(struct brcms_phy *pi);
 
 struct nphy_txgains wlc_phy_get_tx_gain_nphy(struct brcms_phy *pi);
 int wlc_phy_cal_txiqlo_nphy(struct brcms_phy *pi,
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index 084f18f..44cb2f0 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -28257,25 +28257,6 @@ static bool wlc_phy_txpwr_ison_nphy(struct brcms_phy *pi)
 					    (0x1 << 14) | (0x1 << 13));
 }
 
-u16 wlc_phy_txpwr_idx_get_nphy(struct brcms_phy *pi)
-{
-	u16 tmp;
-	u16 pwr_idx[2];
-
-	if (wlc_phy_txpwr_ison_nphy(pi)) {
-		pwr_idx[0] = wlc_phy_txpwr_idx_cur_get_nphy(pi, PHY_CORE_0);
-		pwr_idx[1] = wlc_phy_txpwr_idx_cur_get_nphy(pi, PHY_CORE_1);
-
-		tmp = (pwr_idx[0] << 8) | pwr_idx[1];
-	} else {
-		tmp = ((pi->nphy_txpwrindex[PHY_CORE_0].index_internal & 0xff)
-			<< 8) |
-			(pi->nphy_txpwrindex[PHY_CORE_1].index_internal & 0xff);
-	}
-
-	return tmp;
-}
-
 void wlc_phy_txpwr_papd_cal_nphy(struct brcms_phy *pi)
 {
 	if (PHY_IPA(pi)
-- 
1.7.10.4
