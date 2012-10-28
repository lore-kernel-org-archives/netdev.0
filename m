From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/16] wireless: Convert dev_printk(KERN_<LEVEL> to dev_<level>(
Date: Sun, 28 Oct 2012 01:05:47 -0700
Message-ID: <daba421bfcef21b5fcc58ae0ce5e19e799ca9fe9.1351411047.git.joe@perches.com>
References: <cover.1351411047.git.joe@perches.com>
Cc: Johannes Berg <johannes.berg@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351411047.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_<level> calls take less code than dev_printk(KERN_<LEVEL>
and reducing object size is good.
Coalesce formats for easier grep.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/at76c50x-usb.c       |   85 ++++++++++++++---------------
 drivers/net/wireless/iwlegacy/common.h    |    5 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c |   28 ++++------
 3 files changed, 52 insertions(+), 66 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 99b9ddf..77fa428 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -379,7 +379,7 @@ static int at76_usbdfu_download(struct usb_device *udev, u8 *buf, u32 size,
 		 manifest_sync_timeout);
 
 	if (!size) {
-		dev_printk(KERN_ERR, &udev->dev, "FW buffer length invalid!\n");
+		dev_err(&udev->dev, "FW buffer length invalid!\n");
 		return -EINVAL;
 	}
 
@@ -391,8 +391,8 @@ static int at76_usbdfu_download(struct usb_device *udev, u8 *buf, u32 size,
 		if (need_dfu_state) {
 			ret = at76_dfu_get_state(udev, &dfu_state);
 			if (ret < 0) {
-				dev_printk(KERN_ERR, &udev->dev,
-					   "cannot get DFU state: %d\n", ret);
+				dev_err(&udev->dev,
+					"cannot get DFU state: %d\n", ret);
 				goto exit;
 			}
 			need_dfu_state = 0;
@@ -407,9 +407,9 @@ static int at76_usbdfu_download(struct usb_device *udev, u8 *buf, u32 size,
 				dfu_timeout = at76_get_timeout(&dfu_stat_buf);
 				need_dfu_state = 0;
 			} else
-				dev_printk(KERN_ERR, &udev->dev,
-					   "at76_dfu_get_status returned %d\n",
-					   ret);
+				dev_err(&udev->dev,
+					"at76_dfu_get_status returned %d\n",
+					ret);
 			break;
 
 		case STATE_DFU_DOWNLOAD_BUSY:
@@ -438,9 +438,9 @@ static int at76_usbdfu_download(struct usb_device *udev, u8 *buf, u32 size,
 			blockno++;
 
 			if (ret != bsize)
-				dev_printk(KERN_ERR, &udev->dev,
-					   "at76_load_int_fw_block "
-					   "returned %d\n", ret);
+				dev_err(&udev->dev,
+					"at76_load_int_fw_block returned %d\n",
+					ret);
 			need_dfu_state = 1;
 			break;
 
@@ -1255,8 +1255,7 @@ static int at76_load_external_fw(struct usb_device *udev, struct fwentry *fwe)
 	at76_dbg(DBG_DEVSTART, "opmode %d", op_mode);
 
 	if (op_mode != OPMODE_NORMAL_NIC_WITHOUT_FLASH) {
-		dev_printk(KERN_ERR, &udev->dev, "unexpected opmode %d\n",
-			   op_mode);
+		dev_err(&udev->dev, "unexpected opmode %d\n", op_mode);
 		return -EINVAL;
 	}
 
@@ -1275,9 +1274,9 @@ static int at76_load_external_fw(struct usb_device *udev, struct fwentry *fwe)
 			 size, bsize, blockno);
 		ret = at76_load_ext_fw_block(udev, blockno, block, bsize);
 		if (ret != bsize) {
-			dev_printk(KERN_ERR, &udev->dev,
-				   "loading %dth firmware block failed: %d\n",
-				   blockno, ret);
+			dev_err(&udev->dev,
+				"loading %dth firmware block failed: %d\n",
+				blockno, ret);
 			goto exit;
 		}
 		buf += bsize;
@@ -1293,8 +1292,8 @@ static int at76_load_external_fw(struct usb_device *udev, struct fwentry *fwe)
 exit:
 	kfree(block);
 	if (ret < 0)
-		dev_printk(KERN_ERR, &udev->dev,
-			   "downloading external firmware failed: %d\n", ret);
+		dev_err(&udev->dev,
+			"downloading external firmware failed: %d\n", ret);
 	return ret;
 }
 
@@ -1308,8 +1307,8 @@ static int at76_load_internal_fw(struct usb_device *udev, struct fwentry *fwe)
 				   need_remap ? 0 : 2 * HZ);
 
 	if (ret < 0) {
-		dev_printk(KERN_ERR, &udev->dev,
-			   "downloading internal fw failed with %d\n", ret);
+		dev_err(&udev->dev,
+			"downloading internal fw failed with %d\n", ret);
 		goto exit;
 	}
 
@@ -1319,8 +1318,8 @@ static int at76_load_internal_fw(struct usb_device *udev, struct fwentry *fwe)
 	if (need_remap) {
 		ret = at76_remap(udev);
 		if (ret < 0) {
-			dev_printk(KERN_ERR, &udev->dev,
-				   "sending REMAP failed with %d\n", ret);
+			dev_err(&udev->dev,
+				"sending REMAP failed with %d\n", ret);
 			goto exit;
 		}
 	}
@@ -1555,11 +1554,10 @@ static struct fwentry *at76_load_firmware(struct usb_device *udev,
 	at76_dbg(DBG_FW, "downloading firmware %s", fwe->fwname);
 	ret = request_firmware(&fwe->fw, fwe->fwname, &udev->dev);
 	if (ret < 0) {
-		dev_printk(KERN_ERR, &udev->dev, "firmware %s not found!\n",
-			   fwe->fwname);
-		dev_printk(KERN_ERR, &udev->dev,
-			   "you may need to download the firmware from "
-			   "http://developer.berlios.de/projects/at76c503a/\n");
+		dev_err(&udev->dev, "firmware %s not found!\n",
+			fwe->fwname);
+		dev_err(&udev->dev,
+			"you may need to download the firmware from http://developer.berlios.de/projects/at76c503a/\n");
 		goto exit;
 	}
 
@@ -1567,17 +1565,17 @@ static struct fwentry *at76_load_firmware(struct usb_device *udev,
 	fwh = (struct at76_fw_header *)(fwe->fw->data);
 
 	if (fwe->fw->size <= sizeof(*fwh)) {
-		dev_printk(KERN_ERR, &udev->dev,
-			   "firmware is too short (0x%zx)\n", fwe->fw->size);
+		dev_err(&udev->dev,
+			"firmware is too short (0x%zx)\n", fwe->fw->size);
 		goto exit;
 	}
 
 	/* CRC currently not checked */
 	fwe->board_type = le32_to_cpu(fwh->board_type);
 	if (fwe->board_type != board_type) {
-		dev_printk(KERN_ERR, &udev->dev,
-			   "board type mismatch, requested %u, got %u\n",
-			   board_type, fwe->board_type);
+		dev_err(&udev->dev,
+			"board type mismatch, requested %u, got %u\n",
+			board_type, fwe->board_type);
 		goto exit;
 	}
 
@@ -2150,8 +2148,7 @@ static int at76_alloc_urbs(struct at76_priv *priv,
 	}
 
 	if (!ep_in || !ep_out) {
-		dev_printk(KERN_ERR, &interface->dev,
-			   "bulk endpoints missing\n");
+		dev_err(&interface->dev, "bulk endpoints missing\n");
 		return -ENXIO;
 	}
 
@@ -2161,15 +2158,14 @@ static int at76_alloc_urbs(struct at76_priv *priv,
 	priv->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	priv->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!priv->rx_urb || !priv->tx_urb) {
-		dev_printk(KERN_ERR, &interface->dev, "cannot allocate URB\n");
+		dev_err(&interface->dev, "cannot allocate URB\n");
 		return -ENOMEM;
 	}
 
 	buffer_size = sizeof(struct at76_tx_buffer) + MAX_PADDING_SIZE;
 	priv->bulk_out_buffer = kmalloc(buffer_size, GFP_KERNEL);
 	if (!priv->bulk_out_buffer) {
-		dev_printk(KERN_ERR, &interface->dev,
-			   "cannot allocate output buffer\n");
+		dev_err(&interface->dev, "cannot allocate output buffer\n");
 		return -ENOMEM;
 	}
 
@@ -2230,8 +2226,7 @@ static int at76_init_new_device(struct at76_priv *priv,
 	/* MAC address */
 	ret = at76_get_hw_config(priv);
 	if (ret < 0) {
-		dev_printk(KERN_ERR, &interface->dev,
-			   "cannot get MAC address\n");
+		dev_err(&interface->dev, "cannot get MAC address\n");
 		goto exit;
 	}
 
@@ -2358,8 +2353,8 @@ static int at76_probe(struct usb_interface *interface,
 	   we get 204 with 2.4.23, Fiberline FL-WL240u (505A+RFMD2958) ??? */
 
 	if (op_mode == OPMODE_HW_CONFIG_MODE) {
-		dev_printk(KERN_ERR, &interface->dev,
-			   "cannot handle a device in HW_CONFIG_MODE\n");
+		dev_err(&interface->dev,
+			"cannot handle a device in HW_CONFIG_MODE\n");
 		ret = -EBUSY;
 		goto error;
 	}
@@ -2371,9 +2366,9 @@ static int at76_probe(struct usb_interface *interface,
 			   "downloading internal firmware\n");
 		ret = at76_load_internal_fw(udev, fwe);
 		if (ret < 0) {
-			dev_printk(KERN_ERR, &interface->dev,
-				   "error %d downloading internal firmware\n",
-				   ret);
+			dev_err(&interface->dev,
+				"error %d downloading internal firmware\n",
+				ret);
 			goto error;
 		}
 		usb_put_dev(udev);
@@ -2408,8 +2403,8 @@ static int at76_probe(struct usb_interface *interface,
 		/* Re-check firmware version */
 		ret = at76_get_mib(udev, MIB_FW_VERSION, &fwv, sizeof(fwv));
 		if (ret < 0) {
-			dev_printk(KERN_ERR, &interface->dev,
-				   "error %d getting firmware version\n", ret);
+			dev_err(&interface->dev,
+				"error %d getting firmware version\n", ret);
 			goto error;
 		}
 	}
@@ -2449,7 +2444,7 @@ static void at76_disconnect(struct usb_interface *interface)
 
 	wiphy_info(priv->hw->wiphy, "disconnecting\n");
 	at76_delete_device(priv);
-	dev_printk(KERN_INFO, &interface->dev, "disconnected\n");
+	dev_info(&interface->dev, "disconnected\n");
 }
 
 /* Structure for registering this driver with the USB subsystem */
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index b4bb813..e254cba 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -2919,9 +2919,8 @@ do {									\
 #define IL_DBG(level, fmt, args...)					\
 do {									\
 	if (il_get_debug_level(il) & level)				\
-		dev_printk(KERN_ERR, &il->hw->wiphy->dev,		\
-			 "%c %s " fmt, in_interrupt() ? 'I' : 'U',	\
-			__func__ , ## args);				\
+		dev_err(&il->hw->wiphy->dev, "%c %s " fmt,		\
+			in_interrupt() ? 'I' : 'U', __func__ , ##args); \
 } while (0)
 
 #define il_print_hex_dump(il, level, p, len)				\
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wireless/iwlwifi/pcie/trans.c
index f95d88d..4d9dfa7 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -699,13 +699,11 @@ static void iwl_apm_config(struct iwl_trans *trans)
 				PCI_CFG_LINK_CTRL_VAL_L1_EN) {
 		/* L1-ASPM enabled; disable(!) L0S */
 		iwl_set_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
-		dev_printk(KERN_INFO, trans->dev,
-			   "L1 Enabled; Disabling L0S\n");
+		dev_info(trans->dev, "L1 Enabled; Disabling L0S\n");
 	} else {
 		/* L1-ASPM disabled; enable(!) L0S */
 		iwl_clear_bit(trans, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
-		dev_printk(KERN_INFO, trans->dev,
-			   "L1 Disabled; Enabling L0S\n");
+		dev_info(trans->dev, "L1 Disabled; Enabling L0S\n");
 	}
 	trans->pm_support = !(lctl & PCI_CFG_LINK_CTRL_VAL_L0S_EN);
 }
@@ -2150,34 +2148,29 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev *pdev,
 							  DMA_BIT_MASK(32));
 		/* both attempts failed: */
 		if (err) {
-			dev_printk(KERN_ERR, &pdev->dev,
-				   "No suitable DMA available.\n");
+			dev_err(&pdev->dev, "No suitable DMA available\n");
 			goto out_pci_disable_device;
 		}
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		dev_printk(KERN_ERR, &pdev->dev,
-			   "pci_request_regions failed\n");
+		dev_err(&pdev->dev, "pci_request_regions failed\n");
 		goto out_pci_disable_device;
 	}
 
 	trans_pcie->hw_base = pci_ioremap_bar(pdev, 0);
 	if (!trans_pcie->hw_base) {
-		dev_printk(KERN_ERR, &pdev->dev, "pci_ioremap_bar failed\n");
+		dev_err(&pdev->dev, "pci_ioremap_bar failed\n");
 		err = -ENODEV;
 		goto out_pci_release_regions;
 	}
 
-	dev_printk(KERN_INFO, &pdev->dev,
-		   "pci_resource_len = 0x%08llx\n",
-		   (unsigned long long) pci_resource_len(pdev, 0));
-	dev_printk(KERN_INFO, &pdev->dev,
-		   "pci_resource_base = %p\n", trans_pcie->hw_base);
+	dev_info(&pdev->dev, "pci_resource_len = 0x%08llx\n",
+		 (unsigned long long) pci_resource_len(pdev, 0));
+	dev_info(&pdev->dev, "pci_resource_base = %p\n", trans_pcie->hw_base);
 
-	dev_printk(KERN_INFO, &pdev->dev,
-		   "HW Revision ID = 0x%X\n", pdev->revision);
+	dev_info(&pdev->dev, "HW Revision ID = 0x%X\n", pdev->revision);
 
 	/* We disable the RETRY_TIMEOUT register (0x41) to keep
 	 * PCI Tx retries from interfering with C3 CPU state */
@@ -2185,8 +2178,7 @@ struct iwl_trans *iwl_trans_pcie_alloc(struct pci_dev *pdev,
 
 	err = pci_enable_msi(pdev);
 	if (err)
-		dev_printk(KERN_ERR, &pdev->dev,
-			   "pci_enable_msi failed(0X%x)\n", err);
+		dev_err(&pdev->dev, "pci_enable_msi failed(0X%x)\n", err);
 
 	trans->dev = &pdev->dev;
 	trans_pcie->irq = pdev->irq;
-- 
1.7.8.112.g3fd21
