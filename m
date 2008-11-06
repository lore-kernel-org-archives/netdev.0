From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] ssb: Fix DMA-API compilation for non-PCI systems
Date: Thu, 6 Nov 2008 21:49:21 +0100
Message-ID: <200811062149.21841.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753645AbYKFUxD@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation of the SSB DMA-API code on non-PCI platforms.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

John, please queue this for whatever kernel. I forgot what version
we're working on. :P


Index: wireless-testing/include/linux/ssb/ssb.h
===================================================================
--- wireless-testing.orig/include/linux/ssb/ssb.h	2008-08-01 17:26:05.000000000 +0200
+++ wireless-testing/include/linux/ssb/ssb.h	2008-11-06 21:45:37.000000000 +0100
@@ -427,12 +427,16 @@ static inline int ssb_dma_mapping_error(
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		return pci_dma_mapping_error(dev->bus->host_pci, addr);
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		return dma_mapping_error(dev->dev, addr);
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 	return -ENOSYS;
 }
 
@@ -441,12 +445,16 @@ static inline dma_addr_t ssb_dma_map_sin
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		return pci_map_single(dev->bus->host_pci, p, size, dir);
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		return dma_map_single(dev->dev, p, size, dir);
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 	return 0;
 }
 
@@ -455,14 +463,18 @@ static inline void ssb_dma_unmap_single(
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		pci_unmap_single(dev->bus->host_pci, dma_addr, size, dir);
 		return;
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		dma_unmap_single(dev->dev, dma_addr, size, dir);
 		return;
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 }
 
 static inline void ssb_dma_sync_single_for_cpu(struct ssb_device *dev,
@@ -472,15 +484,19 @@ static inline void ssb_dma_sync_single_f
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		pci_dma_sync_single_for_cpu(dev->bus->host_pci, dma_addr,
 					    size, dir);
 		return;
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		dma_sync_single_for_cpu(dev->dev, dma_addr, size, dir);
 		return;
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 }
 
 static inline void ssb_dma_sync_single_for_device(struct ssb_device *dev,
@@ -490,15 +506,19 @@ static inline void ssb_dma_sync_single_f
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		pci_dma_sync_single_for_device(dev->bus->host_pci, dma_addr,
 					       size, dir);
 		return;
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		dma_sync_single_for_device(dev->dev, dma_addr, size, dir);
 		return;
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 }
 
 static inline void ssb_dma_sync_single_range_for_cpu(struct ssb_device *dev,
@@ -509,17 +529,21 @@ static inline void ssb_dma_sync_single_r
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		/* Just sync everything. That's all the PCI API can do. */
 		pci_dma_sync_single_for_cpu(dev->bus->host_pci, dma_addr,
 					    offset + size, dir);
 		return;
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		dma_sync_single_range_for_cpu(dev->dev, dma_addr, offset,
 					      size, dir);
 		return;
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 }
 
 static inline void ssb_dma_sync_single_range_for_device(struct ssb_device *dev,
@@ -530,17 +554,21 @@ static inline void ssb_dma_sync_single_r
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		/* Just sync everything. That's all the PCI API can do. */
 		pci_dma_sync_single_for_device(dev->bus->host_pci, dma_addr,
 					       offset + size, dir);
 		return;
+#endif
+		break;
 	case SSB_BUSTYPE_SSB:
 		dma_sync_single_range_for_device(dev->dev, dma_addr, offset,
 						 size, dir);
 		return;
 	default:
-		__ssb_dma_not_implemented(dev);
+		break;
 	}
+	__ssb_dma_not_implemented(dev);
 }
 
 

-- 
Greetings Michael.
