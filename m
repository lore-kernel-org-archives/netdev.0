From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 01/20] adm8211: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:41 -0700
Message-ID: <a20e15809f23f2e6b3131a23b1631cbf5bf065b8.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/adm8211.c |   67 ++++++++++++++++++----------------------
 1 files changed, 30 insertions(+), 37 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 0ac09a2..5d2d1b5 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -15,6 +15,8 @@
  * more details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/if.h>
@@ -151,8 +153,8 @@ static int adm8211_read_eeprom(struct ieee80211_hw *dev)
 		else
 			priv->rf_type = ADM8211_TYPE_AIROHA;
 
-		printk(KERN_WARNING "%s (adm8211): Unknown RFtype %d\n",
-		       pci_name(priv->pdev), (cr49 >> 3) & 0x7);
+		pr_warn("%s: Unknown RFtype %d\n",
+			pci_name(priv->pdev), (cr49 >> 3) & 0x7);
 	}
 
 	priv->bbp_type = cr49 & 0x7;
@@ -169,20 +171,21 @@ static int adm8211_read_eeprom(struct ieee80211_hw *dev)
 		else
 			priv->bbp_type = ADM8211_TYPE_ADMTEK;
 
-		printk(KERN_WARNING "%s (adm8211): Unknown BBPtype: %d\n",
-		       pci_name(priv->pdev), cr49 >> 3);
+		pr_warn("%s: Unknown BBPtype: %d\n",
+			pci_name(priv->pdev), cr49 >> 3);
 	}
 
 	if (priv->eeprom->country_code >= ARRAY_SIZE(cranges)) {
-		printk(KERN_WARNING "%s (adm8211): Invalid country code (%d)\n",
-		       pci_name(priv->pdev), priv->eeprom->country_code);
+		pr_warn("%s: Invalid country code (%d)\n",
+			pci_name(priv->pdev), priv->eeprom->country_code);
 
 		chan_range = cranges[2];
 	} else
 		chan_range = cranges[priv->eeprom->country_code];
 
-	printk(KERN_DEBUG "%s (adm8211): Channel range: %d - %d\n",
-	       pci_name(priv->pdev), (int)chan_range.min, (int)chan_range.max);
+	pr_debug("%s: Channel range: %d - %d\n",
+		 pci_name(priv->pdev),
+		 (int)chan_range.min, (int)chan_range.max);
 
 	BUILD_BUG_ON(sizeof(priv->channels) != sizeof(adm8211_channels));
 
@@ -209,8 +212,8 @@ static int adm8211_read_eeprom(struct ieee80211_hw *dev)
 		else
 			priv->specific_bbptype = ADM8211_BBP_ADM8011;
 
-		printk(KERN_WARNING "%s (adm8211): Unknown specific BBP: %d\n",
-		       pci_name(priv->pdev), priv->eeprom->specific_bbptype);
+		pr_warn("%s: Unknown specific BBP: %d\n",
+			pci_name(priv->pdev), priv->eeprom->specific_bbptype);
 	}
 
 	switch (priv->eeprom->specific_rftype) {
@@ -230,15 +233,16 @@ static int adm8211_read_eeprom(struct ieee80211_hw *dev)
 		else if (priv->pdev->revision == ADM8211_REV_AB)
 			priv->transceiver_type = ADM8211_RFMD2948;
 
-		printk(KERN_WARNING "%s (adm8211): Unknown transceiver: %d\n",
-		       pci_name(priv->pdev), priv->eeprom->specific_rftype);
+		pr_warn("%s: Unknown transceiver: %d\n",
+			pci_name(priv->pdev), priv->eeprom->specific_rftype);
 
 		break;
 	}
 
-	printk(KERN_DEBUG "%s (adm8211): RFtype=%d BBPtype=%d Specific BBP=%d "
-               "Transceiver=%d\n", pci_name(priv->pdev), priv->rf_type,
-	       priv->bbp_type, priv->specific_bbptype, priv->transceiver_type);
+	pr_debug("%s: RFtype=%d BBPtype=%d Specific BBP=%d Transceiver=%d\n",
+		 pci_name(priv->pdev), priv->rf_type,
+		 priv->bbp_type, priv->specific_bbptype,
+		 priv->transceiver_type);
 
 	return 0;
 }
@@ -1773,8 +1777,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s (adm8211): Cannot enable new PCI device\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot enable new PCI device\n", pci_name(pdev));
 		return err;
 	}
 
@@ -1783,8 +1786,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	mem_addr = pci_resource_start(pdev, 1);
 	mem_len = pci_resource_len(pdev, 1);
 	if (io_len < 256 || mem_len < 1024) {
-		printk(KERN_ERR "%s (adm8211): Too short PCI resources\n",
-		       pci_name(pdev));
+		pr_err("%s: Too short PCI resources\n", pci_name(pdev));
 		goto err_disable_pdev;
 	}
 
@@ -1792,22 +1794,19 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	/* check signature */
 	pci_read_config_dword(pdev, 0x80 /* CR32 */, &reg);
 	if (reg != ADM8211_SIG1 && reg != ADM8211_SIG2) {
-		printk(KERN_ERR "%s (adm8211): Invalid signature (0x%x)\n",
-		       pci_name(pdev), reg);
+		pr_err("%s: Invalid signature (0x%x)\n", pci_name(pdev), reg);
 		goto err_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, "adm8211");
 	if (err) {
-		printk(KERN_ERR "%s (adm8211): Cannot obtain PCI resources\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot obtain PCI resources\n", pci_name(pdev));
 		return err; /* someone else grabbed it? don't disable it */
 	}
 
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) ||
 	    pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_ERR "%s (adm8211): No suitable DMA available\n",
-		       pci_name(pdev));
+		pr_err("%s: No suitable DMA available\n", pci_name(pdev));
 		goto err_free_reg;
 	}
 
@@ -1815,8 +1814,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 
 	dev = ieee80211_alloc_hw(sizeof(*priv), &adm8211_ops);
 	if (!dev) {
-		printk(KERN_ERR "%s (adm8211): ieee80211 alloc failed\n",
-		       pci_name(pdev));
+		pr_err("%s: ieee80211 alloc failed\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto err_free_reg;
 	}
@@ -1834,8 +1832,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 		priv->map = pci_iomap(pdev, 0, io_len);
 
 	if (!priv->map) {
-		printk(KERN_ERR "%s (adm8211): Cannot map device memory\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot map device memory\n", pci_name(pdev));
 		goto err_free_dev;
 	}
 
@@ -1843,8 +1840,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	priv->tx_ring_size = tx_ring_size;
 
 	if (adm8211_alloc_rings(dev)) {
-		printk(KERN_ERR "%s (adm8211): Cannot allocate TX/RX ring\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot allocate TX/RX ring\n", pci_name(pdev));
 		goto err_iounmap;
 	}
 
@@ -1853,8 +1849,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 		cpu_to_le16(ADM8211_CSR_READ(PAR1) & 0xFFFF);
 
 	if (!is_valid_ether_addr(perm_addr)) {
-		printk(KERN_WARNING "%s (adm8211): Invalid hwaddr in EEPROM!\n",
-		       pci_name(pdev));
+		pr_warn("%s: Invalid hwaddr in EEPROM!\n", pci_name(pdev));
 		random_ether_addr(perm_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, perm_addr);
@@ -1887,8 +1882,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 
 	err = adm8211_read_eeprom(dev);
 	if (err) {
-		printk(KERN_ERR "%s (adm8211): Can't alloc eeprom buffer\n",
-		       pci_name(pdev));
+		pr_err("%s: Can't alloc eeprom buffer\n", pci_name(pdev));
 		goto err_free_desc;
 	}
 
@@ -1898,8 +1892,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 
 	err = ieee80211_register_hw(dev);
 	if (err) {
-		printk(KERN_ERR "%s (adm8211): Cannot register device\n",
-		       pci_name(pdev));
+		pr_err("%s: Cannot register device\n", pci_name(pdev));
 		goto err_free_eeprom;
 	}
 
-- 
1.7.8.111.gad25c.dirty
