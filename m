From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] r8169: move PHY regs tables to .rodata
Date: Thu, 26 Nov 2009 00:39:34 +0300
Message-ID: <20091125213933.GA3455@x200.malnet.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:13382 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934887AbZKYVjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 16:39:31 -0500
Received: by ey-out-2122.google.com with SMTP id 4so55711eyf.19
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2009 13:39:36 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As side effect, consume less stack.

	-rtl8169_get_mac_version [vmlinux]:	432
	-rtl8169_init_one [vmlinux]:		376
	+rtl8169_init_one [vmlinux]:		136

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/r8169.c |   42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -756,7 +756,7 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned int i;
-	static struct {
+	static const struct {
 		u32 opt;
 		u16 reg;
 		u8  mask;
@@ -1247,7 +1247,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	 *
 	 * (RTL_R32(TxConfig) & 0x700000) == 0x200000 ? 8101Eb : 8101Ec
 	 */
-	const struct {
+	static const struct {
 		u32 mask;
 		u32 val;
 		int mac_version;
@@ -1318,7 +1318,7 @@ struct phy_reg {
 	u16 val;
 };
 
-static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
+static void rtl_phy_write(void __iomem *ioaddr, const struct phy_reg *regs, int len)
 {
 	while (len-- > 0) {
 		mdio_write(ioaddr, regs->reg, regs->val);
@@ -1328,7 +1328,7 @@ static void rtl_phy_write(void __iomem *ioaddr, struct phy_reg *regs, int len)
 
 static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 {
-	struct {
+	static const struct {
 		u16 regs[5]; /* Beware of bit-sign propagation */
 	} phy_magic[5] = { {
 		{ 0x0000,	//w 4 15 12 0
@@ -1380,7 +1380,7 @@ static void rtl8169s_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0002 },
 		{ 0x01, 0x90d0 },
 		{ 0x1f, 0x0000 }
@@ -1391,7 +1391,7 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x10, 0xf41b },
 		{ 0x1f, 0x0000 }
 	};
@@ -1404,7 +1404,7 @@ static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x10, 0xf41b },
 		{ 0x1f, 0x0000 }
@@ -1415,7 +1415,7 @@ static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0000 },
 		{ 0x1d, 0x0f00 },
 		{ 0x1f, 0x0002 },
@@ -1428,7 +1428,7 @@ static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x1d, 0x3d98 },
 		{ 0x1f, 0x0000 }
@@ -1443,7 +1443,7 @@ static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
 		{ 0x1f, 0x0002 },
@@ -1472,7 +1472,7 @@ static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168c_2_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
 		{ 0x03, 0x802f },
@@ -1500,7 +1500,7 @@ static void rtl8168c_2_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168c_3_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
 		{ 0x1d, 0x3d98 },
@@ -1527,7 +1527,7 @@ static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8168d_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init_0[] = {
+	static const struct phy_reg phy_reg_init_0[] = {
 		{ 0x1f, 0x0001 },
 		{ 0x09, 0x2770 },
 		{ 0x08, 0x04d0 },
@@ -1556,7 +1556,7 @@ static void rtl8168d_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
 
 	if (mdio_read(ioaddr, 0x06) == 0xc400) {
-		struct phy_reg phy_reg_init_1[] = {
+		static const struct phy_reg phy_reg_init_1[] = {
 			{ 0x1f, 0x0005 },
 			{ 0x01, 0x0300 },
 			{ 0x1f, 0x0000 },
@@ -1597,7 +1597,7 @@ static void rtl8168d_hw_phy_config(void __iomem *ioaddr)
 
 static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
 {
-	struct phy_reg phy_reg_init[] = {
+	static const struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0003 },
 		{ 0x08, 0x441d },
 		{ 0x01, 0x9100 },
@@ -2370,7 +2370,7 @@ static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
 
 static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 {
-	struct {
+	static const struct {
 		u32 mac_version;
 		u32 clk;
 		u32 val;
@@ -2494,7 +2494,7 @@ struct ephy_info {
 	u16 bits;
 };
 
-static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
+static void rtl_ephy_init(void __iomem *ioaddr, const struct ephy_info *e, int len)
 {
 	u16 w;
 
@@ -2565,7 +2565,7 @@ static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static struct ephy_info e_info_8168cp[] = {
+	static const struct ephy_info e_info_8168cp[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x02, 0x0800,	0x1000 },
 		{ 0x03, 0,	0x0042 },
@@ -2609,7 +2609,7 @@ static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static struct ephy_info e_info_8168c_1[] = {
+	static const struct ephy_info e_info_8168c_1[] = {
 		{ 0x02, 0x0800,	0x1000 },
 		{ 0x03, 0,	0x0002 },
 		{ 0x06, 0x0080,	0x0000 }
@@ -2626,7 +2626,7 @@ static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
 
 static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static struct ephy_info e_info_8168c_2[] = {
+	static const struct ephy_info e_info_8168c_2[] = {
 		{ 0x01, 0,	0x0001 },
 		{ 0x03, 0x0400,	0x0220 }
 	};
@@ -2767,7 +2767,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 static void rtl_hw_start_8102e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 {
-	static struct ephy_info e_info_8102e_1[] = {
+	static const struct ephy_info e_info_8102e_1[] = {
 		{ 0x01,	0, 0x6e65 },
 		{ 0x02,	0, 0x091f },
 		{ 0x03,	0, 0xc2f9 },
