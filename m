From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169: Increase MaxReadReq on pci express
Date: Sun, 23 Aug 2015 13:50:15 +0300
Message-ID: <1440327015-8029-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>,
	Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35858 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbbHWKu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 06:50:27 -0400
Received: by wicja10 with SMTP id ja10so48167786wic.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 03:50:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase MaxReadReq to 8192 bytes wich fit with value  
 written  on MaxTxPacketSize register 64 units and   128 descriptors on unit
 on pci express interface.   Old value from MaxReadReq  is half from new value
 as   not fit.

Signed-off-by: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2ee8bca..5fb79b1 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4968,7 +4968,7 @@ static void r8168c_hw_jumbo_disable(struct rtl8169_private *tp)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) & ~Jumbo_En1);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168dp_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -5002,7 +5002,7 @@ static void r8168e_hw_jumbo_disable(struct rtl8169_private *tp)
 	RTL_W8(MaxTxPacketSize, 0x0c);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Jumbo_En0);
 	RTL_W8(Config4, RTL_R8(Config4) & ~0x01);
-	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 }
 
 static void r8168b_0_hw_jumbo_enable(struct rtl8169_private *tp)
@@ -5651,8 +5651,8 @@ static void __rtl_hw_start_8168cp(struct rtl8169_private *tp)
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT); */
 
 	rtl_disable_clock_request(pdev);
 
@@ -5679,14 +5679,14 @@ static void rtl_hw_start_8168cp_1(struct rtl8169_private *tp)
 static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 
 	rtl_csi_access_enable_2(tp);
 
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -5694,7 +5694,7 @@ static void rtl_hw_start_8168cp_2(struct rtl8169_private *tp)
 static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 
 	rtl_csi_access_enable_2(tp);
 
@@ -5705,8 +5705,8 @@ static void rtl_hw_start_8168cp_3(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -5766,8 +5766,8 @@ static void rtl_hw_start_8168d(struct rtl8169_private *tp)
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 }
@@ -5779,8 +5779,8 @@ static void rtl_hw_start_8168dp(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
@@ -5800,7 +5800,7 @@ static void rtl_hw_start_8168d_4(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
@@ -5839,8 +5839,8 @@ static void rtl_hw_start_8168e_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168e_1, ARRAY_SIZE(e_info_8168e_1));
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	RTL_W8(MaxTxPacketSize, TxPacketMax);
 
@@ -5866,8 +5866,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168e_2, ARRAY_SIZE(e_info_8168e_2));
 
-	if (tp->dev->mtu <= ETH_DATA_LEN)
-		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	/*if (tp->dev->mtu <= ETH_DATA_LEN)
+		rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);*/
 
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
@@ -5900,7 +5900,7 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
@@ -5964,7 +5964,7 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 static void rtl_hw_start_8168g(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 
@@ -5975,7 +5975,7 @@ static void rtl_hw_start_8168g(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
@@ -6054,7 +6054,7 @@ static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
 static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 	u16 rg_saw_cnt;
 	u32 data;
 	static const struct ephy_info e_info_8168h_1[] = {
@@ -6080,7 +6080,7 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
@@ -6152,7 +6152,7 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 static void rtl_hw_start_8168ep(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 
 	rtl8168ep_stop_cmac(tp);
 
@@ -6165,7 +6165,7 @@ static void rtl_hw_start_8168ep(struct rtl8169_private *tp)
 
 	rtl_csi_access_enable_1(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
 	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
@@ -6420,7 +6420,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 	static const struct ephy_info e_info_8102e_1[] = {
 		{ 0x01,	0, 0x6e65 },
 		{ 0x02,	0, 0x091f },
@@ -6437,7 +6437,7 @@ static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 
 	RTL_W8(DBG_REG, FIX_NAK_1);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(Config1,
 	       LEDS1 | LEDS0 | Speed_down | MEMMAP | IOMAP | VPD | PMEnable);
@@ -6453,11 +6453,11 @@ static void rtl_hw_start_8102e_1(struct rtl8169_private *tp)
 static void rtl_hw_start_8102e_2(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	struct pci_dev *pdev = tp->pci_dev;
+	//struct pci_dev *pdev = tp->pci_dev;
 
 	rtl_csi_access_enable_2(tp);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(Config1, MEMMAP | IOMAP | VPD | PMEnable);
 	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
@@ -6522,7 +6522,7 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8402, ARRAY_SIZE(e_info_8402));
 
-	rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
+	//rtl_tx_performance_tweak(tp->pci_dev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
@@ -8224,6 +8224,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_is_pcie(pdev))
 		pci_write_config_word(pdev, PCI_COMMAND, ~PCI_COMMAND_IO);
 
+	if (pci_is_pcie(pdev))
+	 	rtl_tx_performance_tweak(tp->pci_dev, 0x6 << MAX_READ_REQUEST_SHIFT);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
-- 
2.1.4
