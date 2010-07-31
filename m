From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 18/29] LMC: strip "lmc_" prefix from field names in struct card.
Date: Sat, 31 Jul 2010 17:05:41 +0200
Message-ID: <1280588752-9340-18-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59291 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756541Ab0GaPG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:26 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |  629 +++++++++++++++++++++--------------=
--------
 drivers/net/wan/lmc/media.c |  144 +++++-----
 drivers/net/wan/lmc/var.h   |   70 +++---
 3 files changed, 421 insertions(+), 422 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 64bd6d5..6698aa9 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -149,11 +149,11 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			break;
 		}
=20
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		sc->lmc_media->set_status(sc, &ctl);
+		spin_lock_irqsave(&sc->lock, flags);
+		sc->media->set_status(sc, &ctl);
=20
 		if (ctl.crc_length !=3D sc->ictl.crc_length) {
-			sc->lmc_media->set_crc_length(sc, ctl.crc_length);
+			sc->media->set_crc_length(sc, ctl.crc_length);
 			if (sc->ictl.crc_length =3D=3D LMC_CTL_CRC_LENGTH_16)
 				sc->TxDescriptControlInit |=3D
 					LMC_TDES_ADD_CRC_DISABLE;
@@ -161,29 +161,29 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 				sc->TxDescriptControlInit &=3D
 					~LMC_TDES_ADD_CRC_DISABLE;
 		}
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		spin_unlock_irqrestore(&sc->lock, flags);
 		ret =3D 0;
 		break;
=20
 	case LMCIOCGETXINFO:
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		sc->lmc_xinfo.Magic0 =3D 0xBEEFCAFE;
-
-		sc->lmc_xinfo.PciCardType =3D sc->lmc_cardtype;
-		sc->lmc_xinfo.PciSlotNumber =3D 0;
-		sc->lmc_xinfo.DriverMajorVersion =3D DRIVER_MAJOR_VERSION;
-		sc->lmc_xinfo.DriverMinorVersion =3D DRIVER_MINOR_VERSION;
-		sc->lmc_xinfo.DriverSubVersion =3D DRIVER_SUB_VERSION;
-		sc->lmc_xinfo.XilinxRevisionNumber =3D
+		spin_lock_irqsave(&sc->lock, flags);
+		sc->xinfo.Magic0 =3D 0xBEEFCAFE;
+
+		sc->xinfo.PciCardType =3D sc->cardtype;
+		sc->xinfo.PciSlotNumber =3D 0;
+		sc->xinfo.DriverMajorVersion =3D DRIVER_MAJOR_VERSION;
+		sc->xinfo.DriverMinorVersion =3D DRIVER_MINOR_VERSION;
+		sc->xinfo.DriverSubVersion =3D DRIVER_SUB_VERSION;
+		sc->xinfo.XilinxRevisionNumber =3D
 			lmc_mii_readreg(sc, 0, 3) & 0xf;
-		sc->lmc_xinfo.MaxFrameSize =3D LMC_PKT_BUF_SZ;
-		sc->lmc_xinfo.link_status =3D sc->lmc_media->get_link_status(sc);
-		sc->lmc_xinfo.mii_reg16 =3D lmc_mii_readreg(sc, 0, 16);
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		sc->xinfo.MaxFrameSize =3D LMC_PKT_BUF_SZ;
+		sc->xinfo.link_status =3D sc->media->get_link_status(sc);
+		sc->xinfo.mii_reg16 =3D lmc_mii_readreg(sc, 0, 16);
+		spin_unlock_irqrestore(&sc->lock, flags);
=20
-		sc->lmc_xinfo.Magic1 =3D 0xDEADBEEF;
+		sc->xinfo.Magic1 =3D 0xDEADBEEF;
=20
-		if (copy_to_user(ifr->ifr_data, &sc->lmc_xinfo,
+		if (copy_to_user(ifr->ifr_data, &sc->xinfo,
 				 sizeof(struct lmc_xinfo)))
 			ret =3D -EFAULT;
 		else
@@ -191,8 +191,8 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		break;
=20
 	case LMCIOCGETLMCSTATS:
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		if (sc->lmc_cardtype =3D=3D LMC_CARDTYPE_T1) {
+		spin_lock_irqsave(&sc->lock, flags);
+		if (sc->cardtype =3D=3D LMC_CARDTYPE_T1) {
 			lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
 			sc->extra_stats.framingBitErrorCount +=3D
 				lmc_mii_readreg(sc, 0, 18) & 0xff;
@@ -215,10 +215,10 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			sc->extra_stats.severelyErroredFrameCount +=3D
 				regVal & T1FRAMER_SEF_MASK;
 		}
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
-		if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
-				 sizeof(sc->lmc_device->stats)) ||
-		    copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
+		spin_unlock_irqrestore(&sc->lock, flags);
+		if (copy_to_user(ifr->ifr_data, &sc->netdev->stats,
+				 sizeof(sc->netdev->stats)) ||
+		    copy_to_user(ifr->ifr_data + sizeof(sc->netdev->stats),
 				 &sc->extra_stats, sizeof(sc->extra_stats)))
 			ret =3D -EFAULT;
 		else
@@ -231,15 +231,14 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			break;
 		}
=20
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		memset(&sc->lmc_device->stats, 0,
-		       sizeof(sc->lmc_device->stats));
+		spin_lock_irqsave(&sc->lock, flags);
+		memset(&sc->netdev->stats, 0, sizeof(sc->netdev->stats));
 		memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
 		sc->extra_stats.check =3D STATCHECK;
 		sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
-			sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
-		sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			sizeof(sc->netdev->stats) + sizeof(sc->extra_stats);
+		sc->extra_stats.cardtype =3D sc->cardtype;
+		spin_unlock_irqrestore(&sc->lock, flags);
 		ret =3D 0;
 		break;
=20
@@ -259,11 +258,11 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			ret =3D -EFAULT;
 			break;
 		}
-		spin_lock_irqsave(&sc->lmc_lock, flags);
-		if (sc->lmc_media->set_circuit_type)
-			sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
+		spin_lock_irqsave(&sc->lock, flags);
+		if (sc->media->set_circuit_type)
+			sc->media->set_circuit_type(sc, ctl.circuit_type);
 		sc->ictl.circuit_type =3D ctl.circuit_type;
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		spin_unlock_irqrestore(&sc->lock, flags);
 		ret =3D 0;
 		break;
=20
@@ -273,7 +272,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			break;
 		}
=20
-		spin_lock_irqsave(&sc->lmc_lock, flags);
+		spin_lock_irqsave(&sc->lock, flags);
 		/* Reset driver and bring back to current state */
 		pr_debug("%s: REG16 before reset +%04x\n", dev->name,
 			 lmc_mii_readreg(sc, 0, 16));
@@ -281,12 +280,12 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 		pr_debug("%s: REG16 after reset +%04x\n", dev->name,
 			 lmc_mii_readreg(sc, 0, 16));
=20
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		spin_unlock_irqrestore(&sc->lock, flags);
 		ret =3D 0;
 		break;
=20
 	case LMCIOCT1CONTROL:
-		if (sc->lmc_cardtype !=3D LMC_CARDTYPE_T1) {
+		if (sc->cardtype !=3D LMC_CARDTYPE_T1) {
 			ret =3D -EOPNOTSUPP;
 			break;
 		}
@@ -312,7 +311,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		case lmc_xilinx_reset:
 		{
 			u16 mii;
-			spin_lock_irqsave(&sc->lmc_lock, flags);
+			spin_lock_irqsave(&sc->lock, flags);
 			mii =3D lmc_mii_readreg(sc, 0, 16);
=20
 			/* Make all of them 0 and make */
@@ -325,22 +324,22 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			   the transmitter clock to be internal, but we expect
 			   to reset that later anyway. */
=20
-			sc->lmc_gpio &=3D ~LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio &=3D ~LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			/* hold for more than 10 microseconds */
 			udelay(50);
=20
-			sc->lmc_gpio |=3D LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio |=3D LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			/* stop driving Xilinx-related signals */
 			lmc_gpio_mkinput(sc, 0xff);
=20
 			/* Reset the frammer hardware */
-			if (sc->lmc_media->set_link_status)
-				sc->lmc_media->set_link_status(sc, 1);
-			sc->lmc_media->set_status(sc, NULL);
+			if (sc->media->set_link_status)
+				sc->media->set_link_status(sc, 1);
+			sc->media->set_status(sc, NULL);
 			/* lmc_softreset(sc); */
=20
 			{
@@ -360,7 +359,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 					lmc_led_off(sc, LMC_DS3_LED2);
 				}
 			}
-			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			spin_unlock_irqrestore(&sc->lock, flags);
 			ret =3D 0x0;
 		}
 		break;
@@ -369,7 +368,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		{
 			u16 mii;
 			int timeout =3D 500000;
-			spin_lock_irqsave(&sc->lmc_lock, flags);
+			spin_lock_irqsave(&sc->lock, flags);
 			mii =3D lmc_mii_readreg(sc, 0, 16);
=20
 			/* Make all of them 0 and make input */
@@ -382,14 +381,14 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			   the transmitter clock to be internal, but we expect
 			   to reset that later anyway. */
=20
-			sc->lmc_gpio &=3D ~(LMC_GEP_RESET | LMC_GEP_DP);
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio &=3D ~(LMC_GEP_RESET | LMC_GEP_DP);
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			/* hold for more than 10 microseconds */
 			udelay(50);
=20
-			sc->lmc_gpio |=3D LMC_GEP_DP | LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio |=3D LMC_GEP_DP | LMC_GEP_RESET;
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			/* busy wait for the chip to reset */
 			while ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0 &&
@@ -398,7 +397,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
=20
 			/* stop driving Xilinx-related signals */
 			lmc_gpio_mkinput(sc, 0xff);
-			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			spin_unlock_irqrestore(&sc->lock, flags);
 			ret =3D 0x0;
 			break;
 		}
@@ -433,7 +432,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			       "%s: Starting load of data Len: %d at 0x%p =3D=3D 0x%p\n",
 			       dev->name, xc.len, xc.data, data);
=20
-			spin_lock_irqsave(&sc->lmc_lock, flags);
+			spin_lock_irqsave(&sc->lock, flags);
 			lmc_gpio_mkinput(sc, 0xff);
=20
 			/* Clear the Xilinx and start programming from
@@ -443,11 +442,11 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			   Reset: 0 (active)
 			   DP:    0 (active)
 			   Mode:  1 */
-			sc->lmc_gpio =3D 0x00;
-			sc->lmc_gpio &=3D ~LMC_GEP_DP;
-			sc->lmc_gpio &=3D ~LMC_GEP_RESET;
-			sc->lmc_gpio |=3D  LMC_GEP_MODE;
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio =3D 0x00;
+			sc->gpio &=3D ~LMC_GEP_DP;
+			sc->gpio &=3D ~LMC_GEP_RESET;
+			sc->gpio |=3D  LMC_GEP_MODE;
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			lmc_gpio_mkoutput(sc, LMC_GEP_MODE | LMC_GEP_DP |
 					  LMC_GEP_RESET);
@@ -470,11 +469,11 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			/*
 			 * Set LOAD, DATA, Clock to 1
 			 */
-			sc->lmc_gpio =3D 0x00;
-			sc->lmc_gpio |=3D LMC_GEP_MODE;
-			sc->lmc_gpio |=3D LMC_GEP_DATA;
-			sc->lmc_gpio |=3D LMC_GEP_CLK;
-			LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+			sc->gpio =3D 0x00;
+			sc->gpio |=3D LMC_GEP_MODE;
+			sc->gpio |=3D LMC_GEP_DATA;
+			sc->gpio |=3D LMC_GEP_CLK;
+			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 			lmc_gpio_mkoutput(sc, LMC_GEP_DATA | LMC_GEP_CLK |
 					  LMC_GEP_MODE);
@@ -492,29 +491,29 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 				switch (data[pos]) {
 				case 0:
 					/* Data is 0 */
-					sc->lmc_gpio &=3D ~LMC_GEP_DATA;
+					sc->gpio &=3D ~LMC_GEP_DATA;
 					break;
 				case 1:
 					/* Data is 1 */
-					sc->lmc_gpio |=3D LMC_GEP_DATA;
+					sc->gpio |=3D LMC_GEP_DATA;
 					break;
 				default:
 					printk(KERN_WARNING
 					       "%s Bad data in xilinx programming data at %d, got %d want=
ed 0 or 1\n",
 					       dev->name, pos, data[pos]);
 					/* Assume it's 1 */
-					sc->lmc_gpio |=3D LMC_GEP_DATA;
+					sc->gpio |=3D LMC_GEP_DATA;
 				}
 				/* Clock to zero */
-				sc->lmc_gpio &=3D ~LMC_GEP_CLK;
-				sc->lmc_gpio |=3D LMC_GEP_MODE;
-				LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+				sc->gpio &=3D ~LMC_GEP_CLK;
+				sc->gpio |=3D LMC_GEP_MODE;
+				LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 				udelay(1);
=20
 				/* Put the clack back to one */
-				sc->lmc_gpio |=3D LMC_GEP_CLK;
-				sc->lmc_gpio |=3D LMC_GEP_MODE;
-				LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+				sc->gpio |=3D LMC_GEP_CLK;
+				sc->gpio |=3D LMC_GEP_MODE;
+				LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 				udelay(1);
 			}
 			if ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0) {
@@ -532,12 +531,12 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
=20
 			lmc_gpio_mkinput(sc, 0xff);
=20
-			sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
-			lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+			sc->miireg16 |=3D LMC_MII16_FIFO_RESET;
+			lmc_mii_writereg(sc, 0, 16, sc->miireg16);
=20
-			sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
-			lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-			spin_unlock_irqrestore(&sc->lmc_lock, flags);
+			sc->miireg16 &=3D ~LMC_MII16_FIFO_RESET;
+			lmc_mii_writereg(sc, 0, 16, sc->miireg16);
+			spin_unlock_irqrestore(&sc->lock, flags);
=20
 			kfree(data);
 			ret =3D 0;
@@ -549,12 +548,12 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 		}
=20
 		netif_wake_queue(dev);
-		sc->lmc_txfull =3D 0;
+		sc->txfull =3D 0;
 	}
 	break;
 	default:
 		/* If we don't know what to do, give the protocol a shot. */
-		ret =3D hdlc_ioctl(sc->lmc_device, ifr, cmd);
+		ret =3D hdlc_ioctl(sc->netdev, ifr, cmd);
 		break;
 	}
=20
@@ -574,12 +573,12 @@ static void lmc_watchdog(unsigned long data)
=20
 	lmc_trace(dev, "lmc_watchdog in");
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lock, flags);
=20
 	if (sc->check !=3D 0xBEAFCAFE) {
 		printk(KERN_ERR
 		       "LMC: Corrupt net_device struct, breaking out\n");
-		spin_unlock_irqrestore(&sc->lmc_lock, flags);
+		spin_unlock_irqrestore(&sc->lock, flags);
 		return;
 	}
=20
@@ -589,23 +588,23 @@ static void lmc_watchdog(unsigned long data)
 	 */
=20
 	LMC_CSR_WRITE(sc, csr_15, 0x00000011);
-	sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN | TULIP_CMD_RXRUN;
-	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+	sc->cmdmode |=3D TULIP_CMD_TXRUN | TULIP_CMD_RXRUN;
+	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
=20
-	if (sc->lmc_ok =3D=3D 0)
+	if (sc->ok =3D=3D 0)
 		goto kick_timer;
=20
 	/* --- begin time out check -----------------------------------
 	 * check for a transmit interrupt timeout
 	 * Has the packet xmt vs xmt serviced threshold been exceeded */
-	if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
-	    sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	if (sc->taint_tx =3D=3D sc->last_taint_tx &&
+	    sc->netdev->stats.tx_packets > sc->lasttx_packets &&
 	    sc->tx_TimeoutInd =3D=3D 0) {
=20
 		/* wait for the watchdog to come around again */
 		sc->tx_TimeoutInd =3D 1;
-	} else if (sc->lmc_taint_tx =3D=3D sc->lastlmc_taint_tx &&
-		   sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	} else if (sc->taint_tx =3D=3D sc->last_taint_tx &&
+		   sc->netdev->stats.tx_packets > sc->lasttx_packets &&
 		   sc->tx_TimeoutInd) {
=20
 		sc->tx_TimeoutDisplay =3D 1;
@@ -621,17 +620,17 @@ static void lmc_watchdog(unsigned long data)
=20
 		/* reset the transmit timeout detection flag */
 		sc->tx_TimeoutInd =3D 0;
-		sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
-		sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
+		sc->last_taint_tx =3D sc->taint_tx;
+		sc->lasttx_packets =3D sc->netdev->stats.tx_packets;
 	} else {
 		sc->tx_TimeoutInd =3D 0;
-		sc->lastlmc_taint_tx =3D sc->lmc_taint_tx;
-		sc->lasttx_packets =3D sc->lmc_device->stats.tx_packets;
+		sc->last_taint_tx =3D sc->taint_tx;
+		sc->lasttx_packets =3D sc->netdev->stats.tx_packets;
 	}
=20
 	/* --- end time out check ----------------------------------- */
=20
-	link_status =3D sc->lmc_media->get_link_status(sc);
+	link_status =3D sc->media->get_link_status(sc);
=20
 	/* Hardware level link lost, but the interface is marked as up.
 	   Mark it as down. */
@@ -657,8 +656,8 @@ static void lmc_watchdog(unsigned long data)
 	}
=20
 	/* Call media specific watchdog functions */
-	if (sc->lmc_media->watchdog)
-		sc->lmc_media->watchdog(sc);
+	if (sc->media->watchdog)
+		sc->media->watchdog(sc);
=20
 	/* Poke the transmitter to make sure it never stops, even if we run
 	   out of mem */
@@ -691,7 +690,7 @@ kick_timer:
 	sc->timer.expires =3D jiffies + HZ;
 	add_timer(&sc->timer);
=20
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	spin_unlock_irqrestore(&sc->lock, flags);
=20
 	lmc_trace(dev, "lmc_watchdog out");
 }
@@ -760,7 +759,7 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 	dev->netdev_ops =3D &lmc_ops;
 	dev->watchdog_timeo =3D HZ; /* 1 second */
 	dev->tx_queue_len =3D 100;
-	sc->lmc_device =3D dev;
+	sc->netdev =3D dev;
 	sc->name =3D dev->name;
 	sc->check =3D 0xBEAFCAFE;
 	dev->base_addr =3D pci_resource_start(pdev, 0);
@@ -770,7 +769,7 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
=20
 	/* Init the spin lock so can call it latter */
=20
-	spin_lock_init(&sc->lmc_lock);
+	spin_lock_init(&sc->lock);
 	pci_set_master(pdev);
=20
 	err =3D register_hdlc_device(dev);
@@ -780,8 +779,8 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 		goto err_hdlcdev;
 	}
=20
-	sc->lmc_cardtype =3D LMC_CARDTYPE_UNKNOWN;
-	sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+	sc->cardtype =3D LMC_CARDTYPE_UNKNOWN;
+	sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
=20
 	/*
 	 * Check either the subvendor or the subdevice, some systems reverse
@@ -794,23 +793,23 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
 	switch (subdevice) {
 	case PCI_DEVICE_ID_LMC_HSSI:
 		dev_info(&pdev->dev, "%s =3D LMC HSSI\n", dev->name);
-		sc->lmc_cardtype =3D LMC_CARDTYPE_HSSI;
-		sc->lmc_media =3D &lmc_hssi_media;
+		sc->cardtype =3D LMC_CARDTYPE_HSSI;
+		sc->media =3D &lmc_hssi_media;
 		break;
 	case PCI_DEVICE_ID_LMC_DS3:
 		dev_info(&pdev->dev, "%s =3D LMC DS3\n", dev->name);
-		sc->lmc_cardtype =3D LMC_CARDTYPE_DS3;
-		sc->lmc_media =3D &lmc_ds3_media;
+		sc->cardtype =3D LMC_CARDTYPE_DS3;
+		sc->media =3D &lmc_ds3_media;
 		break;
 	case PCI_DEVICE_ID_LMC_SSI:
 		dev_info(&pdev->dev, "%s =3D LMC SSI\n", dev->name);
-		sc->lmc_cardtype =3D LMC_CARDTYPE_SSI;
-		sc->lmc_media =3D &lmc_ssi_media;
+		sc->cardtype =3D LMC_CARDTYPE_SSI;
+		sc->media =3D &lmc_ssi_media;
 		break;
 	case PCI_DEVICE_ID_LMC_T1:
 		dev_info(&pdev->dev, "%s =3D LMC T1\n", dev->name);
-		sc->lmc_cardtype =3D LMC_CARDTYPE_T1;
-		sc->lmc_media =3D &lmc_t1_media;
+		sc->cardtype =3D LMC_CARDTYPE_T1;
+		sc->media =3D &lmc_t1_media;
 		break;
 	default:
 		dev_warn(&pdev->dev, "%s =3D LMC UNKNOWN CARD!\n", dev->name);
@@ -820,12 +819,12 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
 	lmc_initcsrs(sc, dev->base_addr, 8);
=20
 	lmc_gpio_mkinput(sc, 0xff);
-	sc->lmc_gpio =3D 0;		/* drive no signals yet */
+	sc->gpio =3D 0;		/* drive no signals yet */
=20
-	sc->lmc_media->defaults(sc);
+	sc->media->defaults(sc);
=20
-	if (sc->lmc_media->set_link_status)
-		sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+	if (sc->media->set_link_status)
+		sc->media->set_link_status(sc, LMC_LINK_UP);
=20
 	/* verify that the PCI Sub System ID matches the Adapter Model number
 	   from the MII register */
@@ -849,10 +848,10 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
 	sc->board_idx =3D cards_found++;
 	sc->extra_stats.check =3D STATCHECK;
 	sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
-		sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
-	sc->extra_stats.lmc_cardtype =3D sc->lmc_cardtype;
+		sizeof(sc->netdev->stats) + sizeof(sc->extra_stats);
+	sc->extra_stats.cardtype =3D sc->cardtype;
=20
-	sc->lmc_ok =3D 0;
+	sc->ok =3D 0;
 	sc->last_link_status =3D 0;
=20
 	lmc_trace(dev, "lmc_init_one out");
@@ -897,7 +896,7 @@ static int lmc_open(struct net_device *dev)
 	lmc_dec_reset(sc);
 	lmc_reset(sc);
=20
-	if (sc->lmc_ok) {
+	if (sc->ok) {
 		lmc_trace(dev, "lmc_open lmc_ok out");
 		return 0;
 	}
@@ -915,14 +914,14 @@ static int lmc_open(struct net_device *dev)
 	sc->got_irq =3D 1;
=20
 	/* Assert Terminal Active */
-	sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL;
-	if (sc->lmc_media->set_link_status)
-		sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+	sc->miireg16 |=3D LMC_MII16_LED_ALL;
+	if (sc->media->set_link_status)
+		sc->media->set_link_status(sc, LMC_LINK_UP);
=20
 	/*
 	 * reset to last state.
 	 */
-	sc->lmc_media->set_status(sc, NULL);
+	sc->media->set_status(sc, NULL);
=20
 	/* setup default bits to be used in tulip_desc_t transmit descriptor =
*/
 	sc->TxDescriptControlInit =3D (LMC_TDES_INTERRUPT_ON_COMPLETION |
@@ -935,30 +934,30 @@ static int lmc_open(struct net_device *dev)
 		/* disable 32 bit CRC generated by ASIC */
 		sc->TxDescriptControlInit |=3D LMC_TDES_ADD_CRC_DISABLE;
=20
-	sc->lmc_media->set_crc_length(sc, sc->ictl.crc_length);
+	sc->media->set_crc_length(sc, sc->ictl.crc_length);
 	/* Acknowledge the Terminal Active and light LEDs */
=20
-	if ((err =3D hdlc_open(sc->lmc_device)) !=3D 0)
+	if ((err =3D hdlc_open(sc->netdev)) !=3D 0)
 		return err;
=20
 	netif_start_queue(dev);
 	sc->extra_stats.tx_tbusy0++;
=20
 	/* select what interrupts we want to get */
-	sc->lmc_intrmask =3D 0;
+	sc->intrmask =3D 0;
 	/* Should be using the default interrupt mask defined in the .h file.=
 */
-	sc->lmc_intrmask |=3D (TULIP_STS_NORMALINTR | TULIP_STS_RXINTR |
+	sc->intrmask |=3D (TULIP_STS_NORMALINTR | TULIP_STS_RXINTR |
 			     TULIP_STS_TXINTR | TULIP_STS_ABNRMLINTR |
 			     TULIP_STS_SYSERROR | TULIP_STS_TXSTOPPED |
 			     TULIP_STS_TXUNDERFLOW | TULIP_STS_RXSTOPPED |
 			     TULIP_STS_RXNOBUF);
-	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
+	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
=20
-	sc->lmc_cmdmode |=3D TULIP_CMD_TXRUN;
-	sc->lmc_cmdmode |=3D TULIP_CMD_RXRUN;
-	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+	sc->cmdmode |=3D TULIP_CMD_TXRUN;
+	sc->cmdmode |=3D TULIP_CMD_RXRUN;
+	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
=20
-	sc->lmc_ok =3D 1; /* Run watchdog */
+	sc->ok =3D 1; /* Run watchdog */
=20
 	/* Set the if up now */
 	sc->last_link_status =3D 1;
@@ -991,21 +990,21 @@ static void lmc_running_reset(struct net_device *=
dev)
 	lmc_dec_reset(sc);
 	lmc_reset(sc);
 	lmc_softreset(sc);
-	/* sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL; */
-	if (sc->lmc_media->set_link_status)
-		sc->lmc_media->set_link_status(sc, 1);
-	sc->lmc_media->set_status(sc, NULL);
+	/* sc->miireg16 |=3D LMC_MII16_LED_ALL; */
+	if (sc->media->set_link_status)
+		sc->media->set_link_status(sc, 1);
+	sc->media->set_status(sc, NULL);
=20
 	netif_wake_queue(dev);
=20
-	sc->lmc_txfull =3D 0;
+	sc->txfull =3D 0;
 	sc->extra_stats.tx_tbusy0++;
=20
-	sc->lmc_intrmask =3D TULIP_DEFAULT_INTR_MASK;
-	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
+	sc->intrmask =3D TULIP_DEFAULT_INTR_MASK;
+	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
=20
-	sc->lmc_cmdmode |=3D (TULIP_CMD_TXRUN | TULIP_CMD_RXRUN);
-	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+	sc->cmdmode |=3D (TULIP_CMD_TXRUN | TULIP_CMD_RXRUN);
+	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
=20
 	lmc_trace(dev, "lmc_runnin_reset_out");
 }
@@ -1020,11 +1019,11 @@ static int lmc_close(struct net_device *dev)
=20
 	lmc_trace(dev, "lmc_close in");
=20
-	sc->lmc_ok =3D 0;
-	if (sc->lmc_media->set_link_status)
-		sc->lmc_media->set_link_status(sc, 0);
+	sc->ok =3D 0;
+	if (sc->media->set_link_status)
+		sc->media->set_link_status(sc, 0);
 	del_timer(&sc->timer);
-	hdlc_close(sc->lmc_device);
+	hdlc_close(sc->netdev);
 	lmc_ifdown(dev);
=20
 	lmc_trace(dev, "lmc_close out");
@@ -1057,7 +1056,7 @@ static int lmc_ifdown(struct net_device *dev)
 	csr6 &=3D ~LMC_DEC_SR;		/* Turn off the Receive bit */
 	LMC_CSR_WRITE(sc, csr_command, csr6);
=20
-	sc->lmc_device->stats.rx_missed_errors +=3D
+	sc->netdev->stats.rx_missed_errors +=3D
 		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
=20
 	/* release the interrupt */
@@ -1068,20 +1067,20 @@ static int lmc_ifdown(struct net_device *dev)
=20
 	/* free skbuffs in the Rx queue */
 	for (i =3D 0; i < LMC_RXDESCS; i++) {
-		struct sk_buff *skb =3D sc->lmc_rxq[i];
-		sc->lmc_rxq[i] =3D NULL;
-		sc->lmc_rxring[i].status =3D 0;
-		sc->lmc_rxring[i].length =3D 0;
-		sc->lmc_rxring[i].buffer1 =3D 0xDEADBEEF;
+		struct sk_buff *skb =3D sc->rxq[i];
+		sc->rxq[i] =3D NULL;
+		sc->rxring[i].status =3D 0;
+		sc->rxring[i].length =3D 0;
+		sc->rxring[i].buffer1 =3D 0xDEADBEEF;
 		if (skb !=3D NULL)
 			dev_kfree_skb(skb);
-		sc->lmc_rxq[i] =3D NULL;
+		sc->rxq[i] =3D NULL;
 	}
=20
 	for (i =3D 0; i < LMC_TXDESCS; i++) {
-		if (sc->lmc_txq[i] !=3D NULL)
-			dev_kfree_skb(sc->lmc_txq[i]);
-		sc->lmc_txq[i] =3D NULL;
+		if (sc->txq[i] !=3D NULL)
+			dev_kfree_skb(sc->txq[i]);
+		sc->txq[i] =3D NULL;
 	}
=20
 	lmc_led_off(sc, LMC_MII16_LED_ALL);
@@ -1110,19 +1109,19 @@ static irqreturn_t lmc_interrupt(int irq, void =
*dev_instance)
=20
 	lmc_trace(dev, "lmc_interrupt in");
=20
-	spin_lock(&sc->lmc_lock);
+	spin_lock(&sc->lock);
=20
 	/* Read the csr to find what interrupts we have (if any) */
 	csr =3D LMC_CSR_READ(sc, csr_status);
=20
 	/* Make sure this is our interrupt */
-	if (!(csr & sc->lmc_intrmask))
+	if (!(csr & sc->intrmask))
 		goto lmc_int_fail_out;
=20
 	firstcsr =3D csr;
=20
 	/* always go through this loop at least once */
-	while (csr & sc->lmc_intrmask) {
+	while (csr & sc->intrmask) {
 		handled =3D 1;
=20
 		/* Clear interrupt bits, we handle all case below */
@@ -1157,11 +1156,11 @@ static irqreturn_t lmc_interrupt(int irq, void =
*dev_instance)
 			/* reset the transmit timeout detection flag */
 			sc->extra_stats.tx_NoCompleteCnt =3D 0;
=20
-			badtx =3D sc->lmc_taint_tx;
+			badtx =3D sc->taint_tx;
 			i =3D badtx % LMC_TXDESCS;
=20
-			while ((badtx < sc->lmc_next_tx)) {
-				stat =3D sc->lmc_txring[i].status;
+			while ((badtx < sc->next_tx)) {
+				stat =3D sc->txring[i].status;
=20
 				/* If bit 31 is 1 the tulip owns it break out
 				   of the loop */
@@ -1172,49 +1171,49 @@ static irqreturn_t lmc_interrupt(int irq, void =
*dev_instance)
 				n_compl++;
 				/* If we have no skbuff or have cleared it
 				   already. Continue to the next buffer */
-				if (sc->lmc_txq[i] =3D=3D NULL)
+				if (sc->txq[i] =3D=3D NULL)
 					continue;
=20
 				/* Check the total error summary to look for
 				   any errors */
 				if (stat & 0x8000) {
-					sc->lmc_device->stats.tx_errors++;
+					sc->netdev->stats.tx_errors++;
 					if (stat & 0x4104)
-						sc->lmc_device->stats.tx_aborted_errors++;
+						sc->netdev->stats.tx_aborted_errors++;
 					if (stat & 0x0C00)
-						sc->lmc_device->stats.tx_carrier_errors++;
+						sc->netdev->stats.tx_carrier_errors++;
 					if (stat & 0x0200)
-						sc->lmc_device->stats.tx_window_errors++;
+						sc->netdev->stats.tx_window_errors++;
 					if (stat & 0x0002)
-						sc->lmc_device->stats.tx_fifo_errors++;
+						sc->netdev->stats.tx_fifo_errors++;
 				} else {
-					sc->lmc_device->stats.tx_bytes +=3D
-						sc->lmc_txring[i].length & 0x7ff;
+					sc->netdev->stats.tx_bytes +=3D
+						sc->txring[i].length & 0x7ff;
=20
-					sc->lmc_device->stats.tx_packets++;
+					sc->netdev->stats.tx_packets++;
 				}
=20
-				dev_kfree_skb_irq(sc->lmc_txq[i]);
-				sc->lmc_txq[i] =3D NULL;
+				dev_kfree_skb_irq(sc->txq[i]);
+				sc->txq[i] =3D NULL;
=20
 				badtx++;
 				i =3D badtx % LMC_TXDESCS;
 			}
=20
-			if (sc->lmc_next_tx - badtx > LMC_TXDESCS) {
+			if (sc->next_tx - badtx > LMC_TXDESCS) {
 				printk(KERN_WARNING "%s: out of sync pointer\n",
 				       dev->name);
 				badtx +=3D LMC_TXDESCS;
 			}
-			sc->lmc_txfull =3D 0;
+			sc->txfull =3D 0;
 			netif_wake_queue(dev);
 			sc->extra_stats.tx_tbusy0++;
 #ifdef DEBUG
 			sc->extra_stats.dirtyTx =3D badtx;
-			sc->extra_stats.lmc_next_tx =3D sc->lmc_next_tx;
-			sc->extra_stats.lmc_txfull =3D sc->lmc_txfull;
+			sc->extra_stats.lmc_next_tx =3D sc->next_tx;
+			sc->extra_stats.lmc_txfull =3D sc->txfull;
 #endif
-			sc->lmc_taint_tx =3D badtx;
+			sc->taint_tx =3D badtx;
 		} /* end handle transmit interrupt */
=20
 		if (csr & TULIP_STS_SYSERROR) {
@@ -1256,7 +1255,7 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 	} /* end interrupt loop */
=20
 lmc_int_fail_out:
-	spin_unlock(&sc->lmc_lock);
+	spin_unlock(&sc->lock);
 	lmc_trace(dev, "lmc_interrupt out");
 	return IRQ_RETVAL(handled);
 }
@@ -1271,14 +1270,14 @@ static netdev_tx_t lmc_start_xmit(struct sk_buf=
f *skb,
=20
 	lmc_trace(dev, "lmc_start_xmit in");
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lock, flags);
=20
 	/* normal path, tbusy known to be zero */
=20
-	entry =3D sc->lmc_next_tx % LMC_TXDESCS;
+	entry =3D sc->next_tx % LMC_TXDESCS;
=20
-	sc->lmc_txq[entry] =3D skb;
-	sc->lmc_txring[entry].buffer1 =3D virt_to_bus(skb->data);
+	sc->txq[entry] =3D skb;
+	sc->txring[entry].buffer1 =3D virt_to_bus(skb->data);
=20
 #ifdef DEBUG_PKT
 	printk(KERN_DEBUG "%s TX(%i):", dev->name, skb->len);
@@ -1287,30 +1286,30 @@ static netdev_tx_t lmc_start_xmit(struct sk_buf=
f *skb,
=20
 #ifndef GCOM
 	/* If the queue is less than half full, don't interrupt */
-	if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS / 2) {
+	if (sc->next_tx - sc->taint_tx < LMC_TXDESCS / 2) {
 		/* Do not interrupt on completion of this packet */
 		flag =3D 0x60000000;
 		netif_wake_queue(dev);
-	} else if (sc->lmc_next_tx - sc->lmc_taint_tx =3D=3D LMC_TXDESCS / 2)=
 {
+	} else if (sc->next_tx - sc->taint_tx =3D=3D LMC_TXDESCS / 2) {
 		/* This generates an interrupt on completion of this packet */
 		flag =3D 0xe0000000;
 		netif_wake_queue(dev);
-	} else if (sc->lmc_next_tx - sc->lmc_taint_tx < LMC_TXDESCS - 1) {
+	} else if (sc->next_tx - sc->taint_tx < LMC_TXDESCS - 1) {
 		/* Do not interrupt on completion of this packet */
 		flag =3D 0x60000000;
 		netif_wake_queue(dev);
 	} else {
 		/* This generates an interrupt on completion of this packet */
 		flag =3D 0xe0000000;
-		sc->lmc_txfull =3D 1;
+		sc->txfull =3D 1;
 		netif_stop_queue(dev);
 	}
 #else
 	flag =3D LMC_TDES_INTERRUPT_ON_COMPLETION;
=20
-	if (sc->lmc_next_tx - sc->lmc_taint_tx >=3D LMC_TXDESCS - 1) {
+	if (sc->next_tx - sc->taint_tx >=3D LMC_TXDESCS - 1) {
 		/* ring full, go busy */
-		sc->lmc_txfull =3D 1;
+		sc->txfull =3D 1;
 		netif_stop_queue(dev);
 		sc->extra_stats.tx_tbusy1++;
 	}
@@ -1320,22 +1319,22 @@ static netdev_tx_t lmc_start_xmit(struct sk_buf=
f *skb,
 		flag |=3D LMC_TDES_END_OF_RING;	/* flag as such for Tulip */
=20
 	/* don't pad small packets either */
-	flag =3D sc->lmc_txring[entry].length =3D (skb->len) | flag |
+	flag =3D sc->txring[entry].length =3D (skb->len) | flag |
 		sc->TxDescriptControlInit;
=20
 	/* set the transmit timeout flag to be checked in the watchdog timer
 	   handler. */
=20
 	sc->extra_stats.tx_NoCompleteCnt++;
-	sc->lmc_next_tx++;
+	sc->next_tx++;
=20
 	/* give ownership to the chip */
-	sc->lmc_txring[entry].status =3D 0x80000000;
+	sc->txring[entry].status =3D 0x80000000;
=20
 	/* send now! */
 	LMC_CSR_WRITE(sc, csr_txpoll, 0);
=20
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	spin_unlock_irqrestore(&sc->lock, flags);
=20
 	lmc_trace(dev, "lmc_start_xmit_out");
 	return NETDEV_TX_OK;
@@ -1360,10 +1359,10 @@ static int lmc_rx(struct net_device *dev)
=20
 	rxIntLoopCnt =3D 0;		/* debug */
=20
-	i =3D sc->lmc_next_rx % LMC_RXDESCS;
-	next_rx =3D sc->lmc_next_rx;
+	i =3D sc->next_rx % LMC_RXDESCS;
+	next_rx =3D sc->next_rx;
=20
-	while (((stat =3D sc->lmc_rxring[i].status) & LMC_RDES_OWN_BIT) !=3D
+	while (((stat =3D sc->rxring[i].status) & LMC_RDES_OWN_BIT) !=3D
 	       DESC_OWNED_BY_DC21X4) {
 		rxIntLoopCnt++;		/* debug */
 		len =3D ((stat & LMC_RDES_FRAME_LENGTH) >>
@@ -1372,32 +1371,32 @@ static int lmc_rx(struct net_device *dev)
 			/* Check first segment and last segment */
 			if ((stat & 0x0000ffff) !=3D 0x7fff) {
 				/* Oversized frame */
-				sc->lmc_device->stats.rx_length_errors++;
+				sc->netdev->stats.rx_length_errors++;
 				goto skip_packet;
 			}
 		}
=20
 		if (stat & 0x00000008) { /* Catch a dribbling bit error */
-			sc->lmc_device->stats.rx_errors++;
-			sc->lmc_device->stats.rx_frame_errors++;
+			sc->netdev->stats.rx_errors++;
+			sc->netdev->stats.rx_frame_errors++;
 			goto skip_packet;
 		}
=20
=20
 		if (stat & 0x00000004) { /* Catch a CRC error by the Xilinx */
-			sc->lmc_device->stats.rx_errors++;
-			sc->lmc_device->stats.rx_crc_errors++;
+			sc->netdev->stats.rx_errors++;
+			sc->netdev->stats.rx_crc_errors++;
 			goto skip_packet;
 		}
=20
 		if (len > LMC_PKT_BUF_SZ) {
-			sc->lmc_device->stats.rx_length_errors++;
+			sc->netdev->stats.rx_length_errors++;
 			localLengthErrCnt++;
 			goto skip_packet;
 		}
=20
-		if (len < sc->lmc_crcSize + 2) {
-			sc->lmc_device->stats.rx_length_errors++;
+		if (len < sc->crcSize + 2) {
+			sc->netdev->stats.rx_length_errors++;
 			sc->extra_stats.rx_SmallPktCnt++;
 			localLengthErrCnt++;
 			goto skip_packet;
@@ -1409,9 +1408,9 @@ static int lmc_rx(struct net_device *dev)
 			       dev->name);
 		}
=20
-		len -=3D sc->lmc_crcSize;
+		len -=3D sc->crcSize;
=20
-		skb =3D sc->lmc_rxq[i];
+		skb =3D sc->rxq[i];
=20
 		/* We ran out of memory at some point just allocate an skb buff
 		   and continue. */
@@ -1419,17 +1418,17 @@ static int lmc_rx(struct net_device *dev)
 		if (!skb) {
 			nsb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
 			if (nsb) {
-				sc->lmc_rxq[i] =3D nsb;
+				sc->rxq[i] =3D nsb;
 				nsb->dev =3D dev;
-				sc->lmc_rxring[i].buffer1 =3D
+				sc->rxring[i].buffer1 =3D
 					virt_to_bus(skb_tail_pointer(nsb));
 			}
 			sc->failed_recv_alloc =3D 1;
 			goto skip_packet;
 		}
=20
-		sc->lmc_device->stats.rx_packets++;
-		sc->lmc_device->stats.rx_bytes +=3D len;
+		sc->netdev->stats.rx_packets++;
+		sc->netdev->stats.rx_bytes +=3D len;
=20
 		/* I'm not sure of the sanity of this. Packets could be arriving
 		   at a constant 44.210mbits/sec and we're going to copy them
@@ -1439,15 +1438,15 @@ static int lmc_rx(struct net_device *dev)
 			/* If it's a large packet don't copy it just hand it
 			   up */
 give_it_anyways:
-			sc->lmc_rxq[i] =3D NULL;
-			sc->lmc_rxring[i].buffer1 =3D 0x0;
+			sc->rxq[i] =3D NULL;
+			sc->rxring[i].buffer1 =3D 0x0;
=20
 			skb_put(skb, len);
 #ifdef DEBUG_PKT
 			printk(KERN_DEBUG "%s RX(%i):", dev->name, len);
 			debug_frame(skb);
 #endif
-			skb->protocol =3D hdlc_type_trans(skb, sc->lmc_device);
+			skb->protocol =3D hdlc_type_trans(skb, sc->netdev);
 			skb_reset_mac_header(skb);
 			/* skb_reset_network_header(skb); */
 			skb->dev =3D dev;
@@ -1457,9 +1456,9 @@ give_it_anyways:
 			   make a new one */
 			nsb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
 			if (nsb) {
-				sc->lmc_rxq[i] =3D nsb;
+				sc->rxq[i] =3D nsb;
 				nsb->dev =3D dev;
-				sc->lmc_rxring[i].buffer1 =3D
+				sc->rxring[i].buffer1 =3D
 					virt_to_bus(skb_tail_pointer(nsb));
 				/* Transferred to 21140 below */
 			} else {
@@ -1481,7 +1480,7 @@ give_it_anyways:
 			printk(KERN_DEBUG "%s RX(%i):", dev->name, len);
 			debug_frame(nsb);
 #endif
-			nsb->protocol =3D hdlc_type_trans(nsb, sc->lmc_device);
+			nsb->protocol =3D hdlc_type_trans(nsb, sc->netdev);
 			skb_reset_mac_header(nsb);
 			/* skb_reset_network_header(nsb); */
 			nsb->dev =3D dev;
@@ -1489,10 +1488,10 @@ give_it_anyways:
 		}
=20
 skip_packet:
-		sc->lmc_rxring[i].status =3D DESC_OWNED_BY_DC21X4;
+		sc->rxring[i].status =3D DESC_OWNED_BY_DC21X4;
=20
-		sc->lmc_next_rx++;
-		i =3D sc->lmc_next_rx % LMC_RXDESCS;
+		sc->next_rx++;
+		i =3D sc->next_rx % LMC_RXDESCS;
 		rx_work_limit--;
 		if (rx_work_limit < 0)
 			break;
@@ -1513,7 +1512,7 @@ skip_packet:
 #ifdef DEBUG
 	if (rxIntLoopCnt =3D=3D 0) {
 		for (i =3D 0; i < LMC_RXDESCS; i++) {
-			if ((sc->lmc_rxring[i].status & LMC_RDES_OWN_BIT)
+			if ((sc->rxring[i].status & LMC_RDES_OWN_BIT)
 			    !=3D DESC_OWNED_BY_DC21X4)
 				rxIntLoopCnt++;
 		}
@@ -1534,15 +1533,15 @@ static struct net_device_stats *lmc_get_stats(s=
truct net_device *dev)
=20
 	lmc_trace(dev, "lmc_get_stats in");
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lock, flags);
=20
-	sc->lmc_device->stats.rx_missed_errors +=3D
+	sc->netdev->stats.rx_missed_errors +=3D
 		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
=20
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	spin_unlock_irqrestore(&sc->lock, flags);
=20
 	lmc_trace(dev, "lmc_get_stats out");
-	return &sc->lmc_device->stats;
+	return &sc->netdev->stats;
 }
=20
 static struct pci_driver lmc_driver =3D {
@@ -1572,11 +1571,11 @@ unsigned lmc_mii_readreg(struct card * const sc=
, unsigned devaddr,
 	int command =3D (0xf6 << 10) | (devaddr << 5) | regno;
 	int retval =3D 0;
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_readreg in");
+	lmc_trace(sc->netdev, "lmc_mii_readreg in");
=20
 	LMC_MII_SYNC(sc);
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_readreg: done sync");
+	lmc_trace(sc->netdev, "lmc_mii_readreg: done sync");
=20
 	for (i =3D 15; i >=3D 0; i--) {
 		int dataval =3D (command & (1 << i)) ? 0x20000 : 0;
@@ -1589,7 +1588,7 @@ unsigned lmc_mii_readreg(struct card * const sc, =
unsigned devaddr,
 		/* __SLOW_DOWN_IO; */
 	}
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_readreg: done1");
+	lmc_trace(sc->netdev, "lmc_mii_readreg: done1");
=20
 	for (i =3D 19; i > 0; i--) {
 		LMC_CSR_WRITE(sc, csr_9, 0x40000);
@@ -1602,7 +1601,7 @@ unsigned lmc_mii_readreg(struct card * const sc, =
unsigned devaddr,
 		/* __SLOW_DOWN_IO; */
 	}
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_readreg out");
+	lmc_trace(sc->netdev, "lmc_mii_readreg out");
=20
 	return (retval >> 1) & 0xffff;
 }
@@ -1613,7 +1612,7 @@ void lmc_mii_writereg(struct card * const sc, uns=
igned devaddr, unsigned regno,
 	int i =3D 32;
 	int command =3D (0x5002 << 16) | (devaddr << 23) | (regno << 18) | da=
ta;
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_writereg in");
+	lmc_trace(sc->netdev, "lmc_mii_writereg in");
=20
 	LMC_MII_SYNC(sc);
=20
@@ -1646,21 +1645,21 @@ void lmc_mii_writereg(struct card * const sc, u=
nsigned devaddr, unsigned regno,
 		i--;
 	}
=20
-	lmc_trace(sc->lmc_device, "lmc_mii_writereg out");
+	lmc_trace(sc->netdev, "lmc_mii_writereg out");
 }
=20
 static void lmc_softreset(struct card * const sc)
 {
 	int i;
=20
-	lmc_trace(sc->lmc_device, "lmc_softreset in");
+	lmc_trace(sc->netdev, "lmc_softreset in");
=20
 	/* Initialize the receive rings and buffers. */
-	sc->lmc_txfull =3D 0;
-	sc->lmc_next_rx =3D 0;
-	sc->lmc_next_tx =3D 0;
-	sc->lmc_taint_rx =3D 0;
-	sc->lmc_taint_tx =3D 0;
+	sc->txfull =3D 0;
+	sc->next_rx =3D 0;
+	sc->next_tx =3D 0;
+	sc->taint_rx =3D 0;
+	sc->taint_tx =3D 0;
=20
 	/* Setup each one of the receiver buffers allocate an skbuff for
 	   each one, setup the descriptor table and point each buffer at
@@ -1669,7 +1668,7 @@ static void lmc_softreset(struct card * const sc)
 	for (i =3D 0; i < LMC_RXDESCS; i++) {
 		struct sk_buff *skb;
=20
-		if (sc->lmc_rxq[i] =3D=3D NULL) {
+		if (sc->rxq[i] =3D=3D NULL) {
 			skb =3D dev_alloc_skb(LMC_PKT_BUF_SZ + 2);
 			if (skb =3D=3D NULL) {
 				printk(KERN_WARNING
@@ -1678,114 +1677,114 @@ static void lmc_softreset(struct card * const=
 sc)
 				sc->failed_ring =3D 1;
 				break;
 			} else
-				sc->lmc_rxq[i] =3D skb;
+				sc->rxq[i] =3D skb;
 		} else
-			skb =3D sc->lmc_rxq[i];
+			skb =3D sc->rxq[i];
=20
-		skb->dev =3D sc->lmc_device;
+		skb->dev =3D sc->netdev;
=20
 		/* owned by 21140 */
-		sc->lmc_rxring[i].status =3D 0x80000000;
+		sc->rxring[i].status =3D 0x80000000;
=20
 		/* used to be PKT_BUF_SZ now uses skb since we lose some
 		   to head room */
-		sc->lmc_rxring[i].length =3D skb_tailroom(skb);
+		sc->rxring[i].length =3D skb_tailroom(skb);
=20
 		/* use to be tail which is dumb since you're thinking why write
 		   to the end of the packet but since there's nothing there
 		   tail =3D=3D data */
-		sc->lmc_rxring[i].buffer1 =3D virt_to_bus(skb->data);
+		sc->rxring[i].buffer1 =3D virt_to_bus(skb->data);
=20
 		/* This is fair since the structure is static and we have
 		   the next address */
-		sc->lmc_rxring[i].buffer2 =3D virt_to_bus(&sc->lmc_rxring[i + 1]);
+		sc->rxring[i].buffer2 =3D virt_to_bus(&sc->rxring[i + 1]);
 	}
=20
 	/* Sets end of ring */
 	if (i !=3D 0) {
 		/* Set end of buffers flag */
-		sc->lmc_rxring[i - 1].length |=3D 0x02000000;
+		sc->rxring[i - 1].length |=3D 0x02000000;
 		/* Point back to the start */
-		sc->lmc_rxring[i - 1].buffer2 =3D virt_to_bus(&sc->lmc_rxring[0]);
+		sc->rxring[i - 1].buffer2 =3D virt_to_bus(&sc->rxring[0]);
 	}
 	/* write base address */
-	LMC_CSR_WRITE(sc, csr_rxlist, virt_to_bus(sc->lmc_rxring));
+	LMC_CSR_WRITE(sc, csr_rxlist, virt_to_bus(sc->rxring));
=20
 	/* Initialize the transmit rings and buffers */
 	for (i =3D 0; i < LMC_TXDESCS; i++) {
-		if (sc->lmc_txq[i] !=3D NULL) {		/* have buffer */
-			dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
+		if (sc->txq[i] !=3D NULL) {		/* have buffer */
+			dev_kfree_skb(sc->txq[i]);	/* free it */
 			/* We just dropped a packet */
-			sc->lmc_device->stats.tx_dropped++;
+			sc->netdev->stats.tx_dropped++;
 		}
-		sc->lmc_txq[i] =3D NULL;
-		sc->lmc_txring[i].status =3D 0x00000000;
-		sc->lmc_txring[i].buffer2 =3D virt_to_bus(&sc->lmc_txring[i + 1]);
+		sc->txq[i] =3D NULL;
+		sc->txring[i].status =3D 0x00000000;
+		sc->txring[i].buffer2 =3D virt_to_bus(&sc->txring[i + 1]);
 	}
-	sc->lmc_txring[i - 1].buffer2 =3D virt_to_bus(&sc->lmc_txring[0]);
-	LMC_CSR_WRITE(sc, csr_txlist, virt_to_bus(sc->lmc_txring));
+	sc->txring[i - 1].buffer2 =3D virt_to_bus(&sc->txring[0]);
+	LMC_CSR_WRITE(sc, csr_txlist, virt_to_bus(sc->txring));
=20
-	lmc_trace(sc->lmc_device, "lmc_softreset out");
+	lmc_trace(sc->netdev, "lmc_softreset out");
 }
=20
 void lmc_gpio_mkinput(struct card * const sc, u32 bits)
 {
-	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput in");
-	sc->lmc_gpio_io &=3D ~bits;
-	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
-	lmc_trace(sc->lmc_device, "lmc_gpio_mkinput out");
+	lmc_trace(sc->netdev, "lmc_gpio_mkinput in");
+	sc->gpio_io &=3D ~bits;
+	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->gpio_io));
+	lmc_trace(sc->netdev, "lmc_gpio_mkinput out");
 }
=20
 void lmc_gpio_mkoutput(struct card * const sc, u32 bits)
 {
-	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput in");
-	sc->lmc_gpio_io |=3D bits;
-	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->lmc_gpio_io));
-	lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput out");
+	lmc_trace(sc->netdev, "lmc_gpio_mkoutput in");
+	sc->gpio_io |=3D bits;
+	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->gpio_io));
+	lmc_trace(sc->netdev, "lmc_gpio_mkoutput out");
 }
=20
 void lmc_led_on(struct card * const sc, u32 led)
 {
-	lmc_trace(sc->lmc_device, "lmc_led_on in");
-	if ((~sc->lmc_miireg16) & led) { /* Already on! */
-		lmc_trace(sc->lmc_device, "lmc_led_on aon out");
+	lmc_trace(sc->netdev, "lmc_led_on in");
+	if ((~sc->miireg16) & led) { /* Already on! */
+		lmc_trace(sc->netdev, "lmc_led_on aon out");
 		return;
 	}
=20
-	sc->lmc_miireg16 &=3D ~led;
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-	lmc_trace(sc->lmc_device, "lmc_led_on out");
+	sc->miireg16 &=3D ~led;
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
+	lmc_trace(sc->netdev, "lmc_led_on out");
 }
=20
 void lmc_led_off(struct card * const sc, u32 led)
 {
-	lmc_trace(sc->lmc_device, "lmc_led_off in");
-	if (sc->lmc_miireg16 & led) { /* Already set don't do anything */
-		lmc_trace(sc->lmc_device, "lmc_led_off aoff out");
+	lmc_trace(sc->netdev, "lmc_led_off in");
+	if (sc->miireg16 & led) { /* Already set don't do anything */
+		lmc_trace(sc->netdev, "lmc_led_off aoff out");
 		return;
 	}
=20
-	sc->lmc_miireg16 |=3D led;
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-	lmc_trace(sc->lmc_device, "lmc_led_off out");
+	sc->miireg16 |=3D led;
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
+	lmc_trace(sc->netdev, "lmc_led_off out");
 }
=20
 static void lmc_reset(struct card * const sc)
 {
-	lmc_trace(sc->lmc_device, "lmc_reset in");
-	sc->lmc_miireg16 |=3D LMC_MII16_FIFO_RESET;
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_trace(sc->netdev, "lmc_reset in");
+	sc->miireg16 |=3D LMC_MII16_FIFO_RESET;
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
=20
-	sc->lmc_miireg16 &=3D ~LMC_MII16_FIFO_RESET;
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	sc->miireg16 &=3D ~LMC_MII16_FIFO_RESET;
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
=20
 	/* make some of the GPIO pins be outputs */
 	lmc_gpio_mkoutput(sc, LMC_GEP_RESET);
=20
 	/* RESET low to force state reset.  This also forces the transmitter
 	   clock to be internal, but we expect to reset that later anyway. */
-	sc->lmc_gpio &=3D ~(LMC_GEP_RESET);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+	sc->gpio &=3D ~(LMC_GEP_RESET);
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 	/* hold for more than 10 microseconds */
 	udelay(50);
@@ -1794,20 +1793,20 @@ static void lmc_reset(struct card * const sc)
 	lmc_gpio_mkinput(sc, LMC_GEP_RESET);
=20
 	/* Call media specific init routine */
-	sc->lmc_media->init(sc);
+	sc->media->init(sc);
=20
 	sc->extra_stats.resetCount++;
-	lmc_trace(sc->lmc_device, "lmc_reset out");
+	lmc_trace(sc->netdev, "lmc_reset out");
 }
=20
 static void lmc_dec_reset(struct card * const sc)
 {
 	u32 val;
-	lmc_trace(sc->lmc_device, "lmc_dec_reset in");
+	lmc_trace(sc->netdev, "lmc_dec_reset in");
=20
 	/* disable all interrupts */
-	sc->lmc_intrmask =3D 0;
-	LMC_CSR_WRITE(sc, csr_intr, sc->lmc_intrmask);
+	sc->intrmask =3D 0;
+	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
=20
 	/* Reset the chip with a software reset command. Wait 10 microseconds
 	   (actually 50 PCI cycles but at 33MHz that comes to two microsecond=
s
@@ -1815,12 +1814,12 @@ static void lmc_dec_reset(struct card * const s=
c)
 	LMC_CSR_WRITE(sc, csr_busmode, TULIP_BUSMODE_SWRESET);
 	udelay(25);
 #ifdef __sparc__
-	sc->lmc_busmode =3D LMC_CSR_READ(sc, csr_busmode);
-	sc->lmc_busmode =3D 0x00100000;
-	sc->lmc_busmode &=3D ~TULIP_BUSMODE_SWRESET;
-	LMC_CSR_WRITE(sc, csr_busmode, sc->lmc_busmode);
+	sc->busmode =3D LMC_CSR_READ(sc, csr_busmode);
+	sc->busmode =3D 0x00100000;
+	sc->busmode &=3D ~TULIP_BUSMODE_SWRESET;
+	LMC_CSR_WRITE(sc, csr_busmode, sc->busmode);
 #endif
-	sc->lmc_cmdmode =3D LMC_CSR_READ(sc, csr_command);
+	sc->cmdmode =3D LMC_CSR_READ(sc, csr_command);
=20
 	/*
 	 * We want:
@@ -1832,44 +1831,44 @@ static void lmc_dec_reset(struct card * const s=
c)
 	 *   if using 16-bit CRC, turn off CRC (trans desc, crc disable)
 	 */
=20
-	sc->lmc_cmdmode |=3D (TULIP_CMD_PROMISCUOUS | TULIP_CMD_FULLDUPLEX |
+	sc->cmdmode |=3D (TULIP_CMD_PROMISCUOUS | TULIP_CMD_FULLDUPLEX |
 			    TULIP_CMD_PASSBADPKT | TULIP_CMD_NOHEARTBEAT |
 			    TULIP_CMD_PORTSELECT | TULIP_CMD_RECEIVEALL |
 			    TULIP_CMD_MUSTBEONE);
-	sc->lmc_cmdmode &=3D ~(TULIP_CMD_OPERMODE | TULIP_CMD_THRESHOLDCTL |
+	sc->cmdmode &=3D ~(TULIP_CMD_OPERMODE | TULIP_CMD_THRESHOLDCTL |
 			     TULIP_CMD_STOREFWD | TULIP_CMD_TXTHRSHLDCTL);
=20
-	LMC_CSR_WRITE(sc, csr_command, sc->lmc_cmdmode);
+	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
=20
 	/* disable receiver watchdog and transmit jabber */
 	val =3D LMC_CSR_READ(sc, csr_sia_general);
 	val |=3D (TULIP_WATCHDOG_TXDISABLE | TULIP_WATCHDOG_RXDISABLE);
 	LMC_CSR_WRITE(sc, csr_sia_general, val);
=20
-	lmc_trace(sc->lmc_device, "lmc_dec_reset out");
+	lmc_trace(sc->netdev, "lmc_dec_reset out");
 }
=20
 static void lmc_initcsrs(struct card * const sc, lmc_csrptr_t csr_base=
,
 			 size_t csr_size)
 {
-	lmc_trace(sc->lmc_device, "lmc_initcsrs in");
-	sc->lmc_csrs.csr_busmode	=3D csr_base +  0 * csr_size;
-	sc->lmc_csrs.csr_txpoll		=3D csr_base +  1 * csr_size;
-	sc->lmc_csrs.csr_rxpoll		=3D csr_base +  2 * csr_size;
-	sc->lmc_csrs.csr_rxlist		=3D csr_base +  3 * csr_size;
-	sc->lmc_csrs.csr_txlist		=3D csr_base +  4 * csr_size;
-	sc->lmc_csrs.csr_status		=3D csr_base +  5 * csr_size;
-	sc->lmc_csrs.csr_command	=3D csr_base +  6 * csr_size;
-	sc->lmc_csrs.csr_intr		=3D csr_base +  7 * csr_size;
-	sc->lmc_csrs.csr_missed_frames	=3D csr_base +  8 * csr_size;
-	sc->lmc_csrs.csr_9		=3D csr_base +  9 * csr_size;
-	sc->lmc_csrs.csr_10		=3D csr_base + 10 * csr_size;
-	sc->lmc_csrs.csr_11		=3D csr_base + 11 * csr_size;
-	sc->lmc_csrs.csr_12		=3D csr_base + 12 * csr_size;
-	sc->lmc_csrs.csr_13		=3D csr_base + 13 * csr_size;
-	sc->lmc_csrs.csr_14		=3D csr_base + 14 * csr_size;
-	sc->lmc_csrs.csr_15		=3D csr_base + 15 * csr_size;
-	lmc_trace(sc->lmc_device, "lmc_initcsrs out");
+	lmc_trace(sc->netdev, "lmc_initcsrs in");
+	sc->csrs.csr_busmode	=3D csr_base +  0 * csr_size;
+	sc->csrs.csr_txpoll		=3D csr_base +  1 * csr_size;
+	sc->csrs.csr_rxpoll		=3D csr_base +  2 * csr_size;
+	sc->csrs.csr_rxlist		=3D csr_base +  3 * csr_size;
+	sc->csrs.csr_txlist		=3D csr_base +  4 * csr_size;
+	sc->csrs.csr_status		=3D csr_base +  5 * csr_size;
+	sc->csrs.csr_command	=3D csr_base +  6 * csr_size;
+	sc->csrs.csr_intr		=3D csr_base +  7 * csr_size;
+	sc->csrs.csr_missed_frames	=3D csr_base +  8 * csr_size;
+	sc->csrs.csr_9		=3D csr_base +  9 * csr_size;
+	sc->csrs.csr_10		=3D csr_base + 10 * csr_size;
+	sc->csrs.csr_11		=3D csr_base + 11 * csr_size;
+	sc->csrs.csr_12		=3D csr_base + 12 * csr_size;
+	sc->csrs.csr_13		=3D csr_base + 13 * csr_size;
+	sc->csrs.csr_14		=3D csr_base + 14 * csr_size;
+	sc->csrs.csr_15		=3D csr_base + 15 * csr_size;
+	lmc_trace(sc->netdev, "lmc_initcsrs out");
 }
=20
 static void lmc_driver_timeout(struct net_device *dev)
@@ -1880,7 +1879,7 @@ static void lmc_driver_timeout(struct net_device =
*dev)
=20
 	lmc_trace(dev, "lmc_driver_timeout in");
=20
-	spin_lock_irqsave(&sc->lmc_lock, flags);
+	spin_lock_irqsave(&sc->lock, flags);
=20
 	printk(KERN_DEBUG "%s: Xmitter busy|\n", dev->name);
=20
@@ -1901,11 +1900,11 @@ static void lmc_driver_timeout(struct net_devic=
e *dev)
 	/* immediate transmit */
 	LMC_CSR_WRITE(sc, csr_txpoll, 0);
=20
-	sc->lmc_device->stats.tx_errors++;
+	sc->netdev->stats.tx_errors++;
 	sc->extra_stats.tx_ProcTimeout++;
 	dev->trans_start =3D jiffies; /* prevent tx timeout */
=20
 bug_out:
-	spin_unlock_irqrestore(&sc->lmc_lock, flags);
+	spin_unlock_irqrestore(&sc->lock, flags);
 	lmc_trace(dev, "lmc_driver_timout out");
 }
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 5851d19..fde275a 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -48,20 +48,20 @@ static void lmc_set_protocol(struct card * const sc=
, struct control *ctl)
 static inline void write_av9110_bit(struct card *sc, int c)
 {
 	/* set the data bit as we need it. */
-	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
+	sc->gpio &=3D ~(LMC_GEP_CLK);
 	if (c & 0x01)
-		sc->lmc_gpio |=3D LMC_GEP_DATA;
+		sc->gpio |=3D LMC_GEP_DATA;
 	else
-		sc->lmc_gpio &=3D ~(LMC_GEP_DATA);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio &=3D ~(LMC_GEP_DATA);
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 	/* set the clock to high */
-	sc->lmc_gpio |=3D LMC_GEP_CLK;
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+	sc->gpio |=3D LMC_GEP_CLK;
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 	/* set the clock to low again. */
-	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+	sc->gpio &=3D ~(LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 }
=20
 static void write_av9110(struct card *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
@@ -73,16 +73,16 @@ static void write_av9110(struct card *sc, u32 n, u3=
2 m, u32 v, u32 x, u32 r)
 	       LMC_PRINTF_ARGS, sc->ictl.clock_rate, n, m, v, x, r);
 #endif
=20
-	sc->lmc_gpio |=3D LMC_GEP_SSI_GENERATOR;
-	sc->lmc_gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+	sc->gpio |=3D LMC_GEP_SSI_GENERATOR;
+	sc->gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 	/* Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK as outputs. */
 	lmc_gpio_mkoutput(sc, (LMC_GEP_DATA | LMC_GEP_CLK
 				| LMC_GEP_SSI_GENERATOR));
=20
-	sc->lmc_gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+	sc->gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
+	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
=20
 	/* a shifting we will go... */
 	for (i =3D 0; i < 7; i++)
@@ -124,15 +124,15 @@ static void lmc_ssi_set_clock(struct card * const=
 sc, int ie)
 	int old;
 	old =3D ie;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (ie !=3D old)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
-		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio |=3D LMC_GEP_SSI_TXCLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (ie !=3D old)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
@@ -188,11 +188,11 @@ static void lmc_ssi_set_status(struct card * cons=
t sc, struct control *ctl)
 	if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
 	    && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
 		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
+		sc->timing =3D LMC_CTL_CLOCK_SOURCE_INT;
 	} else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
 		 && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
 		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
 	}
=20
 	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
@@ -233,7 +233,7 @@ static int lmc_ssi_get_link_status(struct card * co=
nst sc)
 	lmc_led_on(sc, LMC_MII16_LED0);
=20
 	/* transmit clock determination */
-	if (sc->lmc_timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
+	if (sc->timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
 		lmc_led_off(sc, LMC_MII16_LED3);
 	else if (ticks =3D=3D 0) {	/* no clock found ? */
 		ret =3D 0;
@@ -284,16 +284,16 @@ static int lmc_ssi_get_link_status(struct card * =
const sc)
 static void lmc_ssi_set_link_status(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_LINK_UP) {
-		sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		sc->miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
 		printk(LMC_PRINTF_FMT ": asserting DTR and RTS\n",
 		       LMC_PRINTF_ARGS);
 	} else {
-		sc->lmc_miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		sc->miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
 		printk(LMC_PRINTF_FMT ": deasserting DTR and RTS\n",
 		       LMC_PRINTF_ARGS);
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
=20
 }
=20
@@ -302,23 +302,23 @@ static void lmc_ssi_set_crc_length(struct card * =
const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_SSI_CRC;
+		sc->miireg16 |=3D LMC_MII16_SSI_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
+		sc->crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
=20
 	} else {
 		/* 16 bit */
-		sc->lmc_miireg16 &=3D ~LMC_MII16_SSI_CRC;
+		sc->miireg16 &=3D ~LMC_MII16_SSI_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
+		sc->crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 static void lmc_ssi_default(struct card * const sc)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->miireg16 =3D LMC_MII16_LED_ALL;
=20
 	/* make TXCLOCK always be an output */
 	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
@@ -353,15 +353,15 @@ static void lmc_hssi_set_clock(struct card * cons=
t sc, int ie)
 	int old;
 	old =3D sc->ictl.clock_source;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		sc->lmc_gpio |=3D LMC_GEP_HSSI_CLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio |=3D LMC_GEP_HSSI_CLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
-		sc->lmc_gpio &=3D ~(LMC_GEP_HSSI_CLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio &=3D ~LMC_GEP_HSSI_CLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
@@ -383,9 +383,9 @@ static void lmc_hssi_set_status(struct card * const=
 sc, struct control *ctl)
 	/* check for change in clock source */
 	if (ctl->clock_source && !sc->ictl.clock_source) {
 		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
+		sc->timing =3D LMC_CTL_CLOCK_SOURCE_INT;
 	} else if (!ctl->clock_source && sc->ictl.clock_source) {
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 	}
=20
@@ -403,11 +403,11 @@ static inline int lmc_hssi_get_link_status(struct=
 card * const sc)
 static void lmc_hssi_set_link_status(struct card * const sc, int state=
)
 {
 	if (state =3D=3D LMC_LINK_UP)
-		sc->lmc_miireg16 |=3D LMC_MII16_HSSI_TA;
+		sc->miireg16 |=3D LMC_MII16_HSSI_TA;
 	else
-		sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_TA;
+		sc->miireg16 &=3D ~LMC_MII16_HSSI_TA;
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
@@ -415,20 +415,20 @@ static void lmc_hssi_set_crc_length(struct card *=
 const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_HSSI_CRC;
+		sc->miireg16 |=3D LMC_MII16_HSSI_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
 	} else {
 		/* 16 bit */
-		sc->lmc_miireg16 &=3D ~LMC_MII16_HSSI_CRC;
+		sc->miireg16 &=3D ~LMC_MII16_HSSI_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 static void lmc_hssi_default(struct card * const sc)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->miireg16 =3D LMC_MII16_LED_ALL;
 	lmc_hssi_set_link_status(sc, LMC_LINK_DOWN);
 	lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 	lmc_hssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
@@ -441,26 +441,26 @@ static void lmc_hssi_default(struct card * const =
sc)
 static void lmc_ds3_set_100ft(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_CABLE_LENGTH_GT_100FT) {
-		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_ZERO;
+		sc->miireg16 &=3D ~LMC_MII16_DS3_ZERO;
 		sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_GT_100FT;
 	} else if (ie =3D=3D LMC_CTL_CABLE_LENGTH_LT_100FT) {
-		sc->lmc_miireg16 |=3D LMC_MII16_DS3_ZERO;
+		sc->miireg16 |=3D LMC_MII16_DS3_ZERO;
 		sc->ictl.cable_length =3D LMC_CTL_CABLE_LENGTH_LT_100FT;
 	}
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 /* 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled */
 static void lmc_ds3_set_scram(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_ON) {
-		sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
+		sc->miireg16 |=3D LMC_MII16_DS3_SCRAM;
 		sc->ictl.scrambler_onoff =3D LMC_CTL_ON;
 	} else {
-		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
+		sc->miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
 		sc->ictl.scrambler_onoff =3D LMC_CTL_OFF;
 	}
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -612,20 +612,20 @@ static void lmc_ds3_set_crc_length(struct card * =
const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_DS3_CRC;
+		sc->miireg16 |=3D LMC_MII16_DS3_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
 	} else {
 		/* 16 bit */
-		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_CRC;
+		sc->miireg16 &=3D ~LMC_MII16_DS3_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 static void lmc_ds3_default(struct card * const sc)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->miireg16 =3D LMC_MII16_LED_ALL;
=20
 	lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
 	lmc_ds3_set_scram(sc, LMC_CTL_OFF);
@@ -655,16 +655,16 @@ static int lmc_t1_read(struct card * const sc, in=
t a)
 static void lmc_t1_set_circuit_type(struct card * const sc, int ie)
 {
 	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
-		sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
+		sc->miireg16 |=3D LMC_MII16_T1_Z;
 		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
 		printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
 	} else {
-		sc->lmc_miireg16 &=3D ~LMC_MII16_T1_Z;
+		sc->miireg16 &=3D ~LMC_MII16_T1_Z;
 		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
 		printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 static void lmc_t1_init(struct card * const sc)
@@ -681,9 +681,9 @@ static void lmc_t1_init(struct card * const sc)
 	lmc_mii_writereg(sc, 0, 16, mii16);
=20
 	/* set T1 or E1 line.  Uses sc->lmcmii16 reg in function so update it=
 */
-	sc->lmc_miireg16 =3D mii16;
+	sc->miireg16 =3D mii16;
 	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
-	mii16 =3D sc->lmc_miireg16;
+	mii16 =3D sc->miireg16;
=20
 	lmc_t1_write(sc, 0x01, 0x1B); /* CR0     - primary control */
 	lmc_t1_write(sc, 0x02, 0x42); /* JAT_CR  - jitter atten config */
@@ -723,7 +723,7 @@ static void lmc_t1_init(struct card * const sc)
=20
 	mii16 |=3D LMC_MII16_T1_XOE;
 	lmc_mii_writereg(sc, 0, 16, mii16);
-	sc->lmc_miireg16 =3D mii16;
+	sc->miireg16 =3D mii16;
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -757,7 +757,7 @@ static int lmc_t1_get_link_status(struct card * con=
st sc)
 	   - led2 green  =3D power to adapter, Gate Array loaded & driver att=
ached
 	   - led3 red    =3D Loss of Signal (LOS) or out of frame (OOF)
 			   conditions detected on T3 receive signal */
-	lmc_trace(sc->lmc_device, "lmc_t1_get_link_status in");
+	lmc_trace(sc->netdev, "lmc_t1_get_link_status in");
 	lmc_led_on(sc, LMC_DS3_LED2);
=20
 	lmc_mii_writereg(sc, 0, 17, T1FRAMER_ALARM1_STATUS);
@@ -846,12 +846,12 @@ static int lmc_t1_get_link_status(struct card * c=
onst sc)
 		sc->last_led_err[2] =3D 0;
 	}
=20
-	sc->lmc_xinfo.t1_alarm1_status =3D link_status;
+	sc->xinfo.t1_alarm1_status =3D link_status;
=20
 	lmc_mii_writereg(sc, 0, 17, T1FRAMER_ALARM2_STATUS);
-	sc->lmc_xinfo.t1_alarm2_status =3D lmc_mii_readreg(sc, 0, 18);
+	sc->xinfo.t1_alarm2_status =3D lmc_mii_readreg(sc, 0, 18);
=20
-	lmc_trace(sc->lmc_device, "lmc_t1_get_link_status out");
+	lmc_trace(sc->netdev, "lmc_t1_get_link_status out");
 	return ret;
 }
=20
@@ -860,18 +860,18 @@ static void lmc_t1_set_crc_length(struct card * c=
onst sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_T1_CRC;
+		sc->miireg16 |=3D LMC_MII16_T1_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
+		sc->crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
=20
 	} else {
-		/* 16 bit */ sc->lmc_miireg16 &=3D ~LMC_MII16_T1_CRC;
+		/* 16 bit */ sc->miireg16 &=3D ~LMC_MII16_T1_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
+		sc->crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
=20
 	}
=20
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+	lmc_mii_writereg(sc, 0, 16, sc->miireg16);
 }
=20
 /* 1 =3D=3D internal, 0 =3D=3D external */
@@ -880,15 +880,15 @@ static void lmc_t1_set_clock(struct card * const =
sc, int ie)
 	int old;
 	old =3D ie;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
-		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->gpio |=3D LMC_GEP_SSI_TXCLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
@@ -898,7 +898,7 @@ static void lmc_t1_set_clock(struct card * const sc=
, int ie)
=20
 static void lmc_t1_default(struct card * const sc)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	sc->miireg16 =3D LMC_MII16_LED_ALL;
 	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
 	lmc_t1_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 	/* Right now we can only clock from out internal source */
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 38f61cb..a3e9aee 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -22,7 +22,7 @@
 #define lmc_csrptr_t		unsigned long
=20
 #define LMC_PRINTF_FMT		"%s"
-#define LMC_PRINTF_ARGS		(sc->lmc_device->name)
+#define LMC_PRINTF_ARGS		(sc->netdev->name)
=20
 #define TX_TIMEOUT		(2*HZ)
=20
@@ -33,10 +33,10 @@
 #define LMC_LINK_DOWN		0
=20
 /* These macros for generic read and write to and from the dec chip */
-#define LMC_CSR_READ(sc, csr)		inl((sc)->lmc_csrs.csr)
-#define LMC_CSR_WRITE(sc, reg, val)	outl((val), (sc)->lmc_csrs.reg)
+#define LMC_CSR_READ(sc, csr)		inl((sc)->csrs.csr)
+#define LMC_CSR_WRITE(sc, reg, val)	outl((val), (sc)->csrs.reg)
=20
-#define lmc_delay()		inl(sc->lmc_csrs.csr_9)
+#define lmc_delay()		inl(sc->csrs.csr_9)
=20
 /* This macro sync's up with the mii so that reads and writes can take=
 place */
 #define LMC_MII_SYNC(sc)					\
@@ -201,7 +201,7 @@ struct media {
=20
 struct lmc_extra_statistics {
 	u32 version_size;
-	u32 lmc_cardtype;
+	u32 cardtype;
=20
 	u32 tx_ProcTimeout;
 	u32 tx_IntTimeout;
@@ -213,10 +213,10 @@ struct lmc_extra_statistics {
 	u32 tx_tbusy1;
 	u32 tx_tbusy_calls;
 	u32 resetCount;
-	u32 lmc_txfull;
+	u32 txfull;
 	u32 tbusy;
 	u32 dirtyTx;
-	u32 lmc_next_tx;
+	u32 next_tx;
 	u32 otherTypeCnt;
 	u32 lastType;
 	u32 lastTypeOK;
@@ -269,46 +269,46 @@ struct card {
 	char *name;
 	u8 board_idx;
 	struct lmc_extra_statistics extra_stats;
-	struct net_device *lmc_device;
+	struct net_device *netdev;
=20
 	int hang, rxdesc, bad_packet, some_counter;
 	u32 txgo;
-	struct lmc_regfile_t lmc_csrs;
-	volatile u32 lmc_txtick;
-	volatile u32 lmc_rxtick;
-	u32 lmc_flags;
-	u32 lmc_intrmask;	/* our copy of csr_intr */
-	u32 lmc_cmdmode;	/* our copy of csr_cmdmode */
-	u32 lmc_busmode;	/* our copy of csr_busmode */
-	u32 lmc_gpio_io;	/* state of in/out settings */
-	u32 lmc_gpio;		/* state of outputs */
-	struct sk_buff *lmc_txq[LMC_TXDESCS];
-	struct sk_buff *lmc_rxq[LMC_RXDESCS];
-	volatile struct tulip_desc_t lmc_rxring[LMC_RXDESCS];
-	volatile struct tulip_desc_t lmc_txring[LMC_TXDESCS];
-	unsigned int lmc_next_rx, lmc_next_tx;
-	volatile unsigned int lmc_taint_tx, lmc_taint_rx;
-	int lmc_tx_start, lmc_txfull;
-	int lmc_txbusy;
-	u16 lmc_miireg16;
-	int lmc_ok;
+	struct lmc_regfile_t csrs;
+	volatile u32 txtick;
+	volatile u32 rxtick;
+	u32 flags;
+	u32 intrmask;		/* our copy of csr_intr */
+	u32 cmdmode;		/* our copy of csr_cmdmode */
+	u32 busmode;		/* our copy of csr_busmode */
+	u32 gpio_io;		/* state of in/out settings */
+	u32 gpio;		/* state of outputs */
+	struct sk_buff *txq[LMC_TXDESCS];
+	struct sk_buff *rxq[LMC_RXDESCS];
+	volatile struct tulip_desc_t rxring[LMC_RXDESCS];
+	volatile struct tulip_desc_t txring[LMC_TXDESCS];
+	unsigned int next_rx, next_tx;
+	volatile unsigned int taint_tx, taint_rx;
+	int tx_start, txfull;
+	int txbusy;
+	u16 miireg16;
+	int ok;
 	int last_link_status;
-	int lmc_cardtype;
+	int cardtype;
 	u32 last_frameerr;
-	struct media *lmc_media;
+	struct media *media;
 	struct timer_list timer;
 	struct control ictl;
 	u32 TxDescriptControlInit;
=20
 	int tx_TimeoutInd;		/* additional driver state */
 	int tx_TimeoutDisplay;
-	unsigned int lastlmc_taint_tx;
+	unsigned int last_taint_tx;
 	int lasttx_packets;
 	u32 tx_clockState;
-	u32 lmc_crcSize;
-	LMC_XINFO lmc_xinfo;
-	char lmc_yel, lmc_blue, lmc_red; /* for T1 and DS3 */
-	char lmc_timing;		/* for HSSI and SSI */
+	u32 crcSize;
+	LMC_XINFO xinfo;
+	char yel, blue, red; /* for T1 and DS3 */
+	char timing;		/* for HSSI and SSI */
 	int got_irq;
=20
 	char last_led_err[4];
@@ -316,7 +316,7 @@ struct card {
 	u32 last_int;
 	u32 num_int;
=20
-	spinlock_t lmc_lock;
+	spinlock_t lock;
=20
 	u8 failed_ring;			/* Failure cases */
 	u8 failed_recv_alloc;
--=20
1.7.1.1

