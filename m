From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 15/20] prism54: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:55 -0700
Message-ID: <ef1912a8d724b06a9cfc6afe28d4ef4abd9e6491.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
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
 drivers/net/wireless/prism54/isl_ioctl.c      |   69 +++++++++++------------
 drivers/net/wireless/prism54/islpci_dev.c     |   57 +++++++++----------
 drivers/net/wireless/prism54/islpci_eth.c     |   25 +++-----
 drivers/net/wireless/prism54/islpci_hotplug.c |   34 +++++------
 drivers/net/wireless/prism54/islpci_mgt.c     |   75 +++++++++---------------
 drivers/net/wireless/prism54/islpci_mgt.h     |    9 ++-
 drivers/net/wireless/prism54/oid_mgt.c        |   23 ++++----
 7 files changed, 130 insertions(+), 162 deletions(-)

diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 4e44b1a..0e6cfc8 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -71,9 +73,8 @@ prism54_mib_mode_helper(islpci_private *priv, u32 iw_mode)
 
 	/* For now, just catch early the Repeater and Secondary modes here */
 	if (iw_mode == IW_MODE_REPEAT || iw_mode == IW_MODE_SECOND) {
-		printk(KERN_DEBUG
-		       "%s(): Sorry, Repeater mode and Secondary mode "
-		       "are not yet supported by this driver.\n", __func__);
+		pr_debug("%s(): Sorry, Repeater mode and Secondary mode are not yet supported by this driver\n",
+			 __func__);
 		return -EINVAL;
 	}
 
@@ -331,9 +332,8 @@ prism54_set_mode(struct net_device *ndev, struct iw_request_info *info,
 
 	/* Let's see if the user passed a valid Linux Wireless mode */
 	if (*uwrq > IW_MODE_MONITOR || *uwrq < IW_MODE_AUTO) {
-		printk(KERN_DEBUG
-		       "%s: %s() You passed a non-valid init_mode.\n",
-		       priv->ndev->name, __func__);
+		pr_debug("%s: %s() You passed a non-valid init_mode\n",
+			 priv->ndev->name, __func__);
 		return -EINVAL;
 	}
 
@@ -1232,17 +1232,15 @@ prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
 	u *= 4;
 	if (vwrq->disabled) {
 		/* don't know how to disable radio */
-		printk(KERN_DEBUG
-		       "%s: %s() disabling radio is not yet supported.\n",
-		       priv->ndev->name, __func__);
+		pr_debug("%s: %s() disabling radio is not yet supported\n",
+			 priv->ndev->name, __func__);
 		return -ENOTSUPP;
 	} else if (vwrq->fixed)
 		/* currently only fixed value is supported */
 		return mgt_set_request(priv, OID_INL_OUTPUTPOWER, 0, &u);
 	else {
-		printk(KERN_DEBUG
-		       "%s: %s() auto power will be implemented later.\n",
-		       priv->ndev->name, __func__);
+		pr_debug("%s: %s() auto power will be implemented later\n",
+			 priv->ndev->name, __func__);
 		return -ENOTSUPP;
 	}
 }
@@ -1287,8 +1285,7 @@ static int prism54_set_genie(struct net_device *ndev,
 		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
 			priv->wpa_ie_len);
 		if (ret == 0)
-			printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
-				ndev->name);
+			pr_debug("%s: WPA IE Attachment was set\n", ndev->name);
 	}
 
 	kfree(attach);
@@ -2151,8 +2148,7 @@ prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 		bss->wpa_ie_len = wpa_ie_len;
 		bss->last_update = jiffies;
 	} else {
-		printk(KERN_DEBUG "Failed to add BSS WPA entry for "
-		       "%pM\n", bssid);
+		pr_debug("Failed to add BSS WPA entry for %pM\n", bssid);
 	}
 
 	/* expire old entries from WPA list */
@@ -2226,8 +2222,8 @@ prism54_process_bss_data(islpci_private *priv, u32 oid, u8 *addr,
 	end = payload + len;
 	while (pos < end) {
 		if (pos + 2 + pos[1] > end) {
-			printk(KERN_DEBUG "Parsing Beacon/ProbeResp failed "
-			       "for %pM\n", addr);
+			pr_debug("Parsing Beacon/ProbeResp failed for %pM\n",
+				 addr);
 			return;
 		}
 		if (pos[0] == WLAN_EID_GENERIC && pos[1] >= 4 &&
@@ -2354,8 +2350,7 @@ prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
 			break;
 
 		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-		printk(KERN_DEBUG "Authenticate from: address:\t%pM\n",
-		       mlmeex->address);
+		pr_debug("Authenticate from: address:\t%pM\n", mlmeex->address);
 		confirm->id = -1; /* or mlmeex->id ? */
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
@@ -2400,8 +2395,8 @@ prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
 		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from address:\t%pM\n",
-			       mlmeex->address);
+			pr_debug("No WPA IE found from address:\t%pM\n",
+				 mlmeex->address);
 			kfree(confirm);
 			break;
 		}
@@ -2437,8 +2432,8 @@ prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
 		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from address:\t%pM\n",
-			       mlmeex->address);
+			pr_debug("No WPA IE found from address:\t%pM\n",
+				 mlmeex->address);
 			kfree(confirm);
 			break;
 		}
@@ -2521,11 +2516,11 @@ prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 			filter = 0; /* Do not filter un-encrypted data */
 			dot1x = 0;
 			mlme = DOT11_MLME_AUTO;
-			printk("%s: Disabling WPA\n", ndev->name);
+			pr_info("%s: Disabling WPA\n", ndev->name);
 			break;
 		case 2:
 		case 1: /* WPA */
-			printk("%s: Enabling WPA\n", ndev->name);
+			pr_info("%s: Enabling WPA\n", ndev->name);
 			break;
 	}
 	up_write(&priv->mib_sem);
@@ -2577,7 +2572,7 @@ prism54_debug_oid(struct net_device *ndev, struct iw_request_info *info,
 	islpci_private *priv = netdev_priv(ndev);
 
 	priv->priv_oid = *uwrq;
-	printk("%s: oid 0x%08X\n", ndev->name, *uwrq);
+	pr_debug("%s: oid 0x%08X\n", ndev->name, *uwrq);
 
 	return 0;
 }
@@ -2590,7 +2585,7 @@ prism54_debug_get_oid(struct net_device *ndev, struct iw_request_info *info,
 	struct islpci_mgmtframe *response;
 	int ret = -EIO;
 
-	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
+	pr_debug("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
 	data->length = 0;
 
 	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
@@ -2598,20 +2593,20 @@ prism54_debug_get_oid(struct net_device *ndev, struct iw_request_info *info,
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					   priv->priv_oid, extra, 256,
 					   &response);
-		printk("%s: ret: %i\n", ndev->name, ret);
+		pr_debug("%s: ret: %i\n", ndev->name, ret);
 		if (ret || !response
 		    || response->header->operation == PIMFOR_OP_ERROR) {
 			if (response) {
 				islpci_mgt_release(response);
 			}
-			printk("%s: EIO\n", ndev->name);
+			pr_debug("%s: EIO\n", ndev->name);
 			ret = -EIO;
 		}
 		if (!ret) {
 			data->length = response->header->length;
 			memcpy(extra, response->data, data->length);
 			islpci_mgt_release(response);
-			printk("%s: len: %i\n", ndev->name, data->length);
+			pr_debug("%s: len: %i\n", ndev->name, data->length);
 		}
 	}
 
@@ -2626,27 +2621,27 @@ prism54_debug_set_oid(struct net_device *ndev, struct iw_request_info *info,
 	struct islpci_mgmtframe *response;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
 
-	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
-	       data->length);
+	pr_debug("%s: set_oid 0x%08X\tlen: %d\n",
+		 ndev->name, priv->priv_oid, data->length);
 
 	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
 		ret =
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
 					   priv->priv_oid, extra, data->length,
 					   &response);
-		printk("%s: ret: %i\n", ndev->name, ret);
+		pr_debug("%s: ret: %i\n", ndev->name, ret);
 		if (ret || !response
 		    || response->header->operation == PIMFOR_OP_ERROR) {
 			if (response) {
 				islpci_mgt_release(response);
 			}
-			printk("%s: EIO\n", ndev->name);
+			pr_debug("%s: EIO\n", ndev->name);
 			ret = -EIO;
 		}
 		if (!ret) {
 			response_op = response->header->operation;
-			printk("%s: response_op: %i\n", ndev->name,
-			       response_op);
+			pr_debug("%s: response_op: %i\n",
+				 ndev->name, response_op);
 			islpci_mgt_release(response);
 		}
 	}
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 5970ff6..df7a164 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -18,6 +18,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/hardirq.h>
 #include <linux/module.h>
 #include <linux/slab.h>
@@ -94,9 +96,8 @@ isl_upload_firmware(islpci_private *priv)
 
 		rc = request_firmware(&fw_entry, priv->firmware, PRISM_FW_PDEV);
 		if (rc) {
-			printk(KERN_ERR
-			       "%s: request_firmware() failed for '%s'\n",
-			       "prism54", priv->firmware);
+			pr_err("request_firmware() failed for '%s'\n",
+			       priv->firmware);
 			return rc;
 		}
 		/* prepare the Direct Memory Base register */
@@ -106,9 +107,8 @@ isl_upload_firmware(islpci_private *priv)
 		fw_len = fw_entry->size;
 
 		if (fw_len % 4) {
-			printk(KERN_ERR
-			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n",
-			       "prism54", priv->firmware);
+			pr_err("firmware '%s' size is not multiple of 32bit, aborting!\n",
+			       priv->firmware);
 			release_firmware(fw_entry);
 			return -EILSEQ; /* Illegal byte sequence  */;
 		}
@@ -148,8 +148,8 @@ isl_upload_firmware(islpci_private *priv)
 		BUG_ON(fw_len != 0);
 
 		/* Firmware version is at offset 40 (also for "newmac") */
-		printk(KERN_DEBUG "%s: firmware version: %.8s\n",
-		       priv->ndev->name, fw_entry->data + 40);
+		pr_debug("%s: firmware version: %.8s\n",
+			 priv->ndev->name, fw_entry->data + 40);
 
 		release_firmware(fw_entry);
 	}
@@ -411,7 +411,7 @@ islpci_close(struct net_device *ndev)
 {
 	islpci_private *priv = netdev_priv(ndev);
 
-	printk(KERN_DEBUG "%s: islpci_close ()\n", ndev->name);
+	pr_debug("%s: islpci_close ()\n", ndev->name);
 
 	netif_stop_queue(ndev);
 
@@ -465,20 +465,19 @@ islpci_upload_fw(islpci_private *priv)
 
 	old_state = islpci_set_state(priv, PRV_STATE_BOOT);
 
-	printk(KERN_DEBUG "%s: uploading firmware...\n", priv->ndev->name);
+	pr_debug("%s: uploading firmware...\n", priv->ndev->name);
 
 	rc = isl_upload_firmware(priv);
 	if (rc) {
 		/* error uploading the firmware */
-		printk(KERN_ERR "%s: could not upload firmware ('%s')\n",
+		pr_err("%s: could not upload firmware ('%s')\n",
 		       priv->ndev->name, priv->firmware);
 
 		islpci_set_state(priv, old_state);
 		return rc;
 	}
 
-	printk(KERN_DEBUG "%s: firmware upload complete\n",
-	       priv->ndev->name);
+	pr_debug("%s: firmware upload complete\n", priv->ndev->name);
 
 	islpci_set_state(priv, PRV_STATE_POSTBOOT);
 
@@ -513,14 +512,14 @@ islpci_reset_if(islpci_private *priv)
 		/* If we're here it's because our IRQ hasn't yet gone through.
 		 * Retry a bit more...
 		 */
-		printk(KERN_ERR "%s: no 'reset complete' IRQ seen - retrying\n",
-			priv->ndev->name);
+		pr_err("%s: no 'reset complete' IRQ seen - retrying\n",
+		       priv->ndev->name);
 	}
 
 	finish_wait(&priv->reset_done, &wait);
 
 	if (result) {
-		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
+		pr_err("%s: interface reset failure\n", priv->ndev->name);
 		return result;
 	}
 
@@ -536,7 +535,7 @@ islpci_reset_if(islpci_private *priv)
 	down_write(&priv->mib_sem);
 	result = mgt_commit(priv);
 	if (result) {
-		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
+		pr_err("%s: interface reset failure\n", priv->ndev->name);
 		up_write(&priv->mib_sem);
 		return result;
 	}
@@ -544,7 +543,7 @@ islpci_reset_if(islpci_private *priv)
 
 	islpci_set_state(priv, PRV_STATE_READY);
 
-	printk(KERN_DEBUG "%s: interface reset complete\n", priv->ndev->name);
+	pr_debug("%s: interface reset complete\n", priv->ndev->name);
 	return 0;
 }
 
@@ -561,7 +560,7 @@ islpci_reset(islpci_private *priv, int reload_firmware)
 	else
 		islpci_set_state(priv, PRV_STATE_POSTBOOT);
 
-	printk(KERN_DEBUG "%s: resetting device...\n", priv->ndev->name);
+	pr_debug("%s: resetting device...\n", priv->ndev->name);
 
 	/* disable all device interrupts in case they weren't */
 	isl38xx_disable_interrupts(priv->device_base);
@@ -606,8 +605,7 @@ islpci_reset(islpci_private *priv, int reload_firmware)
 	 * firmware and reset interface */
 		rc = islpci_upload_fw(priv);
 		if (rc) {
-			printk(KERN_ERR "%s: islpci_reset: failure\n",
-				priv->ndev->name);
+			pr_err("%s: islpci_reset: failure\n", priv->ndev->name);
 			return rc;
 		}
 	}
@@ -615,7 +613,7 @@ islpci_reset(islpci_private *priv, int reload_firmware)
 	/* finally reset interface */
 	rc = islpci_reset_if(priv);
 	if (rc)
-		printk(KERN_ERR "prism54: Your card/socket may be faulty, or IRQ line too busy :(\n");
+		pr_err("Your card/socket may be faulty, or IRQ line too busy :(\n");
 	return rc;
 }
 
@@ -628,7 +626,7 @@ islpci_alloc_memory(islpci_private *priv)
 	int counter;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-	printk(KERN_DEBUG "islpci_alloc_memory\n");
+	pr_debug("islpci_alloc_memory\n");
 #endif
 
 	/* remap the PCI device base address to accessible */
@@ -636,7 +634,7 @@ islpci_alloc_memory(islpci_private *priv)
 	      ioremap(pci_resource_start(priv->pdev, 0),
 		      ISL38XX_PCI_MEM_SIZE))) {
 		/* error in remapping the PCI device memory address range */
-		printk(KERN_ERR "PCI memory remapping failed\n");
+		pr_err("PCI memory remapping failed\n");
 		return -1;
 	}
 
@@ -656,8 +654,7 @@ islpci_alloc_memory(islpci_private *priv)
 
 	if (!priv->driver_mem_address) {
 		/* error allocating the block of PCI memory */
-		printk(KERN_ERR "%s: could not allocate DMA memory, aborting!",
-		       "prism54");
+		pr_err("could not allocate DMA memory, aborting!\n");
 		return -1;
 	}
 
@@ -695,7 +692,7 @@ islpci_alloc_memory(islpci_private *priv)
 		 * include any required allignment operations */
 		if (!(skb = dev_alloc_skb(MAX_FRAGMENT_SIZE_RX + 2))) {
 			/* error allocating an sk_buff structure elements */
-			printk(KERN_ERR "Error allocating skb.\n");
+			pr_err("Error allocating skb\n");
 			skb = NULL;
 			goto out_free;
 		}
@@ -711,7 +708,7 @@ islpci_alloc_memory(islpci_private *priv)
 		if (!priv->pci_map_rx_address[counter]) {
 			/* error mapping the buffer to device
 			   accessible memory address */
-			printk(KERN_ERR "failed to map skb DMA'able\n");
+			pr_err("failed to map skb DMA'able\n");
 			goto out_free;
 		}
 	}
@@ -948,8 +945,8 @@ islpci_set_state(islpci_private *priv, islpci_state_t new_state)
 		break;
 	}
 #if 0
-	printk(KERN_DEBUG "%s: state transition %d -> %d (off#%d)\n",
-	       priv->ndev->name, old_state, new_state, priv->state_off);
+	pr_debug("%s: state transition %d -> %d (off#%d)\n",
+		 priv->ndev->name, old_state, new_state, priv->state_off);
 #endif
 
 	/* invariants */
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 266d45b..1539077 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -16,6 +16,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/gfp.h>
 
@@ -99,7 +101,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	/* check whether the destination queue has enough fragments for the frame */
 	curr_frag = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_TX_DATA_LQ]);
 	if (unlikely(curr_frag - priv->free_data_tx >= ISL38XX_CB_TX_QSIZE)) {
-		printk(KERN_ERR "%s: transmit device queue full when awake\n",
+		pr_err("%s: transmit device queue full when awake\n",
 		       ndev->name);
 		netif_stop_queue(ndev);
 
@@ -132,7 +134,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 				/* wds requires an additional address field of 6 bytes */
 				skb_put(skb, 6);
 #ifdef ISLPCI_ETH_DEBUG
-				printk("islpci_eth_transmit:wds_mac\n");
+				pr_debug("%s:wds_mac\n", __func__);
 #endif
 				memmove(skb->data + 6, src, skb->len);
 				skb_copy_to_linear_data(skb, wds_mac, 6);
@@ -148,8 +150,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 			newskb =
 			    dev_alloc_skb(init_wds ? skb->len + 6 : skb->len);
 			if (unlikely(newskb == NULL)) {
-				printk(KERN_ERR "%s: Cannot allocate skb\n",
-				       ndev->name);
+				pr_err("%s: Cannot allocate skb\n", ndev->name);
 				goto drop_free;
 			}
 			newskb_offset = (4 - (long) newskb->data) & 0x03;
@@ -165,7 +166,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 							  skb->len);
 				skb_copy_to_linear_data(newskb, wds_mac, 6);
 #ifdef ISLPCI_ETH_DEBUG
-				printk("islpci_eth_transmit:wds_mac\n");
+				pr_debug("%s:wds_mac\n", __func__);
 #endif
 			} else
 				skb_copy_from_linear_data(skb, newskb->data,
@@ -192,8 +193,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 					 (void *) skb->data, skb->len,
 					 PCI_DMA_TODEVICE);
 	if (unlikely(pci_map_address == 0)) {
-		printk(KERN_WARNING "%s: cannot map buffer to PCI\n",
-		       ndev->name);
+		pr_warn("%s: cannot map buffer to PCI\n", ndev->name);
 		goto drop_free;
 	}
 	/* Place the fragment in the control block structure. */
@@ -406,10 +406,7 @@ islpci_eth_receive(islpci_private *priv)
 
 	/* deliver the skb to the network layer */
 #ifdef ISLPCI_ETH_DEBUG
-	printk
-	    ("islpci_eth_receive:netif_rx %2.2X %2.2X %2.2X %2.2X %2.2X %2.2X\n",
-	     skb->data[0], skb->data[1], skb->data[2], skb->data[3],
-	     skb->data[4], skb->data[5]);
+	pr_debug("%s:netif_rx %pM\n", __func__, skb->data);
 #endif
 	if (unlikely(discard)) {
 		dev_kfree_skb_irq(skb);
@@ -495,13 +492,11 @@ islpci_eth_tx_timeout(struct net_device *ndev)
 	ndev->stats.tx_errors++;
 
 	if (!priv->reset_task_pending) {
-		printk(KERN_WARNING
-			"%s: tx_timeout, scheduling reset", ndev->name);
+		pr_warn("%s: tx_timeout, scheduling reset", ndev->name);
 		netif_stop_queue(ndev);
 		priv->reset_task_pending = 1;
 		schedule_work(&priv->reset_task);
 	} else {
-		printk(KERN_WARNING
-			"%s: tx_timeout, waiting for reset", ndev->name);
+		pr_warn("%s: tx_timeout, waiting for reset", ndev->name);
 	}
 }
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 9e68e0c..5336b9a 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -103,7 +105,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	/* Enable the pci device */
 	if (pci_enable_device(pdev)) {
-		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
+		pr_err("pci_enable_device() failed\n");
 		return -ENODEV;
 	}
 
@@ -120,7 +122,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	/* enable PCI DMA */
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_ERR "%s: 32-bit PCI DMA not supported", DRV_NAME);
+		pr_err("32-bit PCI DMA not supported\n");
 		goto do_pci_disable_device;
         }
 
@@ -141,22 +143,20 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		pci_write_config_byte(pdev, 0x40, (u8)init_pcitm);
 		pci_write_config_byte(pdev, 0x41, (u8)init_pcitm);
 	} else {
-		printk(KERN_INFO "PCI TRDY/RETRY unchanged\n");
+		pr_info("PCI TRDY/RETRY unchanged\n");
 	}
 
 	/* request the pci device I/O regions */
 	rvalue = pci_request_regions(pdev, DRV_NAME);
 	if (rvalue) {
-		printk(KERN_ERR "%s: pci_request_regions failure (rc=%d)\n",
-		       DRV_NAME, rvalue);
+		pr_err("pci_request_regions failure (rc=%d)\n", rvalue);
 		goto do_pci_disable_device;
 	}
 
 	/* check if the memory window is indeed set */
 	rvalue = pci_read_config_dword(pdev, PCI_BASE_ADDRESS_0, &mem_addr);
 	if (rvalue || !mem_addr) {
-		printk(KERN_ERR "%s: PCI device memory region not configured; fix your BIOS or CardBus bridge/drivers\n",
-		       DRV_NAME);
+		pr_err("PCI device memory region not configured; fix your BIOS or CardBus bridge/drivers\n");
 		goto do_pci_release_regions;
 	}
 
@@ -170,8 +170,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	/* setup the network device interface and its structure */
 	if (!(ndev = islpci_setup(pdev))) {
 		/* error configuring the driver as a network device */
-		printk(KERN_ERR "%s: could not configure network device\n",
-		       DRV_NAME);
+		pr_err("could not configure network device\n");
 		goto do_pci_clear_mwi;
 	}
 
@@ -187,8 +186,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	if (rvalue) {
 		/* error, could not hook the handler to the irq */
-		printk(KERN_ERR "%s: could not install IRQ handler\n",
-		       ndev->name);
+		pr_err("%s: could not install IRQ handler\n", ndev->name);
 		goto do_unregister_netdev;
 	}
 
@@ -223,11 +221,11 @@ prism54_remove(struct pci_dev *pdev)
 	BUG_ON(!priv);
 
 	if (!__in_cleanup_module) {
-		printk(KERN_DEBUG "%s: hot unplug detected\n", ndev->name);
+		pr_debug("%s: hot unplug detected\n", ndev->name);
 		islpci_set_state(priv, PRV_STATE_OFF);
 	}
 
-	printk(KERN_DEBUG "%s: removing device\n", ndev->name);
+	pr_debug("%s: removing device\n", ndev->name);
 
 	unregister_netdev(ndev);
 
@@ -290,12 +288,11 @@ prism54_resume(struct pci_dev *pdev)
 
 	BUG_ON(!priv);
 
-	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
+	pr_notice("%s: got resume request\n", ndev->name);
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR "%s: pci_enable_device failed on resume\n",
-		       ndev->name);
+		pr_err("%s: pci_enable_device failed on resume\n", ndev->name);
 		return err;
 	}
 
@@ -313,8 +310,7 @@ prism54_resume(struct pci_dev *pdev)
 static int __init
 prism54_module_init(void)
 {
-	printk(KERN_INFO "Loaded %s driver, version %s\n",
-	       DRV_NAME, DRV_VERSION);
+	pr_info("Loaded %s driver, version %s\n", DRV_NAME, DRV_VERSION);
 
 	__bug_on_wrong_struct_sizes ();
 
@@ -331,7 +327,7 @@ prism54_module_exit(void)
 
 	pci_unregister_driver(&prism54_driver);
 
-	printk(KERN_INFO "Unloaded %s driver\n", DRV_NAME);
+	pr_info("Unloaded %s driver\n", DRV_NAME);
 
 	__in_cleanup_module = 0;
 }
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index c5404cb..ef4fe3a 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/netdevice.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -50,13 +52,7 @@ display_buffer(char *buffer, int length)
 	if ((pc_debug & SHOW_BUFFER_CONTENTS) == 0)
 		return;
 
-	while (length > 0) {
-		printk("[%02x]", *buffer & 255);
-		length--;
-		buffer++;
-	}
-
-	printk("\n");
+	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buffer, length);
 }
 #endif
 
@@ -124,8 +120,7 @@ islpci_mgmt_rx_fill(struct net_device *ndev)
 		if (buf->mem == NULL) {
 			buf->mem = kmalloc(MGMT_FRAME_SIZE, GFP_ATOMIC);
 			if (!buf->mem) {
-				printk(KERN_WARNING
-				       "Error allocating management frame.\n");
+				pr_warn("Error allocating management frame\n");
 				return -ENOMEM;
 			}
 			buf->size = MGMT_FRAME_SIZE;
@@ -135,8 +130,7 @@ islpci_mgmt_rx_fill(struct net_device *ndev)
 						       MGMT_FRAME_SIZE,
 						       PCI_DMA_FROMDEVICE);
 			if (!buf->pci_addr) {
-				printk(KERN_WARNING
-				       "Failed to make memory DMA'able.\n");
+				pr_warn("Failed to make memory DMA'able\n");
 				return -ENOMEM;
 			}
 		}
@@ -184,8 +178,7 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 #endif
 
 	if (frag_len > MGMT_FRAME_SIZE) {
-		printk(KERN_DEBUG "%s: mgmt frame too large %d\n",
-		       ndev->name, frag_len);
+		pr_debug("%s: mgmt frame too large %d\n", ndev->name, frag_len);
 		goto error;
 	}
 
@@ -222,8 +215,7 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 	buf.pci_addr = pci_map_single(priv->pdev, buf.mem, frag_len,
 				      PCI_DMA_TODEVICE);
 	if (!buf.pci_addr) {
-		printk(KERN_WARNING "%s: cannot map PCI memory for mgmt\n",
-		       ndev->name);
+		pr_warn("%s: cannot map PCI memory for mgmt\n", ndev->name);
 		goto error_free;
 	}
 
@@ -231,8 +223,7 @@ islpci_mgt_transmit(struct net_device *ndev, int operation, unsigned long oid,
 	spin_lock_irqsave(&priv->slock, flags);
 	curr_frag = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_TX_MGMTQ]);
 	if (curr_frag - priv->index_mgmt_tx >= ISL38XX_CB_MGMT_QSIZE) {
-		printk(KERN_WARNING "%s: mgmt tx queue is still full\n",
-		       ndev->name);
+		pr_warn("%s: mgmt tx queue is still full\n", ndev->name);
 		goto error_unlock;
 	}
 
@@ -297,9 +288,9 @@ islpci_mgt_receive(struct net_device *ndev)
 		/* I have no idea (and no documentation) if flags != 0
 		 * is possible.  Drop the frame, reuse the buffer. */
 		if (le16_to_cpu(cb->rx_data_mgmt[index].flags) != 0) {
-			printk(KERN_WARNING "%s: unknown flags 0x%04x\n",
-			       ndev->name,
-			       le16_to_cpu(cb->rx_data_mgmt[index].flags));
+			pr_warn("%s: unknown flags 0x%04x\n",
+				ndev->name,
+				le16_to_cpu(cb->rx_data_mgmt[index].flags));
 			continue;
 		}
 
@@ -311,8 +302,7 @@ islpci_mgt_receive(struct net_device *ndev)
 		 * size of a receive buffer.  Thus, if this check
 		 * triggers, we likely have kernel heap corruption. */
 		if (frag_len > MGMT_FRAME_SIZE) {
-			printk(KERN_WARNING
-				"%s: Bogus packet size of %d (%#x).\n",
+			pr_warn("%s: Bogus packet size of %d (%#x)\n",
 				ndev->name, frag_len, frag_len);
 			frag_len = MGMT_FRAME_SIZE;
 		}
@@ -324,8 +314,7 @@ islpci_mgt_receive(struct net_device *ndev)
 		/* Perform endianess conversion for PIMFOR header in-place. */
 		header = pimfor_decode_header(buf->mem, frag_len);
 		if (!header) {
-			printk(KERN_WARNING "%s: no PIMFOR header found\n",
-			       ndev->name);
+			pr_warn("%s: no PIMFOR header found\n", ndev->name);
 			continue;
 		}
 
@@ -348,9 +337,8 @@ islpci_mgt_receive(struct net_device *ndev)
 
 		/* nobody sends these */
 		if (header->flags & PIMFOR_FLAG_APPLIC_ORIGIN) {
-			printk(KERN_DEBUG
-			       "%s: errant PIMFOR application frame\n",
-			       ndev->name);
+			pr_debug("%s: errant PIMFOR application frame\n",
+				 ndev->name);
 			continue;
 		}
 
@@ -359,9 +347,8 @@ islpci_mgt_receive(struct net_device *ndev)
 		frame = kmalloc(sizeof (struct islpci_mgmtframe) + size,
 				GFP_ATOMIC);
 		if (!frame) {
-			printk(KERN_WARNING
-			       "%s: Out of memory, cannot handle oid 0x%08x\n",
-			       ndev->name, header->oid);
+			pr_warn("%s: Out of memory, cannot handle oid 0x%08x\n",
+				ndev->name, header->oid);
 			continue;
 		}
 		frame->ndev = ndev;
@@ -377,10 +364,9 @@ islpci_mgt_receive(struct net_device *ndev)
 
 		if (header->operation == PIMFOR_OP_TRAP) {
 #if VERBOSE > SHOW_ERROR_MESSAGES
-			printk(KERN_DEBUG
-			       "TRAP: oid 0x%x, device %i, flags 0x%x length %i\n",
-			       header->oid, header->device_id, header->flags,
-			       header->length);
+			pr_debug("TRAP: oid 0x%x, device %i, flags 0x%x length %i\n",
+				 header->oid, header->device_id, header->flags,
+				 header->length);
 #endif
 
 			/* Create work to handle trap out of interrupt
@@ -392,9 +378,8 @@ islpci_mgt_receive(struct net_device *ndev)
 			/* Signal the one waiting process that a response
 			 * has been received. */
 			if ((frame = xchg(&priv->mgmt_received, frame)) != NULL) {
-				printk(KERN_WARNING
-				       "%s: mgmt response not collected\n",
-				       ndev->name);
+				pr_warn("%s: mgmt response not collected\n",
+					ndev->name);
 				kfree(frame);
 			}
 #if VERBOSE > SHOW_ERROR_MESSAGES
@@ -480,25 +465,21 @@ islpci_mgt_transaction(struct net_device *ndev,
 				err = 0;
 				goto out;
 			} else {
-				printk(KERN_DEBUG
-				       "%s: expecting oid 0x%x, received 0x%x.\n",
-				       ndev->name, (unsigned int) oid,
-				       frame->header->oid);
+				pr_debug("%s: expecting oid 0x%x, received 0x%x\n",
+					 ndev->name, (unsigned int)oid,
+					 frame->header->oid);
 				kfree(frame);
 				frame = NULL;
 			}
 		}
 		if (timeleft == 0) {
-			printk(KERN_DEBUG
-				"%s: timeout waiting for mgmt response %lu, "
-				"triggering device\n",
-				ndev->name, timeout_left);
+			pr_debug("%s: timeout waiting for mgmt response %lu, triggering device\n",
+				 ndev->name, timeout_left);
 			islpci_trigger(priv);
 		}
 		timeout_left += timeleft - wait_cycle_jiffies;
 	}
-	printk(KERN_WARNING "%s: timeout waiting for mgmt response\n",
-	       ndev->name);
+	pr_warn("%s: timeout waiting for mgmt response\n", ndev->name);
 
 	/* TODO: we should reset the device here */
  out:
diff --git a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
index 0db93db..4f129c5 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.h
+++ b/drivers/net/wireless/prism54/islpci_mgt.h
@@ -28,8 +28,13 @@
  *  Function definitions
  */
 
-#define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); } while(0)
-#define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
+#define K_DEBUG(f, m, fmt, ...)				\
+do {							\
+	if (f & m)					\
+		pr_debug(fmt, ##__VA_ARGS__);		\
+} while (0)
+#define DEBUG(f, fmt, ...)				\
+	K_DEBUG(f, pc_debug, fmt, ##__VA_ARGS__)
 
 extern int pc_debug;
 #define init_wds 0	/* help compiler optimize away dead code */
diff --git a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
index a01606b..094baed 100644
--- a/drivers/net/wireless/prism54/oid_mgt.c
+++ b/drivers/net/wireless/prism54/oid_mgt.c
@@ -16,6 +16,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/slab.h>
 
@@ -580,10 +582,8 @@ mgt_get_request(islpci_private *priv, enum oid_num_t n, int extra, void *data,
 		islpci_mgt_release(response);
 
 	if (reslen > isl_oid[n].size)
-		printk(KERN_DEBUG
-		       "mgt_get_request(0x%x): received data length was bigger "
-		       "than expected (%d > %d). Memory is probably corrupted...",
-		       oid, reslen, isl_oid[n].size);
+		pr_debug("mgt_get_request(0x%x): received data length was bigger than expected (%d > %d). Memory is probably corrupted...\n",
+			 oid, reslen, isl_oid[n].size);
 
 	return ret;
 }
@@ -610,9 +610,8 @@ mgt_commit_list(islpci_private *priv, enum oid_num_t *l, int n)
 				islpci_mgt_release(response);
 			}
 			if (r)
-				printk(KERN_ERR "%s: mgt_commit_list: failure. "
-					"oid=%08x err=%d\n",
-					priv->ndev->name, oid, r);
+				pr_err("%s: mgt_commit_list: failure. oid=%08x err=%d\n",
+				       priv->ndev->name, oid, r);
 			ret |= r;
 			j++;
 			oid++;
@@ -689,7 +688,7 @@ mgt_update_addr(islpci_private *priv)
 		islpci_mgt_release(res);
 
 	if (ret)
-		printk(KERN_ERR "%s: mgt_update_addr: failure\n", priv->ndev->name);
+		pr_err("%s: mgt_update_addr: failure\n", priv->ndev->name);
 	return ret;
 }
 
@@ -714,7 +713,7 @@ mgt_commit(islpci_private *priv)
 	if (rvalue) {
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
-		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
+		pr_debug("%s: mgt_commit: failure\n", priv->ndev->name);
 	}
 	return rvalue;
 }
@@ -751,7 +750,7 @@ mgt_unlatch_all(islpci_private *priv)
 #endif
 
 	if (rvalue)
-		printk(KERN_DEBUG "%s: Unlatching OIDs failed\n", priv->ndev->name);
+		pr_debug("%s: Unlatching OIDs failed\n", priv->ndev->name);
 }
 #endif
 
@@ -783,7 +782,7 @@ mgt_oidtonum(u32 oid)
 		if (isl_oid[i].oid == oid)
 			return i;
 
-	printk(KERN_DEBUG "looking for an unknown oid 0x%x", oid);
+	pr_debug("looking for an unknown oid 0x%x\n", oid);
 
 	return OID_NUM_LAST;
 }
@@ -832,7 +831,7 @@ mgt_response_to_str(enum oid_num_t n, union oid_res_t *r, char *str)
 	case OID_TYPE_FREQUENCIES:{
 			struct obj_frequencies *freq = r->ptr;
 			int i, t;
-			printk("nr : %u\n", freq->nr);
+			pr_debug("nr : %u\n", freq->nr);
 			t = snprintf(str, PRIV_STR_SIZE, "nr=%u\n", freq->nr);
 			for (i = 0; i < freq->nr; i++)
 				t += snprintf(str + t, PRIV_STR_SIZE - t,
-- 
1.7.8.111.gad25c.dirty
