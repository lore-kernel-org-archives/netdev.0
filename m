From: Amerigo Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed,  6 Apr 2011 17:49:42 +0800
Message-ID: <1302083382-6715-1-git-send-email-amwang@redhat.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As scheduled in Documentation/feature-removal-schedule.txt,
remove "*50", "disable_hw_scan" module parameters and MODULE_ALIAS("iwl4965").

Cc: Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> 
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Meenakshi Venkataraman <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: WANG Cong <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

---
 Documentation/feature-removal-schedule.txt   |   31 --------------------------
 drivers/net/wireless/iwlegacy/iwl-core.c     |    3 +-
 drivers/net/wireless/iwlegacy/iwl-core.h     |    1 -
 drivers/net/wireless/iwlegacy/iwl3945-base.c |   13 -----------
 drivers/net/wireless/iwlegacy/iwl4965-base.c |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn.c       |   30 -------------------------
 drivers/net/wireless/iwlwifi/iwl-core.h      |    1 -
 7 files changed, 1 insertions(+), 79 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 274b32d..5037d0d 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -444,27 +444,6 @@ Who:	Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 
 ----------------------------
 
-What:	iwlwifi 50XX module parameters
-When:	2.6.40
-Why:	The "..50" modules parameters were used to configure 5000 series and
-	up devices; different set of module parameters also available for 4965
-	with same functionalities. Consolidate both set into single place
-	in drivers/net/wireless/iwlwifi/iwl-agn.c
-
-Who:	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
-
-----------------------------
-
-What:	iwl4965 alias support
-When:	2.6.40
-Why:	Internal alias support has been present in module-init-tools for some
-	time, the MODULE_ALIAS("iwl4965") boilerplate aliases can be removed
-	with no impact.
-
-Who:	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
-
----------------------------
-
 What:	xt_NOTRACK
 Files:	net/netfilter/xt_NOTRACK.c
 When:	April 2011
@@ -521,16 +500,6 @@ Who:    Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
 
 ----------------------------
 
-What:	iwlwifi disable_hw_scan module parameters
-When:	2.6.40
-Why:	Hareware scan is the prefer method for iwlwifi devices for
-	scanning operation. Remove software scan support for all the
-	iwlwifi devices.
-
-Who:	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
-
-----------------------------
-
 What:   access to nfsd auth cache through sys_nfsservctl or '.' files
         in the 'nfsd' filesystem.
 When:   2.6.40
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wireless/iwlegacy/iwl-core.c
index a209a0e..9fd851f 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -2112,8 +2112,7 @@ int iwl_legacy_mac_config(struct ieee80211_hw *hw, u32 changed)
 	IWL_DEBUG_MAC80211(priv, "enter to channel %d changed 0x%X\n",
 					channel->hw_value, changed);
 
-	if (unlikely(!priv->cfg->mod_params->disable_hw_scan &&
-			test_bit(STATUS_SCANNING, &priv->status))) {
+	if (unlikely(test_bit(STATUS_SCANNING, &priv->status))) {
 		scan_active = 1;
 		IWL_DEBUG_MAC80211(priv, "leave - scanning\n");
 	}
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.h b/drivers/net/wireless/iwlegacy/iwl-core.h
index f03b463..3fc77b7 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.h
+++ b/drivers/net/wireless/iwlegacy/iwl-core.h
@@ -194,7 +194,6 @@ struct iwl_ops {
 
 struct iwl_mod_params {
 	int sw_crypto;		/* def: 0 = using hardware encryption */
-	int disable_hw_scan;	/* def: 0 = use h/w scan */
 	int num_of_queues;	/* def: HW dependent */
 	int disable_11n;	/* def: 0 = 11n capabilities enabled */
 	int amsdu_size_8K;	/* def: 1 = enable 8K amsdu size */
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net/wireless/iwlegacy/iwl3945-base.c
index 28eb3d8..57df37c 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -93,7 +93,6 @@ MODULE_LICENSE("GPL");
 struct iwl_mod_params iwl3945_mod_params = {
 	.sw_crypto = 1,
 	.restart_fw = 1,
-	.disable_hw_scan = 1,
 	/* the rest are 0 by default */
 };
 
@@ -3956,15 +3955,6 @@ static int iwl3945_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 	priv->contexts[IWL_RXON_CTX_BSS].station_devtype = RXON_DEV_TYPE_ESS;
 	priv->contexts[IWL_RXON_CTX_BSS].unused_devtype = RXON_DEV_TYPE_ESS;
 
-	/*
-	 * Disabling hardware scan means that mac80211 will perform scans
-	 * "the hard way", rather than using device's scan.
-	 */
-	if (iwl3945_mod_params.disable_hw_scan) {
-		IWL_DEBUG_INFO(priv, "Disabling hw_scan\n");
-		iwl3945_hw_ops.hw_scan = NULL;
-	}
-
 	IWL_DEBUG_INFO(priv, "*** LOAD DRIVER ***\n");
 	priv->cfg = cfg;
 	priv->pci_dev = pdev;
@@ -4278,9 +4268,6 @@ MODULE_PARM_DESC(antenna, "select antenna (1=Main, 2=Aux, default 0 [both])");
 module_param_named(swcrypto, iwl3945_mod_params.sw_crypto, int, S_IRUGO);
 MODULE_PARM_DESC(swcrypto,
 		"using software crypto (default 1 [software])");
-module_param_named(disable_hw_scan, iwl3945_mod_params.disable_hw_scan,
-		int, S_IRUGO);
-MODULE_PARM_DESC(disable_hw_scan, "disable hardware scanning (default 1)");
 #ifdef CONFIG_IWLWIFI_LEGACY_DEBUG
 module_param_named(debug, iwlegacy_debug_level, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "debug output mask");
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index 91b3d8b..2801d87 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -86,7 +86,6 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_VERSION(DRV_VERSION);
 MODULE_AUTHOR(DRV_COPYRIGHT " " DRV_AUTHOR);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("iwl4965");
 
 void iwl4965_update_chain_flags(struct iwl_priv *priv)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 321b18b..f58571b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3968,14 +3968,6 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * 1. Allocating HW data
 	 ************************/
 
-	/* Disabling hardware scan means that mac80211 will perform scans
-	 * "the hard way", rather than using device's scan. */
-	if (cfg->mod_params->disable_hw_scan) {
-		dev_printk(KERN_DEBUG, &(pdev->dev),
-			"sw scan support is deprecated\n");
-		iwlagn_hw_ops.hw_scan = NULL;
-	}
-
 	hw = iwl_alloc_all(cfg);
 	if (!hw) {
 		err = -ENOMEM;
@@ -4585,43 +4577,21 @@ module_exit(iwl_exit);
 module_init(iwl_init);
 
 #ifdef CONFIG_IWLWIFI_DEBUG
-module_param_named(debug50, iwl_debug_level, uint, S_IRUGO);
-MODULE_PARM_DESC(debug50, "50XX debug output mask (deprecated)");
 module_param_named(debug, iwl_debug_level, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(debug, "debug output mask");
 #endif
 
-module_param_named(swcrypto50, iwlagn_mod_params.sw_crypto, bool, S_IRUGO);
-MODULE_PARM_DESC(swcrypto50,
-		 "using crypto in software (default 0 [hardware]) (deprecated)");
 module_param_named(swcrypto, iwlagn_mod_params.sw_crypto, int, S_IRUGO);
 MODULE_PARM_DESC(swcrypto, "using crypto in software (default 0 [hardware])");
-module_param_named(queues_num50,
-		   iwlagn_mod_params.num_of_queues, int, S_IRUGO);
-MODULE_PARM_DESC(queues_num50,
-		 "number of hw queues in 50xx series (deprecated)");
 module_param_named(queues_num, iwlagn_mod_params.num_of_queues, int, S_IRUGO);
 MODULE_PARM_DESC(queues_num, "number of hw queues.");
-module_param_named(11n_disable50, iwlagn_mod_params.disable_11n, int, S_IRUGO);
-MODULE_PARM_DESC(11n_disable50, "disable 50XX 11n functionality (deprecated)");
 module_param_named(11n_disable, iwlagn_mod_params.disable_11n, int, S_IRUGO);
 MODULE_PARM_DESC(11n_disable, "disable 11n functionality");
-module_param_named(amsdu_size_8K50, iwlagn_mod_params.amsdu_size_8K,
-		   int, S_IRUGO);
-MODULE_PARM_DESC(amsdu_size_8K50,
-		 "enable 8K amsdu size in 50XX series (deprecated)");
 module_param_named(amsdu_size_8K, iwlagn_mod_params.amsdu_size_8K,
 		   int, S_IRUGO);
 MODULE_PARM_DESC(amsdu_size_8K, "enable 8K amsdu size");
-module_param_named(fw_restart50, iwlagn_mod_params.restart_fw, int, S_IRUGO);
-MODULE_PARM_DESC(fw_restart50,
-		 "restart firmware in case of error (deprecated)");
 module_param_named(fw_restart, iwlagn_mod_params.restart_fw, int, S_IRUGO);
 MODULE_PARM_DESC(fw_restart, "restart firmware in case of error");
-module_param_named(
-	disable_hw_scan, iwlagn_mod_params.disable_hw_scan, int, S_IRUGO);
-MODULE_PARM_DESC(disable_hw_scan,
-		 "disable hardware scanning (default 0) (deprecated)");
 
 module_param_named(ucode_alternative, iwlagn_wanted_ucode_alternative, int,
 		   S_IRUGO);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index b316d83..2396da5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -252,7 +252,6 @@ struct iwl_ops {
 
 struct iwl_mod_params {
 	int sw_crypto;		/* def: 0 = using hardware encryption */
-	int disable_hw_scan;	/* def: 0 = use h/w scan */
 	int num_of_queues;	/* def: HW dependent */
 	int disable_11n;	/* def: 0 = 11n capabilities enabled */
 	int amsdu_size_8K;	/* def: 1 = enable 8K amsdu size */
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
