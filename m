From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 17/17 linux-2.6.7-rc2] prism54: White space and indentation (resend)
Date: Sat, 5 Jun 2004 14:51:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051451.34065.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_WHcwAw8pWE41qOR"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_WHcwAw8pWE41qOR
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-05-29  Margit Schubert-While <margitsw@t-online.de>

* White space and indentation patch



--Boundary-00=_WHcwAw8pWE41qOR
Content-Type: text/x-diff;
  charset="us-ascii";
  name="17-white-space-indent.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="17-white-space-indent.patch"

diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 15:50:41.989678376 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 15:49:40.516023792 +0200
@@ -166,7 +166,7 @@
 	 * for it save old values */
 	if (init_mode > IW_MODE_MONITOR || init_mode < IW_MODE_AUTO) {
 		printk(KERN_DEBUG "%s(): You passed a non-valid init_mode. "
-				"Using default mode\n", __FUNCTION__);
+		       "Using default mode\n", __FUNCTION__);
 		init_mode = CARD_DEFAULT_IW_MODE;
 	}
 	/* This sets all of the mode-dependent values */
@@ -518,9 +518,7 @@
 		i++;
 		data++;
 	}
-
 	range->num_bitrates = i;
-
 	kfree(r.ptr);
 
 	return rvalue;
@@ -559,7 +557,6 @@
 	int rvalue;
 
 	rvalue = mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
-
 	memcpy(awrq->sa_data, r.ptr, 6);
 	awrq->sa_family = ARPHRD_ETHER;
 	kfree(r.ptr);
@@ -669,7 +666,6 @@
 			kfree(buf);
 		}
 	}
-
 	return current_ev;
 }
 
@@ -731,7 +727,7 @@
 		memcpy(essid.octets, extra, dwrq->length);
 	} else
 		essid.length = 0;
-	
+
 	if (priv->iw_mode != IW_MODE_MONITOR)
 		return mgt_set_request(priv, DOT11_OID_SSID, 0, &essid);
 
@@ -817,21 +813,21 @@
 	char *data;
 	int ret, i;
 	union oid_res_t r;
-	
+
 	if (vwrq->value == -1) {
 		/* auto mode. No limit. */
 		profile = 1;
 		return mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	}
-	
+
 	if ((ret =
 	     mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r)))
 		return ret;
-		
+
 	rate = (u32) (vwrq->value / 500000);
 	data = r.ptr;
 	i = 0;
-	
+
 	while (data[i]) {
 		if (rate && (data[i] == rate)) {
 			break;
@@ -842,14 +838,14 @@
 		data[i] |= 0x80;
 		i++;
 	}
-		
+
 	if (!data[i]) {
 		return -EINVAL;
 	}
-	
+
 	data[i] |= 0x80;
 	data[i + 1] = 0;
-	
+
 	/* Now, check if we want a fixed or auto value */
 	if (vwrq->fixed) {
 		data[0] = data[i];
@@ -864,14 +860,14 @@
 		i++;
 	}
 	printk("0\n");
-*/	
+*/
 	profile = -1;
 	ret = mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	ret |= mgt_set_request(priv, DOT11_OID_EXTENDEDRATES, 0, data);
 	ret |= mgt_set_request(priv, DOT11_OID_RATES, 0, data);
-	
+
 	kfree(r.ptr);
-	
+
 	return ret;
 }
 
@@ -897,7 +893,7 @@
 	data = r.ptr;
 	vwrq->fixed = (data[0] != 0) && (data[1] == 0);
 	kfree(r.ptr);
-	
+
 	return 0;
 }
 
@@ -994,7 +990,6 @@
 		rvalue |=
 		    mgt_set_request(priv, DOT11_OID_MAXTXLIFETIME, 0,
 				    &lifetime);
-
 	return rvalue;
 }
 
@@ -1090,8 +1085,7 @@
 			}
 		}
 	}
-
-	/* now read the flags     */
+	/* now read the flags */
 	if (dwrq->flags & IW_ENCODE_DISABLED) {
 		/* Encoding disabled, 
 		 * authen = DOT11_AUTH_OS;
@@ -1240,7 +1234,7 @@
 
 static int
 prism54_set_u32(struct net_device *ndev, struct iw_request_info *info,
-		   __u32 * uwrq, char *extra)
+		__u32 * uwrq, char *extra)
 {
 	u32 oid = uwrq[0], u = uwrq[1];
 
@@ -1858,7 +1852,7 @@
 	enum oid_num_t n = mgt_oidtonum(frame->header->oid);
 
 	if (n != OID_NUM_LAST)
-	prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
+		prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
 	islpci_mgt_release(frame);
 }
 
@@ -1935,7 +1929,7 @@
 		  __u32 * uwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	
+
 	priv->priv_oid = *uwrq;
 	printk("%s: oid 0x%08X\n", ndev->name, *uwrq);
 
@@ -1944,15 +1938,15 @@
 
 int
 prism54_debug_get_oid(struct net_device *ndev, struct iw_request_info *info,
-		struct iw_point *data, char *extra)
+		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
 	int ret = -EIO, response_op = PIMFOR_OP_ERROR;
-	
+
 	printk("%s: get_oid 0x%08X\n", ndev->name, priv->priv_oid);
 	data->length = 0;
-	
+
 	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
 		ret =
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
@@ -1976,21 +1970,21 @@
 			printk("%s: len: %i\n", ndev->name, data->length);
 		}
 	}
-	
+
 	return ret;
 }
 
 int
 prism54_debug_set_oid(struct net_device *ndev, struct iw_request_info *info,
-		struct iw_point *data, char *extra)
+		      struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct islpci_mgmtframe *response = NULL;
 	int ret = 0, response_op = PIMFOR_OP_ERROR;
-	
+
 	printk("%s: set_oid 0x%08X\tlen: %d\n", ndev->name, priv->priv_oid,
 	       data->length);
-	
+
 	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
 		ret =
 		    islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
@@ -2005,10 +1999,10 @@
 		}
 		if (ret || response_op == PIMFOR_OP_ERROR) {
 			printk("%s: EIO\n", ndev->name);
-		        ret = -EIO;
+			ret = -EIO;
 		}
 	}
-	
+
 	return (ret ? ret : -EINPROGRESS);
 }
 
@@ -2107,7 +2101,7 @@
 #define PRISM54_DBG_GET_OID	SIOCIWFIRSTPRIV+15
 #define PRISM54_DBG_SET_OID	SIOCIWFIRSTPRIV+16
 
-#define PRISM54_GET_OID	   SIOCIWFIRSTPRIV+17
+#define PRISM54_GET_OID		SIOCIWFIRSTPRIV+17
 #define PRISM54_SET_OID_U32	SIOCIWFIRSTPRIV+18
 #define	PRISM54_SET_OID_STR	SIOCIWFIRSTPRIV+20
 #define	PRISM54_SET_OID_ADDR	SIOCIWFIRSTPRIV+22
@@ -2179,7 +2173,7 @@
 	IWPRIV_U32(DOT11_OID_AUTHENABLE, "authenable"),
 	IWPRIV_U32(DOT11_OID_PRIVACYINVOKED, "privinvok"),
 	IWPRIV_U32(DOT11_OID_EXUNENCRYPTED, "exunencrypt"),
-	
+
 	IWPRIV_U32(DOT11_OID_REKEYTHRESHOLD, "rekeythresh"),
 
 	IWPRIV_U32(DOT11_OID_MAXTXLIFETIME, "maxtxlife"),
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.h linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.h	2004-05-28 14:40:26.994455048 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.h	2004-05-28 14:25:30.063809232 +0200
@@ -173,7 +173,7 @@
 	islpci_state_t state;
 	int state_off;		/* enumeration of off-state, if 0 then
 				 * we're not in any off-state */
-	
+
 	/* WPA stuff */
 	int wpa; /* WPA mode enabled */
 	struct list_head bss_wpa_list;
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 15:50:41.991678072 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-05-28 15:49:40.517023640 +0200
@@ -208,7 +208,7 @@
 	priv->data_low_tx[index] = skb;
 	/* set the proper fragment start address and size information */
 	fragment->size = cpu_to_le16(frame_size);
-	fragment->flags = cpu_to_le16(0);  /* set to 1 if more fragments */
+	fragment->flags = cpu_to_le16(0);	/* set to 1 if more fragments */
 	fragment->address = cpu_to_le32(pci_map_address);
 	curr_frag++;
 
@@ -218,7 +218,7 @@
 	cb->driver_curr_frag[ISL38XX_CB_TX_DATA_LQ] = cpu_to_le32(curr_frag);
 
 	if (curr_frag - priv->free_data_tx + ISL38XX_MIN_QTHRESHOLD
-	                                           > ISL38XX_CB_TX_QSIZE) {
+	    > ISL38XX_CB_TX_QSIZE) {
 		/* stop sends from upper layers */
 		netif_stop_queue(ndev);
 
@@ -239,7 +239,7 @@
 
 	return 0;
 
- drop_free:
+      drop_free:
 	/* free the skbuf structure before aborting */
 	dev_kfree_skb(skb);
 	skb = NULL;
@@ -287,7 +287,7 @@
 		    (struct avs_80211_1_header *) skb_push(*skb,
 							   sizeof (struct
 								   avs_80211_1_header));
-
+		
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
 		avs->mactime = cpu_to_be64(le64_to_cpu(clock));
@@ -487,10 +487,10 @@
 void
 islpci_do_reset_and_wake(void *data)
 {
-       islpci_private *priv = (islpci_private *) data;
-       islpci_reset(priv, 1);
-       netif_wake_queue(priv->ndev);
-       priv->reset_task_pending = 0;
+	islpci_private *priv = (islpci_private *) data;
+	islpci_reset(priv, 1);
+	netif_wake_queue(priv->ndev);
+	priv->reset_task_pending = 0;
 }
 
 void
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c	2004-05-28 15:14:49.426917656 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c	2004-05-28 15:12:49.370169056 +0200
@@ -85,7 +85,7 @@
 {
 	pimfor_header_t *h = data;
 
-        while ((void *) h < data + len) {
+	while ((void *) h < data + len) {
 		if (h->flags & PIMFOR_FLAG_LITTLE_ENDIAN) {
 			le32_to_cpus(&h->oid);
 			le32_to_cpus(&h->length);
@@ -107,8 +107,8 @@
 islpci_mgmt_rx_fill(struct net_device *ndev)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	isl38xx_control_block *cb =    /* volatile not needed */
-		(isl38xx_control_block *) priv->control_block;
+	isl38xx_control_block *cb =	/* volatile not needed */
+	    (isl38xx_control_block *) priv->control_block;
 	u32 curr = le32_to_cpu(cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ]);
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
@@ -140,15 +140,15 @@
 			}
 		}
 
-                /* be safe: always reset control block information */
+		/* be safe: always reset control block information */
 		frag->size = cpu_to_le16(MGMT_FRAME_SIZE);
 		frag->flags = 0;
 		frag->address = cpu_to_le32(buf->pci_addr);
 		curr++;
 
-                /* The fragment address in the control block must have
-                 * been written before announcing the frame buffer to
-                 * device */
+		/* The fragment address in the control block must have
+		 * been written before announcing the frame buffer to
+		 * device */
 		wmb();
 		cb->driver_curr_frag[ISL38XX_CB_RX_MGMTQ] = cpu_to_le32(curr);
 	}
@@ -168,7 +168,7 @@
 {
 	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =
-		(isl38xx_control_block *) priv->control_block;
+	    (isl38xx_control_block *) priv->control_block;
 	void *p;
 	int err = -EINVAL;
 	unsigned long flags;
@@ -242,7 +242,7 @@
 	priv->mgmt_tx[index] = buf;
 	frag = &cb->tx_data_mgmt[index];
 	frag->size = cpu_to_le16(frag_len);
-	frag->flags = 0;   /* for any other than the last fragment, set to 1 */
+	frag->flags = 0;	/* for any other than the last fragment, set to 1 */
 	frag->address = cpu_to_le32(buf.pci_addr);
 
 	/* The fragment address in the control block must have
@@ -256,11 +256,11 @@
 	islpci_trigger(priv);
 	return 0;
 
- error_unlock:
+      error_unlock:
 	spin_unlock_irqrestore(&priv->slock, flags);
- error_free:
+      error_free:
 	kfree(buf.mem);
- error:
+      error:
 	return err;
 }
 
@@ -274,16 +274,16 @@
 {
 	islpci_private *priv = netdev_priv(ndev);
 	isl38xx_control_block *cb =
-		(isl38xx_control_block *) priv->control_block;
+	    (isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_receive \n");
 #endif
 
-        /* Only once per interrupt, determine fragment range to
-         * process.  This avoids an endless loop (i.e. lockup) if
-         * frames come in faster than we can process them. */
+	/* Only once per interrupt, determine fragment range to
+	 * process.  This avoids an endless loop (i.e. lockup) if
+	 * frames come in faster than we can process them. */
 	curr_frag = le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_RX_MGMTQ]);
 	barrier();
 
@@ -294,29 +294,29 @@
 		u16 frag_len;
 		int size;
 		struct islpci_mgmtframe *frame;
-              
-                /* I have no idea (and no documentation) if flags != 0
-                 * is possible.  Drop the frame, reuse the buffer. */
+
+		/* I have no idea (and no documentation) if flags != 0
+		 * is possible.  Drop the frame, reuse the buffer. */
 		if (le16_to_cpu(cb->rx_data_mgmt[index].flags) != 0) {
-                        printk(KERN_WARNING "%s: unknown flags 0x%04x\n",
-                               ndev->name,
-                               le16_to_cpu(cb->rx_data_mgmt[index].flags));
-                        continue;
-                }
+			printk(KERN_WARNING "%s: unknown flags 0x%04x\n",
+			       ndev->name,
+			       le16_to_cpu(cb->rx_data_mgmt[index].flags));
+			continue;
+		}
 
 		/* The device only returns the size of the header(s) here. */
 		frag_len = le16_to_cpu(cb->rx_data_mgmt[index].size);
 
 		/*
-                 * We appear to have no way to tell the device the
-                 * size of a receive buffer.  Thus, if this check
-                 * triggers, we likely have kernel heap corruption. */
-                if (frag_len > MGMT_FRAME_SIZE) {
+		 * We appear to have no way to tell the device the
+		 * size of a receive buffer.  Thus, if this check
+		 * triggers, we likely have kernel heap corruption. */
+		if (frag_len > MGMT_FRAME_SIZE) {
 			printk(KERN_WARNING
 				"%s: Bogus packet size of %d (%#x).\n",
 				ndev->name, frag_len, frag_len);
-                        frag_len = MGMT_FRAME_SIZE;
-                }
+			frag_len = MGMT_FRAME_SIZE;
+		}
 
 		/* Ensure the results of device DMA are visible to the CPU. */
 		pci_dma_sync_single(priv->pdev, buf->pci_addr,
@@ -338,7 +338,7 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_PIMFOR_FRAMES,
 		      "PIMFOR: op %i, oid 0x%08x, device %i, flags 0x%x length 0x%x \n",
-		      header->operation, header->oid, header->device_id, 
+		      header->operation, header->oid, header->device_id,
 		      header->flags, header->length);
 
 		/* display the buffer contents for debugging */
@@ -363,7 +363,7 @@
 			printk(KERN_WARNING
 			       "%s: Out of memory, cannot handle oid 0x%08x\n",
 			       ndev->name, header->oid);
-			continue;        
+			continue;
 		}
 		frame->ndev = ndev;
 		memcpy(&frame->buf, header, size);
@@ -383,7 +383,7 @@
 			       header->oid, header->device_id, header->flags,
 			       header->length);
 #endif
-                      
+
 			/* Create work to handle trap out of interrupt
 			 * context. */
 			INIT_WORK(&frame->ws, prism54_process_trap, frame);
@@ -416,19 +416,19 @@
 islpci_mgt_cleanup_transmit(struct net_device *ndev)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	isl38xx_control_block *cb =    /* volatile not needed */
-		(isl38xx_control_block *) priv->control_block;
+	isl38xx_control_block *cb =	/* volatile not needed */
+	    (isl38xx_control_block *) priv->control_block;
 	u32 curr_frag;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
-        DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_cleanup_transmit\n");
+	DEBUG(SHOW_FUNCTION_CALLS, "islpci_mgt_cleanup_transmit\n");
 #endif
 
 	/* Only once per cleanup, determine fragment range to
 	 * process.  This avoids an endless loop (i.e. lockup) if
 	 * the device became confused, incrementing device_curr_frag
 	 * rapidly. */
-	curr_frag = le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_TX_MGMTQ]); 
+	curr_frag = le32_to_cpu(cb->device_curr_frag[ISL38XX_CB_TX_MGMTQ]);
 	barrier();
 
 	for (; priv->index_mgmt_tx < curr_frag; priv->index_mgmt_tx++) {
@@ -475,9 +475,9 @@
 		frame = xchg(&priv->mgmt_received, NULL);
 		if (frame) {
 			if (frame->header->oid == oid) {
-			*recvframe = frame;
-			err = 0;
-			goto out;
+				*recvframe = frame;
+				err = 0;
+				goto out;
 			} else {
 				printk(KERN_DEBUG
 				       "%s: expecting oid 0x%x, received 0x%x.\n",
@@ -485,13 +485,13 @@
 				       frame->header->oid);
 				kfree(frame);
 				frame = NULL;
-		}
+			}
 		}
 		if (timeleft == 0) {
 			printk(KERN_DEBUG
 				"%s: timeout waiting for mgmt response %lu, "
 				"triggering device\n",
-			       ndev->name, timeout_left);
+				ndev->name, timeout_left);
 			islpci_trigger(priv);
 		}
 		timeout_left += timeleft - wait_cycle_jiffies;
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 15:14:49.431916896 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 15:12:49.372168752 +0200
@@ -454,7 +454,7 @@
 			islpci_mgt_release(response);
 		}
 		if (ret || response_op == PIMFOR_OP_ERROR)
-		        ret = -EIO;
+			ret = -EIO;
 	} else if (!cache)
 		ret = -EIO;
 
@@ -479,7 +479,7 @@
 	int ret = -EIO;
 	int reslen = 0;
 	struct islpci_mgmtframe *response = NULL;
-	
+
 	int dlen;
 	void *cache, *_res = NULL;
 	u32 oid;
@@ -504,7 +504,7 @@
 		ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					     oid, data, dlen, &response);
 		if (ret || !response ||
-			response->header->operation == PIMFOR_OP_ERROR) {
+		    response->header->operation == PIMFOR_OP_ERROR) {
 			if (response)
 				islpci_mgt_release(response);
 			ret = -EIO;
@@ -541,7 +541,7 @@
 		       "mgt_get_request(0x%x): received data length was bigger "
 		       "than expected (%d > %d). Memory is probably corrupted...",
 		       oid, reslen, isl_oid[n].size);
-	
+
 	return ret;
 }
 
@@ -561,11 +561,11 @@
 		while (j <= t->range) {
 			response = NULL;
 			ret |= islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET,
-			                              oid, data, t->size,
+						      oid, data, t->size,
 						      &response);
 			if (response) {
 				ret |= (response->header->operation ==
-				        PIMFOR_OP_ERROR);
+					PIMFOR_OP_ERROR);
 				islpci_mgt_release(response);
 			}
 			j++;
@@ -669,7 +669,7 @@
 		/* some request have failed. The device might be in an
 		   incoherent state. We should reset it ! */
 		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
-                "device \n", priv->ndev->name);
+		       "device \n", priv->ndev->name);
 	}
 }
 
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.h linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.h	2004-05-28 14:07:22.645122000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.h	2004-05-28 14:06:37.941917920 +0200
@@ -38,7 +38,7 @@
 int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
 
 int mgt_get_request(islpci_private *, enum oid_num_t, int, void *,
-                    union oid_res_t *);
+		    union oid_res_t *);
 
 int mgt_commit_list(islpci_private *, enum oid_num_t *, int);
 

--Boundary-00=_WHcwAw8pWE41qOR--
