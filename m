From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [3/9] ieee80211: fix ipw 64bit compilation warnings
Date: Tue, 7 Jun 2005 14:58:41 +0200
Message-ID: <20050607145841.06d8d40f@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
	<20050603183048.7786f98b@griffin.suse.cz>
	<1118039392.5702.30.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, Jeff Garzik <jgarzik@pobox.com>,
        Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <1118039392.5702.30.camel@debian.sh.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 06 Jun 2005 14:29:52 +0800, Zhu Yi wrote:
> ("%zd", sizeof()) should be better.

Thanks. This is a corrected version of the patch.


This patch fixes warnings when compiling ipw2100 and ipw2200 on x86_64.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/drivers/net/wireless/ipw2200.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2200.c	2005-06-01 11:03:37.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2200.c	2005-06-07 14:23:08.000000000 +0200
@@ -241,8 +241,8 @@
 	IPW_DEBUG_IO(" reg = 0x%8X : value = 0x%8X\n", reg, value);
 	_ipw_write32(priv, CX2_INDIRECT_ADDR, reg & CX2_INDIRECT_ADDR_MASK);
 	_ipw_write8(priv, CX2_INDIRECT_DATA, value);
-	IPW_DEBUG_IO(" reg = 0x%8X : value = 0x%8X\n", 
-		     (unsigned)(priv->hw_base + CX2_INDIRECT_DATA),
+	IPW_DEBUG_IO(" reg = 0x%8lX : value = 0x%8X\n", 
+		     (unsigned long)(priv->hw_base + CX2_INDIRECT_DATA),
 		     value);
 }
 
@@ -508,7 +508,7 @@
 		/* verify we have enough room to store the value */
 		if (*len < sizeof(u32)) {
 			IPW_DEBUG_ORD("ordinal buffer length too small, "
-				      "need %d\n", sizeof(u32));
+				      "need %zd\n", sizeof(u32));
 			return -EINVAL;
 		}
 
@@ -541,7 +541,7 @@
 		/* verify we have enough room to store the value */
 		if (*len < sizeof(u32)) {
 			IPW_DEBUG_ORD("ordinal buffer length too small, "
-				      "need %d\n", sizeof(u32));
+				      "need %zd\n", sizeof(u32));
 			return -EINVAL;
 		}
 
@@ -1740,7 +1740,7 @@
 	u32 address = CX2_SHARED_SRAM_DMA_CONTROL + (sizeof(struct command_block) * index); 
 	IPW_DEBUG_FW(">> :\n");
 
-	ipw_write_indirect(priv, address, (u8*)cb, sizeof(struct command_block));
+	ipw_write_indirect(priv, address, (u8*)cb, (int)sizeof(struct command_block));
 
 	IPW_DEBUG_FW("<< :\n");
 	return 0;
@@ -2342,7 +2342,7 @@
 		return -EINVAL;
 	}
 
-	IPW_DEBUG_INFO("Loading firmware '%s' file v%d.%d (%d bytes)\n",
+	IPW_DEBUG_INFO("Loading firmware '%s' file v%d.%d (%zd bytes)\n",
 		       name,
 		       IPW_FW_MAJOR(header->version),
 		       IPW_FW_MINOR(header->version),
@@ -2697,7 +2697,7 @@
 
 	q->bd = pci_alloc_consistent(dev,sizeof(q->bd[0])*count, &q->q.dma_addr);
 	if (!q->bd) {
-		IPW_ERROR("pci_alloc_consistent(%d) failed\n",
+		IPW_ERROR("pci_alloc_consistent(%zd) failed\n",
 				sizeof(q->bd[0]) * count);
 		kfree(q->txb);
 		q->txb = NULL;
@@ -3466,8 +3466,8 @@
 				       x->channel_num);
 		} else {
 			IPW_DEBUG_SCAN("Scan result of wrong size %d "
-				       "(should be %d)\n",
-				       notif->size,sizeof(*x));
+				       "(should be %zd)\n",
+				       notif->size, sizeof(*x));
 		}
 		break;
 	}
@@ -3482,8 +3482,8 @@
 				       x->status);
 		} else {
 			IPW_ERROR("Scan completed of wrong size %d "
-				  "(should be %d)\n",
-				  notif->size,sizeof(*x));
+				  "(should be %zd)\n",
+				  notif->size, sizeof(*x));
 		}
 	
 		priv->status &= ~(STATUS_SCANNING | STATUS_SCAN_ABORTING);
@@ -3515,7 +3515,7 @@
 			IPW_ERROR("Frag length: %d\n", x->frag_length);
 		} else {
 			IPW_ERROR("Frag length of wrong size %d "
-				  "(should be %d)\n",
+				  "(should be %zd)\n",
 				  notif->size, sizeof(*x));
 		}
 		break;
@@ -3532,8 +3532,8 @@
 			memcpy(&priv->last_link_deterioration, x, sizeof(*x));
 		} else {
 			IPW_ERROR("Link Deterioration of wrong size %d "
-				  "(should be %d)\n",
-				  notif->size,sizeof(*x));
+				  "(should be %zd)\n",
+				  notif->size, sizeof(*x));
 		}
 		break;
 	}
@@ -3552,7 +3552,7 @@
 		struct notif_beacon_state *x = &notif->u.beacon_state;
 		if (notif->size != sizeof(*x)) {
 			IPW_ERROR("Beacon state of wrong size %d (should "
-				  "be %d)\n", notif->size, sizeof(*x));
+				  "be %zd)\n", notif->size, sizeof(*x));
 			break;
 		}
 
@@ -3602,8 +3602,8 @@
 			break;
 		} 
 
-		IPW_ERROR("TGi Tx Key of wrong size %d (should be %d)\n",
-			  notif->size,sizeof(*x));
+		IPW_ERROR("TGi Tx Key of wrong size %d (should be %zd)\n",
+			  notif->size, sizeof(*x));
 		break;
 	}
 
@@ -3616,8 +3616,8 @@
 			break;
 		} 
 		
-		IPW_ERROR("Calibration of wrong size %d (should be %d)\n",
-			  notif->size,sizeof(*x));
+		IPW_ERROR("Calibration of wrong size %d (should be %zd)\n",
+			  notif->size, sizeof(*x));
 		break;
 	}
 
@@ -3628,7 +3628,7 @@
 			break;
 		}
 
-		IPW_ERROR("Noise stat is wrong size %d (should be %d)\n",
+		IPW_ERROR("Noise stat is wrong size %d (should be %zd)\n",
 			  notif->size, sizeof(u32));
 		break;
 	}
@@ -4823,7 +4823,7 @@
 	}
 
 	/* Advance skb->data to the start of the actual payload */
-	skb_reserve(rxb->skb, (u32)&pkt->u.frame.data[0] - (u32)pkt);
+	skb_reserve(rxb->skb, offsetof(struct ipw_rx_packet, u.frame.data));
 
 	/* Set the size of the skb to the size of the frame */
 	skb_put(rxb->skb, pkt->u.frame.length);
Index: netdev/drivers/net/wireless/ipw2100.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2100.c	2005-06-01 11:03:37.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2100.c	2005-06-07 14:29:13.000000000 +0200
@@ -493,7 +493,7 @@
 			*len = IPW_ORD_TAB_1_ENTRY_SIZE;
 
 			IPW_DEBUG_WARNING(DRV_NAME
-			       ": ordinal buffer length too small, need %d\n",
+			       ": ordinal buffer length too small, need %zd\n",
 			       IPW_ORD_TAB_1_ENTRY_SIZE);
 
 			return -EINVAL;
@@ -2302,7 +2302,7 @@
 #endif
 
 	IPW_DEBUG_INFO(DRV_NAME ": PCI latency error detected at "
-		       "0x%04X.\n", i * sizeof(struct ipw2100_status));
+		       "0x%04zX.\n", i * sizeof(struct ipw2100_status));
 
 #ifdef ACPI_CSTATE_LIMIT_DEFINED
 	IPW_DEBUG_INFO(DRV_NAME ": Disabling C3 transitions.\n");
@@ -2398,7 +2398,7 @@
 	/* Make a copy of the frame so we can dump it to the logs if
 	 * ieee80211_rx fails */
 	memcpy(packet_data, packet->skb->data,
-	       min(status->frame_size, IPW_RX_NIC_BUFFER_LENGTH));
+	       min_t(u32, status->frame_size, IPW_RX_NIC_BUFFER_LENGTH));
 #endif
 
 	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
@@ -2730,21 +2730,21 @@
 	{
 		int i = txq->oldest;
 		IPW_DEBUG_TX(
-			"TX%d V=%p P=%p T=%p L=%d\n", i,
+			"TX%d V=%p P=%04X T=%04X L=%d\n", i,
 			&txq->drv[i],
-			(void*)txq->nic + i * sizeof(struct ipw2100_bd),
-			(void*)txq->drv[i].host_addr,
+			(u32)(txq->nic + i * sizeof(struct ipw2100_bd)),
+			txq->drv[i].host_addr,
 			txq->drv[i].buf_length);
 
 		if (packet->type == DATA) {
 			i = (i + 1) % txq->entries;
 
 			IPW_DEBUG_TX(
-				"TX%d V=%p P=%p T=%p L=%d\n", i,
+				"TX%d V=%p P=%04X T=%04X L=%d\n", i,
 				&txq->drv[i],
-				(void*)txq->nic + i *
-				sizeof(struct ipw2100_bd),
-				(void*)txq->drv[i].host_addr,
+				(u32)(txq->nic + i *
+				sizeof(struct ipw2100_bd)),
+				(u32)txq->drv[i].host_addr,
 				txq->drv[i].buf_length);
 		}
 	}
@@ -4212,7 +4212,7 @@
 {
 	IPW_DEBUG_INFO("enter\n");
 
-	IPW_DEBUG_INFO("initializing bd queue at virt=%p, phys=%08x\n", q->drv, q->nic);
+	IPW_DEBUG_INFO("initializing bd queue at virt=%p, phys=%08x\n", q->drv, (u32)q->nic);
 
 	write_register(priv->net_dev, base, q->nic);
 	write_register(priv->net_dev, size, q->entries);
@@ -8431,7 +8431,7 @@
 		       priv->net_dev->name, fw_name);
 		return rc;
 	}
-	IPW_DEBUG_INFO("firmware data %p size %d\n", fw->fw_entry->data,
+	IPW_DEBUG_INFO("firmware data %p size %zd\n", fw->fw_entry->data,
 			   fw->fw_entry->size);
 
 	ipw2100_mod_firmware_load(fw);


-- 
Jiri Benc
SUSE Labs
