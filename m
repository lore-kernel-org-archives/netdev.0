From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Subject: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 14:24:04 +0100
Message-ID: <4EE4AEF4.2080702@udo.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060407050101070901000206"
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.HRZ.Uni-Dortmund.DE ([129.217.128.51]:60246 "EHLO
	unimail.uni-dortmund.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab1LKNxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 08:53:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060407050101070901000206
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

there in an regression in kernel release v3.1.5. Commit 
43c308bd8d0a3e7d98c5abcd41a4a3fada3d198f "iwlwifi: do not re-configure 
HT40 after associated" break iwlagn driver for Intel Corporation 
Centrino Ultimate-N 6300 (rev 35) on my Thinkpad t510. I still can 
connect to the AP, but i can't pin or access anything. Reverting that 
commit solved the Problem. I attached the patch.

Regards,
Andrej Gelenberg

--------------060407050101070901000206
Content-Type: text/x-patch;
 name="0001-Revert-iwlwifi-do-not-re-configure-HT40-after-associ.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Revert-iwlwifi-do-not-re-configure-HT40-after-associ.pa";
 filename*1="tch"

>From 4f53ace64deb22cc4dc5616c93a3b5e21435d429 Mon Sep 17 00:00:00 2001
From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Date: Sun, 11 Dec 2011 13:50:26 +0100
Subject: [PATCH] Revert "iwlwifi: do not re-configure HT40 after associated"

This reverts commit 43c308bd8d0a3e7d98c5abcd41a4a3fada3d198f.
It break wlan driver on my Thinkpad t510. I can connect to the network
and i get ip from dhcpcd, but no ping or tcp connection can be
established.

lspci:
03:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300
(rev 35)

dmesg:
[    3.697288] iwlagn 0000:03:00.0: PCI INT A -> GSI 17 (level, low) ->
IRQ 17
[    3.697841] iwlagn 0000:03:00.0: setting latency timer to 64
[    3.697873] iwlagn 0000:03:00.0: pci_resource_len = 0x00002000
[    3.698389] iwlagn 0000:03:00.0: pci_resource_base = ffffc90010084000
[    3.698954] iwlagn 0000:03:00.0: HW Revision ID = 0x35
[    3.699629] iwlagn 0000:03:00.0: irq 43 for MSI/MSI-X
[    3.699705] iwlagn 0000:03:00.0: Detected Intel(R) Centrino(R)
Ultimate-N 6300 AGN, REV=0x74
[    3.700181] iwlagn 0000:03:00.0: L1 Enabled; Disabling L0S
[    3.717265] iwlagn 0000:03:00.0: device EEPROM VER=0x436, CALIB=0x6
[    3.717461] iwlagn 0000:03:00.0: Device SKU: 0X1f0
[    3.717984] iwlagn 0000:03:00.0: Valid Tx ant: 0X7, Valid Rx ant: 0X7
[    3.718531] iwlagn 0000:03:00.0: Tunable channels: 13 802.11bg, 24
802.11a channels
[    3.719141] iwlagn 0000:03:00.0: loaded firmware version 9.221.4.1
build 25532
...
[   71.965289] iwlagn 0000:03:00.0: L1 Enabled; Disabling L0S
[   71.972290] iwlagn 0000:03:00.0: Radio type=0x0-0x3-0x1
[   72.213804] iwlagn 0000:03:00.0: L1 Enabled; Disabling L0S
[   72.220770] iwlagn 0000:03:00.0: Radio type=0x0-0x3-0x1

Signed-off-by: Andrej Gelenberg <andrej.gelenberg@udo.edu>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |   36 +++++++++-----------------
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   18 +++++++++++--
 drivers/net/wireless/iwlwifi/iwl-agn.h      |    2 -
 3 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index eabbf1a..a7ddc98 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -542,24 +542,6 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
 	return 0;
 }
 
-void iwlagn_config_ht40(struct ieee80211_conf *conf,
-	struct iwl_rxon_context *ctx)
-{
-	if (conf_is_ht40_minus(conf)) {
-		ctx->ht.extension_chan_offset =
-			IEEE80211_HT_PARAM_CHA_SEC_BELOW;
-		ctx->ht.is_40mhz = true;
-	} else if (conf_is_ht40_plus(conf)) {
-		ctx->ht.extension_chan_offset =
-			IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
-		ctx->ht.is_40mhz = true;
-	} else {
-		ctx->ht.extension_chan_offset =
-			IEEE80211_HT_PARAM_CHA_SEC_NONE;
-		ctx->ht.is_40mhz = false;
-	}
-}
-
 int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct iwl_priv *priv = hw->priv;
@@ -618,11 +600,19 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 				ctx->ht.enabled = conf_is_ht(conf);
 
 			if (ctx->ht.enabled) {
-				/* if HT40 is used, it should not change
-				 * after associated except channel switch */
-				if (iwl_is_associated_ctx(ctx) &&
-				     !ctx->ht.is_40mhz)
-					iwlagn_config_ht40(conf, ctx);
+				if (conf_is_ht40_minus(conf)) {
+					ctx->ht.extension_chan_offset =
+						IEEE80211_HT_PARAM_CHA_SEC_BELOW;
+					ctx->ht.is_40mhz = true;
+				} else if (conf_is_ht40_plus(conf)) {
+					ctx->ht.extension_chan_offset =
+						IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
+					ctx->ht.is_40mhz = true;
+				} else {
+					ctx->ht.extension_chan_offset =
+						IEEE80211_HT_PARAM_CHA_SEC_NONE;
+					ctx->ht.is_40mhz = false;
+				}
 			} else
 				ctx->ht.is_40mhz = false;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index f473c01..7157c6b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3086,9 +3086,21 @@ static void iwlagn_mac_channel_switch(struct ieee80211_hw *hw,
 
 	/* Configure HT40 channels */
 	ctx->ht.enabled = conf_is_ht(conf);
-	if (ctx->ht.enabled)
-		iwlagn_config_ht40(conf, ctx);
-	else
+	if (ctx->ht.enabled) {
+		if (conf_is_ht40_minus(conf)) {
+			ctx->ht.extension_chan_offset =
+				IEEE80211_HT_PARAM_CHA_SEC_BELOW;
+			ctx->ht.is_40mhz = true;
+		} else if (conf_is_ht40_plus(conf)) {
+			ctx->ht.extension_chan_offset =
+				IEEE80211_HT_PARAM_CHA_SEC_ABOVE;
+			ctx->ht.is_40mhz = true;
+		} else {
+			ctx->ht.extension_chan_offset =
+				IEEE80211_HT_PARAM_CHA_SEC_NONE;
+			ctx->ht.is_40mhz = false;
+		}
+	} else
 		ctx->ht.is_40mhz = false;
 
 	if ((le16_to_cpu(ctx->staging.channel) != ch))
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.h b/drivers/net/wireless/iwlwifi/iwl-agn.h
index e172f6b..d941c4c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -135,8 +135,6 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 			     struct ieee80211_vif *vif,
 			     struct ieee80211_bss_conf *bss_conf,
 			     u32 changes);
-void iwlagn_config_ht40(struct ieee80211_conf *conf,
-			struct iwl_rxon_context *ctx);
 
 /* uCode */
 void iwlagn_rx_calib_result(struct iwl_priv *priv,
-- 
1.7.8


--------------060407050101070901000206--
