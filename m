From: Chen Gang S <gang.chen@sunrus.com.cn>
Subject: [PATCH] net: usb: sr9700: Use 'SR_' prefix for the common register
 macros
Date: Tue, 03 Feb 2015 05:00:40 +0800
Message-ID: <54CFE578.7030207@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commone register macors (e.g. RSR) is too commont to drivers, it may
be conflict with the architectures (e.g. xtensa, sh).

The related warnings (with allmodconfig under xtensa):

    CC [M]  drivers/net/usb/sr9700.o
  In file included from drivers/net/usb/sr9700.c:24:0:
  drivers/net/usb/sr9700.h:65:0: warning: "RSR" redefined
   #define RSR   0x06
   ^
  In file included from ./arch/xtensa/include/asm/bitops.h:22:0,
                   from include/linux/bitops.h:36,
                   from include/linux/kernel.h:10,
                   from include/linux/list.h:8,
                   from include/linux/module.h:9,
                   from drivers/net/usb/sr9700.c:13:
  ./arch/xtensa/include/asm/processor.h:190:0: note: this is the location of the previous definition
   #define RSR(v,sr) __asm__ __volatile__ ("rsr %0,"__stringify(sr) : "=a"(v));
   ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/usb/sr9700.c | 36 +++++++++++++-------------
 drivers/net/usb/sr9700.h | 66 ++++++++++++++++++++++++------------------------
 2 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 99b69af..4a1e9c4 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -77,7 +77,7 @@ static int wait_phy_eeprom_ready(struct usbnet *dev, int phy)
 		int ret;
 
 		udelay(1);
-		ret = sr_read_reg(dev, EPCR, &tmp);
+		ret = sr_read_reg(dev, SR_EPCR, &tmp);
 		if (ret < 0)
 			return ret;
 
@@ -98,15 +98,15 @@ static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg,
 
 	mutex_lock(&dev->phy_mutex);
 
-	sr_write_reg(dev, EPAR, phy ? (reg | EPAR_PHY_ADR) : reg);
-	sr_write_reg(dev, EPCR, phy ? (EPCR_EPOS | EPCR_ERPRR) : EPCR_ERPRR);
+	sr_write_reg(dev, SR_EPAR, phy ? (reg | EPAR_PHY_ADR) : reg);
+	sr_write_reg(dev, SR_EPCR, phy ? (EPCR_EPOS | EPCR_ERPRR) : EPCR_ERPRR);
 
 	ret = wait_phy_eeprom_ready(dev, phy);
 	if (ret < 0)
 		goto out_unlock;
 
-	sr_write_reg(dev, EPCR, 0x0);
-	ret = sr_read(dev, EPDR, 2, value);
+	sr_write_reg(dev, SR_EPCR, 0x0);
+	ret = sr_read(dev, SR_EPDR, 2, value);
 
 	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
 		   phy, reg, *value, ret);
@@ -123,19 +123,19 @@ static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg,
 
 	mutex_lock(&dev->phy_mutex);
 
-	ret = sr_write(dev, EPDR, 2, &value);
+	ret = sr_write(dev, SR_EPDR, 2, &value);
 	if (ret < 0)
 		goto out_unlock;
 
-	sr_write_reg(dev, EPAR, phy ? (reg | EPAR_PHY_ADR) : reg);
-	sr_write_reg(dev, EPCR, phy ? (EPCR_WEP | EPCR_EPOS | EPCR_ERPRW) :
+	sr_write_reg(dev, SR_EPAR, phy ? (reg | EPAR_PHY_ADR) : reg);
+	sr_write_reg(dev, SR_EPCR, phy ? (EPCR_WEP | EPCR_EPOS | EPCR_ERPRW) :
 		    (EPCR_WEP | EPCR_ERPRW));
 
 	ret = wait_phy_eeprom_ready(dev, phy);
 	if (ret < 0)
 		goto out_unlock;
 
-	sr_write_reg(dev, EPCR, 0x0);
+	sr_write_reg(dev, SR_EPCR, 0x0);
 
 out_unlock:
 	mutex_unlock(&dev->phy_mutex);
@@ -188,7 +188,7 @@ static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	if (loc == MII_BMSR) {
 		u8 value;
 
-		sr_read_reg(dev, NSR, &value);
+		sr_read_reg(dev, SR_NSR, &value);
 		if (value & NSR_LINKST)
 			rc = 1;
 	}
@@ -228,7 +228,7 @@ static u32 sr9700_get_link(struct net_device *netdev)
 	int rc = 0;
 
 	/* Get the Link Status directly */
-	sr_read_reg(dev, NSR, &value);
+	sr_read_reg(dev, SR_NSR, &value);
 	if (value & NSR_LINKST)
 		rc = 1;
 
@@ -281,8 +281,8 @@ static void sr9700_set_multicast(struct net_device *netdev)
 		}
 	}
 
-	sr_write_async(dev, MAR, SR_MCAST_SIZE, hashes);
-	sr_write_reg_async(dev, RCR, rx_ctl);
+	sr_write_async(dev, SR_MAR, SR_MCAST_SIZE, hashes);
+	sr_write_reg_async(dev, SR_RCR, rx_ctl);
 }
 
 static int sr9700_set_mac_address(struct net_device *netdev, void *p)
@@ -297,7 +297,7 @@ static int sr9700_set_mac_address(struct net_device *netdev, void *p)
 	}
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	sr_write_async(dev, PAR, 6, netdev->dev_addr);
+	sr_write_async(dev, SR_PAR, 6, netdev->dev_addr);
 
 	return 0;
 }
@@ -340,7 +340,7 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 	mii->phy_id_mask = 0x1f;
 	mii->reg_num_mask = 0x1f;
 
-	sr_write_reg(dev, NCR, NCR_RST);
+	sr_write_reg(dev, SR_NCR, NCR_RST);
 	udelay(20);
 
 	/* read MAC
@@ -348,17 +348,17 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 	 * EEPROM automatically to PAR. In case there is no EEPROM externally,
 	 * a default MAC address is stored in PAR for making chip work properly.
 	 */
-	if (sr_read(dev, PAR, ETH_ALEN, netdev->dev_addr) < 0) {
+	if (sr_read(dev, SR_PAR, ETH_ALEN, netdev->dev_addr) < 0) {
 		netdev_err(netdev, "Error reading MAC address\n");
 		ret = -ENODEV;
 		goto out;
 	}
 
 	/* power up and reset phy */
-	sr_write_reg(dev, PRR, PRR_PHY_RST);
+	sr_write_reg(dev, SR_PRR, PRR_PHY_RST);
 	/* at least 10ms, here 20ms for safe */
 	mdelay(20);
-	sr_write_reg(dev, PRR, 0);
+	sr_write_reg(dev, SR_PRR, 0);
 	/* at least 1ms, here 2ms for reading right register */
 	udelay(2 * 1000);
 
diff --git a/drivers/net/usb/sr9700.h b/drivers/net/usb/sr9700.h
index fd687c5..258b030 100644
--- a/drivers/net/usb/sr9700.h
+++ b/drivers/net/usb/sr9700.h
@@ -14,13 +14,13 @@
 /* sr9700 spec. register table on Linux platform */
 
 /* Network Control Reg */
-#define	NCR			0x00
+#define	SR_NCR			0x00
 #define		NCR_RST			(1 << 0)
 #define		NCR_LBK			(3 << 1)
 #define		NCR_FDX			(1 << 3)
 #define		NCR_WAKEEN		(1 << 6)
 /* Network Status Reg */
-#define	NSR			0x01
+#define	SR_NSR			0x01
 #define		NSR_RXRDY		(1 << 0)
 #define		NSR_RXOV		(1 << 1)
 #define		NSR_TX1END		(1 << 2)
@@ -30,7 +30,7 @@
 #define		NSR_LINKST		(1 << 6)
 #define		NSR_SPEED		(1 << 7)
 /* Tx Control Reg */
-#define	TCR			0x02
+#define	SR_TCR			0x02
 #define		TCR_CRC_DIS		(1 << 1)
 #define		TCR_PAD_DIS		(1 << 2)
 #define		TCR_LC_CARE		(1 << 3)
@@ -38,7 +38,7 @@
 #define		TCR_EXCECM		(1 << 5)
 #define		TCR_LF_EN		(1 << 6)
 /* Tx Status Reg for Packet Index 1 */
-#define	TSR1		0x03
+#define	SR_TSR1		0x03
 #define		TSR1_EC			(1 << 2)
 #define		TSR1_COL		(1 << 3)
 #define		TSR1_LC			(1 << 4)
@@ -46,7 +46,7 @@
 #define		TSR1_LOC		(1 << 6)
 #define		TSR1_TLF		(1 << 7)
 /* Tx Status Reg for Packet Index 2 */
-#define	TSR2		0x04
+#define	SR_TSR2		0x04
 #define		TSR2_EC			(1 << 2)
 #define		TSR2_COL		(1 << 3)
 #define		TSR2_LC			(1 << 4)
@@ -54,7 +54,7 @@
 #define		TSR2_LOC		(1 << 6)
 #define		TSR2_TLF		(1 << 7)
 /* Rx Control Reg*/
-#define	RCR			0x05
+#define	SR_RCR			0x05
 #define		RCR_RXEN		(1 << 0)
 #define		RCR_PRMSC		(1 << 1)
 #define		RCR_RUNT		(1 << 2)
@@ -62,87 +62,87 @@
 #define		RCR_DIS_CRC		(1 << 4)
 #define		RCR_DIS_LONG	(1 << 5)
 /* Rx Status Reg */
-#define	RSR			0x06
+#define	SR_RSR			0x06
 #define		RSR_AE			(1 << 2)
 #define		RSR_MF			(1 << 6)
 #define		RSR_RF			(1 << 7)
 /* Rx Overflow Counter Reg */
-#define	ROCR		0x07
+#define	SR_ROCR		0x07
 #define		ROCR_ROC		(0x7F << 0)
 #define		ROCR_RXFU		(1 << 7)
 /* Back Pressure Threshold Reg */
-#define	BPTR		0x08
+#define	SR_BPTR		0x08
 #define		BPTR_JPT		(0x0F << 0)
 #define		BPTR_BPHW		(0x0F << 4)
 /* Flow Control Threshold Reg */
-#define	FCTR		0x09
+#define	SR_FCTR		0x09
 #define		FCTR_LWOT		(0x0F << 0)
 #define		FCTR_HWOT		(0x0F << 4)
 /* rx/tx Flow Control Reg */
-#define	FCR			0x0A
+#define	SR_FCR			0x0A
 #define		FCR_FLCE		(1 << 0)
 #define		FCR_BKPA		(1 << 4)
 #define		FCR_TXPEN		(1 << 5)
 #define		FCR_TXPF		(1 << 6)
 #define		FCR_TXP0		(1 << 7)
 /* Eeprom & Phy Control Reg */
-#define	EPCR		0x0B
+#define	SR_EPCR		0x0B
 #define		EPCR_ERRE		(1 << 0)
 #define		EPCR_ERPRW		(1 << 1)
 #define		EPCR_ERPRR		(1 << 2)
 #define		EPCR_EPOS		(1 << 3)
 #define		EPCR_WEP		(1 << 4)
 /* Eeprom & Phy Address Reg */
-#define	EPAR		0x0C
+#define	SR_EPAR		0x0C
 #define		EPAR_EROA		(0x3F << 0)
 #define		EPAR_PHY_ADR_MASK	(0x03 << 6)
 #define		EPAR_PHY_ADR		(0x01 << 6)
 /* Eeprom &	Phy Data Reg */
-#define	EPDR		0x0D	/* 0x0D ~ 0x0E for Data Reg Low & High */
+#define	SR_EPDR		0x0D	/* 0x0D ~ 0x0E for Data Reg Low & High */
 /* Wakeup Control Reg */
-#define	WCR			0x0F
+#define	SR_WCR			0x0F
 #define		WCR_MAGICST		(1 << 0)
 #define		WCR_LINKST		(1 << 2)
 #define		WCR_MAGICEN		(1 << 3)
 #define		WCR_LINKEN		(1 << 5)
 /* Physical Address Reg */
-#define	PAR			0x10	/* 0x10 ~ 0x15 6 bytes for PAR */
+#define	SR_PAR			0x10	/* 0x10 ~ 0x15 6 bytes for PAR */
 /* Multicast Address Reg */
-#define	MAR			0x16	/* 0x16 ~ 0x1D 8 bytes for MAR */
+#define	SR_MAR			0x16	/* 0x16 ~ 0x1D 8 bytes for MAR */
 /* 0x1e unused */
 /* Phy Reset Reg */
-#define	PRR			0x1F
+#define	SR_PRR			0x1F
 #define		PRR_PHY_RST		(1 << 0)
 /* Tx sdram Write Pointer Address Low */
-#define	TWPAL		0x20
+#define	SR_TWPAL		0x20
 /* Tx sdram Write Pointer Address High */
-#define	TWPAH		0x21
+#define	SR_TWPAH		0x21
 /* Tx sdram Read Pointer Address Low */
-#define	TRPAL		0x22
+#define	SR_TRPAL		0x22
 /* Tx sdram Read Pointer Address High */
-#define	TRPAH		0x23
+#define	SR_TRPAH		0x23
 /* Rx sdram Write Pointer Address Low */
-#define	RWPAL		0x24
+#define	SR_RWPAL		0x24
 /* Rx sdram Write Pointer Address High */
-#define	RWPAH		0x25
+#define	SR_RWPAH		0x25
 /* Rx sdram Read Pointer Address Low */
-#define	RRPAL		0x26
+#define	SR_RRPAL		0x26
 /* Rx sdram Read Pointer Address High */
-#define	RRPAH		0x27
+#define	SR_RRPAH		0x27
 /* Vendor ID register */
-#define	VID			0x28	/* 0x28 ~ 0x29 2 bytes for VID */
+#define	SR_VID			0x28	/* 0x28 ~ 0x29 2 bytes for VID */
 /* Product ID register */
-#define	PID			0x2A	/* 0x2A ~ 0x2B 2 bytes for PID */
+#define	SR_PID			0x2A	/* 0x2A ~ 0x2B 2 bytes for PID */
 /* CHIP Revision register */
-#define	CHIPR		0x2C
+#define	SR_CHIPR		0x2C
 /* 0x2D --> 0xEF unused */
 /* USB Device Address */
-#define	USBDA		0xF0
+#define	SR_USBDA		0xF0
 #define		USBDA_USBFA		(0x7F << 0)
 /* RX packet Counter Reg */
-#define	RXC			0xF1
+#define	SR_RXC			0xF1
 /* Tx packet Counter & USB Status Reg */
-#define	TXC_USBS	0xF2
+#define	SR_TXC_USBS		0xF2
 #define		TXC_USBS_TXC0		(1 << 0)
 #define		TXC_USBS_TXC1		(1 << 1)
 #define		TXC_USBS_TXC2		(1 << 2)
@@ -150,7 +150,7 @@
 #define		TXC_USBS_SUSFLAG	(1 << 6)
 #define		TXC_USBS_RXFAULT	(1 << 7)
 /* USB Control register */
-#define	USBC		0xF4
+#define	SR_USBC			0xF4
 #define		USBC_EP3NAK		(1 << 4)
 #define		USBC_EP3ACK		(1 << 5)
 
-- 
1.9.3
