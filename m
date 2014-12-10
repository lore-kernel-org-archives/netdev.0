From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.19] rtlwifi: rtl8192ce: Set fw_ready flag
Date: Wed, 10 Dec 2014 14:38:29 -0600
Message-ID: <1418243909-23428-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The setting of this flag was missed in previous modifications.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index eecb79f..1b73158 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -959,6 +959,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	local_save_flags(flags);
 	local_irq_enable();
 
+	rtlhal->fw_ready = false;
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus = _rtl92ce_init_mac(hw);
 	if (!rtstatus) {
@@ -975,6 +976,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		goto exit;
 	}
 
+	rtlhal->fw_ready = true;
 	rtlhal->last_hmeboxnum = 0;
 	rtl92c_phy_mac_config(hw);
 	/* because last function modify RCR, so we update
-- 
2.1.2
