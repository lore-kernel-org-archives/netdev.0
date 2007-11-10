From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sat, 10 Nov 2007 16:42:37 -0500
Message-ID: <20071110214237.GA17340@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48917 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310AbXKJVmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 16:42:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                              |   10 ++-
 drivers/net/Kconfig                      |    2 +-
 drivers/net/bonding/bond_main.c          |    1 +
 drivers/net/bonding/bond_sysfs.c         |    4 +-
 drivers/net/pasemi_mac.c                 |   18 ++++-
 drivers/net/qla3xxx.c                    |   42 +++++------
 drivers/net/qla3xxx.h                    |    1 +
 drivers/net/r8169.c                      |   26 ++-----
 drivers/net/sky2.c                       |  116 ++++++++++++++++++------------
 drivers/net/sky2.h                       |    3 +-
 drivers/net/smc91x.h                     |   15 ++++
 drivers/net/wireless/Kconfig             |    2 +-
 drivers/net/wireless/b43/Kconfig         |   10 ++-
 drivers/net/wireless/b43/debugfs.c       |    2 +-
 drivers/net/wireless/b43/main.c          |   19 +++---
 drivers/net/wireless/b43/pcmcia.c        |   52 +++++++++-----
 drivers/net/wireless/b43/rfkill.c        |  115 +++++++++++++----------------
 drivers/net/wireless/b43/rfkill.h        |   14 +---
 drivers/net/wireless/b43legacy/debugfs.c |    2 +-
 drivers/net/wireless/b43legacy/main.c    |   21 +++---
 drivers/net/wireless/hostap/hostap_pci.c |    6 +-
 drivers/net/wireless/ipw2100.c           |    4 +-
 drivers/net/wireless/libertas/cmd.c      |   10 ++-
 drivers/net/wireless/libertas/if_cs.c    |    7 ++-
 drivers/net/wireless/libertas/if_sdio.c  |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c  |    8 ++
 26 files changed, 285 insertions(+), 229 deletions(-)

Ciaran McCreesh (1):
      r8169: add PCI ID for the 8168 in the Abit Fatal1ty F-190HD motherboard

Francois Romieu (2):
      r8169: do not enable the TBI for the 8168 and the 81x0
      r8169: prevent bit sign expansion error in mdio_write

Holger Schurig (1):
      libertas: fixes for slow hardware

Ivo van Doorn (1):
      rt2x00: Block adhoc & master mode

Jay Vosburgh (2):
      bonding: fix rtnl locking merge error
      bonding: don't validate address at device open

John W. Linville (1):
      hermes: clarify Intel reference in Kconfig help

Magnus Damm (1):
      ax88796: add superh to kconfig dependencies

Marcelo Tosatti (1):
      libertas: properly account for queue commands

Mark Lord (2):
      r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (partly)
      r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (bis repetita)

Michael Buesch (7):
      b43: pcmcia-host initialization bugfixes
      b43: Fix rfkill callback deadlock
      b43: debugfs SHM read buffer overrun fix
      b43: Rewrite and fix rfkill init
      b43: properly request pcmcia IRQ
      b43legacy: Fix sparse warning
      b43: Fix kconfig dependencies for rfkill and leds

Olof Johansson (2):
      pasemi_mac: Don't set replace-source-address descriptor bits
      pasemi_mac: Fix CRC checks

Pierre Ossman (1):
      libertas: make if_sdio align packets

Randy Dunlap (1):
      hostap: fix section mismatch warning

Roel Kluin (1):
      ipw2100: fix postfix decrement errors

Ron Mercer (2):
      qla3xxx: bugfix: Move link state machine into a worker thread
      qla3xxx: bugfix: Fix bad logical operation in link state machine.

Stefano Brivio (4):
      b43legacy: fix possible buffer overrun in debugfs
      b43legacy: add me as maintainer and fix URLs
      b43: fix shared IRQ race condition
      b43legacy: fix shared IRQ race condition

Stephen Hemminger (9):
      sky2: enable PCI config writes
      sky2: status ring race fix
      sky2: longer PHY delay
      sky2: dont change LED after autoneg
      sky2: remove unneeded mask update
      sky2: handle advanced error recovery config issues
      sky2: version 1.20
      sky2: netpoll on port 0 only
      sky2: new pci id's

eric miao (1):
      add support for smc91x ethernet interface on zylonite

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c7c229..6a97027 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -787,23 +787,25 @@ B43 WIRELESS DRIVER
 P:	Michael Buesch
 M:	mb@bu3sch.de
 P:	Stefano Brivio
-M:	st3@riseup.net
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 B43LEGACY WIRELESS DRIVER
 P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
+P:	Stefano Brivio
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
 P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
 P:	Stefano Brivio
-M:	st3@riseup.net
+M:	stefano.brivio@polimi.it
 L:	linux-wireless@vger.kernel.org
 W:	http://bcm43xx.berlios.de/
 S:	Maintained
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index cb581eb..bf8890e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -235,7 +235,7 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS
+	depends on ARM || MIPS || SUPERH
 	select CRC32
 	select MII
 	help
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6937ef0..a198404 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4405,6 +4405,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond_dev->set_multicast_list = bond_set_multicast_list;
 	bond_dev->change_mtu = bond_change_mtu;
 	bond_dev->set_mac_address = bond_set_mac_address;
+	bond_dev->validate_addr = NULL;
 
 	bond_set_mode_ops(bond, bond->params.mode);
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7a06ade..b29330d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1193,8 +1193,6 @@ static ssize_t bonding_show_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 	int count;
 
-	rtnl_lock();
-
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -1216,7 +1214,9 @@ static ssize_t bonding_store_active_slave(struct device *d,
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to change active slave; %s is in mode %d\n",
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index ab4d309..09b4fde 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -580,6 +580,16 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
+		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
+
+		if (macrx & XCT_MACRX_CRC) {
+			/* CRC error flagged */
+			mac->netdev->stats.rx_errors++;
+			mac->netdev->stats.rx_crc_errors++;
+			dev_kfree_skb_irq(skb);
+			goto next;
+		}
+
 		if (len < 256) {
 			struct sk_buff *new_skb;
 
@@ -595,11 +605,10 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		} else
 			info->skb = NULL;
 
-		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
-
 		info->dma = 0;
 
-		skb_put(skb, len);
+		/* Don't include CRC */
+		skb_put(skb, len-4);
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -614,6 +623,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
 
+next:
 		RX_RING(mac, n) = 0;
 		RX_RING(mac, n+1) = 0;
 
@@ -1126,7 +1136,7 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	int i, nfrags;
 
-	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
+	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_CRC_PAD;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const unsigned char *nh = skb_network_header(skb);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 30adf72..a579111 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1456,16 +1456,11 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 			   PHYAddr[qdev->mac_index]);
 	reg &= ~PHY_GIG_ALL_PARAMS;
 
-	if(portConfiguration &
-	   PORT_CONFIG_FULL_DUPLEX_ENABLED &
-	   PORT_CONFIG_1000MB_SPEED) {
-		reg |= PHY_GIG_ADV_1000F;
-	}
-
-	if(portConfiguration &
-	   PORT_CONFIG_HALF_DUPLEX_ENABLED &
-	   PORT_CONFIG_1000MB_SPEED) {
-		reg |= PHY_GIG_ADV_1000H;
+	if(portConfiguration & PORT_CONFIG_1000MB_SPEED) {
+		if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) 
+			reg |= PHY_GIG_ADV_1000F;
+		else 
+			reg |= PHY_GIG_ADV_1000H;
 	}
 
 	ql_mii_write_reg_ex(qdev, PHY_GIG_CONTROL, reg,
@@ -1645,8 +1640,11 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 	return 0;
 }
 
-static void ql_link_state_machine(struct ql3_adapter *qdev)
+static void ql_link_state_machine_work(struct work_struct *work)
 {
+	struct ql3_adapter *qdev =
+		container_of(work, struct ql3_adapter, link_state_work.work);
+
 	u32 curr_link_state;
 	unsigned long hw_flags;
 
@@ -1661,6 +1659,10 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 			       "state.\n", qdev->ndev->name);
 
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
+		/* Restart timer on 2 second interval. */
+		mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);\
+
 		return;
 	}
 
@@ -1705,6 +1707,9 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 		break;
 	}
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
+
+	/* Restart timer on 2 second interval. */
+	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 }
 
 /*
@@ -3941,19 +3946,7 @@ static void ql_get_board_info(struct ql3_adapter *qdev)
 static void ql3xxx_timer(unsigned long ptr)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)ptr;
-
-	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
-		printk(KERN_DEBUG PFX
-		       "%s: Reset in progress.\n",
-		       qdev->ndev->name);
-		goto end;
-	}
-
-	ql_link_state_machine(qdev);
-
-	/* Restart timer on 2 second interval. */
-end:
-	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
+	queue_delayed_work(qdev->workqueue, &qdev->link_state_work, 0);
 }
 
 static int __devinit ql3xxx_probe(struct pci_dev *pdev,
@@ -4103,6 +4096,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	qdev->workqueue = create_singlethread_workqueue(ndev->name);
 	INIT_DELAYED_WORK(&qdev->reset_work, ql_reset_work);
 	INIT_DELAYED_WORK(&qdev->tx_timeout_work, ql_tx_timeout_work);
+	INIT_DELAYED_WORK(&qdev->link_state_work, ql_link_state_machine_work);
 
 	init_timer(&qdev->adapter_timer);
 	qdev->adapter_timer.function = ql3xxx_timer;
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index fbcb0b9..d0ffb30 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1286,6 +1286,7 @@ struct ql3_adapter {
 	struct workqueue_struct *workqueue;
 	struct delayed_work reset_work;
 	struct delayed_work tx_timeout_work;
+	struct delayed_work link_state_work;
 	u32 max_frame_size;
 	u32 device_id;
 	u16 phyType;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b94fa7e..1f647b9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -171,6 +171,8 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
+	{ 0x0001,				0x8168,
+		PCI_ANY_ID, 0x2410, 0, 0, RTL_CFG_2 },
 	{0,},
 };
 
@@ -468,7 +470,7 @@ static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
 
-	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0xFF) << 16 | value);
+	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -485,7 +487,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 {
 	int i, value = -1;
 
-	RTL_W32(PHYAR, 0x0 | (reg_addr & 0xFF) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -493,7 +495,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 		 * the specified MII register.
 		 */
 		if (RTL_R32(PHYAR) & 0x80000000) {
-			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
+			value = RTL_R32(PHYAR) & 0xffff;
 			break;
 		}
 		udelay(25);
@@ -1245,16 +1247,6 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
-static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
-{
-	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
-		{ 0x10, 0xf41b },
-		{ 0x1f, 0x0000 }
-	};
-
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
-}
 
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 {
@@ -1324,11 +1316,6 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
-	case RTL_GIGA_MAC_VER_11:
-	case RTL_GIGA_MAC_VER_12:
-	case RTL_GIGA_MAC_VER_17:
-		rtl8168b_hw_phy_config(ioaddr);
-		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
@@ -1739,7 +1726,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if (RTL_R8(PHYstatus) & TBI_Enable) {
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index c27c7d6..a2070db 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -52,7 +52,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.19"
+#define DRV_VERSION		"1.20"
 #define PFX			DRV_NAME " "
 
 /*
@@ -121,6 +121,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4353) }, /* 88E8039 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4354) }, /* 88E8040 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4356) }, /* 88EC033 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4357) }, /* 88E8042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x435A) }, /* 88E8048 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4360) }, /* 88E8052 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
@@ -134,6 +135,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436C) }, /* 88E8072 */
 	{ 0 }
 };
 
@@ -156,7 +158,7 @@ static const char *yukon2_name[] = {
 
 static void sky2_set_multicast(struct net_device *dev);
 
-/* Access to external PHY */
+/* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
 	int i;
@@ -166,13 +168,22 @@ static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 		    GM_SMI_CT_PHY_AD(PHY_ADDR_MARV) | GM_SMI_CT_REG_AD(reg));
 
 	for (i = 0; i < PHY_RETRIES; i++) {
-		if (!(gma_read16(hw, port, GM_SMI_CTRL) & GM_SMI_CT_BUSY))
+		u16 ctrl = gma_read16(hw, port, GM_SMI_CTRL);
+		if (ctrl == 0xffff)
+			goto io_error;
+
+		if (!(ctrl & GM_SMI_CT_BUSY))
 			return 0;
-		udelay(1);
+
+		udelay(10);
 	}
 
-	printk(KERN_WARNING PFX "%s: phy write timeout\n", hw->dev[port]->name);
+	dev_warn(&hw->pdev->dev,"%s: phy write timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
+
+io_error:
+	dev_err(&hw->pdev->dev, "%s: phy I/O error\n", hw->dev[port]->name);
+	return -EIO;
 }
 
 static int __gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg, u16 *val)
@@ -183,23 +194,29 @@ static int __gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg, u16 *val)
 		    | GM_SMI_CT_REG_AD(reg) | GM_SMI_CT_OP_RD);
 
 	for (i = 0; i < PHY_RETRIES; i++) {
-		if (gma_read16(hw, port, GM_SMI_CTRL) & GM_SMI_CT_RD_VAL) {
+		u16 ctrl = gma_read16(hw, port, GM_SMI_CTRL);
+		if (ctrl == 0xffff)
+			goto io_error;
+
+		if (ctrl & GM_SMI_CT_RD_VAL) {
 			*val = gma_read16(hw, port, GM_SMI_DATA);
 			return 0;
 		}
 
-		udelay(1);
+		udelay(10);
 	}
 
+	dev_warn(&hw->pdev->dev, "%s: phy read timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
+io_error:
+	dev_err(&hw->pdev->dev, "%s: phy I/O error\n", hw->dev[port]->name);
+	return -EIO;
 }
 
-static u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
+static inline u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
 {
 	u16 v;
-
-	if (__gm_phy_read(hw, port, reg, &v) != 0)
-		printk(KERN_WARNING PFX "%s: phy read timeout\n", hw->dev[port]->name);
+	__gm_phy_read(hw, port, reg, &v);
 	return v;
 }
 
@@ -273,8 +290,6 @@ static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
 
 	/* disable all GMAC IRQ's */
 	sky2_write8(hw, SK_REG(port, GMAC_IRQ_MSK), 0);
-	/* disable PHY IRQs */
-	gm_phy_write(hw, port, PHY_MARV_INT_MASK, 0);
 
 	gma_write16(hw, port, GM_MC_ADDR_H1, 0);	/* clear MC hash */
 	gma_write16(hw, port, GM_MC_ADDR_H2, 0);
@@ -1805,29 +1820,6 @@ static void sky2_link_up(struct sky2_port *sky2)
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (hw->flags & SKY2_HW_NEWER_PHY) {
-		u16 pg = gm_phy_read(hw, port, PHY_MARV_EXT_ADR);
-		u16 led = PHY_M_LEDC_LOS_CTRL(1);	/* link active */
-
-		switch(sky2->speed) {
-		case SPEED_10:
-			led |= PHY_M_LEDC_INIT_CTRL(7);
-			break;
-
-		case SPEED_100:
-			led |= PHY_M_LEDC_STA1_CTRL(7);
-			break;
-
-		case SPEED_1000:
-			led |= PHY_M_LEDC_STA0_CTRL(7);
-			break;
-		}
-
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 3);
-		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, led);
-		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);
-	}
-
 	if (netif_msg_link(sky2))
 		printk(KERN_INFO PFX
 		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",
@@ -2247,20 +2239,26 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 	do {
 		struct sky2_port *sky2;
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
-		unsigned port = le->css & CSS_LINK_BIT;
+		unsigned port;
 		struct net_device *dev;
 		struct sk_buff *skb;
 		u32 status;
 		u16 length;
+		u8 opcode = le->opcode;
+
+		if (!(opcode & HW_OWNER))
+			break;
 
 		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
 
+		port = le->css & CSS_LINK_BIT;
 		dev = hw->dev[port];
 		sky2 = netdev_priv(dev);
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);
 
-		switch (le->opcode & ~HW_OWNER) {
+		le->opcode = 0;
+		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
 			++rx[port];
 			skb = sky2_receive(dev, length, status);
@@ -2353,7 +2351,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 		default:
 			if (net_ratelimit())
 				printk(KERN_WARNING PFX
-				       "unknown status opcode 0x%x\n", le->opcode);
+				       "unknown status opcode 0x%x\n", opcode);
 		}
 	} while (hw->st_idx != idx);
 
@@ -2439,13 +2437,26 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
-		int pos = pci_find_aer_capability(hw->pdev);
+		int aer = pci_find_aer_capability(hw->pdev);
 		u32 err;
 
-		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_STATUS, &err);
+		if (aer) {
+			pci_read_config_dword(pdev, aer + PCI_ERR_UNCOR_STATUS,
+					      &err);
+			pci_cleanup_aer_uncorrect_error_status(pdev);
+		} else {
+			/* Either AER not configured, or not working
+			 * because of bad MMCONFIG, so just do recover
+			 * manually.
+			 */
+			err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+				     0xfffffffful);
+		}
+
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
-		pci_cleanup_aer_uncorrect_error_status(pdev);
+
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2791,6 +2802,9 @@ static void sky2_reset(struct sky2_hw *hw)
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
+	/* allow writes to PCI config */
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+
 	/* clear PCI errors, if any */
 	pci_read_config_word(pdev, PCI_STATUS, &status);
 	status |= PCI_STATUS_ERROR_BITS;
@@ -2800,9 +2814,18 @@ static void sky2_reset(struct sky2_hw *hw)
 
 	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (cap) {
-		/* Check for advanced error reporting */
-		pci_cleanup_aer_uncorrect_error_status(pdev);
-		pci_cleanup_aer_correct_error_status(pdev);
+		if (pci_find_aer_capability(pdev)) {
+			/* Check for advanced error reporting */
+			pci_cleanup_aer_uncorrect_error_status(pdev);
+			pci_cleanup_aer_correct_error_status(pdev);
+		} else {
+			dev_warn(&pdev->dev,
+				"PCI Express Advanced Error Reporting"
+				" not configured or MMCONFIG problem?\n");
+
+			sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
+				     0xfffffffful);
+		}
 
 		/* If error bit is stuck on ignore it */
 		if (sky2_read32(hw, B0_HWE_ISRC) & Y2_IS_PCI_EXP)
@@ -3974,7 +3997,8 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	dev->tx_timeout = sky2_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = sky2_netpoll;
+	if (port == 0)
+		dev->poll_controller = sky2_netpoll;
 #endif
 
 	sky2 = netdev_priv(dev);
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 49ee264..69525fd 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -247,7 +247,8 @@ enum csr_regs {
 	B3_PA_CTRL	= 0x01f0,
 	B3_PA_TEST	= 0x01f2,
 
-	Y2_CFG_SPC	= 0x1c00,
+	Y2_CFG_SPC	= 0x1c00,	/* PCI config space region */
+	Y2_CFG_AER      = 0x1d00,	/* PCI Advanced Error Report region */
 };
 
 /*	B0_CTST			16 bit	Control/Status register */
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 729fd28..db34e1e 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -224,6 +224,21 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 	}
 }
 
+#elif defined(CONFIG_MACH_ZYLONITE)
+
+#define SMC_CAN_USE_8BIT        1
+#define SMC_CAN_USE_16BIT       1
+#define SMC_CAN_USE_32BIT       0
+#define SMC_IO_SHIFT            0
+#define SMC_NOWAIT              1
+#define SMC_USE_PXA_DMA		1
+#define SMC_inb(a, r)           readb((a) + (r))
+#define SMC_inw(a, r)           readw((a) + (r))
+#define SMC_insw(a, r, p, l)    insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)   outsw((a) + (r), p, l)
+#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)       writew(v, (a) + (r))
+
 #elif	defined(CONFIG_ARCH_OMAP)
 
 /* We can only do 16-bit reads and writes in the static memory space. */
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index dae5c8d..2b733c5 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -325,7 +325,7 @@ config HERMES
 	  Cabletron/EnteraSys Roamabout, ELSA AirLancer, MELCO Buffalo, Avaya,
 	  IBM High Rate Wireless, Farralon Syyline, Samsung MagicLAN, Netgear
 	  MA401, LinkSys WPC-11, D-Link DWL-650, 3Com AirConnect, Intel
-	  PRO/Wireless, and Symbol Spectrum24 High Rate amongst others.
+	  IPW2011, and Symbol Spectrum24 High Rate amongst others.
 
 	  This option includes the guts of the driver, but in order to
 	  actually use a card you will also need to enable support for PCMCIA
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kconfig
index e3c573e..fdbc351 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -61,16 +61,18 @@ config B43_PCMCIA
 
 	  If unsure, say N.
 
-# LED support
+# This config option automatically enables b43 LEDS support,
+# if it's possible.
 config B43_LEDS
 	bool
-	depends on B43 && MAC80211_LEDS
+	depends on B43 && MAC80211_LEDS && (LEDS_CLASS = y || LEDS_CLASS = B43)
 	default y
 
-# RFKILL support
+# This config option automatically enables b43 RFKILL support,
+# if it's possible.
 config B43_RFKILL
 	bool
-	depends on B43 && RFKILL && RFKILL_INPUT && INPUT_POLLDEV
+	depends on B43 && (RFKILL = y || RFKILL = B43) && RFKILL_INPUT && (INPUT_POLLDEV = y || INPUT_POLLDEV = B43)
 	default y
 
 config B43_DEBUG
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 734e70e..ef0075d 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -128,7 +128,7 @@ static ssize_t shm_read_file(struct b43_wldev *dev,
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43_shm_read16(dev, B43_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 5058e60..2b17c1d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2985,6 +2985,16 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	if (b43_status(dev) < B43_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
+	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43_synchronize_irq(dev);
+
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2995,13 +3005,6 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw);	//FIXME this could cause a deadlock, as mac80211 seems buggy.
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
-	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43_synchronize_irq(dev);
-
 	b43_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43dbg(wl, "Wireless interface stopped\n");
@@ -3661,7 +3664,6 @@ static int b43_setup_modes(struct b43_wldev *dev,
 
 static void b43_wireless_core_detach(struct b43_wldev *dev)
 {
-	b43_rfkill_free(dev);
 	/* We release firmware that late to not be required to re-request
 	 * is all the time when we reinit the core. */
 	b43_release_firmware(dev);
@@ -3747,7 +3749,6 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 	if (!wl->current_dev)
 		wl->current_dev = dev;
 	INIT_WORK(&dev->restart_work, b43_chip_reset);
-	b43_rfkill_alloc(dev);
 
 	b43_radio_turn_off(dev, 1);
 	b43_switch_analog(dev, 0);
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index b242a9a..b79a6bd 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -65,12 +65,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	tuple_t tuple;
 	cisparse_t parse;
 	int err = -ENOMEM;
-	int res;
+	int res = 0;
 	unsigned char buf[64];
 
 	ssb = kzalloc(sizeof(*ssb), GFP_KERNEL);
 	if (!ssb)
-		goto out;
+		goto out_error;
 
 	err = -ENODEV;
 	tuple.DesiredTuple = CISTPL_CONFIG;
@@ -96,10 +96,12 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	dev->io.NumPorts2 = 0;
 	dev->io.Attributes2 = 0;
 
-	win.Attributes = WIN_MEMORY_TYPE_CM | WIN_ENABLE | WIN_USE_WAIT;
+	win.Attributes = WIN_ADDR_SPACE_MEM | WIN_MEMORY_TYPE_CM |
+			 WIN_ENABLE | WIN_DATA_WIDTH_16 |
+			 WIN_USE_WAIT;
 	win.Base = 0;
 	win.Size = SSB_CORE_SIZE;
-	win.AccessSpeed = 1000;
+	win.AccessSpeed = 250;
 	res = pcmcia_request_window(&dev, &win, &dev->win);
 	if (res != CS_SUCCESS)
 		goto err_kfree_ssb;
@@ -108,21 +110,34 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	mem.Page = 0;
 	res = pcmcia_map_mem_page(dev->win, &mem);
 	if (res != CS_SUCCESS)
-		goto err_kfree_ssb;
+		goto err_disable;
+
+	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FIRST_SHARED;
+	dev->irq.IRQInfo1 = IRQ_LEVEL_ID | IRQ_SHARE_ID;
+	dev->irq.Handler = NULL; /* The handler is registered later. */
+	dev->irq.Instance = NULL;
+	res = pcmcia_request_irq(dev, &dev->irq);
+	if (res != CS_SUCCESS)
+		goto err_disable;
 
 	res = pcmcia_request_configuration(dev, &dev->conf);
 	if (res != CS_SUCCESS)
 		goto err_disable;
 
 	err = ssb_bus_pcmciabus_register(ssb, dev, win.Base);
+	if (err)
+		goto err_disable;
 	dev->priv = ssb;
 
-      out:
-	return err;
-      err_disable:
+	return 0;
+
+err_disable:
 	pcmcia_disable_device(dev);
-      err_kfree_ssb:
+err_kfree_ssb:
 	kfree(ssb);
+out_error:
+	printk(KERN_ERR "b43-pcmcia: Initialization failed (%d, %d)\n",
+	       res, err);
 	return err;
 }
 
@@ -131,22 +146,21 @@ static void __devexit b43_pcmcia_remove(struct pcmcia_device *dev)
 	struct ssb_bus *ssb = dev->priv;
 
 	ssb_bus_unregister(ssb);
-	pcmcia_release_window(dev->win);
 	pcmcia_disable_device(dev);
 	kfree(ssb);
 	dev->priv = NULL;
 }
 
 static struct pcmcia_driver b43_pcmcia_driver = {
-	.owner = THIS_MODULE,
-	.drv = {
-		.name = "b43-pcmcia",
-		},
-	.id_table = b43_pcmcia_tbl,
-	.probe = b43_pcmcia_probe,
-	.remove = b43_pcmcia_remove,
-	.suspend = b43_pcmcia_suspend,
-	.resume = b43_pcmcia_resume,
+	.owner		= THIS_MODULE,
+	.drv		= {
+				.name = "b43-pcmcia",
+			},
+	.id_table	= b43_pcmcia_tbl,
+	.probe		= b43_pcmcia_probe,
+	.remove		= __devexit_p(b43_pcmcia_remove),
+	.suspend	= b43_pcmcia_suspend,
+	.resume		= b43_pcmcia_resume,
 };
 
 int b43_pcmcia_init(void)
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 800e0a6..9b1f905 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -47,32 +47,35 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	struct b43_wldev *dev = poll_dev->private;
 	struct b43_wl *wl = dev->wl;
 	bool enabled;
+	bool report_change = 0;
 
 	mutex_lock(&wl->mutex);
 	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	enabled = b43_is_hw_radio_enabled(dev);
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
+		report_change = 1;
 		b43info(wl, "Radio hardware status changed to %s\n",
 			enabled ? "ENABLED" : "DISABLED");
-		mutex_unlock(&wl->mutex);
+	}
+	mutex_unlock(&wl->mutex);
+
+	if (unlikely(report_change))
 		input_report_key(poll_dev->input, KEY_WLAN, enabled);
-	} else
-		mutex_unlock(&wl->mutex);
 }
 
-/* Called when the RFKILL toggled in software.
- * This is called without locking. */
+/* Called when the RFKILL toggled in software. */
 static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 {
 	struct b43_wldev *dev = data;
 	struct b43_wl *wl = dev->wl;
 	int err = 0;
 
-	mutex_lock(&wl->mutex);
-	if (b43_status(dev) < B43_STAT_INITIALIZED)
-		goto out_unlock;
+	if (!wl->rfkill.registered)
+		return 0;
 
+	mutex_lock(&wl->mutex);
+	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	switch (state) {
 	case RFKILL_STATE_ON:
 		if (!dev->radio_hw_enable) {
@@ -89,7 +92,6 @@ static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 			b43_radio_turn_off(dev, 0);
 		break;
 	}
-
 out_unlock:
 	mutex_unlock(&wl->mutex);
 
@@ -98,11 +100,11 @@ out_unlock:
 
 char * b43_rfkill_led_name(struct b43_wldev *dev)
 {
-	struct b43_wl *wl = dev->wl;
+	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
-	if (!wl->rfkill.rfkill)
+	if (!rfk->registered)
 		return NULL;
-	return rfkill_get_led_name(wl->rfkill.rfkill);
+	return rfkill_get_led_name(rfk->rfkill);
 }
 
 void b43_rfkill_init(struct b43_wldev *dev)
@@ -111,53 +113,13 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	struct b43_rfkill *rfk = &(wl->rfkill);
 	int err;
 
-	if (rfk->rfkill) {
-		err = rfkill_register(rfk->rfkill);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill button\n");
-			goto err_free_rfk;
-		}
-	}
-	if (rfk->poll_dev) {
-		err = input_register_polled_device(rfk->poll_dev);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill polldev\n");
-			goto err_free_polldev;
-		}
-	}
-
-	return;
-err_free_rfk:
-	rfkill_free(rfk->rfkill);
-	rfk->rfkill = NULL;
-err_free_polldev:
-	input_free_polled_device(rfk->poll_dev);
-	rfk->poll_dev = NULL;
-}
-
-void b43_rfkill_exit(struct b43_wldev *dev)
-{
-	struct b43_rfkill *rfk = &(dev->wl->rfkill);
-
-	if (rfk->poll_dev)
-		input_unregister_polled_device(rfk->poll_dev);
-	if (rfk->rfkill)
-		rfkill_unregister(rfk->rfkill);
-}
-
-void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-	struct b43_wl *wl = dev->wl;
-	struct b43_rfkill *rfk = &(wl->rfkill);
+	rfk->registered = 0;
 
+	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
+	if (!rfk->rfkill)
+		goto out_error;
 	snprintf(rfk->name, sizeof(rfk->name),
 		 "b43-%s", wiphy_name(wl->hw->wiphy));
-
-	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
-	if (!rfk->rfkill) {
-		b43warn(wl, "Failed to allocate RF-kill button\n");
-		return;
-	}
 	rfk->rfkill->name = rfk->name;
 	rfk->rfkill->state = RFKILL_STATE_ON;
 	rfk->rfkill->data = dev;
@@ -165,18 +127,45 @@ void b43_rfkill_alloc(struct b43_wldev *dev)
 	rfk->rfkill->user_claim_unsupported = 1;
 
 	rfk->poll_dev = input_allocate_polled_device();
-	if (rfk->poll_dev) {
-		rfk->poll_dev->private = dev;
-		rfk->poll_dev->poll = b43_rfkill_poll;
-		rfk->poll_dev->poll_interval = 1000; /* msecs */
-	} else
-		b43warn(wl, "Failed to allocate RF-kill polldev\n");
+	if (!rfk->poll_dev)
+		goto err_free_rfk;
+	rfk->poll_dev->private = dev;
+	rfk->poll_dev->poll = b43_rfkill_poll;
+	rfk->poll_dev->poll_interval = 1000; /* msecs */
+
+	err = rfkill_register(rfk->rfkill);
+	if (err)
+		goto err_free_polldev;
+	err = input_register_polled_device(rfk->poll_dev);
+	if (err)
+		goto err_unreg_rfk;
+
+	rfk->registered = 1;
+
+	return;
+err_unreg_rfk:
+	rfkill_unregister(rfk->rfkill);
+err_free_polldev:
+	input_free_polled_device(rfk->poll_dev);
+	rfk->poll_dev = NULL;
+err_free_rfk:
+	rfkill_free(rfk->rfkill);
+	rfk->rfkill = NULL;
+out_error:
+	rfk->registered = 0;
+	b43warn(wl, "RF-kill button init failed\n");
 }
 
-void b43_rfkill_free(struct b43_wldev *dev)
+void b43_rfkill_exit(struct b43_wldev *dev)
 {
 	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
+	if (!rfk->registered)
+		return;
+	rfk->registered = 0;
+
+	input_unregister_polled_device(rfk->poll_dev);
+	rfkill_unregister(rfk->rfkill);
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
 	rfkill_free(rfk->rfkill);
diff --git a/drivers/net/wireless/b43/rfkill.h b/drivers/net/wireless/b43/rfkill.h
index 29544e8..adacf93 100644
--- a/drivers/net/wireless/b43/rfkill.h
+++ b/drivers/net/wireless/b43/rfkill.h
@@ -15,14 +15,14 @@ struct b43_rfkill {
 	struct rfkill *rfkill;
 	/* The poll device for the RFKILL input button */
 	struct input_polled_dev *poll_dev;
+	/* Did initialization succeed? Used for freeing. */
+	bool registered;
 	/* The unique name of this rfkill switch */
-	char name[32];
+	char name[sizeof("b43-phy4294967295")];
 };
 
-/* All the init functions return void, because we are not interested
+/* The init function returns void, because we are not interested
  * in failing the b43 init process when rfkill init failed. */
-void b43_rfkill_alloc(struct b43_wldev *dev);
-void b43_rfkill_free(struct b43_wldev *dev);
 void b43_rfkill_init(struct b43_wldev *dev);
 void b43_rfkill_exit(struct b43_wldev *dev);
 
@@ -36,12 +36,6 @@ struct b43_rfkill {
 	/* empty */
 };
 
-static inline void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-}
-static inline void b43_rfkill_free(struct b43_wldev *dev)
-{
-}
 static inline void b43_rfkill_init(struct b43_wldev *dev)
 {
 }
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index eefa6fb..619b453 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -124,7 +124,7 @@ static ssize_t shm_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufs
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43legacy_shm_read16(dev, B43legacy_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index f0e56df..3bde1e9 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2781,6 +2781,17 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	if (b43legacy_status(dev) < B43legacy_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
+							  B43legacy_IRQ_ALL);
+	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43legacy_synchronize_irq(dev);
+
 	b43legacy_set_status(dev, B43legacy_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2791,14 +2802,6 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw); /* FIXME this could cause a deadlock */
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
-							  B43legacy_IRQ_ALL);
-	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43legacy_synchronize_irq(dev);
-
 	b43legacy_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43legacydbg(wl, "Wireless interface stopped\n");
@@ -3332,7 +3335,7 @@ out_mutex_unlock:
 	return err;
 }
 
-void b43legacy_stop(struct ieee80211_hw *hw)
+static void b43legacy_stop(struct ieee80211_hw *hw)
 {
 	struct b43legacy_wl *wl = hw_to_b43legacy_wl(hw);
 	struct b43legacy_wldev *dev = wl->current_dev;
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 7da3664..fc876ba 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -444,7 +444,7 @@ static int prism2_pci_resume(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, prism2_pci_id_table);
 
-static struct pci_driver prism2_pci_drv_id = {
+static struct pci_driver prism2_pci_driver = {
 	.name		= "hostap_pci",
 	.id_table	= prism2_pci_id_table,
 	.probe		= prism2_pci_probe,
@@ -458,13 +458,13 @@ static struct pci_driver prism2_pci_drv_id = {
 
 static int __init init_prism2_pci(void)
 {
-	return pci_register_driver(&prism2_pci_drv_id);
+	return pci_register_driver(&prism2_pci_driver);
 }
 
 
 static void __exit exit_prism2_pci(void)
 {
-	pci_unregister_driver(&prism2_pci_drv_id);
+	pci_unregister_driver(&prism2_pci_driver);
 }
 
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 8d53d08..fc6cdd8 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1267,7 +1267,7 @@ static int ipw2100_start_adapter(struct ipw2100_priv *priv)
 				       IPW2100_INTA_FATAL_ERROR |
 				       IPW2100_INTA_PARITY_ERROR);
 		}
-	} while (i--);
+	} while (--i);
 
 	/* Clear out any pending INTAs since we aren't supposed to have
 	 * interrupts enabled at this point... */
@@ -1339,7 +1339,7 @@ static int ipw2100_power_cycle_adapter(struct ipw2100_priv *priv)
 
 		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
 			break;
-	} while (i--);
+	} while (--i);
 
 	priv->status &= ~STATUS_RESET_PENDING;
 
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 1cbbd96..be5cfd8 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -912,6 +912,10 @@ static int wlan_cmd_set_boot2_ver(wlan_private * priv,
 	return 0;
 }
 
+/*
+ * Note: NEVER use libertas_queue_cmd() with addtail==0 other than for
+ * the command timer, because it does not account for queued commands.
+ */
 void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u8 addtail)
 {
 	unsigned long flags;
@@ -941,10 +945,11 @@ void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u
 
 	spin_lock_irqsave(&adapter->driver_lock, flags);
 
-	if (addtail)
+	if (addtail) {
 		list_add_tail((struct list_head *)cmdnode,
 			      &adapter->cmdpendingq);
-	else
+		adapter->nr_cmd_pending++;
+	} else
 		list_add((struct list_head *)cmdnode, &adapter->cmdpendingq);
 
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
@@ -1412,7 +1417,6 @@ int libertas_prepare_and_send_command(wlan_private * priv,
 	cmdnode->cmdwaitqwoken = 0;
 
 	libertas_queue_cmd(adapter, cmdnode, 1);
-	adapter->nr_cmd_pending++;
 	wake_up_interruptible(&priv->waitq);
 
 	if (wait_option & CMD_OPTION_WAITFORRSP) {
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 0360cad..ec89dab 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -148,11 +148,11 @@ static int if_cs_poll_while_fw_download(struct if_cs_card *card, uint addr, u8 r
 {
 	int i;
 
-	for (i = 0; i < 500; i++) {
+	for (i = 0; i < 1000; i++) {
 		u8 val = if_cs_read8(card, addr);
 		if (val == reg)
 			return i;
-		udelay(100);
+		udelay(500);
 	}
 	return -ETIME;
 }
@@ -878,6 +878,9 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
 		goto out3;
 	}
 
+	/* Clear any interrupt cause that happend while sending
+	 * firmware/initializing card */
+	if_cs_write16(card, IF_CS_C_INT_CAUSE, IF_CS_C_IC_MASK);
 	if_cs_enable_ints(card);
 
 	/* And finally bring the card up */
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index a8e1707..b24425f 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -182,12 +182,14 @@ static int if_sdio_handle_data(struct if_sdio_card *card,
 		goto out;
 	}
 
-	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
+	skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		ret = -ENOMEM;
 		goto out;
 	}
 
+	skb_reserve(skb, NET_IP_ALIGN);
+
 	data = skb_put(skb, size);
 
 	memcpy(data, buffer, size);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 4a6a0bd..85ea8a8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -196,6 +196,14 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct interface *intf = &rt2x00dev->interface;
 
+	/* FIXME: Beaconing is broken in rt2x00. */
+	if (conf->type == IEEE80211_IF_TYPE_IBSS ||
+	    conf->type == IEEE80211_IF_TYPE_AP) {
+		ERROR(rt2x00dev,
+		      "rt2x00 does not support Adhoc or Master mode");
+		return -EOPNOTSUPP;
+	}
+
 	/*
 	 * Don't allow interfaces to be added while
 	 * either the device has disappeared or when
