From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] brcm80211: drop unreachable else case
Date: Fri,  6 Feb 2015 08:26:50 -0500
Message-ID: <1423229210-7313-1-git-send-email-hofrat@osadl.org>
Cc: Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Fabian Frederick <fabf@skynet.be>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Brett Rudley <brudley@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the if/elseif/else is exhaustive - there is no 4th case given the 
  rssi_ctrl_mask = RADIO_2055_NBRSSI_SEL | RADIO_2055_WBRSSI_G1_SEL | 
  RADIO_2055_WBRSSI_G2_SEL;
so this unreachable else case (dead code) can be dropped.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

It seems that there are only three cases:
RADIO_2055_NBRSSI_SEL | RADIO_2055_WBRSSI_G1_SEL | RADIO_2055_WBRSSI_G2_SEL
The conditional call to wlc_phy_rssisel_nphy(... NPHY_RSSI_SEL_*) thus do 
not seem to have a 4th case which would be covered by the final else.

If the final else is there to accommodate extensions then this patch is
of course wrong - in that case it would be good though to comment the
final else as it appears to be dead-code at the moment.

Patch was only compile tested with x86_64_defconfig + CONFIG_BRCMSMAC=m

Patch is against 3.19.0-rc7 (localversion-next is -next-20150204)

 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index 084f18f..99dac9b 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -23041,10 +23041,7 @@ static void wlc_phy_rssi_cal_nphy_rev2(struct brcms_phy *pi, u8 rssi_type)
 	else if (rssi_ctrl_state[0] == RADIO_2055_WBRSSI_G1_SEL)
 		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE1,
 				     NPHY_RSSI_SEL_W1);
-	else if (rssi_ctrl_state[0] == RADIO_2055_WBRSSI_G2_SEL)
-		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE1,
-				     NPHY_RSSI_SEL_W2);
-	else
+	else /* RADIO_2055_WBRSSI_G2_SEL */
 		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE1,
 				     NPHY_RSSI_SEL_W2);
 	if (rssi_ctrl_state[1] == RADIO_2055_NBRSSI_SEL)
@@ -23053,13 +23050,9 @@ static void wlc_phy_rssi_cal_nphy_rev2(struct brcms_phy *pi, u8 rssi_type)
 	else if (rssi_ctrl_state[1] == RADIO_2055_WBRSSI_G1_SEL)
 		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE2,
 				     NPHY_RSSI_SEL_W1);
-	else if (rssi_ctrl_state[1] == RADIO_2055_WBRSSI_G2_SEL)
+	else /* RADIO_2055_WBRSSI_G1_SEL */
 		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE2,
 				     NPHY_RSSI_SEL_W2);
-	else
-		wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_CORE2,
-				     NPHY_RSSI_SEL_W2);
-
 	wlc_phy_rssisel_nphy(pi, RADIO_MIMO_CORESEL_OFF, rssi_type);
 
 	write_phy_reg(pi, 0x91, rfctrlintc_state[0]);
-- 
1.7.10.4
