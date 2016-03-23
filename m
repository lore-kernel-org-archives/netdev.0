From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] drivers: net: ethernet: dlink: dl2k: fix indent
Date: Wed, 23 Mar 2016 10:34:57 -0700
Message-ID: <1458754497.6819.10.camel@perches.com>
References: <1458748660-10571-1-git-send-email-mussitantesmortem@gmail.com>
	 <1458748660-10571-2-git-send-email-mussitantesmortem@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Maxim Zhukov <mussitantesmortem@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458748660-10571-2-git-send-email-mussitantesmortem@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If dl2k is modified at all, maybe convert the
printks to netdev_<level> too so that the logging
output is more like other networking drivers.

Something like:
---
=A0drivers/net/ethernet/dlink/dl2k.c | 181 +++++++++++++++++++++-------=
----------
=A01 file changed, 100 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/d=
link/dl2k.c
index f92b6d9..0f0326b 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -10,9 +10,9 @@
=A0=A0=A0=A0=A0(at your option) any later version.
=A0*/
=A0
-#define DRV_NAME	"DL2000/TC902x-based linux driver"
=A0#define DRV_VERSION	"v1.19"
=A0#define DRV_RELDATE	"2007/08/12"
+
=A0#include "dl2k.h"
=A0#include <linux/dma-mapping.h>
=A0
@@ -23,8 +23,6 @@
=A0#define dr16(reg)	ioread16(ioaddr + (reg))
=A0#define dr8(reg)	ioread8(ioaddr + (reg))
=A0
-static char version[] =3D
-=A0=A0=A0=A0=A0=A0KERN_INFO DRV_NAME " " DRV_VERSION " " DRV_RELDATE "=
\n";
=A0#define MAX_UNITS 8
=A0static int mtu[MAX_UNITS];
=A0static int vlan[MAX_UNITS];
@@ -118,12 +116,11 @@ rio_probe1 (struct pci_dev *pdev, const struct pc=
i_device_id *ent)
=A0	int chip_idx =3D ent->driver_data;
=A0	int err, irq;
=A0	void __iomem *ioaddr;
-	static int version_printed;
=A0	void *ring_space;
=A0	dma_addr_t ring_dma;
=A0
-	if (!version_printed++)
-		printk ("%s", version);
+	pr_info_once("DL2000/TC902x-based linux driver %s %s\n",
+		=A0=A0=A0=A0=A0DRV_VERSION, DRV_RELDATE);
=A0
=A0	err =3D pci_enable_device (pdev);
=A0	if (err)
@@ -274,18 +271,20 @@ rio_probe1 (struct pci_dev *pdev, const struct pc=
i_device_id *ent)
=A0
=A0	card_idx++;
=A0
-	printk (KERN_INFO "%s: %s, %pM, IRQ %d\n",
-		dev->name, np->name, dev->dev_addr, irq);
+	netdev_info(dev, "%s, %pM, IRQ %d\n",
+		=A0=A0=A0=A0np->name, dev->dev_addr, irq);
=A0	if (tx_coalesce > 1)
-		printk(KERN_INFO "tx_coalesce:\t%d packets\n",
-				tx_coalesce);
-	if (np->coalesce)
-		printk(KERN_INFO
-		=A0=A0=A0=A0=A0=A0=A0"rx_coalesce:\t%d packets\n"
-		=A0=A0=A0=A0=A0=A0=A0"rx_timeout: \t%d ns\n",
-				np->rx_coalesce, np->rx_timeout*640);
+		netdev_info(dev, "tx_coalesce:\t%d packets\n",
+			=A0=A0=A0=A0tx_coalesce);
+	if (np->coalesce) {
+		netdev_info(dev, "rx_coalesce:\t%d packets\n",
+			=A0=A0=A0=A0np->rx_coalesce);
+		netdev_info(dev, "rx_timeout: \t%d ns\n",
+			=A0=A0=A0=A0np->rx_timeout * 640);
+	}
=A0	if (np->vlan)
-		printk(KERN_INFO "vlan(id):\t%d\n", np->vlan);
+		netdev_info(dev, "vlan(id):\t%d\n", np->vlan);
+
=A0	return 0;
=A0
=A0err_out_unmap_rx:
@@ -322,7 +321,7 @@ find_miiphy (struct net_device *dev)
=A0		}
=A0	}
=A0	if (!phy_found) {
-		printk (KERN_ERR "%s: No MII PHY found!\n", dev->name);
+		netdev_err(dev, "No MII PHY found!\n");
=A0		return -ENODEV;
=A0	}
=A0	return 0;
@@ -348,8 +347,7 @@ parse_eeprom (struct net_device *dev)
=A0		/* Check CRC */
=A0		crc =3D ~ether_crc_le (256 - 4, sromdata);
=A0		if (psrom->crc !=3D cpu_to_le32(crc)) {
-			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
-					dev->name);
+			netdev_err(dev, "EEPROM data CRC error\n");
=A0			return -1;
=A0		}
=A0	}
@@ -374,7 +372,7 @@ parse_eeprom (struct net_device *dev)
=A0		cid =3D psib[i++];
=A0		next =3D psib[i++];
=A0		if ((cid =3D=3D 0 && next =3D=3D 0) || (cid =3D=3D 0xff && next =3D=
=3D 0xff)) {
-			printk (KERN_ERR "Cell data error\n");
+			netdev_err(dev, "Cell data error\n");
=A0			return -1;
=A0		}
=A0		switch (cid) {
@@ -664,7 +662,7 @@ rio_timer (unsigned long data)
=A0	spin_lock_irqsave(&np->rx_lock, flags);
=A0	/* Recover rx ring exhausted error */
=A0	if (np->cur_rx - np->old_rx >=3D RX_RING_SIZE) {
-		printk(KERN_INFO "Try to recover rx ring exhausted...\n");
+		netdev_info(dev, "Trying to recover, rx ring exhausted...\n");
=A0		/* Re-allocate skbuffs to fill the descriptor ring */
=A0		for (; np->cur_rx - np->old_rx > 0; np->old_rx++) {
=A0			struct sk_buff *skb;
@@ -675,9 +673,8 @@ rio_timer (unsigned long data)
=A0								np->rx_buf_sz);
=A0				if (skb =3D=3D NULL) {
=A0					np->rx_ring[entry].fraginfo =3D 0;
-					printk (KERN_INFO
-						"%s: Still unable to re-allocate Rx skbuff.#%d\n",
-						dev->name, entry);
+					netdev_info(dev, "Still unable to re-allocate Rx skbuff.#%d\n",
+						=A0=A0=A0=A0entry);
=A0					break;
=A0				}
=A0				np->rx_skbuff[entry] =3D skb;
@@ -702,8 +699,8 @@ rio_tx_timeout (struct net_device *dev)
=A0	struct netdev_private *np =3D netdev_priv(dev);
=A0	void __iomem *ioaddr =3D np->ioaddr;
=A0
-	printk (KERN_INFO "%s: Tx timed out (%4.4x), is buffer full?\n",
-		dev->name, dr32(TxStatus));
+	netdev_info(dev, "Tx timed out (%04x), is buffer full?\n",
+		=A0=A0=A0=A0dr32(TxStatus));
=A0	rio_free_tx(dev, 0);
=A0	dev->if_port =3D 0;
=A0	dev->trans_start =3D jiffies; /* prevent tx timeout */
@@ -874,8 +871,8 @@ tx_error (struct net_device *dev, int tx_status)
=A0	int i;
=A0
=A0	frame_id =3D (tx_status & 0xffff0000);
-	printk (KERN_ERR "%s: Transmit error, TxStatus %4.4x, FrameId %d.\n",
-		dev->name, tx_status, frame_id);
+	netdev_err(dev, "Transmit error, TxStatus %04x, FrameId %d\n",
+		=A0=A0=A0tx_status, frame_id);
=A0	np->stats.tx_errors++;
=A0	/* Ttransmit Underrun */
=A0	if (tx_status & 0x10) {
@@ -1007,10 +1004,8 @@ receive_packet (struct net_device *dev)
=A0			skb =3D netdev_alloc_skb_ip_align(dev, np->rx_buf_sz);
=A0			if (skb =3D=3D NULL) {
=A0				np->rx_ring[entry].fraginfo =3D 0;
-				printk (KERN_INFO
-					"%s: receive_packet: "
-					"Unable to re-allocate Rx skbuff.#%d\n",
-					dev->name, entry);
+				netdev_info(dev, "receive_packet: Unable to re-allocate Rx skbuff.=
#%d\n",
+					=A0=A0=A0=A0entry);
=A0				break;
=A0			}
=A0			np->rx_skbuff[entry] =3D skb;
@@ -1039,7 +1034,7 @@ rio_error (struct net_device *dev, int int_status=
)
=A0	/* Link change event */
=A0	if (int_status & LinkEvent) {
=A0		if (mii_wait_link (dev, 10) =3D=3D 0) {
-			printk (KERN_INFO "%s: Link up\n", dev->name);
+			netdev_info(dev, "Link up\n");
=A0			if (np->phy_media)
=A0				mii_get_media_pcs (dev);
=A0			else
@@ -1059,7 +1054,7 @@ rio_error (struct net_device *dev, int int_status=
)
=A0			np->link_status =3D 1;
=A0			netif_carrier_on(dev);
=A0		} else {
-			printk (KERN_INFO "%s: Link off\n", dev->name);
+			netdev_info(dev, "Link off\n");
=A0			np->link_status =3D 0;
=A0			netif_carrier_off(dev);
=A0		}
@@ -1073,8 +1068,7 @@ rio_error (struct net_device *dev, int int_status=
)
=A0	/* PCI Error, a catastronphic error related to the bus interface
=A0	=A0=A0=A0occurs, set GlobalReset and HostReset to reset. */
=A0	if (int_status & HostError) {
-		printk (KERN_ERR "%s: HostError! IntStatus %4.4x.\n",
-			dev->name, int_status);
+		netdev_err(dev, "HostError! IntStatus %04x\n", int_status);
=A0		dw16(ASICCtrl + 2, GlobalReset | HostReset);
=A0		mdelay (500);
=A0		rio_set_led_mode(dev);
@@ -1325,7 +1319,7 @@ static int rio_set_settings(struct net_device *de=
v, struct ethtool_cmd *cmd)
=A0		if (np->speed =3D=3D 1000) {
=A0			ethtool_cmd_speed_set(cmd, SPEED_100);
=A0			cmd->duplex =3D DUPLEX_FULL;
-			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, chang=
e to Manual 100Mbps, Full duplex.\n");
+			netdev_warn(dev, "Can't disable Auto negotiation in 1000Mbps, chang=
e to Manual 100Mbps, Full duplex\n");
=A0		}
=A0		switch (ethtool_cmd_speed(cmd)) {
=A0		case SPEED_10:
@@ -1515,6 +1509,9 @@ mii_get_media (struct net_device *dev)
=A0	__u16 mssr;
=A0	int phy_addr;
=A0	struct netdev_private *np;
+	const char *how;
+	const char *speed;
+	const char *duplex;
=A0
=A0	np =3D netdev_priv(dev);
=A0	phy_addr =3D np->phy_addr;
@@ -1525,6 +1522,7 @@ mii_get_media (struct net_device *dev)
=A0			/* Auto-Negotiation not completed */
=A0			return -1;
=A0		}
+		how =3D "Auto";
=A0		negotiate =3D mii_read (dev, phy_addr, MII_ADVERTISE) &
=A0			mii_read (dev, phy_addr, MII_LPA);
=A0		mscr =3D mii_read (dev, phy_addr, MII_CTRL1000);
@@ -1532,27 +1530,36 @@ mii_get_media (struct net_device *dev)
=A0		if (mscr & ADVERTISE_1000FULL && mssr & LPA_1000FULL) {
=A0			np->speed =3D 1000;
=A0			np->full_duplex =3D 1;
-			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
+			speed =3D "1000";
+			duplex =3D "Full";
=A0		} else if (mscr & ADVERTISE_1000HALF && mssr & LPA_1000HALF) {
=A0			np->speed =3D 1000;
=A0			np->full_duplex =3D 0;
-			printk (KERN_INFO "Auto 1000 Mbps, Half duplex\n");
+			speed =3D "1000";
+			duplex =3D "Half";
=A0		} else if (negotiate & ADVERTISE_100FULL) {
=A0			np->speed =3D 100;
=A0			np->full_duplex =3D 1;
-			printk (KERN_INFO "Auto 100 Mbps, Full duplex\n");
+			speed =3D "100";
+			duplex =3D "Full";
=A0		} else if (negotiate & ADVERTISE_100HALF) {
=A0			np->speed =3D 100;
=A0			np->full_duplex =3D 0;
-			printk (KERN_INFO "Auto 100 Mbps, Half duplex\n");
+			speed =3D "100";
+			duplex =3D "Half";
=A0		} else if (negotiate & ADVERTISE_10FULL) {
=A0			np->speed =3D 10;
=A0			np->full_duplex =3D 1;
-			printk (KERN_INFO "Auto 10 Mbps, Full duplex\n");
+			speed =3D "10";
+			duplex =3D "Full";
=A0		} else if (negotiate & ADVERTISE_10HALF) {
=A0			np->speed =3D 10;
=A0			np->full_duplex =3D 0;
-			printk (KERN_INFO "Auto 10 Mbps, Half duplex\n");
+			speed =3D "10";
+			duplex =3D "Half";
+		} else {
+			speed =3D "unknown";
+			duplex =3D "unknown";
=A0		}
=A0		if (negotiate & ADVERTISE_PAUSE_CAP) {
=A0			np->tx_flow &=3D 1;
@@ -1564,30 +1571,33 @@ mii_get_media (struct net_device *dev)
=A0		/* else tx_flow, rx_flow =3D user select=A0=A0*/
=A0	} else {
=A0		__u16 bmcr =3D mii_read (dev, phy_addr, MII_BMCR);
+
+		how =3D "Operating at";
=A0		switch (bmcr & (BMCR_SPEED100 | BMCR_SPEED1000)) {
=A0		case BMCR_SPEED1000:
-			printk (KERN_INFO "Operating at 1000 Mbps, ");
+			speed =3D "1000";
=A0			break;
=A0		case BMCR_SPEED100:
-			printk (KERN_INFO "Operating at 100 Mbps, ");
+			speed =3D "100";
=A0			break;
=A0		case 0:
-			printk (KERN_INFO "Operating at 10 Mbps, ");
-		}
-		if (bmcr & BMCR_FULLDPLX) {
-			printk (KERN_CONT "Full duplex\n");
-		} else {
-			printk (KERN_CONT "Half duplex\n");
+			speed =3D "10";
+			break;
+		default:
+			speed =3D "unknown";
+			break;
=A0		}
+		if (bmcr & BMCR_FULLDPLX)
+			duplex =3D "Full";
+		else
+			duplex =3D "Half";
+
=A0	}
-	if (np->tx_flow)
-		printk(KERN_INFO "Enable Tx Flow Control\n");
-	else
-		printk(KERN_INFO "Disable Tx Flow Control\n");
-	if (np->rx_flow)
-		printk(KERN_INFO "Enable Rx Flow Control\n");
-	else
-		printk(KERN_INFO "Disable Rx Flow Control\n");
+
+	netdev_info(dev, "%s %s Mbps, %s duplex, Tx Flow Control: %s Rx Flow =
Control: %s\n",
+		=A0=A0=A0=A0how, speed, duplex,
+		=A0=A0=A0=A0np->tx_flow ? "Enabled" : "Disabled",
+		=A0=A0=A0=A0np->rx_flow ? "Enabled" : "Disabled");
=A0
=A0	return 0;
=A0}
@@ -1636,6 +1646,10 @@ mii_set_media (struct net_device *dev)
=A0		mii_write (dev, phy_addr, MII_BMCR, bmcr);
=A0		mdelay(1);
=A0	} else {
+		const char *how =3D "Manual";
+		const char *speed =3D "unknown";
+		const char *duplex =3D "unknown";
+
=A0		/* Force speed setting */
=A0		/* 1) Disable Auto crossover */
=A0		pscr =3D mii_read (dev, phy_addr, MII_PHY_SCR);
@@ -1659,16 +1673,18 @@ mii_set_media (struct net_device *dev)
=A0		bmcr =3D BMCR_PDOWN;
=A0		if (np->speed =3D=3D 100) {
=A0			bmcr |=3D BMCR_SPEED100;
-			printk (KERN_INFO "Manual 100 Mbps, ");
+			speed =3D "100";
=A0		} else if (np->speed =3D=3D 10) {
-			printk (KERN_INFO "Manual 10 Mbps, ");
+			speed =3D "10";
=A0		}
=A0		if (np->full_duplex) {
=A0			bmcr |=3D BMCR_FULLDPLX;
-			printk (KERN_CONT "Full duplex\n");
+			duplex =3D "Full";
=A0		} else {
-			printk (KERN_CONT "Half duplex\n");
+			duplex =3D "Half";
=A0		}
+		netdev_info(dev, "%s %s Mbps, %s duplex\n",
+			=A0=A0=A0=A0how, speed, duplex);
=A0#if 0
=A0		/* Set 1000BaseT Master/Slave setting */
=A0		mscr =3D mii_read (dev, phy_addr, MII_CTRL1000);
@@ -1688,6 +1704,9 @@ mii_get_media_pcs (struct net_device *dev)
=A0	__u16 bmsr;
=A0	int phy_addr;
=A0	struct netdev_private *np;
+	const char *how;
+	const char *speed;
+	const char *duplex;
=A0
=A0	np =3D netdev_priv(dev);
=A0	phy_addr =3D np->phy_addr;
@@ -1698,15 +1717,17 @@ mii_get_media_pcs (struct net_device *dev)
=A0			/* Auto-Negotiation not completed */
=A0			return -1;
=A0		}
+		how =3D "Auto";
=A0		negotiate =3D mii_read (dev, phy_addr, PCS_ANAR) &
=A0			mii_read (dev, phy_addr, PCS_ANLPAR);
=A0		np->speed =3D 1000;
+		speed =3D "1000";
=A0		if (negotiate & PCS_ANAR_FULL_DUPLEX) {
-			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
=A0			np->full_duplex =3D 1;
+			duplex =3D "Full";
=A0		} else {
-			printk (KERN_INFO "Auto 1000 Mbps, half duplex\n");
=A0			np->full_duplex =3D 0;
+			duplex =3D "Half";
=A0		}
=A0		if (negotiate & PCS_ANAR_PAUSE) {
=A0			np->tx_flow &=3D 1;
@@ -1718,21 +1739,19 @@ mii_get_media_pcs (struct net_device *dev)
=A0		/* else tx_flow, rx_flow =3D user select=A0=A0*/
=A0	} else {
=A0		__u16 bmcr =3D mii_read (dev, phy_addr, PCS_BMCR);
-		printk (KERN_INFO "Operating at 1000 Mbps, ");
-		if (bmcr & BMCR_FULLDPLX) {
-			printk (KERN_CONT "Full duplex\n");
-		} else {
-			printk (KERN_CONT "Half duplex\n");
-		}
+
+		how =3D "Operating at";
+		speed =3D "1000";
+		if (bmcr & BMCR_FULLDPLX)
+			duplex =3D "Full";
+		else
+			duplex =3D "Half";
=A0	}
-	if (np->tx_flow)
-		printk(KERN_INFO "Enable Tx Flow Control\n");
-	else
-		printk(KERN_INFO "Disable Tx Flow Control\n");
-	if (np->rx_flow)
-		printk(KERN_INFO "Enable Rx Flow Control\n");
-	else
-		printk(KERN_INFO "Disable Rx Flow Control\n");
+
+	netdev_info(dev, "%s %s Mbps, %s duplex, Tx Flow Control: %s Rx Flow =
Control: %s\n",
+		=A0=A0=A0=A0how, speed, duplex,
+		=A0=A0=A0=A0np->tx_flow ? "Enabled" : "Disabled",
+		=A0=A0=A0=A0np->rx_flow ? "Enabled" : "Disabled");
=A0
=A0	return 0;
=A0}
@@ -1775,10 +1794,10 @@ mii_set_media_pcs (struct net_device *dev)
=A0		mdelay(10);
=A0		if (np->full_duplex) {
=A0			bmcr =3D BMCR_FULLDPLX;
-			printk (KERN_INFO "Manual full duplex\n");
+			netdev_info(dev, "Manual full duplex\n");
=A0		} else {
=A0			bmcr =3D 0;
-			printk (KERN_INFO "Manual half duplex\n");
+			netdev_info(dev, "Manual half duplex\n");
=A0		}
=A0		mii_write (dev, phy_addr, MII_BMCR, bmcr);
=A0		mdelay(10);
