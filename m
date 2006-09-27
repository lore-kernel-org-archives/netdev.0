From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/9][TG3]: Add 5722 and 5756 support.
Date: Wed, 27 Sep 2006 13:34:43 -0700
Message-ID: <1159389283.3411.21.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23314 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030790AbWI0UiO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:38:14 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add 5722 and 5756 support.

Add IDs to support 5722 and 5756.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 14e9645..d443b73 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -173,6 +173,7 @@ static struct pci_device_id tg3_pci_tbl[
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5721)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5722)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5750)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5750M)},
@@ -187,6 +188,7 @@ static struct pci_device_id tg3_pci_tbl[
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5754M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5755M)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5756)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5786)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5787M)},
@@ -11273,6 +11275,7 @@ static char * __devinit tg3_phy_string(s
 	case PHY_ID_BCM5780:	return "5780";
 	case PHY_ID_BCM5755:	return "5755";
 	case PHY_ID_BCM5787:	return "5787";
+	case PHY_ID_BCM5756:	return "5722/5756";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f7462c2..feed13d 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2282,6 +2282,7 @@ struct tg3 {
 #define PHY_ID_BCM5780			0x60008350
 #define PHY_ID_BCM5755			0xbc050cc0
 #define PHY_ID_BCM5787			0xbc050ce0
+#define PHY_ID_BCM5756			0xbc050ed0
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
 #define PHY_ID_REV_MASK			0x0000000f
@@ -2308,7 +2309,8 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5705 || (X) == PHY_ID_BCM5750 || \
 	 (X) == PHY_ID_BCM5752 || (X) == PHY_ID_BCM5714 || \
 	 (X) == PHY_ID_BCM5780 || (X) == PHY_ID_BCM5787 || \
-	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
+	 (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6a1e098..d9e75be 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1905,6 +1905,7 @@
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
 #define PCI_DEVICE_ID_TIGON3_5720	0x1658
 #define PCI_DEVICE_ID_TIGON3_5721	0x1659
+#define PCI_DEVICE_ID_TIGON3_5722	0x165a
 #define PCI_DEVICE_ID_TIGON3_5705M	0x165d
 #define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
 #define PCI_DEVICE_ID_TIGON3_5714	0x1668
@@ -1914,6 +1915,7 @@
 #define PCI_DEVICE_ID_TIGON3_5705F	0x166e
 #define PCI_DEVICE_ID_TIGON3_5754M	0x1672
 #define PCI_DEVICE_ID_TIGON3_5755M	0x1673
+#define PCI_DEVICE_ID_TIGON3_5756	0x1674
 #define PCI_DEVICE_ID_TIGON3_5750	0x1676
 #define PCI_DEVICE_ID_TIGON3_5751	0x1677
 #define PCI_DEVICE_ID_TIGON3_5715	0x1678


