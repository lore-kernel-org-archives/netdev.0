From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [net-next-2.6 #2 07/08] r8169: rtl_csi_access_enable rename.
Date: Tue, 4 Jan 2011 02:08:29 +0100
Message-ID: <20110104010829.GH5957@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42083 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab1ADBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 20:08:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer 8168 needs a slightly different rtl_csi_access_enable.
This patch separates some noise from the real thing.

No functional change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a73dd28..a468ee9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3310,12 +3310,17 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 	}
 }
 
-static void rtl_csi_access_enable(void __iomem *ioaddr)
+static void rtl_csi_access_enable(void __iomem *ioaddr, u32 bits)
 {
 	u32 csi;
 
 	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
-	rtl_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+	rtl_csi_write(ioaddr, 0x070c, csi | bits);
+}
+
+static void rtl_csi_access_enable_2(void __iomem *ioaddr)
+{
+	rtl_csi_access_enable(ioaddr, 0x27000000);
 }
 
 struct ephy_info {
@@ -3403,7 +3408,7 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x07, 0,	0x2000 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
 
@@ -3412,7 +3417,7 @@ static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -3423,7 +3428,7 @@ static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
@@ -3445,7 +3450,7 @@ static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x06, 0x0080,	0x0000 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
 
@@ -3461,7 +3466,7 @@ static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x03, 0x0400,	0x0220 }
 	};
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
 
@@ -3475,14 +3480,14 @@ static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	__rtl_hw_start_8168cp(ioaddr, pdev);
 }
 
 static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_disable_clock_request(pdev);
 
@@ -3611,7 +3616,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	};
 	u8 cfg1;
 
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	RTL_W8(DBG_REG, FIX_NAK_1);
 
@@ -3632,7 +3637,7 @@ static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8102e_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	rtl_csi_access_enable(ioaddr);
+	rtl_csi_access_enable_2(ioaddr);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-- 
1.7.3.4

