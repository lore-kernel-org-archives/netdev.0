From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 12/20] mwl8k: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:52 -0700
Message-ID: <f6b98c85e5cfd71c05078643f2388fb9797d1561.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.
Add missing newline terminations.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/mwl8k.c |   53 ++++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index cf7bdc6..7197e80 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -9,6 +9,8 @@
  * warranty of any kind, whether express or implied.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
@@ -522,7 +524,7 @@ static int mwl8k_request_firmware(struct mwl8k_priv *priv, char *fw_image,
 			rc = mwl8k_request_fw(priv, di->helper_image,
 					      &priv->fw_helper, false);
 		if (rc)
-			printk(KERN_ERR "%s: Error requesting helper fw %s\n",
+			pr_err("%s: Error requesting helper fw %s\n",
 			       pci_name(priv->pdev), di->helper_image);
 
 		if (rc || nowait)
@@ -542,7 +544,7 @@ static int mwl8k_request_firmware(struct mwl8k_priv *priv, char *fw_image,
 		rc = mwl8k_request_fw(priv, fw_image,
 				      &priv->fw_ucode, false);
 	if (rc) {
-		printk(KERN_ERR "%s: Error requesting firmware file %s\n",
+		pr_err("%s: Error requesting firmware file %s\n",
 		       pci_name(priv->pdev), fw_image);
 		mwl8k_release_fw(&priv->fw_helper);
 		return rc;
@@ -712,15 +714,15 @@ static int mwl8k_load_firmware(struct ieee80211_hw *hw)
 		const struct firmware *helper = priv->fw_helper;
 
 		if (helper == NULL) {
-			printk(KERN_ERR "%s: helper image needed but none "
-			       "given\n", pci_name(priv->pdev));
+			pr_err("%s: helper image needed but none given\n",
+			       pci_name(priv->pdev));
 			return -EINVAL;
 		}
 
 		rc = mwl8k_load_fw_image(priv, helper->data, helper->size);
 		if (rc) {
-			printk(KERN_ERR "%s: unable to load firmware "
-			       "helper image\n", pci_name(priv->pdev));
+			pr_err("%s: unable to load firmware helper image\n",
+			       pci_name(priv->pdev));
 			return rc;
 		}
 		msleep(20);
@@ -731,7 +733,7 @@ static int mwl8k_load_firmware(struct ieee80211_hw *hw)
 	}
 
 	if (rc) {
-		printk(KERN_ERR "%s: unable to load firmware image\n",
+		pr_err("%s: unable to load firmware image\n",
 		       pci_name(priv->pdev));
 		return rc;
 	}
@@ -2425,8 +2427,7 @@ static int mwl8k_cmd_get_hw_spec_ap(struct ieee80211_hw *hw)
 
 		api_version = le32_to_cpu(cmd->fw_api_version);
 		if (priv->device_info->fw_api_ap != api_version) {
-			printk(KERN_ERR "%s: Unsupported fw API version for %s."
-			       "  Expected %d got %d.\n", MWL8K_NAME,
+			pr_err("Unsupported fw API version for %s.  Expected %d got %d.\n",
 			       priv->device_info->part_name,
 			       priv->device_info->fw_api_ap,
 			       api_version);
@@ -5278,12 +5279,12 @@ MODULE_DEVICE_TABLE(pci, mwl8k_pci_id_table);
 static int mwl8k_request_alt_fw(struct mwl8k_priv *priv)
 {
 	int rc;
-	printk(KERN_ERR "%s: Error requesting preferred fw %s.\n"
-	       "Trying alternative firmware %s\n", pci_name(priv->pdev),
-	       priv->fw_pref, priv->fw_alt);
+	pr_err("%s: Error requesting preferred fw %s.\n"
+	       "Trying alternative firmware %s\n",
+	       pci_name(priv->pdev), priv->fw_pref, priv->fw_alt);
 	rc = mwl8k_request_fw(priv, priv->fw_alt, &priv->fw_ucode, true);
 	if (rc) {
-		printk(KERN_ERR "%s: Error requesting alt fw %s\n",
+		pr_err("%s: Error requesting alt fw %s\n",
 		       pci_name(priv->pdev), priv->fw_alt);
 		return rc;
 	}
@@ -5300,7 +5301,7 @@ static void mwl8k_fw_state_machine(const struct firmware *fw, void *context)
 	switch (priv->fw_state) {
 	case FW_STATE_INIT:
 		if (!fw) {
-			printk(KERN_ERR "%s: Error requesting helper fw %s\n",
+			pr_err("%s: Error requesting helper fw %s\n",
 			       pci_name(priv->pdev), di->helper_image);
 			goto fail;
 		}
@@ -5339,7 +5340,7 @@ static void mwl8k_fw_state_machine(const struct firmware *fw, void *context)
 
 	case FW_STATE_LOADING_ALT:
 		if (!fw) {
-			printk(KERN_ERR "%s: Error requesting alt fw %s\n",
+			pr_err("%s: Error requesting alt fw %s\n",
 			       pci_name(priv->pdev), di->helper_image);
 			goto fail;
 		}
@@ -5352,8 +5353,8 @@ static void mwl8k_fw_state_machine(const struct firmware *fw, void *context)
 		break;
 
 	default:
-		printk(KERN_ERR "%s: Unexpected firmware loading state: %d\n",
-		       MWL8K_NAME, priv->fw_state);
+		pr_err("Unexpected firmware loading state: %d\n",
+		       priv->fw_state);
 		BUG_ON(1);
 	}
 
@@ -5607,7 +5608,7 @@ static int mwl8k_reload_firmware(struct ieee80211_hw *hw, char *fw_image)
 	return rc;
 
 fail:
-	printk(KERN_WARNING "mwl8k: Failed to reload firmware image.\n");
+	pr_warn("Failed to reload firmware image\n");
 	return rc;
 }
 
@@ -5725,22 +5726,20 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	int rc;
 
 	if (!printed_version) {
-		printk(KERN_INFO "%s version %s\n", MWL8K_DESC, MWL8K_VERSION);
+		pr_info("%s version %s\n", MWL8K_DESC, MWL8K_VERSION);
 		printed_version = 1;
 	}
 
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot enable new PCI device\n",
-		       MWL8K_NAME);
+		pr_err("Cannot enable new PCI device\n");
 		return rc;
 	}
 
 	rc = pci_request_regions(pdev, MWL8K_NAME);
 	if (rc) {
-		printk(KERN_ERR "%s: Cannot obtain PCI resources\n",
-		       MWL8K_NAME);
+		pr_err("Cannot obtain PCI resources\n");
 		goto err_disable_device;
 	}
 
@@ -5749,7 +5748,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 
 	hw = ieee80211_alloc_hw(sizeof(*priv), &mwl8k_ops);
 	if (hw == NULL) {
-		printk(KERN_ERR "%s: ieee80211 alloc failed\n", MWL8K_NAME);
+		pr_err("ieee80211 alloc failed\n");
 		rc = -ENOMEM;
 		goto err_free_reg;
 	}
@@ -5796,10 +5795,10 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 		priv->fw_pref = di->fw_image_sta;
 		priv->fw_alt = di->fw_image_ap;
 	} else if (ap_mode_default && !di->fw_image_ap && di->fw_image_sta) {
-		printk(KERN_WARNING "AP fw is unavailable.  Using STA fw.");
+		pr_warn("AP fw is unavailable.  Using STA fw.\n");
 		priv->fw_pref = di->fw_image_sta;
 	} else if (!ap_mode_default && !di->fw_image_sta && di->fw_image_ap) {
-		printk(KERN_WARNING "STA fw is unavailable.  Using AP fw.");
+		pr_warn("STA fw is unavailable.  Using AP fw.\n");
 		priv->fw_pref = di->fw_image_ap;
 	}
 	rc = mwl8k_init_firmware(hw, priv->fw_pref, true);
@@ -5834,7 +5833,7 @@ err_disable_device:
 
 static void __devexit mwl8k_shutdown(struct pci_dev *pdev)
 {
-	printk(KERN_ERR "===>%s(%u)\n", __func__, __LINE__);
+	pr_err("===>%s(%u)\n", __func__, __LINE__);
 }
 
 static void __devexit mwl8k_remove(struct pci_dev *pdev)
-- 
1.7.8.111.gad25c.dirty
