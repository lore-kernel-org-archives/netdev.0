From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 00/39] net_device.{base_addr, irq} removal update
Date: Fri,  6 Apr 2012 12:06:14 +0200
Message-ID: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Chris Snook <chris.snook@gmail.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Lv <DavidLv@viatech.com.cn>,
	Grant Grundler <grantgrundler@gmail.com>,
	Ion Badulescu <ionut@badula.org>,
	Jay Cliburn <jcliburn@gmail.com>, Jon Mason <jdmason@kudzu.us>,
	Jon Mason <mason@myri.com>, Michael Chan <mchan@broadcom.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Tim Hockin <thockin@hockin.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43508 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932082Ab2DFKKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The branch 'davem-next.base_addr.removal' is available in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.base_addr.removal

with the changes below.

Changes since #1 (2012/03/15)

- display the PCI resource address in the bnx2 driver as suggested by
  Michael Chan. It is done as well where things have been moved to mapped
  addresses, namely sc92031, epic100 and rrunner. I have not done it where
  net_device.base_addr already contained a mapped address.

- convert drivers to io{read/write} in place of inl/out #define. Minimal
  comments keep trace of the nature of the committed PCI bar range when it
  gets remapped. It applies to dl2k, dmfe, epic100, uli526x, xircom_cb

- reworked the chip dependent uli526x phy operations to minimize conditional
  registers offsets and parameters. void (__iomem) * are too easy to abuse.

- added myri10ge, rrunner, ipw2100, ipw2200

Patches previously acked by Grant Grundler have been modified by ioread and
iowrite changes. A compressed diff from the former version of the relevant
files is included below. I have moved version #1 of the branch to
davem-next.base_addr.removal-20120315 for those who want to diff themselves.
If there are no further changes, I'll rebase and send a single pull request
for the series including Grant's Acked-by once he says it is ok.

Distance from 'davem-next' (73a0d907301ece200d32b4e8ba2da2ca296b507f)
---------------------------------------------------------------------

6165c337223fb787abc2dfc1f8c5605ec3ba9950
a37b4503ec92e71e5bba6f64ffd2b524deab1b84
3865105f32477233bcbaec6d335bd1ea261b6ef9
61deffedec0c150a7c09085ca91146d881a3e48e
a5a6d0922ea55d7c8e7792633135e8cb94ccd1c2
ece290b1c52d06f3e336eb2677a7f374b1ec8036
83b453d5ea2df18d0af1a760e458c5b649415bfd
6b7afbabfb5dc03aca2fea47cae8db27239bb589
0a3928f4342bab3bf0b2eb63fe71cecace548e99
3fb93f6502cb93284bc6e6eec6ffb36456cef37a
31158379894d7abc5a76f282130dff7402a071b8
d13055fe45a281c97ec85454ca8e1c2bc9932166
722b2708e6b621a33fe8f778ea35e1f0ddb4636a
3cebeb3c55c12a033d30603baf34d449df75d2c1
d8cb2b1097a9c64778dc1ab9bb33bcf5bf62bfc7
271dcd170006b9d55eb555b2e79e22c1fa86e0a0
5a61e7c690fce53cd37eddc9808134bc0e6b9837
f1d8b45bae9746b74531bb9c5eacc022183df6e3
43487f61a41077ec5cf8587248eb502f5d9be785
d97db1700b0c2498bd0a80fd7dee03a8c38dcf5e
2f236cba12a738e3ba82bf49e43047013d1f913e
61119e9efbb8710948a1d88147c10090af0b42ae
3958bafae0bfb262eda364adebf21aebb25af69a
d4f8c16cc10a675dcdc3973be8d9bd722d90aa0a
923387c00c92b368ae7906952817cbd1d014fe4c
671aa01c99a80822e918777b86f4b18b83fd999d
c7e9d5247826d4d38802a4c01e96299ec883436b
6a332e692c558b86ffcb124c5b3a269de66b5e37
887dbdbee66f11ad4c1ba842e89b284ccf50da70
7db239c57d31d1d3fdc73e22b27ed9c46fc1da65
5a6c96842f5ca982949538ce74a9d687c684707e
c0defd6f6abf4b10dee5c9ea29bcd8581d99e3fd
59190a37ba3016b2bcfcdc901b921fb2ced718e5
5dba46ed9674eae504c8545ed06f9122c04d543d
7b9e3259ac12529c5780881ffd18497450bea20c
b581457262a49dac7f66edf3fcbb6aa9e728b59b
6b8e6e7dc86a9103970db98c0b9cb44e5640c2fc
7d49f20cb9a3bc4328e68a159692648e364341c8
560cb3215c2055fc4f79fef91ed7c9e337785d25

Diffstat
--------

 drivers/net/ethernet/adaptec/starfire.c          |   54 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c  |    5 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c  |   17 +-
 drivers/net/ethernet/broadcom/bnx2.c             |   41 +--
 drivers/net/ethernet/dec/tulip/de2104x.c         |   34 +-
 drivers/net/ethernet/dec/tulip/dmfe.c            |  295 ++++++++-------
 drivers/net/ethernet/dec/tulip/tulip_core.c      |   27 +-
 drivers/net/ethernet/dec/tulip/uli526x.c         |  443 +++++++++++-----------
 drivers/net/ethernet/dec/tulip/winbond-840.c     |   17 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c       |  280 ++++++++------
 drivers/net/ethernet/dlink/dl2k.c                |  416 ++++++++++----------
 drivers/net/ethernet/dlink/dl2k.h                |   19 +-
 drivers/net/ethernet/dlink/sundance.c            |   12 +-
 drivers/net/ethernet/fealnx.c                    |   17 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    7 +-
 drivers/net/ethernet/natsemi/natsemi.c           |   67 ++--
 drivers/net/ethernet/neterion/s2io.c             |   14 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c   |   18 +-
 drivers/net/ethernet/nvidia/forcedeth.c          |    5 -
 drivers/net/ethernet/packetengines/hamachi.c     |   11 +-
 drivers/net/ethernet/packetengines/yellowfin.c   |   32 +-
 drivers/net/ethernet/realtek/8139cp.c            |   21 +-
 drivers/net/ethernet/realtek/8139too.c           |  136 +++----
 drivers/net/ethernet/silan/sc92031.c             |   34 +--
 drivers/net/ethernet/sis/sis190.c                |   26 +-
 drivers/net/ethernet/sis/sis900.c                |  375 ++++++++++---------
 drivers/net/ethernet/smsc/epic100.c              |  403 ++++++++++----------
 drivers/net/ethernet/smsc/smsc9420.c             |   48 ++--
 drivers/net/ethernet/sun/sungem.c                |    2 -
 drivers/net/ethernet/sun/sunhme.c                |   20 +-
 drivers/net/ethernet/sun/sunhme.h                |    1 +
 drivers/net/ethernet/tehuti/tehuti.c             |    4 -
 drivers/net/ethernet/via/via-rhine.c             |   12 +-
 drivers/net/ethernet/via/via-velocity.c          |    9 +-
 drivers/net/hippi/rrunner.c                      |   82 ++---
 drivers/net/wireless/ipw2x00/ipw2100.c           |  131 +++----
 drivers/net/wireless/ipw2x00/ipw2100.h           |    1 +
 drivers/net/wireless/ipw2x00/ipw2200.c           |    4 -
 38 files changed, 1527 insertions(+), 1613 deletions(-)

Shortlog
--------

Francois Romieu (39):
      sungem: stop using net_device.{base_addr, irq}.
      tehuti: stop using net_device.{base_addr, irq}.
      forcedeth: stop using net_device.{base_addr, irq}.
      atl1c: stop using net_device.{base_addr, irq}.
      via-rhine: stop using net_device.{base_addr, irq}.
      hamachi: stop using net_device.{base_addr, irq}.
      via-velocity: stop using net_device.{base_addr, irq}.
      sundance: stop using net_device.{base_addr, irq}.
      vxge: stop using net_device.{base_addr, irq}.
      fealnx: stop using net_device.{base_addr, irq}.
      atl1e: stop using net_device.{base_addr, irq}.
      s2io: stop using net_device.{base_addr, irq}.
      8139cp: stop using net_device.{base_addr, irq}.
      yellowfin: stop using net_device.{base_addr, irq}.
      starfire: stop using net_device.{base_addr, irq}.
      starfire: remove deprecated options.
      bnx2: stop using net_device.{base_addr, irq}.
      winbond840: stop using net_device.{base_addr, irq}.
      sc92031: stop using net_device.{base_addr, irq}
      sis190: stop using net_device.{base_addr, irq}
      tulip_core: stop using net_device.{base_addr, irq}.
      sunhme: stop using net_device.{base_addr, irq}.
      uli526x: fix regions leak in driver probe error path.
      xircom_cb: fix device probe error path.
      xircom_cb: stop using net_device.{base_addr, irq} and convert to __iomem.
      de2104x: stop using net_device.{base_addr, irq}.
      smsc9420: stop using net_device.{base_addr, irq}.
      natsemi: stop using net_device.{base_addr, irq}.
      8139too: dev->{base_addr, irq} removal.
      dl2k: stop using net_device.{base_addr, irq} and convert to __iomem.
      uli526x: stop using net_device.{base_addr, irq} and convert to __iomem.
      epic100: stop using net_device.{base_addr, irq} and convert to __iomem.
      dmfe: stop using net_device.{base_addr, irq} and convert to __iomem.
      sis900: stop using net_device.{base_addr, irq} and convert to __iomem.
      myri10ge: stop using net_device.{base_addr, irq}.
      rrunner: stop using net_device.{base_addr, irq}.
      ipw2200: stop using net_device.{base_addr, irq}.
      ipw2100: stop using net_device.base_addr.
      ipw2100: remove useless tests in the PCI device remove path.

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index a1b5914..0ef5b68 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -150,6 +150,12 @@
 #define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
 #define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
 
+#define dw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define dw16(reg, val)	iowrite16(val, ioaddr + (reg))
+#define dr32(reg)	ioread32(ioaddr + (reg))
+#define dr16(reg)	ioread16(ioaddr + (reg))
+#define dr8(reg)	ioread8(ioaddr + (reg))
+
 #define DMFE_DBUG(dbug_now, msg, value)			\
 	do {						\
 		if (dmfe_debug || (dbug_now))		\
@@ -178,20 +184,6 @@
 
 #define SROM_V41_CODE   0x14
 
-#define outl		iowrite32
-#define outw		iowrite16
-#define inl		ioread32
-#define inw		ioread16
-#define inb		ioread8
-
-#define SROM_CLK_WRITE(data, ioaddr) \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr); \
-	udelay(5); \
-	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
-	udelay(5);
-
 #define __CHK_IO_SIZE(pci_id, dev_rev) \
  (( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x30) ) ? \
 	DM9102A_IO_SIZE: DM9102_IO_SIZE)
@@ -631,9 +623,9 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	DMFE_DBUG(0, "dmfe_init_dm910x()", 0);
 
 	/* Reset DM910x MAC controller */
-	outl(DM910X_RESET, ioaddr + DCR0);	/* RESET MAC */
+	dw32(DCR0, DM910X_RESET);	/* RESET MAC */
 	udelay(100);
-	outl(db->cr0_data, ioaddr + DCR0);
+	dw32(DCR0, db->cr0_data);
 	udelay(5);
 
 	/* Phy addr : DM910(A)2/DM9132/9801, phy address = 1 */
@@ -644,12 +636,12 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	db->media_mode = dmfe_media_mode;
 
 	/* RESET Phyxcer Chip by GPR port bit 7 */
-	outl(0x180, ioaddr + DCR12);		/* Let bit 7 output port */
+	dw32(DCR12, 0x180);		/* Let bit 7 output port */
 	if (db->chip_id == PCI_DM9009_ID) {
-		outl(0x80, ioaddr + DCR12);	/* Issue RESET signal */
+		dw32(DCR12, 0x80);	/* Issue RESET signal */
 		mdelay(300);			/* Delay 300 ms */
 	}
-	outl(0x0, ioaddr + DCR12);	/* Clear RESET signal */
+	dw32(DCR12, 0x0);	/* Clear RESET signal */
 
 	/* Process Phyxcer Media Mode */
 	if ( !(db->media_mode & 0x10) )	/* Force 1M mode */
@@ -673,10 +665,10 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
-	outl(db->cr7_data, ioaddr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	/* Init CR15, Tx jabber and Rx watchdog timer */
-	outl(db->cr15_data, ioaddr + DCR15);
+	dw32(DCR15, db->cr15_data);
 
 	/* Enable DM910X Tx/Rx function */
 	db->cr6_data |= CR6_RXSC | CR6_TXSC | 0x40000;
@@ -719,7 +711,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Disable NIC interrupt */
-	outl(0, ioaddr + DCR7);
+	dw32(DCR7, 0);
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
@@ -733,11 +725,11 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 	if ( (!db->tx_queue_cnt) && (db->tx_packet_cnt < TX_MAX_SEND_CNT) ) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
-		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	} else {
 		db->tx_queue_cnt++;			/* queue TX packet */
-		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 	}
 
 	/* Tx resource check */
@@ -746,7 +738,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
 
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
-	outl(db->cr7_data, ioaddr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	/* free this SKB */
 	dev_kfree_skb(skb);
@@ -774,7 +766,7 @@ static int dmfe_stop(struct DEVICE *dev)
 	del_timer_sync(&db->timer);
 
 	/* Reset & stop DM910X board */
-	outl(DM910X_RESET, ioaddr + DCR0);
+	dw32(DCR0, DM910X_RESET);
 	udelay(5);
 	phy_write(ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
 
@@ -814,15 +806,15 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	spin_lock_irqsave(&db->lock, flags);
 
 	/* Got DM910X status */
-	db->cr5_data = inl(ioaddr + DCR5);
-	outl(db->cr5_data, ioaddr + DCR5);
+	db->cr5_data = dr32(DCR5);
+	dw32(DCR5, db->cr5_data);
 	if ( !(db->cr5_data & 0xc1) ) {
 		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
 
 	/* Disable all interrupt in CR7 to solve the interrupt edge problem */
-	outl(0, ioaddr + DCR7);
+	dw32(DCR7, 0);
 
 	/* Check system status */
 	if (db->cr5_data & 0x2000) {
@@ -854,7 +846,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 	}
 
 	/* Restore CR7 to enable interrupt mask */
-	outl(db->cr7_data, ioaddr + DCR7);
+	dw32(DCR7, db->cr7_data);
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	return IRQ_HANDLED;
@@ -939,7 +931,7 @@ static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
 		db->tx_queue_cnt--;
-		outl(0x1, ioaddr + DCR1);		/* Issue Tx polling */
+		dw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	}
 
@@ -1177,7 +1169,7 @@ static void dmfe_timer(unsigned long data)
 		db->dm910x_chk_mode = 0x4;
 
 	/* Dynamic reset DM910X : system error or transmit time-out */
-	tmp_cr8 = inl(db->ioaddr + DCR8);
+	tmp_cr8 = dr32(DCR8);
 	if ( (db->interval_rx_cnt==0) && (tmp_cr8) ) {
 		db->reset_cr8++;
 		db->wait_reset = 1;
@@ -1187,7 +1179,7 @@ static void dmfe_timer(unsigned long data)
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
 	     time_after(jiffies, dev_trans_start(dev) + DMFE_TX_KICK) ) {
-		outl(0x1, ioaddr + DCR1);   /* Tx polling again */
+		dw32(DCR1, 0x1);   /* Tx polling again */
 
 		/* TX Timeout */
 		if (time_after(jiffies, dev_trans_start(dev) + DMFE_TX_TIMEOUT) ) {
@@ -1210,9 +1202,9 @@ static void dmfe_timer(unsigned long data)
 
 	/* Link status check, Dynamic media type change */
 	if (db->chip_id == PCI_DM9132_ID)
-		tmp_cr12 = inb(db->ioaddr + DCR9 + 3);	/* DM9132 */
+		tmp_cr12 = dr8(DCR9 + 3);	/* DM9132 */
 	else
-		tmp_cr12 = inb(db->ioaddr + DCR12);	/* DM9102/DM9102A */
+		tmp_cr12 = dr8(DCR12);		/* DM9102/DM9102A */
 
 	if ( ((db->chip_id == PCI_DM9102_ID) &&
 		(db->chip_revision == 0x30)) ||
@@ -1308,8 +1300,8 @@ static void dmfe_dynamic_reset(struct net_device *dev)
 	/* Sopt MAC controller */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);	/* Disable Tx/Rx */
 	update_cr6(db->cr6_data, ioaddr);
-	outl(0, ioaddr + DCR7);		/* Disable Interrupt */
-	outl(inl(ioaddr + DCR5), ioaddr + DCR5);
+	dw32(DCR7, 0);				/* Disable Interrupt */
+	dw32(DCR5, dr32(DCR5));
 
 	/* Disable upper layer interface */
 	netif_stop_queue(dev);
@@ -1391,7 +1383,7 @@ static void dmfe_descriptor_init(struct net_device *dev)
 	/* tx descriptor start pointer */
 	db->tx_insert_ptr = db->first_tx_desc;
 	db->tx_remove_ptr = db->first_tx_desc;
-	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
+	dw32(DCR4, db->first_tx_desc_dma);     /* TX DESC address */
 
 	/* rx descriptor start pointer */
 	db->first_rx_desc = (void *)db->first_tx_desc +
@@ -1401,7 +1393,7 @@ static void dmfe_descriptor_init(struct net_device *dev)
 			sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
-	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
+	dw32(DCR3, db->first_rx_desc_dma);		/* RX DESC address */
 
 	/* Init Transmit chain */
 	tmp_buf = db->buf_pool_start;
@@ -1448,9 +1440,9 @@ static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 	u32 cr6_tmp;
 
 	cr6_tmp = cr6_data & ~0x2002;           /* stop Tx/Rx */
-	outl(cr6_tmp, ioaddr + DCR6);
+	dw32(DCR6, cr6_tmp);
 	udelay(5);
-	outl(cr6_data, ioaddr + DCR6);
+	dw32(DCR6, cr6_data);
 	udelay(5);
 }
 
@@ -1463,22 +1455,16 @@ static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 static void dm9132_id_table(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
-	void __iomem *ioaddr = db->ioaddr + 0xc0;		/* ID Table */
+	void __iomem *ioaddr = db->ioaddr + 0xc0;
+	u16 *addrptr = (u16 *)dev->dev_addr;
 	struct netdev_hw_addr *ha;
-	u16 * addrptr;
-	u32 hash_val;
 	u16 i, hash_table[4];
 
-	DMFE_DBUG(0, "dm9132_id_table()", 0);
-
 	/* Node address */
-	addrptr = (u16 *) dev->dev_addr;
-	outw(addrptr[0], ioaddr);
-	ioaddr += 4;
-	outw(addrptr[1], ioaddr);
-	ioaddr += 4;
-	outw(addrptr[2], ioaddr);
-	ioaddr += 4;
+	for (i = 0; i < 3; i++) {
+		dw16(0, addrptr[i]);
+		ioaddr += 4;
+	}
 
 	/* Clear Hash Table */
 	memset(hash_table, 0, sizeof(hash_table));
@@ -1488,13 +1474,14 @@ static void dm9132_id_table(struct net_device *dev)
 
 	/* the multicast address in Hash Table : 64 bits */
 	netdev_for_each_mc_addr(ha, dev) {
-		hash_val = cal_CRC((char *) ha->addr, 6, 0) & 0x3f;
+		u32 hash_val = cal_CRC((char *)ha->addr, 6, 0) & 0x3f;
+
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
 	/* Write the hash table to MAC MD table */
 	for (i = 0; i < 4; i++, ioaddr += 4)
-		outw(hash_table[i], ioaddr);
+		dw16(0, hash_table[i]);
 }
 
 
@@ -1554,7 +1541,7 @@ static void send_filter_frame(struct net_device *dev)
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
 		update_cr6(db->cr6_data | 0x2000, ioaddr);
-		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		dw32(DCR1, 0x1);	/* Issue Tx polling */
 		update_cr6(db->cr6_data, ioaddr);
 		dev->trans_start = jiffies;
 	} else
@@ -1590,43 +1577,55 @@ static void allocate_rx_buffer(struct net_device *dev)
 	db->rx_insert_ptr = rxptr;
 }
 
+static void srom_clk_write(void __iomem *ioaddr, u32 data)
+{
+	static const u32 cmd[] = {
+		CR9_SROM_READ | CR9_SRCS,
+		CR9_SROM_READ | CR9_SRCS | CR9_SRCLK,
+		CR9_SROM_READ | CR9_SRCS
+	};
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cmd); i++) {
+		dw32(DCR9, data | cmd[i]);
+		udelay(5);
+	}
+}
 
 /*
  *	Read one word data from the serial ROM
  */
-
 static u16 read_srom_word(void __iomem *ioaddr, int offset)
 {
-	void __iomem *cr9_ioaddr = ioaddr + DCR9;
+	u16 srom_data;
 	int i;
-	u16 srom_data = 0;
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ);
+	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	/* Send the Read Command 110b */
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
+	srom_clk_write(ioaddr, SROM_DATA_1);
+	srom_clk_write(ioaddr, SROM_DATA_1);
+	srom_clk_write(ioaddr, SROM_DATA_0);
 
 	/* Send the offset */
 	for (i = 5; i >= 0; i--) {
 		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
-		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
+		srom_clk_write(ioaddr, srom_data);
 	}
 
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	for (i = 16; i > 0; i--) {
-		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
+		dw32(DCR9, CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
 		udelay(5);
 		srom_data = (srom_data << 1) |
-				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
-		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+				((dr32(DCR9) & CR9_CRDOUT) ? 1 : 0);
+		dw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 		udelay(5);
 	}
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
+	dw32(DCR9, CR9_SROM_READ);
 	return srom_data;
 }
 
@@ -1782,16 +1781,15 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
  *	Write a word to Phy register
  */
 
-static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
+static void phy_write(void __iomem *ioaddr, u8 phy_addr, u8 offset,
 		      u16 phy_data, u32 chip_id)
 {
 	u16 i;
 
 	if (chip_id == PCI_DM9132_ID) {
-		outw(phy_data, iobase + 0x80 + offset * 4);
+		dw16(0x80 + offset * 4, phy_data);
 	} else {
 		/* DM9102/DM9102A Chip */
-		void __iomem *ioaddr = iobase + DCR9;
 
 		/* Send 33 synchronization clock to Phy controller */
 		for (i = 0; i < 35; i++)
@@ -1831,19 +1829,16 @@ static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
  *	Read a word data from phy register
  */
 
-static u16 phy_read(void __iomem *iobase, u8 phy_addr, u8 offset, u32 chip_id)
+static u16 phy_read(void __iomem *ioaddr, u8 phy_addr, u8 offset, u32 chip_id)
 {
-	void __iomem *ioaddr;
 	int i;
 	u16 phy_data;
 
 	if (chip_id == PCI_DM9132_ID) {
 		/* DM9132 Chip */
-		ioaddr = iobase + 0x80 + offset * 4;
-		phy_data = inw(ioaddr);
+		phy_data = dr16(0x80 + offset * 4);
 	} else {
 		/* DM9102/DM9102A Chip */
-		ioaddr = iobase + DCR9;
 
 		/* Send 33 synchronization clock to Phy controller */
 		for (i = 0; i < 35; i++)
@@ -1887,11 +1882,11 @@ static u16 phy_read(void __iomem *iobase, u8 phy_addr, u8 offset, u32 chip_id)
 
 static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data)
 {
-	outl(phy_data, ioaddr);			/* MII Clock Low */
+	dw32(DCR9, phy_data);		/* MII Clock Low */
 	udelay(1);
-	outl(phy_data | MDCLKH, ioaddr);	/* MII Clock High */
+	dw32(DCR9, phy_data | MDCLKH);	/* MII Clock High */
 	udelay(1);
-	outl(phy_data, ioaddr);			/* MII Clock Low */
+	dw32(DCR9, phy_data);		/* MII Clock Low */
 	udelay(1);
 }
 
@@ -1904,10 +1899,10 @@ static u16 phy_read_1bit(void __iomem *ioaddr)
 {
 	u16 phy_data;
 
-	outl(0x50000, ioaddr);
+	dw32(DCR9, 0x50000);
 	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
-	outl(0x40000, ioaddr);
+	phy_data = (dr32(DCR9) >> 19) & 0x1;
+	dw32(DCR9, 0x40000);
 	udelay(1);
 
 	return phy_data;
@@ -2121,8 +2116,8 @@ static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 	update_cr6(db->cr6_data, ioaddr);
 
 	/* Disable Interrupt */
-	outl(0, ioaddr + DCR7);
-	outl(inl(ioaddr + DCR5), ioaddr + DCR5);
+	dw32(DCR7, 0);
+	dw32(DCR5, dr32(DCR5));
 
 	/* Fre RX buffers */
 	dmfe_free_rxbuffer(db);
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 2035791..75d45f8 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -42,8 +42,8 @@
 #include <asm/dma.h>
 #include <asm/uaccess.h>
 
-#define outl	iowrite32
-#define inl	ioread32
+#define uw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define ur32(reg)	ioread32(ioaddr + (reg))
 
 /* Board/System/Debug information/definition ---------------- */
 #define PCI_ULI5261_ID  0x526110B9	/* ULi M5261 ID*/
@@ -112,14 +112,6 @@ do {								\
 
 #define SROM_V41_CODE   0x14
 
-#define SROM_CLK_WRITE(data, ioaddr)					\
-		outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);		\
-		udelay(5);						\
-		outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr);	\
-		udelay(5);						\
-		outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);		\
-		udelay(5);
-
 /* Structure/enum declaration ------------------------------- */
 struct tx_desc {
         __le32 tdes0, tdes1, tdes2, tdes3; /* Data for the card */
@@ -134,7 +126,10 @@ struct rx_desc {
 } __attribute__(( aligned(32) ));
 
 struct uli526x_board_info {
-	u32 chip_id;			/* Chip vendor/Device ID */
+	struct uli_phy_ops {
+		void (*write)(struct uli526x_board_info *, u8, u8, u16);
+		u16 (*read)(struct uli526x_board_info *, u8, u8);
+	} phy;
 	struct net_device *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
@@ -229,7 +224,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *,
 static int uli526x_stop(struct net_device *);
 static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
-static u16 read_srom_word(void __iomem *, int);
+static u16 read_srom_word(struct uli526x_board_info *, int);
 static irqreturn_t uli526x_interrupt(int, void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uli526x_poll(struct net_device *dev);
@@ -238,12 +233,12 @@ static void uli526x_descriptor_init(struct net_device *, void __iomem *);
 static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, void __iomem *);
 static void send_filter_frame(struct net_device *, int);
-static u16 phy_read(void __iomem *, u8, u8, u32);
-static u16 phy_readby_cr10(void __iomem *, u8, u8);
-static void phy_write(void __iomem *, u8, u8, u16, u32);
-static void phy_writeby_cr10(void __iomem *, u8, u8, u16);
-static void phy_write_1bit(void __iomem *, u32, u32);
-static u16 phy_read_1bit(void __iomem *, u32);
+static u16 phy_readby_cr9(struct uli526x_board_info *, u8, u8);
+static u16 phy_readby_cr10(struct uli526x_board_info *, u8, u8);
+static void phy_writeby_cr9(struct uli526x_board_info *, u8, u8, u16);
+static void phy_writeby_cr10(struct uli526x_board_info *, u8, u8, u16);
+static void phy_write_1bit(struct uli526x_board_info *db, u32);
+static u16 phy_read_1bit(struct uli526x_board_info *db);
 static u8 uli526x_sense_speed(struct uli526x_board_info *);
 static void uli526x_process_mode(struct uli526x_board_info *);
 static void uli526x_timer(unsigned long);
@@ -255,6 +250,18 @@ static void uli526x_free_rxbuffer(struct uli526x_board_info *);
 static void uli526x_init(struct net_device *);
 static void uli526x_set_phyxcer(struct uli526x_board_info *);
 
+static void srom_clk_write(struct uli526x_board_info *db, u32 data)
+{
+	void __iomem *ioaddr = db->ioaddr;
+
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
+	udelay(5);
+	uw32(DCR9, data | CR9_SROM_READ | CR9_SRCS);
+	udelay(5);
+}
+
 /* ULI526X network board routine ---------------------------- */
 
 static const struct net_device_ops netdev_ops = {
@@ -279,6 +286,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 {
 	struct uli526x_board_info *db;	/* board information structure */
 	struct net_device *dev;
+	void __iomem *ioaddr;
 	int i, err;
 
 	ULI526X_DBUG(0, "uli526x_init_one()", 0);
@@ -340,13 +348,23 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	db->buf_pool_start = db->buf_pool_ptr;
 	db->buf_pool_dma_start = db->buf_pool_dma_ptr;
 
-	db->chip_id = ent->driver_data;
+	switch (ent->driver_data) {
+	case PCI_ULI5263_ID:
+		db->phy.write	= phy_writeby_cr10;
+		db->phy.read	= phy_readby_cr10;
+		break;
+	default:
+		db->phy.write	= phy_writeby_cr9;
+		db->phy.read	= phy_readby_cr9;
+		break;
+	}
 
 	/* IO region. */
-	db->ioaddr = pci_iomap(pdev, 0, 0);
-	if (!db->ioaddr)
+	ioaddr = pci_iomap(pdev, 0, 0);
+	if (!ioaddr)
 		goto err_out_free_tx_buf;
 
+	db->ioaddr = ioaddr;
 	db->pdev = pdev;
 	db->init = 1;
 
@@ -361,24 +379,24 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 
 	/* read 64 word srom data */
 	for (i = 0; i < 64; i++)
-		((__le16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db->ioaddr, i));
+		((__le16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db, i));
 
 	/* Set Node address */
 	if(((u16 *) db->srom)[0] == 0xffff || ((u16 *) db->srom)[0] == 0)		/* SROM absent, so read MAC address from ID Table */
 	{
-		outl(0x10000, db->ioaddr + DCR0);	//Diagnosis mode
-		outl(0x1c0, db->ioaddr + DCR13);	//Reset dianostic pointer port
-		outl(0, db->ioaddr + DCR14);		//Clear reset port
-		outl(0x10, db->ioaddr + DCR14);		//Reset ID Table pointer
-		outl(0, db->ioaddr + DCR14);		//Clear reset port
-		outl(0, db->ioaddr + DCR13);		//Clear CR13
-		outl(0x1b0, db->ioaddr + DCR13);	//Select ID Table access port
+		uw32(DCR0, 0x10000);	//Diagnosis mode
+		uw32(DCR13, 0x1c0);	//Reset dianostic pointer port
+		uw32(DCR14, 0);		//Clear reset port
+		uw32(DCR14, 0x10);	//Reset ID Table pointer
+		uw32(DCR14, 0);		//Clear reset port
+		uw32(DCR13, 0);		//Clear CR13
+		uw32(DCR13, 0x1b0);	//Select ID Table access port
 		//Read MAC address from CR14
 		for (i = 0; i < 6; i++)
-			dev->dev_addr[i] = inl(db->ioaddr + DCR14);
+			dev->dev_addr[i] = ur32(DCR14);
 		//Read end
-		outl(0, db->ioaddr + DCR13);	//Clear CR13
-		outl(0, db->ioaddr + DCR0);		//Clear CR0
+		uw32(DCR13, 0);		//Clear CR13
+		uw32(DCR0, 0);		//Clear CR0
 		udelay(10);
 	}
 	else		/*Exist SROM*/
@@ -496,57 +514,57 @@ static int uli526x_open(struct net_device *dev)
 static void uli526x_init(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
+	struct uli_phy_ops *phy = &db->phy;
 	void __iomem *ioaddr = db->ioaddr;
 	u8	phy_tmp;
 	u8	timeout;
-	u16	phy_value;
 	u16 phy_reg_reset;
 
 
 	ULI526X_DBUG(0, "uli526x_init()", 0);
 
 	/* Reset M526x MAC controller */
-	outl(ULI526X_RESET, ioaddr + DCR0);	/* RESET MAC */
+	uw32(DCR0, ULI526X_RESET);	/* RESET MAC */
 	udelay(100);
-	outl(db->cr0_data, ioaddr + DCR0);
+	uw32(DCR0, db->cr0_data);
 	udelay(5);
 
 	/* Phy addr : In some boards,M5261/M5263 phy address != 1 */
 	db->phy_addr = 1;
-	for(phy_tmp=0;phy_tmp<32;phy_tmp++)
-	{
-		phy_value=phy_read(db->ioaddr,phy_tmp,3,db->chip_id);//peer add
-		if(phy_value != 0xffff&&phy_value!=0)
-		{
+	for (phy_tmp = 0; phy_tmp < 32; phy_tmp++) {
+		u16 phy_value;
+
+		phy_value = phy->read(db, phy_tmp, 3);	//peer add
+		if (phy_value != 0xffff && phy_value != 0) {
 			db->phy_addr = phy_tmp;
 			break;
 		}
 	}
-	if(phy_tmp == 32)
+
+	if (phy_tmp == 32)
 		pr_warn("Can not find the phy address!!!\n");
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
 	/* phyxcer capability setting */
-	phy_reg_reset = phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id);
+	phy_reg_reset = phy->read(db, db->phy_addr, 0);
 	phy_reg_reset = (phy_reg_reset | 0x8000);
-	phy_write(db->ioaddr, db->phy_addr, 0, phy_reg_reset, db->chip_id);
+	phy->write(db, db->phy_addr, 0, phy_reg_reset);
 
 	/* See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management
 	 * functions") or phy data sheet for details on phy reset
 	 */
 	udelay(500);
 	timeout = 10;
-	while (timeout-- &&
-		phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id) & 0x8000)
-			udelay(100);
+	while (timeout-- && phy->read(db, db->phy_addr, 0) & 0x8000)
+		udelay(100);
 
 	/* Process Phyxcer Media Mode */
 	uli526x_set_phyxcer(db);
 
 	/* Media Mode Process */
 	if ( !(db->media_mode & ULI526X_AUTO) )
-		db->op_mode = db->media_mode; 	/* Force Mode */
+		db->op_mode = db->media_mode;		/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
 	uli526x_descriptor_init(dev, ioaddr);
@@ -559,10 +577,10 @@ static void uli526x_init(struct net_device *dev)
 
 	/* Init CR7, interrupt active bit */
 	db->cr7_data = CR7_DEFAULT;
-	outl(db->cr7_data, ioaddr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	/* Init CR15, Tx jabber and Rx watchdog timer */
-	outl(db->cr15_data, ioaddr + DCR15);
+	uw32(DCR15, db->cr15_data);
 
 	/* Enable ULI526X Tx/Rx function */
 	db->cr6_data |= CR6_RXSC | CR6_TXSC;
@@ -605,7 +623,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Disable NIC interrupt */
-	outl(0, ioaddr + DCR7);
+	uw32(DCR7, 0);
 
 	/* transmit this packet */
 	txptr = db->tx_insert_ptr;
@@ -616,10 +634,10 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 	db->tx_insert_ptr = txptr->next_tx_desc;
 
 	/* Transmit Packet Process */
-	if ( (db->tx_packet_cnt < TX_DESC_CNT) ) {
+	if (db->tx_packet_cnt < TX_DESC_CNT) {
 		txptr->tdes0 = cpu_to_le32(0x80000000);	/* Set owner bit */
 		db->tx_packet_cnt++;			/* Ready to send */
-		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		uw32(DCR1, 0x1);			/* Issue Tx polling */
 		dev->trans_start = jiffies;		/* saved time stamp */
 	}
 
@@ -629,7 +647,7 @@ static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
 
 	/* Restore CR7 to enable interrupt */
 	spin_unlock_irqrestore(&db->lock, flags);
-	outl(db->cr7_data, ioaddr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	/* free this SKB */
 	dev_kfree_skb(skb);
@@ -648,8 +666,6 @@ static int uli526x_stop(struct net_device *dev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 	void __iomem *ioaddr = db->ioaddr;
 
-	ULI526X_DBUG(0, "uli526x_stop", 0);
-
 	/* disable system */
 	netif_stop_queue(dev);
 
@@ -657,9 +673,9 @@ static int uli526x_stop(struct net_device *dev)
 	del_timer_sync(&db->timer);
 
 	/* Reset & stop ULI526X board */
-	outl(ULI526X_RESET, ioaddr + DCR0);
+	uw32(DCR0, ULI526X_RESET);
 	udelay(5);
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+	db->phy.write(db, db->phy_addr, 0, 0x8000);
 
 	/* free interrupt */
 	free_irq(db->pdev->irq, dev);
@@ -684,14 +700,14 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 	unsigned long flags;
 
 	spin_lock_irqsave(&db->lock, flags);
-	outl(0, ioaddr + DCR7);
+	uw32(DCR7, 0);
 
 	/* Got ULI526X status */
-	db->cr5_data = inl(ioaddr + DCR5);
-	outl(db->cr5_data, ioaddr + DCR5);
+	db->cr5_data = ur32(DCR5);
+	uw32(DCR5, db->cr5_data);
 	if ( !(db->cr5_data & 0x180c1) ) {
 		/* Restore CR7 to enable interrupt mask */
-		outl(db->cr7_data, ioaddr + DCR7);
+		uw32(DCR7, db->cr7_data);
 		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
@@ -719,7 +735,7 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 		uli526x_free_tx_pkt(dev, db);
 
 	/* Restore CR7 to enable interrupt mask */
-	outl(db->cr7_data, ioaddr + DCR7);
+	uw32(DCR7, db->cr7_data);
 
 	spin_unlock_irqrestore(&db->lock, flags);
 	return IRQ_HANDLED;
@@ -1005,18 +1021,20 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static void uli526x_timer(unsigned long data)
 {
-	u32 tmp_cr8;
-	unsigned char tmp_cr12=0;
 	struct net_device *dev = (struct net_device *) data;
 	struct uli526x_board_info *db = netdev_priv(dev);
+	struct uli_phy_ops *phy = &db->phy;
+	void __iomem *ioaddr = db->ioaddr;
  	unsigned long flags;
+	u8 tmp_cr12 = 0;
+	u32 tmp_cr8;
 
 	//ULI526X_DBUG(0, "uli526x_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
 
 
 	/* Dynamic reset ULI526X : system error or transmit time-out */
-	tmp_cr8 = inl(db->ioaddr + DCR8);
+	tmp_cr8 = ur32(DCR8);
 	if ( (db->interval_rx_cnt==0) && (tmp_cr8) ) {
 		db->reset_cr8++;
 		db->wait_reset = 1;
@@ -1026,7 +1044,7 @@ static void uli526x_timer(unsigned long data)
 	/* TX polling kick monitor */
 	if ( db->tx_packet_cnt &&
 	     time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_KICK) ) {
-		outl(0x1, db->ioaddr + DCR1);   // Tx polling again
+		uw32(DCR1, 0x1);   // Tx polling again
 
 		// TX Timeout
 		if ( time_after(jiffies, dev_trans_start(dev) + ULI526X_TX_TIMEOUT) ) {
@@ -1047,7 +1065,7 @@ static void uli526x_timer(unsigned long data)
 	}
 
 	/* Link status check, Dynamic media type change */
-	if((phy_read(db->ioaddr, db->phy_addr, 5, db->chip_id) & 0x01e0)!=0)
+	if ((phy->read(db, db->phy_addr, 5) & 0x01e0)!=0)
 		tmp_cr12 = 3;
 
 	if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
@@ -1060,7 +1078,7 @@ static void uli526x_timer(unsigned long data)
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO don't need */
 		if ( !(db->media_mode & 0x8) )
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy->write(db, db->phy_addr, 0, 0x1000);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & ULI526X_AUTO) {
@@ -1122,8 +1140,8 @@ static void uli526x_reset_prepare(struct net_device *dev)
 	/* Sopt MAC controller */
 	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);	/* Disable Tx/Rx */
 	update_cr6(db->cr6_data, ioaddr);
-	outl(0, ioaddr + DCR7);		/* Disable Interrupt */
-	outl(inl(ioaddr + DCR5), ioaddr + DCR5);
+	uw32(DCR7, 0);				/* Disable Interrupt */
+	uw32(DCR5, ur32(DCR5));
 
 	/* Disable upper layer interface */
 	netif_stop_queue(dev);
@@ -1303,14 +1321,14 @@ static void uli526x_descriptor_init(struct net_device *dev, void __iomem *ioaddr
 	/* tx descriptor start pointer */
 	db->tx_insert_ptr = db->first_tx_desc;
 	db->tx_remove_ptr = db->first_tx_desc;
-	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
+	uw32(DCR4, db->first_tx_desc_dma);	/* TX DESC address */
 
 	/* rx descriptor start pointer */
 	db->first_rx_desc = (void *)db->first_tx_desc + sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->first_rx_desc_dma =  db->first_tx_desc_dma + sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
-	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
+	uw32(DCR3, db->first_rx_desc_dma);	/* RX DESC address */
 
 	/* Init Transmit chain */
 	tmp_buf = db->buf_pool_start;
@@ -1351,11 +1369,9 @@ static void uli526x_descriptor_init(struct net_device *dev, void __iomem *ioaddr
  *	Update CR6 value
  *	Firstly stop ULI526X, then written value and start
  */
-
 static void update_cr6(u32 cr6_data, void __iomem *ioaddr)
 {
-
-	outl(cr6_data, ioaddr + DCR6);
+	uw32(DCR6, cr6_data);
 	udelay(5);
 }
 
@@ -1421,7 +1437,7 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 		db->tx_packet_cnt++;
 		txptr->tdes0 = cpu_to_le32(0x80000000);
 		update_cr6(db->cr6_data | 0x2000, ioaddr);
-		outl(0x1, ioaddr + DCR1);	/* Issue Tx polling */
+		uw32(DCR1, 0x1);	/* Issue Tx polling */
 		update_cr6(db->cr6_data, ioaddr);
 		dev->trans_start = jiffies;
 	} else
@@ -1465,37 +1481,38 @@ static void allocate_rx_buffer(struct net_device *dev)
  *	Read one word data from the serial ROM
  */
 
-static u16 read_srom_word(void __iomem *ioaddr, int offset)
+static u16 read_srom_word(struct uli526x_board_info *db, int offset)
 {
-	void __iomem *cr9_ioaddr = ioaddr + DCR9;
+	void __iomem *ioaddr = db->ioaddr;
 	u16 srom_data = 0;
 	int i;
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ);
+	uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	/* Send the Read Command 110b */
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_1, cr9_ioaddr);
-	SROM_CLK_WRITE(SROM_DATA_0, cr9_ioaddr);
+	srom_clk_write(db, SROM_DATA_1);
+	srom_clk_write(db, SROM_DATA_1);
+	srom_clk_write(db, SROM_DATA_0);
 
 	/* Send the offset */
 	for (i = 5; i >= 0; i--) {
 		srom_data = (offset & (1 << i)) ? SROM_DATA_1 : SROM_DATA_0;
-		SROM_CLK_WRITE(srom_data, cr9_ioaddr);
+		srom_clk_write(db, srom_data);
 	}
 
-	outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 
 	for (i = 16; i > 0; i--) {
-		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
+		uw32(DCR9, CR9_SROM_READ | CR9_SRCS | CR9_SRCLK);
 		udelay(5);
-		srom_data = (srom_data << 1) | ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
-		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
+		srom_data = (srom_data << 1) |
+			    ((ur32(DCR9) & CR9_CRDOUT) ? 1 : 0);
+		uw32(DCR9, CR9_SROM_READ | CR9_SRCS);
 		udelay(5);
 	}
 
-	outl(CR9_SROM_READ, cr9_ioaddr);
+	uw32(DCR9, CR9_SROM_READ);
 	return srom_data;
 }
 
@@ -1506,15 +1523,16 @@ static u16 read_srom_word(void __iomem *ioaddr, int offset)
 
 static u8 uli526x_sense_speed(struct uli526x_board_info * db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u8 ErrFlag = 0;
 	u16 phy_mode;
 
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
-	phy_mode = phy_read(db->ioaddr, db->phy_addr, 1, db->chip_id);
+	phy_mode = phy->read(db, db->phy_addr, 1);
+	phy_mode = phy->read(db, db->phy_addr, 1);
 
 	if ( (phy_mode & 0x24) == 0x24 ) {
 
-		phy_mode = ((phy_read(db->ioaddr, db->phy_addr, 5, db->chip_id) & 0x01e0)<<7);
+		phy_mode = ((phy->read(db, db->phy_addr, 5) & 0x01e0)<<7);
 		if(phy_mode&0x8000)
 			phy_mode = 0x8000;
 		else if(phy_mode&0x4000)
@@ -1549,10 +1567,11 @@ static u8 uli526x_sense_speed(struct uli526x_board_info * db)
 
 static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u16 phy_reg;
 
 	/* Phyxcer capability setting */
-	phy_reg = phy_read(db->ioaddr, db->phy_addr, 4, db->chip_id) & ~0x01e0;
+	phy_reg = phy->read(db, db->phy_addr, 4) & ~0x01e0;
 
 	if (db->media_mode & ULI526X_AUTO) {
 		/* AUTO Mode */
@@ -1573,10 +1592,10 @@ static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 		phy_reg|=db->PHY_reg4;
 		db->media_mode|=ULI526X_AUTO;
 	}
-	phy_write(db->ioaddr, db->phy_addr, 4, phy_reg, db->chip_id);
+	phy->write(db, db->phy_addr, 4, phy_reg);
 
  	/* Restart Auto-Negotiation */
-	phy_write(db->ioaddr, db->phy_addr, 0, 0x1200, db->chip_id);
+	phy->write(db, db->phy_addr, 0, 0x1200);
 	udelay(50);
 }
 
@@ -1590,6 +1609,7 @@ static void uli526x_set_phyxcer(struct uli526x_board_info *db)
 
 static void uli526x_process_mode(struct uli526x_board_info *db)
 {
+	struct uli_phy_ops *phy = &db->phy;
 	u16 phy_reg;
 
 	/* Full Duplex Mode Check */
@@ -1601,10 +1621,10 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 	update_cr6(db->cr6_data, db->ioaddr);
 
 	/* 10/100M phyxcer force mode need */
-	if ( !(db->media_mode & 0x8)) {
+	if (!(db->media_mode & 0x8)) {
 		/* Forece Mode */
-		phy_reg = phy_read(db->ioaddr, db->phy_addr, 6, db->chip_id);
-		if ( !(phy_reg & 0x1) ) {
+		phy_reg = phy->read(db, db->phy_addr, 6);
+		if (!(phy_reg & 0x1)) {
 			/* parter without N-Way capability */
 			phy_reg = 0x0;
 			switch(db->op_mode) {
@@ -1613,148 +1633,126 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 			case ULI526X_100MHF: phy_reg = 0x2000; break;
 			case ULI526X_100MFD: phy_reg = 0x2100; break;
 			}
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy->write(db, db->phy_addr, 0, phy_reg);
 		}
 	}
 }
 
 
-/*
- *	Write a word to Phy register
- */
-
-static void phy_write(void __iomem *iobase, u8 phy_addr, u8 offset,
-		      u16 phy_data, u32 chip_id)
+/* M5261/M5263 Chip */
+static void phy_writeby_cr9(struct uli526x_board_info *db, u8 phy_addr,
+			    u8 offset, u16 phy_data)
 {
-	/* M5261/M5263 Chip */
-	void __iomem *ioaddr = iobase + DCR9;
 	u16 i;
 
-	if(chip_id == PCI_ULI5263_ID)
-	{
-		phy_writeby_cr10(iobase, phy_addr, offset, phy_data);
-		return;
-	}
-
 	/* Send 33 synchronization clock to Phy controller */
 	for (i = 0; i < 35; i++)
-		phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+		phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send start command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send write command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send Phy address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Send register address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* written trasnition */
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
+	phy_write_1bit(db, PHY_DATA_1);
+	phy_write_1bit(db, PHY_DATA_0);
 
 	/* Write a word data to PHY controller */
-	for ( i = 0x8000; i > 0; i >>= 1)
-		phy_write_1bit(ioaddr, phy_data & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
-
+	for (i = 0x8000; i > 0; i >>= 1)
+		phy_write_1bit(db, phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
 }
 
-
-/*
- *	Read a word data from phy register
- */
-
-static u16 phy_read(void __iomem *iobase, u8 phy_addr, u8 offset, u32 chip_id)
+static u16 phy_readby_cr9(struct uli526x_board_info *db, u8 phy_addr, u8 offset)
 {
-	void __iomem *ioaddr;
-	int i;
 	u16 phy_data;
-
-	if(chip_id == PCI_ULI5263_ID)
-		return phy_readby_cr10(iobase, phy_addr, offset);
-	/* M5261/M5263 Chip */
-	ioaddr = iobase + DCR9;
+	int i;
 
 	/* Send 33 synchronization clock to Phy controller */
 	for (i = 0; i < 35; i++)
-		phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+		phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send start command(01) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
+	phy_write_1bit(db, PHY_DATA_0);
+	phy_write_1bit(db, PHY_DATA_1);
 
 	/* Send read command(10) to Phy */
-	phy_write_1bit(ioaddr, PHY_DATA_1, chip_id);
-	phy_write_1bit(ioaddr, PHY_DATA_0, chip_id);
+	phy_write_1bit(db, PHY_DATA_1);
+	phy_write_1bit(db, PHY_DATA_0);
 
 	/* Send Phy address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Send register address */
 	for (i = 0x10; i > 0; i = i >> 1)
-		phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0, chip_id);
+		phy_write_1bit(db, offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 	/* Skip transition state */
-	phy_read_1bit(ioaddr, chip_id);
+	phy_read_1bit(db);
 
 	/* read 16bit data */
 	for (phy_data = 0, i = 0; i < 16; i++) {
 		phy_data <<= 1;
-		phy_data |= phy_read_1bit(ioaddr, chip_id);
+		phy_data |= phy_read_1bit(db);
 	}
 
 	return phy_data;
 }
 
-static u16 phy_readby_cr10(void __iomem *iobase, u8 phy_addr, u8 offset)
+static u16 phy_readby_cr10(struct uli526x_board_info *db, u8 phy_addr,
+			   u8 offset)
 {
-	void __iomem *ioaddr = iobase + DCR10;
-	u32 cr10_value;
+	void __iomem *ioaddr = db->ioaddr;
+	u32 cr10_value = phy_addr;
 
-	cr10_value = phy_addr;
 	cr10_value = (cr10_value <<  5) + offset;
 	cr10_value = (cr10_value << 16) + 0x08000000;
-	outl(cr10_value, ioaddr);
+	uw32(DCR10, cr10_value);
 	udelay(1);
-	while(1) {
-		cr10_value = inl(ioaddr);
+	while (1) {
+		cr10_value = ur32(DCR10);
 		if (cr10_value & 0x10000000)
 			break;
 	}
 	return cr10_value & 0x0ffff;
 }
 
-static void phy_writeby_cr10(void __iomem *iobase, u8 phy_addr, u8 offset,
-			     u16 phy_data)
+static void phy_writeby_cr10(struct uli526x_board_info *db, u8 phy_addr,
+			     u8 offset, u16 phy_data)
 {
-	void __iomem *ioaddr = iobase + DCR10;
-	u32 cr10_value;
+	void __iomem *ioaddr = db->ioaddr;
+	u32 cr10_value = phy_addr;
 
-	cr10_value = phy_addr;
 	cr10_value = (cr10_value <<  5) + offset;
 	cr10_value = (cr10_value << 16) + 0x04000000 + phy_data;
-	outl(cr10_value, ioaddr);
+	uw32(DCR10, cr10_value);
 	udelay(1);
 }
 /*
  *	Write one bit data to Phy Controller
  */
 
-static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data, u32 chip_id)
+static void phy_write_1bit(struct uli526x_board_info *db, u32 data)
 {
-	outl(phy_data , ioaddr);			/* MII Clock Low */
+	void __iomem *ioaddr = db->ioaddr;
+
+	uw32(DCR9, data);		/* MII Clock Low */
 	udelay(1);
-	outl(phy_data  | MDCLKH, ioaddr);	/* MII Clock High */
+	uw32(DCR9, data | MDCLKH);	/* MII Clock High */
 	udelay(1);
-	outl(phy_data , ioaddr);			/* MII Clock Low */
+	uw32(DCR9, data);		/* MII Clock Low */
 	udelay(1);
 }
 
@@ -1763,14 +1761,15 @@ static void phy_write_1bit(void __iomem *ioaddr, u32 phy_data, u32 chip_id)
  *	Read one bit phy data from PHY controller
  */
 
-static u16 phy_read_1bit(void __iomem *ioaddr, u32 chip_id)
+static u16 phy_read_1bit(struct uli526x_board_info *db)
 {
+	void __iomem *ioaddr = db->ioaddr;
 	u16 phy_data;
 
-	outl(0x50000 , ioaddr);
+	uw32(DCR9, 0x50000);
 	udelay(1);
-	phy_data = ( inl(ioaddr) >> 19 ) & 0x1;
-	outl(0x40000 , ioaddr);
+	phy_data = (ur32(DCR9) >> 19) & 0x1;
+	uw32(DCR9, 0x40000);
 	udelay(1);
 
 	return phy_data;
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 4aed477..138bf83 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -41,9 +41,9 @@ MODULE_DESCRIPTION("Xircom Cardbus ethernet driver");
 MODULE_AUTHOR("Arjan van de Ven <arjanv@redhat.com>");
 MODULE_LICENSE("GPL");
 
-#define outl	iowrite32
-#define inl	ioread32
-#define inb	ioread8
+#define xw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define xr32(reg)	ioread32(ioaddr + (reg))
+#define xr8(reg)	ioread8(ioaddr + (reg))
 
 /* IO registers on the card, offsets */
 #define CSR0	0x00
@@ -85,7 +85,7 @@ struct xircom_private {
 
 	struct sk_buff *tx_skb[4];
 
-	void __iomem *io_port;
+	void __iomem *ioaddr;
 	int open;
 
 	/* transmit_used is the rotating counter that indicates which transmit
@@ -139,7 +139,7 @@ static int link_status(struct xircom_private *card);
 
 
 static DEFINE_PCI_DEVICE_TABLE(xircom_pci_table) = {
-	{0x115D, 0x0003, PCI_ANY_ID, PCI_ANY_ID,},
+	{ PCI_VDEVICE(XIRCOM, 0x0003), },
 	{0,},
 };
 MODULE_DEVICE_TABLE(pci, xircom_pci_table);
@@ -148,9 +148,7 @@ static struct pci_driver xircom_ops = {
 	.name		= "xircom_cb",
 	.id_table	= xircom_pci_table,
 	.probe		= xircom_probe,
-	.remove		= xircom_remove,
-	.suspend =NULL,
-	.resume =NULL
+	.remove		= __devexit_p(xircom_remove),
 };
 
 
@@ -257,8 +255,8 @@ static int __devinit xircom_probe(struct pci_dev *pdev, const struct pci_device_
 	private->pdev = pdev;
 
 	/* IO range. */
-	private->io_port = pci_iomap(pdev, 0, 0);
-	if (!private->io_port)
+	private->ioaddr = pci_iomap(pdev, 0, 0);
+	if (!private->ioaddr)
 		goto reg_fail;
 
 	spin_lock_init(&private->lock);
@@ -292,7 +290,7 @@ out:
 	return rc;
 
 err_unmap:
-	pci_iounmap(pdev, private->io_port);
+	pci_iounmap(pdev, private->ioaddr);
 reg_fail:
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, private->tx_buffer, private->tx_dma_handle);
@@ -321,7 +319,7 @@ static void __devexit xircom_remove(struct pci_dev *pdev)
 	struct device *d = &pdev->dev;
 
 	unregister_netdev(dev);
-	pci_iounmap(pdev, card->io_port);
+	pci_iounmap(pdev, card->ioaddr);
 	pci_set_drvdata(pdev, NULL);
 	dma_free_coherent(d, 8192, card->tx_buffer, card->tx_dma_handle);
 	dma_free_coherent(d, 8192, card->rx_buffer, card->rx_dma_handle);
@@ -334,11 +332,12 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
 	struct xircom_private *card = netdev_priv(dev);
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int status;
 	int i;
 
 	spin_lock(&card->lock);
-	status = inl(card->io_port+CSR5);
+	status = xr32(CSR5);
 
 #if defined DEBUG && DEBUG > 1
 	print_binary(status);
@@ -368,7 +367,7 @@ static irqreturn_t xircom_interrupt(int irq, void *dev_instance)
 	/* Clear all remaining interrupts */
 	status |= 0xffffffff; /* FIXME: make this clear only the
 				        real existing bits */
-	outl(status,card->io_port+CSR5);
+	xw32(CSR5, status);
 
 
 	for (i=0;i<NUMDESCRIPTORS;i++)
@@ -504,26 +503,27 @@ static void xircom_poll_controller(struct net_device *dev)
 
 static void initialize_card(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
+	u32 val;
 
 	spin_lock_irqsave(&card->lock, flags);
 
 	/* First: reset the card */
-	val = inl(card->io_port + CSR0);
+	val = xr32(CSR0);
 	val |= 0x01;		/* Software reset */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 	udelay(100);		/* give the card some time to reset */
 
-	val = inl(card->io_port + CSR0);
+	val = xr32(CSR0);
 	val &= ~0x01;		/* disable Software reset */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 
 	val = 0;		/* Value 0x00 is a safe and conservative value
 				   for the PCI configuration settings */
-	outl(val, card->io_port + CSR0);
+	xw32(CSR0, val);
 
 
 	disable_all_interrupts(card);
@@ -541,10 +541,9 @@ ignored; I chose zero.
 */
 static void trigger_transmit(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;
-	outl(val, card->io_port + CSR1);
+	xw32(CSR1, 0);
 }
 
 /*
@@ -556,10 +555,9 @@ ignored; I chose zero.
 */
 static void trigger_receive(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;
-	outl(val, card->io_port + CSR2);
+	xw32(CSR2, 0);
 }
 
 /*
@@ -568,6 +566,7 @@ descriptors and programs the addresses into the card.
 */
 static void setup_descriptors(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	u32 address;
 	int i;
 
@@ -597,7 +596,7 @@ static void setup_descriptors(struct xircom_private *card)
 	wmb();
 	/* Write the receive descriptor ring address to the card */
 	address = card->rx_dma_handle;
-	outl(address, card->io_port + CSR3);	/* Receive descr list address */
+	xw32(CSR3, address);	/* Receive descr list address */
 
 
 	/* transmit descriptors */
@@ -622,7 +621,7 @@ static void setup_descriptors(struct xircom_private *card)
 	wmb();
 	/* wite the transmit descriptor ring to the card */
 	address = card->tx_dma_handle;
-	outl(address, card->io_port + CSR4);	/* xmit descr list address */
+	xw32(CSR4, address);	/* xmit descr list address */
 }
 
 /*
@@ -631,11 +630,12 @@ valid by setting the address in the card to 0x00.
 */
 static void remove_descriptors(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
 	val = 0;
-	outl(val, card->io_port + CSR3);	/* Receive descriptor address */
-	outl(val, card->io_port + CSR4);	/* Send descriptor address */
+	xw32(CSR3, val);	/* Receive descriptor address */
+	xw32(CSR4, val);	/* Send descriptor address */
 }
 
 /*
@@ -646,17 +646,17 @@ This function also clears the status-bit.
 */
 static int link_status_changed(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR5);	/* Status register */
-
-	if ((val & (1 << 27)) == 0)		/* no change */
+	val = xr32(CSR5);	/* Status register */
+	if (!(val & (1 << 27)))	/* no change */
 		return 0;
 
 	/* clear the event by writing a 1 to the bit in the
 	   status register. */
 	val = (1 << 27);
-	outl(val, card->io_port + CSR5);
+	xw32(CSR5, val);
 
 	return 1;
 }
@@ -668,11 +668,9 @@ in a non-stopped state.
 */
 static int transmit_active(struct xircom_private *card)
 {
-	unsigned int val;
-
-	val = inl(card->io_port + CSR5);	/* Status register */
+	void __iomem *ioaddr = card->ioaddr;
 
-	if ((val & (7 << 20)) == 0)		/* transmitter disabled */
+	if (!(xr32(CSR5) & (7 << 20)))	/* transmitter disabled */
 		return 0;
 
 	return 1;
@@ -684,11 +682,9 @@ in a non-stopped state.
 */
 static int receive_active(struct xircom_private *card)
 {
-	unsigned int val;
-
-	val = inl(card->io_port + CSR5);	/* Status register */
+	void __iomem *ioaddr = card->ioaddr;
 
-	if ((val & (7 << 17)) == 0)		/* receiver disabled */
+	if (!(xr32(CSR5) & (7 << 17)))	/* receiver disabled */
 		return 0;
 
 	return 1;
@@ -706,10 +702,11 @@ must be called with the lock held and interrupts disabled.
 */
 static void activate_receiver(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 
 	/* If the "active" bit is set and the receiver is already
 	   active, no need to do the expensive thing */
@@ -718,7 +715,7 @@ static void activate_receiver(struct xircom_private *card)
 
 
 	val = val & ~2;		/* disable the receiver */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -732,9 +729,9 @@ static void activate_receiver(struct xircom_private *card)
 	}
 
 	/* enable the receiver */
-	val = inl(card->io_port + CSR6);	/* Operation mode */
-	val = val | 2;				/* enable the receiver */
-	outl(val, card->io_port + CSR6);
+	val = xr32(CSR6);	/* Operation mode */
+	val = val | 2;		/* enable the receiver */
+	xw32(CSR6, val);
 
 	/* now wait for the card to activate again */
 	counter = 10;
@@ -759,12 +756,13 @@ must be called with the lock held and interrupts disabled.
 */
 static void deactivate_receiver(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
-	val = val & ~2;				/* disable the receiver */
-	outl(val, card->io_port + CSR6);
+	val = xr32(CSR6);	/* Operation mode */
+	val = val & ~2;		/* disable the receiver */
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -791,10 +789,11 @@ must be called with the lock held and interrupts disabled.
 */
 static void activate_transmitter(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 
 	/* If the "active" bit is set and the receiver is already
 	   active, no need to do the expensive thing */
@@ -802,7 +801,7 @@ static void activate_transmitter(struct xircom_private *card)
 		return;
 
 	val = val & ~(1 << 13);	/* disable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 10;
 	while (counter > 0) {
@@ -817,9 +816,9 @@ static void activate_transmitter(struct xircom_private *card)
 	}
 
 	/* enable the transmitter */
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 	val = val | (1 << 13);	/* enable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	/* now wait for the card to activate again */
 	counter = 10;
@@ -844,12 +843,13 @@ must be called with the lock held and interrupts disabled.
 */
 static void deactivate_transmitter(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 	int counter;
 
-	val = inl(card->io_port + CSR6);	/* Operation mode */
+	val = xr32(CSR6);	/* Operation mode */
 	val = val & ~2;		/* disable the transmitter */
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	counter = 20;
 	while (counter > 0) {
@@ -872,11 +872,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_transmit_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val |= 1;				/* enable the transmit interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val |= 1;		/* enable the transmit interrupt */
+	xw32(CSR7, val);
 }
 
 
@@ -887,11 +888,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_receive_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val = val | (1 << 6);			/* enable the receive interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val = val | (1 << 6);	/* enable the receive interrupt */
+	xw32(CSR7, val);
 }
 
 /*
@@ -901,11 +903,12 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_link_interrupt(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
-	val = val | (1 << 27);			/* enable the link status chage interrupt */
-	outl(val, card->io_port + CSR7);
+	val = xr32(CSR7);	/* Interrupt enable register */
+	val = val | (1 << 27);	/* enable the link status chage interrupt */
+	xw32(CSR7, val);
 }
 
 
@@ -917,10 +920,9 @@ must be called with the lock held and interrupts disabled.
 */
 static void disable_all_interrupts(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
 
-	val = 0;				/* disable all interrupts */
-	outl(val, card->io_port + CSR7);
+	xw32(CSR7, 0);
 }
 
 /*
@@ -930,9 +932,10 @@ must be called with the lock held and interrupts disabled.
 */
 static void enable_common_interrupts(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR7);	/* Interrupt enable register */
+	val = xr32(CSR7);	/* Interrupt enable register */
 	val |= (1<<16); /* Normal Interrupt Summary */
 	val |= (1<<15); /* Abnormal Interrupt Summary */
 	val |= (1<<13); /* Fatal bus error */
@@ -941,7 +944,7 @@ static void enable_common_interrupts(struct xircom_private *card)
 	val |= (1<<5);  /* Transmit Underflow */
 	val |= (1<<2);  /* Transmit Buffer Unavailable */
 	val |= (1<<1);  /* Transmit Process Stopped */
-	outl(val, card->io_port + CSR7);
+	xw32(CSR7, val);
 }
 
 /*
@@ -951,11 +954,12 @@ must be called with the lock held and interrupts disabled.
 */
 static int enable_promisc(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned int val;
 
-	val = inl(card->io_port + CSR6);
+	val = xr32(CSR6);
 	val = val | (1 << 6);
-	outl(val, card->io_port + CSR6);
+	xw32(CSR6, val);
 
 	return 1;
 }
@@ -970,13 +974,16 @@ Must be called in locked state with interrupts disabled
 */
 static int link_status(struct xircom_private *card)
 {
-	unsigned int val;
+	void __iomem *ioaddr = card->ioaddr;
+	u8 val;
 
-	val = inb(card->io_port + CSR12);
+	val = xr8(CSR12);
 
-	if (!(val&(1<<2)))  /* bit 2 is 0 for 10mbit link, 1 for not an 10mbit link */
+	/* bit 2 is 0 for 10mbit link, 1 for not an 10mbit link */
+	if (!(val & (1 << 2)))
 		return 10;
-	if (!(val&(1<<1)))  /* bit 1 is 0 for 100mbit link, 1 for not an 100mbit link */
+	/* bit 1 is 0 for 100mbit link, 1 for not an 100mbit link */
+	if (!(val & (1 << 1)))
 		return 100;
 
 	/* If we get here -> no link at all */
@@ -995,29 +1002,31 @@ static int link_status(struct xircom_private *card)
  */
 static void read_mac_address(struct xircom_private *card)
 {
-	unsigned char j, tuple, link, data_id, data_count;
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
+	u8 link;
 	int i;
 
 	spin_lock_irqsave(&card->lock, flags);
 
-	outl(1 << 12, card->io_port + CSR9);	/* enable boot rom access */
+	xw32(CSR9, 1 << 12);	/* enable boot rom access */
 	for (i = 0x100; i < 0x1f7; i += link + 2) {
-		outl(i, card->io_port + CSR10);
-		tuple = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 1, card->io_port + CSR10);
-		link = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 2, card->io_port + CSR10);
-		data_id = inl(card->io_port + CSR9) & 0xff;
-		outl(i + 3, card->io_port + CSR10);
-		data_count = inl(card->io_port + CSR9) & 0xff;
+		u8 tuple, data_id, data_count;
+
+		xw32(CSR10, i);
+		tuple = xr32(CSR9);
+		xw32(CSR10, i + 1);
+		link = xr32(CSR9);
+		xw32(CSR10, i + 2);
+		data_id = xr32(CSR9);
+		xw32(CSR10, i + 3);
+		data_count = xr32(CSR9);
 		if ((tuple == 0x22) && (data_id == 0x04) && (data_count == 0x06)) {
-			/*
-			 * This is it.  We have the data we want.
-			 */
+			int j;
+
 			for (j = 0; j < 6; j++) {
-				outl(i + j + 4, card->io_port + CSR10);
-				card->dev->dev_addr[j] = inl(card->io_port + CSR9) & 0xff;
+				xw32(CSR10, i + j + 4);
+				card->dev->dev_addr[j] = xr32(CSR9) & 0xff;
 			}
 			break;
 		} else if (link == 0) {
@@ -1036,6 +1045,7 @@ static void read_mac_address(struct xircom_private *card)
  */
 static void transceiver_voodoo(struct xircom_private *card)
 {
+	void __iomem *ioaddr = card->ioaddr;
 	unsigned long flags;
 
 	/* disable all powermanagement */
@@ -1045,14 +1055,14 @@ static void transceiver_voodoo(struct xircom_private *card)
 
 	spin_lock_irqsave(&card->lock, flags);
 
-	outl(0x0008, card->io_port + CSR15);
-        udelay(25);
-        outl(0xa8050000, card->io_port + CSR15);
-        udelay(25);
-        outl(0xa00f0000, card->io_port + CSR15);
-        udelay(25);
+	xw32(CSR15, 0x0008);
+	udelay(25);
+	xw32(CSR15, 0xa8050000);
+	udelay(25);
+	xw32(CSR15, 0xa00f0000);
+	udelay(25);
 
-        spin_unlock_irqrestore(&card->lock, flags);
+	spin_unlock_irqrestore(&card->lock, flags);
 
 	netif_start_queue(card->dev);
 }
-- 
Ueimor

Will code drivers for food.
