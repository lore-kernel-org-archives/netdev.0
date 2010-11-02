From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] net: sh_eth: ctrl_in/outX to __raw_read/writeX conversion.
Date: Tue,  2 Nov 2010 11:51:35 +0900
Message-ID: <1288666295-12529-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: lethal@linux-sh.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:59913 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab0KBCvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 22:51:31 -0400
Received: by pwj3 with SMTP id 3so1438438pwj.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 19:51:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ctrl_xxx routines are deprecated, switch over to the __raw_xxx
versions.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/sh_eth.c |  244 +++++++++++++++++++++++++-------------------------
 1 files changed, 122 insertions(+), 122 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 50259df..7229f5d 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -45,9 +45,9 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 	u32 ioaddr = ndev->base_addr;
 
 	if (mdp->duplex) /* Full */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
 	else		/* Half */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
 }
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -57,10 +57,10 @@ static void sh_eth_set_rate(struct net_device *ndev)
 
 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_RTM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) & ~ECMR_RTM, ioaddr + ECMR);
 		break;
 	case 100:/* 100BASE */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_RTM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) | ECMR_RTM, ioaddr + ECMR);
 		break;
 	default:
 		break;
@@ -96,9 +96,9 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 	u32 ioaddr = ndev->base_addr;
 
 	if (mdp->duplex) /* Full */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
 	else		/* Half */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
 }
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -108,10 +108,10 @@ static void sh_eth_set_rate(struct net_device *ndev)
 
 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		ctrl_outl(0, ioaddr + RTRATE);
+		__raw_writel(0, ioaddr + RTRATE);
 		break;
 	case 100:/* 100BASE */
-		ctrl_outl(1, ioaddr + RTRATE);
+		__raw_writel(1, ioaddr + RTRATE);
 		break;
 	default:
 		break;
@@ -143,7 +143,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
 	/* reset device */
-	ctrl_outl(ARSTR_ARSTR, ARSTR);
+	__raw_writel(ARSTR_ARSTR, ARSTR);
 	mdelay(1);
 }
 
@@ -152,10 +152,10 @@ static void sh_eth_reset(struct net_device *ndev)
 	u32 ioaddr = ndev->base_addr;
 	int cnt = 100;
 
-	ctrl_outl(EDSR_ENALL, ioaddr + EDSR);
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	__raw_writel(EDSR_ENALL, ioaddr + EDSR);
+	__raw_writel(__raw_readl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
 	while (cnt > 0) {
-		if (!(ctrl_inl(ioaddr + EDMR) & 0x3))
+		if (!(__raw_readl(ioaddr + EDMR) & 0x3))
 			break;
 		mdelay(1);
 		cnt--;
@@ -164,14 +164,14 @@ static void sh_eth_reset(struct net_device *ndev)
 		printk(KERN_ERR "Device reset fail\n");
 
 	/* Table Init */
-	ctrl_outl(0x0, ioaddr + TDLAR);
-	ctrl_outl(0x0, ioaddr + TDFAR);
-	ctrl_outl(0x0, ioaddr + TDFXR);
-	ctrl_outl(0x0, ioaddr + TDFFR);
-	ctrl_outl(0x0, ioaddr + RDLAR);
-	ctrl_outl(0x0, ioaddr + RDFAR);
-	ctrl_outl(0x0, ioaddr + RDFXR);
-	ctrl_outl(0x0, ioaddr + RDFFR);
+	__raw_writel(0x0, ioaddr + TDLAR);
+	__raw_writel(0x0, ioaddr + TDFAR);
+	__raw_writel(0x0, ioaddr + TDFXR);
+	__raw_writel(0x0, ioaddr + TDFFR);
+	__raw_writel(0x0, ioaddr + RDLAR);
+	__raw_writel(0x0, ioaddr + RDFAR);
+	__raw_writel(0x0, ioaddr + RDFXR);
+	__raw_writel(0x0, ioaddr + RDFFR);
 }
 
 static void sh_eth_set_duplex(struct net_device *ndev)
@@ -180,9 +180,9 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 	u32 ioaddr = ndev->base_addr;
 
 	if (mdp->duplex) /* Full */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) | ECMR_DM, ioaddr + ECMR);
 	else		/* Half */
-		ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
+		__raw_writel(__raw_readl(ioaddr + ECMR) & ~ECMR_DM, ioaddr + ECMR);
 }
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -192,13 +192,13 @@ static void sh_eth_set_rate(struct net_device *ndev)
 
 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		ctrl_outl(GECMR_10, ioaddr + GECMR);
+		__raw_writel(GECMR_10, ioaddr + GECMR);
 		break;
 	case 100:/* 100BASE */
-		ctrl_outl(GECMR_100, ioaddr + GECMR);
+		__raw_writel(GECMR_100, ioaddr + GECMR);
 		break;
 	case 1000: /* 1000BASE */
-		ctrl_outl(GECMR_1000, ioaddr + GECMR);
+		__raw_writel(GECMR_1000, ioaddr + GECMR);
 		break;
 	default:
 		break;
@@ -283,9 +283,9 @@ static void sh_eth_reset(struct net_device *ndev)
 {
 	u32 ioaddr = ndev->base_addr;
 
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	__raw_writel(__raw_readl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
 	mdelay(3);
-	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+	__raw_writel(__raw_readl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
 }
 #endif
 
@@ -336,10 +336,10 @@ static void update_mac_address(struct net_device *ndev)
 {
 	u32 ioaddr = ndev->base_addr;
 
-	ctrl_outl((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+	__raw_writel((ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
 		  (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]),
 		  ioaddr + MAHR);
-	ctrl_outl((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
+	__raw_writel((ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]),
 		  ioaddr + MALR);
 }
 
@@ -358,12 +358,12 @@ static void read_mac_address(struct net_device *ndev, unsigned char *mac)
 	if (mac[0] || mac[1] || mac[2] || mac[3] || mac[4] || mac[5]) {
 		memcpy(ndev->dev_addr, mac, 6);
 	} else {
-		ndev->dev_addr[0] = (ctrl_inl(ioaddr + MAHR) >> 24);
-		ndev->dev_addr[1] = (ctrl_inl(ioaddr + MAHR) >> 16) & 0xFF;
-		ndev->dev_addr[2] = (ctrl_inl(ioaddr + MAHR) >> 8) & 0xFF;
-		ndev->dev_addr[3] = (ctrl_inl(ioaddr + MAHR) & 0xFF);
-		ndev->dev_addr[4] = (ctrl_inl(ioaddr + MALR) >> 8) & 0xFF;
-		ndev->dev_addr[5] = (ctrl_inl(ioaddr + MALR) & 0xFF);
+		ndev->dev_addr[0] = (__raw_readl(ioaddr + MAHR) >> 24);
+		ndev->dev_addr[1] = (__raw_readl(ioaddr + MAHR) >> 16) & 0xFF;
+		ndev->dev_addr[2] = (__raw_readl(ioaddr + MAHR) >> 8) & 0xFF;
+		ndev->dev_addr[3] = (__raw_readl(ioaddr + MAHR) & 0xFF);
+		ndev->dev_addr[4] = (__raw_readl(ioaddr + MALR) >> 8) & 0xFF;
+		ndev->dev_addr[5] = (__raw_readl(ioaddr + MALR) & 0xFF);
 	}
 }
 
@@ -379,19 +379,19 @@ struct bb_info {
 /* PHY bit set */
 static void bb_set(u32 addr, u32 msk)
 {
-	ctrl_outl(ctrl_inl(addr) | msk, addr);
+	__raw_writel(__raw_readl(addr) | msk, addr);
 }
 
 /* PHY bit clear */
 static void bb_clr(u32 addr, u32 msk)
 {
-	ctrl_outl((ctrl_inl(addr) & ~msk), addr);
+	__raw_writel((__raw_readl(addr) & ~msk), addr);
 }
 
 /* PHY bit read */
 static int bb_read(u32 addr, u32 msk)
 {
-	return (ctrl_inl(addr) & msk) != 0;
+	return (__raw_readl(addr) & msk) != 0;
 }
 
 /* Data I/O pin control */
@@ -506,9 +506,9 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 		/* Rx descriptor address set */
 		if (i == 0) {
-			ctrl_outl(mdp->rx_desc_dma, ioaddr + RDLAR);
+			__raw_writel(mdp->rx_desc_dma, ioaddr + RDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			ctrl_outl(mdp->rx_desc_dma, ioaddr + RDFAR);
+			__raw_writel(mdp->rx_desc_dma, ioaddr + RDFAR);
 #endif
 		}
 	}
@@ -528,9 +528,9 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		txdesc->buffer_length = 0;
 		if (i == 0) {
 			/* Tx descriptor address set */
-			ctrl_outl(mdp->tx_desc_dma, ioaddr + TDLAR);
+			__raw_writel(mdp->tx_desc_dma, ioaddr + TDLAR);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-			ctrl_outl(mdp->tx_desc_dma, ioaddr + TDFAR);
+			__raw_writel(mdp->tx_desc_dma, ioaddr + TDFAR);
 #endif
 		}
 	}
@@ -623,71 +623,71 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
 	if (mdp->cd->rpadir)
-		ctrl_outl(mdp->cd->rpadir_value, ioaddr + RPADIR);
+		__raw_writel(mdp->cd->rpadir_value, ioaddr + RPADIR);
 
 	/* all sh_eth int mask */
-	ctrl_outl(0, ioaddr + EESIPR);
+	__raw_writel(0, ioaddr + EESIPR);
 
 #if defined(__LITTLE_ENDIAN__)
 	if (mdp->cd->hw_swap)
-		ctrl_outl(EDMR_EL, ioaddr + EDMR);
+		__raw_writel(EDMR_EL, ioaddr + EDMR);
 	else
 #endif
-		ctrl_outl(0, ioaddr + EDMR);
+		__raw_writel(0, ioaddr + EDMR);
 
 	/* FIFO size set */
-	ctrl_outl(mdp->cd->fdr_value, ioaddr + FDR);
-	ctrl_outl(0, ioaddr + TFTR);
+	__raw_writel(mdp->cd->fdr_value, ioaddr + FDR);
+	__raw_writel(0, ioaddr + TFTR);
 
 	/* Frame recv control */
-	ctrl_outl(mdp->cd->rmcr_value, ioaddr + RMCR);
+	__raw_writel(mdp->cd->rmcr_value, ioaddr + RMCR);
 
 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
-	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);
+	__raw_writel(rx_int_var | tx_int_var, ioaddr + TRSCER);
 
 	if (mdp->cd->bculr)
-		ctrl_outl(0x800, ioaddr + BCULR);	/* Burst sycle set */
+		__raw_writel(0x800, ioaddr + BCULR);	/* Burst sycle set */
 
-	ctrl_outl(mdp->cd->fcftr_value, ioaddr + FCFTR);
+	__raw_writel(mdp->cd->fcftr_value, ioaddr + FCFTR);
 
 	if (!mdp->cd->no_trimd)
-		ctrl_outl(0, ioaddr + TRIMD);
+		__raw_writel(0, ioaddr + TRIMD);
 
 	/* Recv frame limit set register */
-	ctrl_outl(RFLR_VALUE, ioaddr + RFLR);
+	__raw_writel(RFLR_VALUE, ioaddr + RFLR);
 
-	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
-	ctrl_outl(mdp->cd->eesipr_value, ioaddr + EESIPR);
+	__raw_writel(__raw_readl(ioaddr + EESR), ioaddr + EESR);
+	__raw_writel(mdp->cd->eesipr_value, ioaddr + EESIPR);
 
 	/* PAUSE Prohibition */
-	val = (ctrl_inl(ioaddr + ECMR) & ECMR_DM) |
+	val = (__raw_readl(ioaddr + ECMR) & ECMR_DM) |
 		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
 
-	ctrl_outl(val, ioaddr + ECMR);
+	__raw_writel(val, ioaddr + ECMR);
 
 	if (mdp->cd->set_rate)
 		mdp->cd->set_rate(ndev);
 
 	/* E-MAC Status Register clear */
-	ctrl_outl(mdp->cd->ecsr_value, ioaddr + ECSR);
+	__raw_writel(mdp->cd->ecsr_value, ioaddr + ECSR);
 
 	/* E-MAC Interrupt Enable register */
-	ctrl_outl(mdp->cd->ecsipr_value, ioaddr + ECSIPR);
+	__raw_writel(mdp->cd->ecsipr_value, ioaddr + ECSIPR);
 
 	/* Set MAC address */
 	update_mac_address(ndev);
 
 	/* mask reset */
 	if (mdp->cd->apr)
-		ctrl_outl(APR_AP, ioaddr + APR);
+		__raw_writel(APR_AP, ioaddr + APR);
 	if (mdp->cd->mpr)
-		ctrl_outl(MPR_MP, ioaddr + MPR);
+		__raw_writel(MPR_MP, ioaddr + MPR);
 	if (mdp->cd->tpauser)
-		ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+		__raw_writel(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
 
 	/* Setting the Rx mode will start the Rx process. */
-	ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+	__raw_writel(EDRRR_R, ioaddr + EDRRR);
 
 	netif_start_queue(ndev);
 
@@ -811,8 +811,8 @@ static int sh_eth_rx(struct net_device *ndev)
 
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (!(ctrl_inl(ndev->base_addr + EDRRR) & EDRRR_R))
-		ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
+	if (!(__raw_readl(ndev->base_addr + EDRRR) & EDRRR_R))
+		__raw_writel(EDRRR_R, ndev->base_addr + EDRRR);
 
 	return 0;
 }
@@ -827,8 +827,8 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 	u32 mask;
 
 	if (intr_status & EESR_ECI) {
-		felic_stat = ctrl_inl(ioaddr + ECSR);
-		ctrl_outl(felic_stat, ioaddr + ECSR);	/* clear int */
+		felic_stat = __raw_readl(ioaddr + ECSR);
+		__raw_writel(felic_stat, ioaddr + ECSR);	/* clear int */
 		if (felic_stat & ECSR_ICD)
 			mdp->stats.tx_carrier_errors++;
 		if (felic_stat & ECSR_LCHNG) {
@@ -839,25 +839,25 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				else
 					link_stat = PHY_ST_LINK;
 			} else {
-				link_stat = (ctrl_inl(ioaddr + PSR));
+				link_stat = (__raw_readl(ioaddr + PSR));
 				if (mdp->ether_link_active_low)
 					link_stat = ~link_stat;
 			}
 			if (!(link_stat & PHY_ST_LINK)) {
 				/* Link Down : disable tx and rx */
-				ctrl_outl(ctrl_inl(ioaddr + ECMR) &
+				__raw_writel(__raw_readl(ioaddr + ECMR) &
 					  ~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
 			} else {
 				/* Link Up */
-				ctrl_outl(ctrl_inl(ioaddr + EESIPR) &
+				__raw_writel(__raw_readl(ioaddr + EESIPR) &
 					  ~DMAC_M_ECI, ioaddr + EESIPR);
 				/*clear int */
-				ctrl_outl(ctrl_inl(ioaddr + ECSR),
+				__raw_writel(__raw_readl(ioaddr + ECSR),
 					  ioaddr + ECSR);
-				ctrl_outl(ctrl_inl(ioaddr + EESIPR) |
+				__raw_writel(__raw_readl(ioaddr + EESIPR) |
 					  DMAC_M_ECI, ioaddr + EESIPR);
 				/* enable tx and rx */
-				ctrl_outl(ctrl_inl(ioaddr + ECMR) |
+				__raw_writel(__raw_readl(ioaddr + ECMR) |
 					  (ECMR_RE | ECMR_TE), ioaddr + ECMR);
 			}
 		}
@@ -888,8 +888,8 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* Receive Descriptor Empty int */
 		mdp->stats.rx_over_errors++;
 
-		if (ctrl_inl(ioaddr + EDRRR) ^ EDRRR_R)
-			ctrl_outl(EDRRR_R, ioaddr + EDRRR);
+		if (__raw_readl(ioaddr + EDRRR) ^ EDRRR_R)
+			__raw_writel(EDRRR_R, ioaddr + EDRRR);
 		dev_err(&ndev->dev, "Receive Descriptor Empty\n");
 	}
 	if (intr_status & EESR_RFE) {
@@ -903,7 +903,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		mask &= ~EESR_ADE;
 	if (intr_status & mask) {
 		/* Tx error */
-		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
+		u32 edtrr = __raw_readl(ndev->base_addr + EDTRR);
 		/* dmesg */
 		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
 				intr_status, mdp->cur_tx);
@@ -915,7 +915,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* SH7712 BUG */
 		if (edtrr ^ EDTRR_TRNS) {
 			/* tx dma start */
-			ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+			__raw_writel(EDTRR_TRNS, ndev->base_addr + EDTRR);
 		}
 		/* wakeup */
 		netif_wake_queue(ndev);
@@ -934,12 +934,12 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	spin_lock(&mdp->lock);
 
 	/* Get interrpt stat */
-	intr_status = ctrl_inl(ioaddr + EESR);
+	intr_status = __raw_readl(ioaddr + EESR);
 	/* Clear interrupt */
 	if (intr_status & (EESR_FRC | EESR_RMAF | EESR_RRF |
 			EESR_RTLF | EESR_RTSF | EESR_PRE | EESR_CERF |
 			cd->tx_check | cd->eesr_err_check)) {
-		ctrl_outl(intr_status, ioaddr + EESR);
+		__raw_writel(intr_status, ioaddr + EESR);
 		ret = IRQ_HANDLED;
 	} else
 		goto other_irq;
@@ -1000,7 +1000,7 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 				mdp->cd->set_rate(ndev);
 		}
 		if (mdp->link == PHY_DOWN) {
-			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
+			__raw_writel((__raw_readl(ioaddr + ECMR) & ~ECMR_TXF)
 					| ECMR_DM, ioaddr + ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
@@ -1125,7 +1125,7 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 
 	/* worning message out. */
 	printk(KERN_WARNING "%s: transmit timed out, status %8.8x,"
-	       " resetting...\n", ndev->name, (int)ctrl_inl(ioaddr + EESR));
+	       " resetting...\n", ndev->name, (int)__raw_readl(ioaddr + EESR));
 
 	/* tx_errors count up */
 	mdp->stats.tx_errors++;
@@ -1196,8 +1196,8 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	mdp->cur_tx++;
 
-	if (!(ctrl_inl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
-		ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	if (!(__raw_readl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
+		__raw_writel(EDTRR_TRNS, ndev->base_addr + EDTRR);
 
 	return NETDEV_TX_OK;
 }
@@ -1212,11 +1212,11 @@ static int sh_eth_close(struct net_device *ndev)
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts by clearing the interrupt mask. */
-	ctrl_outl(0x0000, ioaddr + EESIPR);
+	__raw_writel(0x0000, ioaddr + EESIPR);
 
 	/* Stop the chip's Tx and Rx processes. */
-	ctrl_outl(0, ioaddr + EDTRR);
-	ctrl_outl(0, ioaddr + EDRRR);
+	__raw_writel(0, ioaddr + EDTRR);
+	__raw_writel(0, ioaddr + EDRRR);
 
 	/* PHY Disconnect */
 	if (mdp->phydev) {
@@ -1251,20 +1251,20 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
-	mdp->stats.tx_dropped += ctrl_inl(ioaddr + TROCR);
-	ctrl_outl(0, ioaddr + TROCR);	/* (write clear) */
-	mdp->stats.collisions += ctrl_inl(ioaddr + CDCR);
-	ctrl_outl(0, ioaddr + CDCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + LCCR);
-	ctrl_outl(0, ioaddr + LCCR);	/* (write clear) */
+	mdp->stats.tx_dropped += __raw_readl(ioaddr + TROCR);
+	__raw_writel(0, ioaddr + TROCR);	/* (write clear) */
+	mdp->stats.collisions += __raw_readl(ioaddr + CDCR);
+	__raw_writel(0, ioaddr + CDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += __raw_readl(ioaddr + LCCR);
+	__raw_writel(0, ioaddr + LCCR);	/* (write clear) */
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CERCR);/* CERCR */
-	ctrl_outl(0, ioaddr + CERCR);	/* (write clear) */
-	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CEECR);/* CEECR */
-	ctrl_outl(0, ioaddr + CEECR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += __raw_readl(ioaddr + CERCR);/* CERCR */
+	__raw_writel(0, ioaddr + CERCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += __raw_readl(ioaddr + CEECR);/* CEECR */
+	__raw_writel(0, ioaddr + CEECR);	/* (write clear) */
 #else
-	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
-	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += __raw_readl(ioaddr + CNDCR);
+	__raw_writel(0, ioaddr + CNDCR);	/* (write clear) */
 #endif
 	pm_runtime_put_sync(&mdp->pdev->dev);
 
@@ -1295,11 +1295,11 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 
 	if (ndev->flags & IFF_PROMISC) {
 		/* Set promiscuous. */
-		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_MCT) | ECMR_PRM,
+		__raw_writel((__raw_readl(ioaddr + ECMR) & ~ECMR_MCT) | ECMR_PRM,
 			  ioaddr + ECMR);
 	} else {
 		/* Normal, unicast/broadcast-only mode. */
-		ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_PRM) | ECMR_MCT,
+		__raw_writel((__raw_readl(ioaddr + ECMR) & ~ECMR_PRM) | ECMR_MCT,
 			  ioaddr + ECMR);
 	}
 }
@@ -1307,30 +1307,30 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(u32 ioaddr)
 {
-	ctrl_outl(0, ioaddr + TSU_FWEN0);	/* Disable forward(0->1) */
-	ctrl_outl(0, ioaddr + TSU_FWEN1);	/* Disable forward(1->0) */
-	ctrl_outl(0, ioaddr + TSU_FCM);	/* forward fifo 3k-3k */
-	ctrl_outl(0xc, ioaddr + TSU_BSYSL0);
-	ctrl_outl(0xc, ioaddr + TSU_BSYSL1);
-	ctrl_outl(0, ioaddr + TSU_PRISL0);
-	ctrl_outl(0, ioaddr + TSU_PRISL1);
-	ctrl_outl(0, ioaddr + TSU_FWSL0);
-	ctrl_outl(0, ioaddr + TSU_FWSL1);
-	ctrl_outl(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+	__raw_writel(0, ioaddr + TSU_FWEN0);	/* Disable forward(0->1) */
+	__raw_writel(0, ioaddr + TSU_FWEN1);	/* Disable forward(1->0) */
+	__raw_writel(0, ioaddr + TSU_FCM);	/* forward fifo 3k-3k */
+	__raw_writel(0xc, ioaddr + TSU_BSYSL0);
+	__raw_writel(0xc, ioaddr + TSU_BSYSL1);
+	__raw_writel(0, ioaddr + TSU_PRISL0);
+	__raw_writel(0, ioaddr + TSU_PRISL1);
+	__raw_writel(0, ioaddr + TSU_FWSL0);
+	__raw_writel(0, ioaddr + TSU_FWSL1);
+	__raw_writel(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
 #if defined(CONFIG_CPU_SUBTYPE_SH7763)
-	ctrl_outl(0, ioaddr + TSU_QTAG0);	/* Disable QTAG(0->1) */
-	ctrl_outl(0, ioaddr + TSU_QTAG1);	/* Disable QTAG(1->0) */
+	__raw_writel(0, ioaddr + TSU_QTAG0);	/* Disable QTAG(0->1) */
+	__raw_writel(0, ioaddr + TSU_QTAG1);	/* Disable QTAG(1->0) */
 #else
-	ctrl_outl(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
-	ctrl_outl(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+	__raw_writel(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
+	__raw_writel(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
 #endif
-	ctrl_outl(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
-	ctrl_outl(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
-	ctrl_outl(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
-	ctrl_outl(0, ioaddr + TSU_POST1);	/* Disable CAM entry [ 0- 7] */
-	ctrl_outl(0, ioaddr + TSU_POST2);	/* Disable CAM entry [ 8-15] */
-	ctrl_outl(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
-	ctrl_outl(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
+	__raw_writel(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
+	__raw_writel(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
+	__raw_writel(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
+	__raw_writel(0, ioaddr + TSU_POST1);	/* Disable CAM entry [ 0- 7] */
+	__raw_writel(0, ioaddr + TSU_POST2);	/* Disable CAM entry [ 8-15] */
+	__raw_writel(0, ioaddr + TSU_POST3);	/* Disable CAM entry [16-23] */
+	__raw_writel(0, ioaddr + TSU_POST4);	/* Disable CAM entry [24-31] */
 }
 #endif /* SH_ETH_HAS_TSU */
 
-- 
1.7.2.3

