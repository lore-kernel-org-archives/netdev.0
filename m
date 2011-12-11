From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Subject: Re: iwlagn regression in v3.1.5
Date: Sun, 11 Dec 2011 17:33:25 +0100
Message-ID: <4EE4DB55.4090804@udo.edu>
References: <4EE4AEF4.2080702@udo.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020502090407090303020902"
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EE4AEF4.2080702@udo.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020502090407090303020902
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

the original commit 34a5b4b6af104cf18eb50748509528b9bdbc4036 in upstream 
(v3.2.0-rc5) break the driver too. Please revert it, before the release. 
Patch for 3.2-rc5 attached.

Regards,
Andrej Gelenberg

On 12/11/2011 02:24 PM, Andrej Gelenberg wrote:
> Hello,
>
> there in an regression in kernel release v3.1.5. Commit
> 43c308bd8d0a3e7d98c5abcd41a4a3fada3d198f "iwlwifi: do not re-configure
> HT40 after associated" break iwlagn driver for Intel Corporation
> Centrino Ultimate-N 6300 (rev 35) on my Thinkpad t510. I still can
> connect to the AP, but i can't pin or access anything. Reverting that
> commit solved the Problem. I attached the patch.
>
> Regards,
> Andrej Gelenberg


--------------020502090407090303020902
Content-Type: text/x-patch;
 name="0001-Revert-iwlwifi-do-not-re-configure-HT40-after-associ.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Revert-iwlwifi-do-not-re-configure-HT40-after-associ.pa";
 filename*1="tch"

>From 88a9409dbe93193d28e2fde6525e98c84a0ce115 Mon Sep 17 00:00:00 2001
From: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Date: Sun, 11 Dec 2011 17:21:38 +0100
Subject: [PATCH] Revert "iwlwifi: do not re-configure HT40 after associated"

This reverts commit 34a5b4b6af104cf18eb50748509528b9bdbc4036.
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
index a7a6def..58a381c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -528,24 +528,6 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
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
@@ -604,11 +586,19 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
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
index bacc06c..3a5e802 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2610,9 +2610,21 @@ static void iwlagn_mac_channel_switch(struct ieee80211_hw *hw,
 
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
index 3856aba..5b936ec 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -86,8 +86,6 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 			     struct ieee80211_vif *vif,
 			     struct ieee80211_bss_conf *bss_conf,
 			     u32 changes);
-void iwlagn_config_ht40(struct ieee80211_conf *conf,
-			struct iwl_rxon_context *ctx);
 
 /* uCode */
 int iwlagn_rx_calib_result(struct iwl_priv *priv,
-- 
1.7.8


--------------020502090407090303020902--
