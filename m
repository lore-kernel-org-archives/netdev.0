From: Jiri Benc <jbenc@suse.cz>
Subject: [3/9] ieee80211: fix ipw 64bit compilation warnings
Date: Fri, 3 Jun 2005 18:30:48 +0200
Message-ID: <20050603183048.7786f98b@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes warnings when compiling ipw2100 and ipw2200 on x86_64.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/drivers/net/wireless/ipw2200.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2200.c	2005-06-01 11:03:37.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2200.c	2005-06-03 15:46:31.000000000 +0200
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
+				      "need %d\n", (int)sizeof(u32));
 			return -EINVAL;
 		}
 
@@ -541,7 +541,7 @@
 		/* verify we have enough room to store the value */
 		if (*len < sizeof(u32)) {
 			IPW_DEBUG_ORD("ordinal buffer length too small, "
-				      "need %d\n", sizeof(u32));
+				      "need %d\n", (int)sizeof(u32));
 			return -EINVAL;
 		}
 
@@ -1740,7 +1740,7 @@
 	u32 address = CX2_SHARED_SRAM_DMA_CONTROL + (sizeof(struct command_block) * index); 
 	IPW_DEBUG_FW(">> :\n");
 
-	ipw_write_indirect(priv, address, (u8*)cb, sizeof(struct command_block));
+	ipw_write_indirect(priv, address, (u8*)cb, (int)sizeof(struct command_block));
 
 	IPW_DEBUG_FW("<< :\n");
 	return 0;
@@ -2342,11 +2342,11 @@
 		return -EINVAL;
 	}
 
-	IPW_DEBUG_INFO("Loading firmware '%s' file v%d.%d (%d bytes)\n",
+	IPW_DEBUG_INFO("Loading firmware '%s' file v%d.%d (%ld bytes)\n",
 		       name,
 		       IPW_FW_MAJOR(header->version),
 		       IPW_FW_MINOR(header->version),
-		       (*fw)->size - sizeof(struct fw_header));
+		       (long)(*fw)->size - sizeof(struct fw_header));
 	return 0;
 }
 
@@ -2698,7 +2698,7 @@
 	q->bd = pci_alloc_consistent(dev,sizeof(q->bd[0])*count, &q->q.dma_addr);
 	if (!q->bd) {
 		IPW_ERROR("pci_alloc_consistent(%d) failed\n",
-				sizeof(q->bd[0]) * count);
+				(int)sizeof(q->bd[0]) * count);
 		kfree(q->txb);
 		q->txb = NULL;
 		return -ENOMEM;
@@ -3467,7 +3467,7 @@
 		} else {
 			IPW_DEBUG_SCAN("Scan result of wrong size %d "
 				       "(should be %d)\n",
-				       notif->size,sizeof(*x));
+				       notif->size, (int)sizeof(*x));
 		}
 		break;
 	}
@@ -3483,7 +3483,7 @@
 		} else {
 			IPW_ERROR("Scan completed of wrong size %d "
 				  "(should be %d)\n",
-				  notif->size,sizeof(*x));
+				  notif->size, (int)sizeof(*x));
 		}
 	
 		priv->status &= ~(STATUS_SCANNING | STATUS_SCAN_ABORTING);
@@ -3516,7 +3516,7 @@
 		} else {
 			IPW_ERROR("Frag length of wrong size %d "
 				  "(should be %d)\n",
-				  notif->size, sizeof(*x));
+				  notif->size, (int)sizeof(*x));
 		}
 		break;
 	}
@@ -3533,7 +3533,7 @@
 		} else {
 			IPW_ERROR("Link Deterioration of wrong size %d "
 				  "(should be %d)\n",
-				  notif->size,sizeof(*x));
+				  notif->size, (int)sizeof(*x));
 		}
 		break;
 	}
@@ -3552,7 +3552,7 @@
 		struct notif_beacon_state *x = &notif->u.beacon_state;
 		if (notif->size != sizeof(*x)) {
 			IPW_ERROR("Beacon state of wrong size %d (should "
-				  "be %d)\n", notif->size, sizeof(*x));
+				  "be %d)\n", notif->size, (int)sizeof(*x));
 			break;
 		}
 
@@ -3603,7 +3603,7 @@
 		} 
 
 		IPW_ERROR("TGi Tx Key of wrong size %d (should be %d)\n",
-			  notif->size,sizeof(*x));
+			  notif->size, (int)sizeof(*x));
 		break;
 	}
 
@@ -3617,7 +3617,7 @@
 		} 
 		
 		IPW_ERROR("Calibration of wrong size %d (should be %d)\n",
-			  notif->size,sizeof(*x));
+			  notif->size, (int)sizeof(*x));
 		break;
 	}
 
@@ -3629,7 +3629,7 @@
 		}
 
 		IPW_ERROR("Noise stat is wrong size %d (should be %d)\n",
-			  notif->size, sizeof(u32));
+			  notif->size, (int)sizeof(u32));
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
+++ netdev/drivers/net/wireless/ipw2100.c	2005-06-03 15:43:53.000000000 +0200
@@ -494,7 +494,7 @@
 
 			IPW_DEBUG_WARNING(DRV_NAME
 			       ": ordinal buffer length too small, need %d\n",
-			       IPW_ORD_TAB_1_ENTRY_SIZE);
+			       (int)IPW_ORD_TAB_1_ENTRY_SIZE);
 
 			return -EINVAL;
 		}
@@ -2302,7 +2302,7 @@
 #endif
 
 	IPW_DEBUG_INFO(DRV_NAME ": PCI latency error detected at "
-		       "0x%04X.\n", i * sizeof(struct ipw2100_status));
+		       "0x%04X.\n", i * (int)sizeof(struct ipw2100_status));
 
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
@@ -8431,8 +8431,8 @@
 		       priv->net_dev->name, fw_name);
 		return rc;
 	}
-	IPW_DEBUG_INFO("firmware data %p size %d\n", fw->fw_entry->data,
-			   fw->fw_entry->size);
+	IPW_DEBUG_INFO("firmware data %p size %ld\n", fw->fw_entry->data,
+			   (long)fw->fw_entry->size);
 
 	ipw2100_mod_firmware_load(fw);
 


-- 
Jiri Benc
SUSE Labs
