From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH] net: wireless: brcm80211: brcmsmac: phy: phy_lcn.c:  Remove unused function
Date: Sun, 21 Dec 2014 01:34:13 +0100
Message-ID: <1419122053-14613-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the function wlc_lcnphy_crsuprs() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  |    1 -
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   31 --------------------
 2 files changed, 32 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
index 4960f7d..a05dbde 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
@@ -1002,7 +1002,6 @@ s16 wlc_lcnphy_tempsense_new(struct brcms_phy *pi, bool mode);
 s8 wlc_lcnphy_tempsense_degree(struct brcms_phy *pi, bool mode);
 s8 wlc_lcnphy_vbatsense(struct brcms_phy *pi, bool mode);
 void wlc_phy_carrier_suppress_lcnphy(struct brcms_phy *pi);
-void wlc_lcnphy_crsuprs(struct brcms_phy *pi, int channel);
 void wlc_lcnphy_epa_switch(struct brcms_phy *pi, bool mode);
 void wlc_2064_vco_cal(struct brcms_phy *pi);
 
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
index 5f13662..d2adb2d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
@@ -1546,37 +1546,6 @@ s8 wlc_lcnphy_get_current_tx_pwr_idx(struct brcms_phy *pi)
 	return index;
 }
 
-void wlc_lcnphy_crsuprs(struct brcms_phy *pi, int channel)
-{
-	u16 afectrlovr, afectrlovrval;
-	afectrlovr = read_phy_reg(pi, 0x43b);
-	afectrlovrval = read_phy_reg(pi, 0x43c);
-	if (channel != 0) {
-		mod_phy_reg(pi, 0x43b, (0x1 << 1), (1) << 1);
-
-		mod_phy_reg(pi, 0x43c, (0x1 << 1), (0) << 1);
-
-		mod_phy_reg(pi, 0x43b, (0x1 << 4), (1) << 4);
-
-		mod_phy_reg(pi, 0x43c, (0x1 << 6), (0) << 6);
-
-		write_phy_reg(pi, 0x44b, 0xffff);
-		wlc_lcnphy_tx_pu(pi, 1);
-
-		mod_phy_reg(pi, 0x634, (0xff << 8), (0) << 8);
-
-		or_phy_reg(pi, 0x6da, 0x0080);
-
-		or_phy_reg(pi, 0x00a, 0x228);
-	} else {
-		and_phy_reg(pi, 0x00a, ~(0x228));
-
-		and_phy_reg(pi, 0x6da, 0xFF7F);
-		write_phy_reg(pi, 0x43b, afectrlovr);
-		write_phy_reg(pi, 0x43c, afectrlovrval);
-	}
-}
