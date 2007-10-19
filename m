From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 6/8] [MV643XX_ETH] Remove MV643XX_ETH_ register prefix
Date: Fri, 19 Oct 2007 04:11:28 +0200
Message-ID: <20071019021128.GH16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:44013 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763986AbXJSCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:11:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that all register address and bit defines are in private
namespace (drivers/net/mv643xx_eth.h), we can safely remove the
MV643XX_ETH_ prefix to conserve horizontal space.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6/drivers/net/mv643xx_eth.c
@@ -80,7 +80,7 @@ static char mv643xx_driver_version[] = "
 
 static void __iomem *mv643xx_eth_base;
 
-/* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
+/* used to protect SMI_REG, which is shared across ports */
 static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
 
 static inline u32 mv_read(int offset)
@@ -214,12 +214,12 @@ static void mv643xx_eth_set_rx_mode(stru
 	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num));
+	config_reg = mv_read(PORT_CONFIG_REG(mp->port_num));
 	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
 	else
-		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num), config_reg);
+		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
+	mv_write(PORT_CONFIG_REG(mp->port_num), config_reg);
 
 	eth_port_set_multicast_list(dev);
 }
@@ -455,41 +455,37 @@ static void mv643xx_eth_update_pscr(stru
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
 
-	o_pscr = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	o_pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
 	n_pscr = o_pscr;
 
 	/* clear speed, duplex and rx buffer size fields */
-	n_pscr &= ~(MV643XX_ETH_SET_MII_SPEED_TO_100  |
-		   MV643XX_ETH_SET_GMII_SPEED_TO_1000 |
-		   MV643XX_ETH_SET_FULL_DUPLEX_MODE   |
-		   MV643XX_ETH_MAX_RX_PACKET_MASK);
+	n_pscr &= ~(SET_MII_SPEED_TO_100  |
+		   SET_GMII_SPEED_TO_1000 |
+		   SET_FULL_DUPLEX_MODE   |
+		   MAX_RX_PACKET_MASK);
 
 	if (ecmd->duplex == DUPLEX_FULL)
-		n_pscr |= MV643XX_ETH_SET_FULL_DUPLEX_MODE;
+		n_pscr |= SET_FULL_DUPLEX_MODE;
 
 	if (ecmd->speed == SPEED_1000)
-		n_pscr |= MV643XX_ETH_SET_GMII_SPEED_TO_1000 |
-			  MV643XX_ETH_MAX_RX_PACKET_9700BYTE;
+		n_pscr |= SET_GMII_SPEED_TO_1000 |
+			  MAX_RX_PACKET_9700BYTE;
 	else {
 		if (ecmd->speed == SPEED_100)
-			n_pscr |= MV643XX_ETH_SET_MII_SPEED_TO_100;
-		n_pscr |= MV643XX_ETH_MAX_RX_PACKET_1522BYTE;
+			n_pscr |= SET_MII_SPEED_TO_100;
+		n_pscr |= MAX_RX_PACKET_1522BYTE;
 	}
 
 	if (n_pscr != o_pscr) {
-		if ((o_pscr & MV643XX_ETH_SERIAL_PORT_ENABLE) == 0)
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
+		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 		else {
 			queues = mv643xx_eth_port_disable_tx(port_num);
 
-			o_pscr &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								o_pscr);
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
-			mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-								n_pscr);
+			o_pscr &= ~SERIAL_PORT_ENABLE;
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 			if (queues)
 				mv643xx_eth_port_enable_tx(port_num, queues);
 		}
@@ -515,13 +511,13 @@ static irqreturn_t mv643xx_eth_int_handl
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = mv_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+	eth_int_cause = mv_read(INTERRUPT_CAUSE_REG(port_num)) &
 						ETH_INT_UNMASK_ALL;
 	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
 		eth_int_cause_ext = mv_read(
-			MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
+			INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
 						ETH_INT_UNMASK_ALL_EXT;
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num),
+		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num),
 							~eth_int_cause_ext);
 	}
 
@@ -549,10 +545,10 @@ static irqreturn_t mv643xx_eth_int_handl
 #ifdef MV643XX_NAPI
 	if (eth_int_cause & ETH_INT_CAUSE_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-							ETH_INT_MASK_ALL);
+		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+
 		/* wait for previous write to complete */
-		mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+		mv_read(INTERRUPT_MASK_REG(port_num));
 
 		netif_rx_schedule(dev, &mp->napi);
 	}
@@ -604,9 +600,9 @@ static unsigned int eth_port_set_rx_coal
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
+	mv_write(SDMA_CONFIG_REG(eth_port_num),
 		((coal & 0x3fff) << 8) |
-		(mv_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
+		(mv_read(SDMA_CONFIG_REG(eth_port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -642,8 +638,7 @@ static unsigned int eth_port_set_tx_coal
 	unsigned int coal;
 	coal = ((t_clk / 1000000) * delay) / 64;
 	/* Set TX Coalescing mechanism */
-	mv_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
-								coal << 4);
+	mv_write(TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num), coal << 4);
 	return coal;
 }
 
@@ -779,10 +774,10 @@ static int mv643xx_eth_open(struct net_d
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 	/* wait for previous write to complete */
-	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+	mv_read (INTERRUPT_CAUSE_EXTEND_REG(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -889,11 +884,10 @@ static int mv643xx_eth_open(struct net_d
 		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
-						ETH_INT_UNMASK_ALL_EXT);
+	mv_write(INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
 
 	/* Unmask RX buffer and TX end interrupt */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 
 	return 0;
 
@@ -973,9 +967,9 @@ static int mv643xx_eth_stop(struct net_d
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_read(INTERRUPT_MASK_REG(port_num));
 
 #ifdef MV643XX_NAPI
 	napi_disable(&mp->napi);
@@ -1014,16 +1008,15 @@ static int mv643xx_poll(struct napi_stru
 #endif
 
 	work_done = 0;
-	if ((mv_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	if ((mv_read(RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
 	    != (u32) mp->rx_used_desc_q)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
-						ETH_INT_UNMASK_ALL);
+		mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
+		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 	}
 
 	return work_done;
@@ -1226,13 +1219,13 @@ static void mv643xx_netpoll(struct net_d
 	struct mv643xx_private *mp = netdev_priv(netdev);
 	int port_num = mp->port_num;
 
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_read(INTERRUPT_MASK_REG(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 }
 #endif
 
@@ -1350,8 +1343,8 @@ static int mv643xx_eth_probe(struct plat
 
 	/* set default config values */
 	eth_port_uc_addr_get(port_num, dev->dev_addr);
-	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
-	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
+	mp->tx_ring_size = PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
@@ -1486,8 +1479,8 @@ static void mv643xx_eth_shutdown(struct 
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
-	mv_read (MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+	mv_write(INTERRUPT_MASK_REG(port_num), 0);
+	mv_read (INTERRUPT_MASK_REG(port_num));
 
 	eth_port_reset(port_num);
 }
@@ -1754,49 +1747,49 @@ static void eth_port_start(struct net_de
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	mv_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv_write(TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	mv_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv_write(RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(port_num, dev->dev_addr);
 
 	/* Assign port configuration and command. */
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
-			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
+	mv_write(PORT_CONFIG_REG(port_num),
+			  PORT_CONFIG_DEFAULT_VALUE);
 
-	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
-			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+	mv_write(PORT_CONFIG_EXTEND_REG(port_num),
+			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
 
-	pscr = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
 
-	pscr &= ~(MV643XX_ETH_SERIAL_PORT_ENABLE | MV643XX_ETH_FORCE_LINK_PASS);
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
-	pscr |= MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII    |
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX     |
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	   |
-		MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED;
+	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+		DISABLE_AUTO_NEG_SPEED_GMII    |
+		DISABLE_AUTO_NEG_FOR_DUPLX     |
+		DO_NOT_FORCE_LINK_FAIL	   |
+		SERIAL_PORT_CONTROL_RESERVED;
 
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
-	pscr |= MV643XX_ETH_SERIAL_PORT_ENABLE;
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	pscr |= SERIAL_PORT_ENABLE;
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
 	/* Assign port SDMA configuration */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
-			  MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE);
+	mv_write(SDMA_CONFIG_REG(port_num),
+			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
 	mv643xx_eth_port_enable_rx(port_num, ETH_RX_QUEUES_ENABLED);
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	mv_write(MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+	mv_write(MAXIMUM_TRANSMIT_UNIT(port_num), 0);
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
@@ -1817,11 +1810,11 @@ static void eth_port_uc_addr_set(unsigne
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	mv_write(MV643XX_ETH_MAC_ADDR_LOW(port_num), mac_l);
-	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(port_num), mac_h);
+	mv_write(MAC_ADDR_LOW(port_num), mac_l);
+	mv_write(MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
-	table = MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port_num);
+	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
 	eth_port_set_filter_table_entry(table, p_addr[5] & 0x0f);
 }
 
@@ -1833,8 +1826,8 @@ static void eth_port_uc_addr_get(unsigne
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(port_num));
-	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(port_num));
+	mac_h = mv_read(MAC_ADDR_HIGH(port_num));
+	mac_l = mv_read(MAC_ADDR_LOW(port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
@@ -1894,7 +1887,7 @@ static void eth_port_mc_addr(unsigned in
 
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 					(eth_port_num);
 		eth_port_set_filter_table_entry(table, p_addr[5]);
 		return;
@@ -1968,7 +1961,7 @@ static void eth_port_mc_addr(unsigned in
 	for (i = 0; i < 8; i++)
 		crc_result = crc_result | (crc[i] << i);
 
-	table = MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num);
+	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num);
 	eth_port_set_filter_table_entry(table, crc_result);
 }
 
@@ -1998,7 +1991,7 @@ static void eth_port_set_multicast_list(
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -2008,7 +2001,7 @@ static void eth_port_set_multicast_list(
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -2018,11 +2011,11 @@ static void eth_port_set_multicast_list(
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 	}
 
@@ -2056,15 +2049,15 @@ static void eth_port_init_mac_tables(uns
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv_write(MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		mv_write(DA_FILTER_UNICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index, 0);
 	}
 }
@@ -2093,12 +2086,12 @@ static void eth_clear_mib_counters(unsig
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+		mv_read(MIB_COUNTERS_BASE(eth_port_num) + i);
 }
 
 static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 {
-	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return mv_read(MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
 static void eth_update_mib_counters(struct mv643xx_private *mp)
@@ -2183,7 +2176,7 @@ static int ethernet_phy_get(unsigned int
 {
 	unsigned int reg_data;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv_read(PHY_ADDR_REG);
 
 	return ((reg_data >> (5 * eth_port_num)) & 0x1f);
 }
@@ -2210,10 +2203,10 @@ static void ethernet_phy_set(unsigned in
 	u32 reg_data;
 	int addr_shift = 5 * eth_port_num;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv_read(PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	mv_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
+	mv_write(PHY_ADDR_REG, reg_data);
 }
 
 /*
@@ -2251,13 +2244,13 @@ static void ethernet_phy_reset(unsigned 
 static void mv643xx_eth_port_enable_tx(unsigned int port_num,
 					unsigned int queues)
 {
-	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
 }
 
 static void mv643xx_eth_port_enable_rx(unsigned int port_num,
 					unsigned int queues)
 {
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
 }
 
 static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num)
@@ -2265,21 +2258,18 @@ static unsigned int mv643xx_eth_port_dis
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	queues = mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
-							& 0xFF;
+	queues = mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
-							(queues << 8));
+		mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
-							& 0xFF)
+		while (mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 
 		/* Wait for Tx FIFO to empty */
-		while (mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num)) &
+		while (mv_read(PORT_STATUS_REG(port_num)) &
 							ETH_PORT_TX_FIFO_EMPTY)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
@@ -2292,17 +2282,14 @@ static unsigned int mv643xx_eth_port_dis
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	queues = mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
-							& 0xFF;
+	queues = mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
-							(queues << 8));
+		mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
-							& 0xFF)
+		while (mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
@@ -2338,11 +2325,11 @@ static void eth_port_reset(unsigned int 
 	eth_clear_mib_counters(port_num);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
-	reg_data &= ~(MV643XX_ETH_SERIAL_PORT_ENABLE		|
-			MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|
-			MV643XX_ETH_FORCE_LINK_PASS);
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	reg_data = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data &= ~(SERIAL_PORT_ENABLE		|
+			DO_NOT_FORCE_LINK_FAIL	|
+			FORCE_LINK_PASS);
+	mv_write(PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 
@@ -2377,7 +2364,7 @@ static void eth_port_read_smi_reg(unsign
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n", port_num);
 			goto out;
@@ -2385,11 +2372,11 @@ static void eth_port_read_smi_reg(unsign
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG,
+	mv_write(SMI_REG,
 		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(mv_read(SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY read timeout, port %d\n", port_num);
 			goto out;
@@ -2397,7 +2384,7 @@ static void eth_port_read_smi_reg(unsign
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = mv_read(MV643XX_ETH_SMI_REG) & 0xffff;
+	*value = mv_read(SMI_REG) & 0xffff;
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
@@ -2435,7 +2422,7 @@ static void eth_port_write_smi_reg(unsig
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n",
 								eth_port_num);
@@ -2444,7 +2431,7 @@ static void eth_port_write_smi_reg(unsig
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
+	mv_write(SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -55,318 +55,318 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
-#define MV643XX_ETH_PHY_ADDR_REG                                    0x0000
-#define MV643XX_ETH_SMI_REG                                         0x0004
-#define MV643XX_ETH_UNIT_DEFAULT_ADDR_REG                           0x0008
-#define MV643XX_ETH_UNIT_DEFAULTID_REG                              0x000c
-#define MV643XX_ETH_UNIT_INTERRUPT_CAUSE_REG                        0x0080
-#define MV643XX_ETH_UNIT_INTERRUPT_MASK_REG                         0x0084
-#define MV643XX_ETH_UNIT_INTERNAL_USE_REG                           0x04fc
-#define MV643XX_ETH_UNIT_ERROR_ADDR_REG                             0x0094
-#define MV643XX_ETH_BAR_0                                           0x0200
-#define MV643XX_ETH_BAR_1                                           0x0208
-#define MV643XX_ETH_BAR_2                                           0x0210
-#define MV643XX_ETH_BAR_3                                           0x0218
-#define MV643XX_ETH_BAR_4                                           0x0220
-#define MV643XX_ETH_BAR_5                                           0x0228
-#define MV643XX_ETH_SIZE_REG_0                                      0x0204
-#define MV643XX_ETH_SIZE_REG_1                                      0x020c
-#define MV643XX_ETH_SIZE_REG_2                                      0x0214
-#define MV643XX_ETH_SIZE_REG_3                                      0x021c
-#define MV643XX_ETH_SIZE_REG_4                                      0x0224
-#define MV643XX_ETH_SIZE_REG_5                                      0x022c
-#define MV643XX_ETH_HEADERS_RETARGET_BASE_REG                       0x0230
-#define MV643XX_ETH_HEADERS_RETARGET_CONTROL_REG                    0x0234
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_0                           0x0280
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_1                           0x0284
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_2                           0x0288
-#define MV643XX_ETH_HIGH_ADDR_REMAP_REG_3                           0x028c
-#define MV643XX_ETH_BASE_ADDR_ENABLE_REG                            0x0290
-#define MV643XX_ETH_ACCESS_PROTECTION_REG(port)                    (0x0294 + (port<<2))
-#define MV643XX_ETH_MIB_COUNTERS_BASE(port)                        (0x1000 + (port<<7))
-#define MV643XX_ETH_PORT_CONFIG_REG(port)                          (0x0400 + (port<<10))
-#define MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port)                   (0x0404 + (port<<10))
-#define MV643XX_ETH_MII_SERIAL_PARAMETRS_REG(port)                 (0x0408 + (port<<10))
-#define MV643XX_ETH_GMII_SERIAL_PARAMETRS_REG(port)                (0x040c + (port<<10))
-#define MV643XX_ETH_VLAN_ETHERTYPE_REG(port)                       (0x0410 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_LOW(port)                             (0x0414 + (port<<10))
-#define MV643XX_ETH_MAC_ADDR_HIGH(port)                            (0x0418 + (port<<10))
-#define MV643XX_ETH_SDMA_CONFIG_REG(port)                          (0x041c + (port<<10))
-#define MV643XX_ETH_DSCP_0(port)                                   (0x0420 + (port<<10))
-#define MV643XX_ETH_DSCP_1(port)                                   (0x0424 + (port<<10))
-#define MV643XX_ETH_DSCP_2(port)                                   (0x0428 + (port<<10))
-#define MV643XX_ETH_DSCP_3(port)                                   (0x042c + (port<<10))
-#define MV643XX_ETH_DSCP_4(port)                                   (0x0430 + (port<<10))
-#define MV643XX_ETH_DSCP_5(port)                                   (0x0434 + (port<<10))
-#define MV643XX_ETH_DSCP_6(port)                                   (0x0438 + (port<<10))
-#define MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port)                  (0x043c + (port<<10))
-#define MV643XX_ETH_VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x0440 + (port<<10))
-#define MV643XX_ETH_PORT_STATUS_REG(port)                          (0x0444 + (port<<10))
-#define MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port)               (0x0448 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_FIXED_PRIORITY(port)                  (0x044c + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x0450 + (port<<10))
-#define MV643XX_ETH_MAXIMUM_TRANSMIT_UNIT(port)                    (0x0458 + (port<<10))
-#define MV643XX_ETH_PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x045c + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_REG(port)                      (0x0460 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port)               (0x0464 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_MASK_REG(port)                       (0x0468 + (port<<10))
-#define MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port)                (0x046c + (port<<10))
-#define MV643XX_ETH_RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0470 + (port<<10))
-#define MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0474 + (port<<10))
-#define MV643XX_ETH_RX_MINIMAL_FRAME_SIZE_REG(port)                (0x047c + (port<<10))
-#define MV643XX_ETH_RX_DISCARDED_FRAMES_COUNTER(port)              (0x0484 + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_0_REG(port)                         (0x048c + (port<<10))
-#define MV643XX_ETH_PORT_DEBUG_1_REG(port)                         (0x0490 + (port<<10))
-#define MV643XX_ETH_PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x0494 + (port<<10))
-#define MV643XX_ETH_INTERNAL_USE_REG(port)                         (0x04fc + (port<<10))
-#define MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port)                (0x0680 + (port<<10))
-#define MV643XX_ETH_CURRENT_SERVED_TX_DESC_PTR(port)               (0x0684 + (port<<10))
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x060c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x061c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x062c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x063c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x064c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x065c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x066c + (port<<10))     
-#define MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x067c + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x06c0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x06c4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x06c8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x06cc + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x06d0 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x06d4 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x06d8 + (port<<10))     
-#define MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x06dc + (port<<10))     
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x0700 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x0710 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x0720 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x0730 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x0740 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x0750 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x0760 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x0770 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x0704 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x0714 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x0724 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x0734 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x0744 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x0754 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x0764 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x0774 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_0_ARBITER_CONFIG(port)                (0x0708 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_1_ARBITER_CONFIG(port)                (0x0718 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_2_ARBITER_CONFIG(port)                (0x0728 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_3_ARBITER_CONFIG(port)                (0x0738 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_4_ARBITER_CONFIG(port)                (0x0748 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_5_ARBITER_CONFIG(port)                (0x0758 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_6_ARBITER_CONFIG(port)                (0x0768 + (port<<10))
-#define MV643XX_ETH_TX_QUEUE_7_ARBITER_CONFIG(port)                (0x0778 + (port<<10))
-#define MV643XX_ETH_PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x0780 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x1400 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x1500 + (port<<10))
-#define MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE(port)             (0x1600 + (port<<10))
+#define PHY_ADDR_REG                                    0x0000
+#define SMI_REG                                         0x0004
+#define UNIT_DEFAULT_ADDR_REG                           0x0008
+#define UNIT_DEFAULTID_REG                              0x000c
+#define UNIT_INTERRUPT_CAUSE_REG                        0x0080
+#define UNIT_INTERRUPT_MASK_REG                         0x0084
+#define UNIT_INTERNAL_USE_REG                           0x04fc
+#define UNIT_ERROR_ADDR_REG                             0x0094
+#define BAR_0                                           0x0200
+#define BAR_1                                           0x0208
+#define BAR_2                                           0x0210
+#define BAR_3                                           0x0218
+#define BAR_4                                           0x0220
+#define BAR_5                                           0x0228
+#define SIZE_REG_0                                      0x0204
+#define SIZE_REG_1                                      0x020c
+#define SIZE_REG_2                                      0x0214
+#define SIZE_REG_3                                      0x021c
+#define SIZE_REG_4                                      0x0224
+#define SIZE_REG_5                                      0x022c
+#define HEADERS_RETARGET_BASE_REG                       0x0230
+#define HEADERS_RETARGET_CONTROL_REG                    0x0234
+#define HIGH_ADDR_REMAP_REG_0                           0x0280
+#define HIGH_ADDR_REMAP_REG_1                           0x0284
+#define HIGH_ADDR_REMAP_REG_2                           0x0288
+#define HIGH_ADDR_REMAP_REG_3                           0x028c
+#define BASE_ADDR_ENABLE_REG                            0x0290
+#define ACCESS_PROTECTION_REG(port)                    (0x0294 + (port<<2))
+#define MIB_COUNTERS_BASE(port)                        (0x1000 + (port<<7))
+#define PORT_CONFIG_REG(port)                          (0x0400 + (port<<10))
+#define PORT_CONFIG_EXTEND_REG(port)                   (0x0404 + (port<<10))
+#define MII_SERIAL_PARAMETRS_REG(port)                 (0x0408 + (port<<10))
+#define GMII_SERIAL_PARAMETRS_REG(port)                (0x040c + (port<<10))
+#define VLAN_ETHERTYPE_REG(port)                       (0x0410 + (port<<10))
+#define MAC_ADDR_LOW(port)                             (0x0414 + (port<<10))
+#define MAC_ADDR_HIGH(port)                            (0x0418 + (port<<10))
+#define SDMA_CONFIG_REG(port)                          (0x041c + (port<<10))
+#define DSCP_0(port)                                   (0x0420 + (port<<10))
+#define DSCP_1(port)                                   (0x0424 + (port<<10))
+#define DSCP_2(port)                                   (0x0428 + (port<<10))
+#define DSCP_3(port)                                   (0x042c + (port<<10))
+#define DSCP_4(port)                                   (0x0430 + (port<<10))
+#define DSCP_5(port)                                   (0x0434 + (port<<10))
+#define DSCP_6(port)                                   (0x0438 + (port<<10))
+#define PORT_SERIAL_CONTROL_REG(port)                  (0x043c + (port<<10))
+#define VLAN_PRIORITY_TAG_TO_PRIORITY(port)            (0x0440 + (port<<10))
+#define PORT_STATUS_REG(port)                          (0x0444 + (port<<10))
+#define TRANSMIT_QUEUE_COMMAND_REG(port)               (0x0448 + (port<<10))
+#define TX_QUEUE_FIXED_PRIORITY(port)                  (0x044c + (port<<10))
+#define PORT_TX_TOKEN_BUCKET_RATE_CONFIG(port)         (0x0450 + (port<<10))
+#define MAXIMUM_TRANSMIT_UNIT(port)                    (0x0458 + (port<<10))
+#define PORT_MAXIMUM_TOKEN_BUCKET_SIZE(port)           (0x045c + (port<<10))
+#define INTERRUPT_CAUSE_REG(port)                      (0x0460 + (port<<10))
+#define INTERRUPT_CAUSE_EXTEND_REG(port)               (0x0464 + (port<<10))
+#define INTERRUPT_MASK_REG(port)                       (0x0468 + (port<<10))
+#define INTERRUPT_EXTEND_MASK_REG(port)                (0x046c + (port<<10))
+#define RX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0470 + (port<<10))
+#define TX_FIFO_URGENT_THRESHOLD_REG(port)             (0x0474 + (port<<10))
+#define RX_MINIMAL_FRAME_SIZE_REG(port)                (0x047c + (port<<10))
+#define RX_DISCARDED_FRAMES_COUNTER(port)              (0x0484 + (port<<10))
+#define PORT_DEBUG_0_REG(port)                         (0x048c + (port<<10))
+#define PORT_DEBUG_1_REG(port)                         (0x0490 + (port<<10))
+#define PORT_INTERNAL_ADDR_ERROR_REG(port)             (0x0494 + (port<<10))
+#define INTERNAL_USE_REG(port)                         (0x04fc + (port<<10))
+#define RECEIVE_QUEUE_COMMAND_REG(port)                (0x0680 + (port<<10))
+#define CURRENT_SERVED_TX_DESC_PTR(port)               (0x0684 + (port<<10))
+#define RX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x060c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x061c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x062c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x063c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x064c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x065c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x066c + (port<<10))     
+#define RX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x067c + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_0(port)              (0x06c0 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_1(port)              (0x06c4 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_2(port)              (0x06c8 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_3(port)              (0x06cc + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_4(port)              (0x06d0 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_5(port)              (0x06d4 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_6(port)              (0x06d8 + (port<<10))     
+#define TX_CURRENT_QUEUE_DESC_PTR_7(port)              (0x06dc + (port<<10))     
+#define TX_QUEUE_0_TOKEN_BUCKET_COUNT(port)            (0x0700 + (port<<10))
+#define TX_QUEUE_1_TOKEN_BUCKET_COUNT(port)            (0x0710 + (port<<10))
+#define TX_QUEUE_2_TOKEN_BUCKET_COUNT(port)            (0x0720 + (port<<10))
+#define TX_QUEUE_3_TOKEN_BUCKET_COUNT(port)            (0x0730 + (port<<10))
+#define TX_QUEUE_4_TOKEN_BUCKET_COUNT(port)            (0x0740 + (port<<10))
+#define TX_QUEUE_5_TOKEN_BUCKET_COUNT(port)            (0x0750 + (port<<10))
+#define TX_QUEUE_6_TOKEN_BUCKET_COUNT(port)            (0x0760 + (port<<10))
+#define TX_QUEUE_7_TOKEN_BUCKET_COUNT(port)            (0x0770 + (port<<10))
+#define TX_QUEUE_0_TOKEN_BUCKET_CONFIG(port)           (0x0704 + (port<<10))
+#define TX_QUEUE_1_TOKEN_BUCKET_CONFIG(port)           (0x0714 + (port<<10))
+#define TX_QUEUE_2_TOKEN_BUCKET_CONFIG(port)           (0x0724 + (port<<10))
+#define TX_QUEUE_3_TOKEN_BUCKET_CONFIG(port)           (0x0734 + (port<<10))
+#define TX_QUEUE_4_TOKEN_BUCKET_CONFIG(port)           (0x0744 + (port<<10))
+#define TX_QUEUE_5_TOKEN_BUCKET_CONFIG(port)           (0x0754 + (port<<10))
+#define TX_QUEUE_6_TOKEN_BUCKET_CONFIG(port)           (0x0764 + (port<<10))
+#define TX_QUEUE_7_TOKEN_BUCKET_CONFIG(port)           (0x0774 + (port<<10))
+#define TX_QUEUE_0_ARBITER_CONFIG(port)                (0x0708 + (port<<10))
+#define TX_QUEUE_1_ARBITER_CONFIG(port)                (0x0718 + (port<<10))
+#define TX_QUEUE_2_ARBITER_CONFIG(port)                (0x0728 + (port<<10))
+#define TX_QUEUE_3_ARBITER_CONFIG(port)                (0x0738 + (port<<10))
+#define TX_QUEUE_4_ARBITER_CONFIG(port)                (0x0748 + (port<<10))
+#define TX_QUEUE_5_ARBITER_CONFIG(port)                (0x0758 + (port<<10))
+#define TX_QUEUE_6_ARBITER_CONFIG(port)                (0x0768 + (port<<10))
+#define TX_QUEUE_7_ARBITER_CONFIG(port)                (0x0778 + (port<<10))
+#define PORT_TX_TOKEN_BUCKET_COUNT(port)               (0x0780 + (port<<10))
+#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port)   (0x1400 + (port<<10))
+#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port)     (0x1500 + (port<<10))
+#define DA_FILTER_UNICAST_TABLE_BASE(port)             (0x1600 + (port<<10))
 
 /* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
-#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
-#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
-#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
-#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
-#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
-#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
-#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
-#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	(1<<21)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
-
-#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
-		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
-		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
-		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
-		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
-		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
-		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
-		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
+#define UNICAST_NORMAL_MODE		0
+#define UNICAST_PROMISCUOUS_MODE	(1<<0)
+#define DEFAULT_RX_QUEUE_0		0
+#define DEFAULT_RX_QUEUE_1		(1<<1)
+#define DEFAULT_RX_QUEUE_2		(1<<2)
+#define DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
+#define DEFAULT_RX_QUEUE_4		(1<<3)
+#define DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
+#define DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
+#define DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
+#define DEFAULT_RX_ARP_QUEUE_0	0
+#define DEFAULT_RX_ARP_QUEUE_1	(1<<4)
+#define DEFAULT_RX_ARP_QUEUE_2	(1<<5)
+#define DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
+#define DEFAULT_RX_ARP_QUEUE_4	(1<<6)
+#define DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
+#define DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
+#define DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
+#define RECEIVE_BC_IF_NOT_IP_OR_ARP	0
+#define REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
+#define RECEIVE_BC_IF_IP		0
+#define REJECT_BC_IF_IP		(1<<8)
+#define RECEIVE_BC_IF_ARP		0
+#define REJECT_BC_IF_ARP		(1<<9)
+#define TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
+#define CAPTURE_TCP_FRAMES_DIS	0
+#define CAPTURE_TCP_FRAMES_EN	(1<<14)
+#define CAPTURE_UDP_FRAMES_DIS	0
+#define CAPTURE_UDP_FRAMES_EN	(1<<15)
+#define DEFAULT_RX_TCP_QUEUE_0	0
+#define DEFAULT_RX_TCP_QUEUE_1	(1<<16)
+#define DEFAULT_RX_TCP_QUEUE_2	(1<<17)
+#define DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
+#define DEFAULT_RX_TCP_QUEUE_4	(1<<18)
+#define DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
+#define DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
+#define DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
+#define DEFAULT_RX_UDP_QUEUE_0	0
+#define DEFAULT_RX_UDP_QUEUE_1	(1<<19)
+#define DEFAULT_RX_UDP_QUEUE_2	(1<<20)
+#define DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
+#define DEFAULT_RX_UDP_QUEUE_4	(1<<21)
+#define DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
+#define DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
+#define DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
+#define DEFAULT_RX_BPDU_QUEUE_0	0
+#define DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
+#define DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
+#define DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
+#define DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
+#define DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
+#define DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
+#define DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+
+#define	PORT_CONFIG_DEFAULT_VALUE			\
+		UNICAST_NORMAL_MODE		|	\
+		DEFAULT_RX_QUEUE_0		|	\
+		DEFAULT_RX_ARP_QUEUE_0	|	\
+		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		RECEIVE_BC_IF_IP		|	\
+		RECEIVE_BC_IF_ARP		|	\
+		CAPTURE_TCP_FRAMES_DIS	|	\
+		CAPTURE_UDP_FRAMES_DIS	|	\
+		DEFAULT_RX_TCP_QUEUE_0	|	\
+		DEFAULT_RX_UDP_QUEUE_0	|	\
+		DEFAULT_RX_BPDU_QUEUE_0
 
 /* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
-#define MV643XX_ETH_PARTITION_DISABLE			0
-#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
-
-#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		MV643XX_ETH_PARTITION_DISABLE
+#define CLASSIFY_EN				(1<<0)
+#define SPAN_BPDU_PACKETS_AS_NORMAL		0
+#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
+#define PARTITION_DISABLE			0
+#define PARTITION_ENABLE			(1<<2)
+
+#define	PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		PARTITION_DISABLE
 
 /* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define MV643XX_ETH_RIFB			(1<<0)
-#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
-#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
-#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
-#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
-#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
-#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
-#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
-#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
-#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
-#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
-#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
-#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
-#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
-#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
+#define RIFB			(1<<0)
+#define RX_BURST_SIZE_1_64BIT		0
+#define RX_BURST_SIZE_2_64BIT		(1<<1)
+#define RX_BURST_SIZE_4_64BIT		(1<<2)
+#define RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
+#define RX_BURST_SIZE_16_64BIT		(1<<3)
+#define BLM_RX_NO_SWAP			(1<<4)
+#define BLM_RX_BYTE_SWAP			0
+#define BLM_TX_NO_SWAP			(1<<5)
+#define BLM_TX_BYTE_SWAP			0
+#define DESCRIPTORS_BYTE_SWAP		(1<<6)
+#define DESCRIPTORS_NO_SWAP			0
+#define TX_BURST_SIZE_1_64BIT		0
+#define TX_BURST_SIZE_2_64BIT		(1<<22)
+#define TX_BURST_SIZE_4_64BIT		(1<<23)
+#define TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
+#define TX_BURST_SIZE_16_64BIT		(1<<24)
 
-#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
+#define	IPG_INT_RX(value) ((value & 0x3fff) << 8)
 
 #if defined(__BIG_ENDIAN)
-#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
-		MV643XX_ETH_IPG_INT_RX(0)		|	\
-		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+#define	PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		RX_BURST_SIZE_4_64BIT	|	\
+		IPG_INT_RX(0)		|	\
+		TX_BURST_SIZE_4_64BIT
 #elif defined(__LITTLE_ENDIAN)
-#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
-		MV643XX_ETH_BLM_RX_NO_SWAP		|	\
-		MV643XX_ETH_BLM_TX_NO_SWAP		|	\
-		MV643XX_ETH_IPG_INT_RX(0)		|	\
-		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+#define	PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		RX_BURST_SIZE_4_64BIT	|	\
+		BLM_RX_NO_SWAP		|	\
+		BLM_TX_NO_SWAP		|	\
+		IPG_INT_RX(0)		|	\
+		TX_BURST_SIZE_4_64BIT
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
 /* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
-#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
-#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
-#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
-#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
-#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
-#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
-#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
-#define MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED	(1<<9)
-#define MV643XX_ETH_FORCE_LINK_FAIL			0
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
-#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
-#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
-#define MV643XX_ETH_DTE_ADV_0				0
-#define MV643XX_ETH_DTE_ADV_1				(1<<14)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
-#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
-#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
-#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
-#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
-#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
-#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
-#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
-#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
-#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
-#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
-#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
-#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
-#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
-#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
-#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
-#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
-
-#define MV643XX_ETH_MAX_RX_PACKET_MASK			(0x7<<17)
-
-#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
-		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
-		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
-		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
+#define SERIAL_PORT_DISABLE			0
+#define SERIAL_PORT_ENABLE			(1<<0)
+#define FORCE_LINK_PASS			(1<<1)
+#define DO_NOT_FORCE_LINK_PASS		0
+#define ENABLE_AUTO_NEG_FOR_DUPLX		0
+#define DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
+#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
+#define ADV_NO_FLOW_CTRL			0
+#define ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
+#define FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
+#define FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
+#define FORCE_BP_MODE_NO_JAM		0
+#define FORCE_BP_MODE_JAM_TX		(1<<7)
+#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
+#define SERIAL_PORT_CONTROL_RESERVED	(1<<9)
+#define FORCE_LINK_FAIL			0
+#define DO_NOT_FORCE_LINK_FAIL		(1<<10)
+#define RETRANSMIT_16_ATTEMPTS		0
+#define RETRANSMIT_FOREVER			(1<<11)
+#define DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
+#define ENABLE_AUTO_NEG_SPEED_GMII		0
+#define DTE_ADV_0				0
+#define DTE_ADV_1				(1<<14)
+#define DISABLE_AUTO_NEG_BYPASS		0
+#define ENABLE_AUTO_NEG_BYPASS		(1<<15)
+#define AUTO_NEG_NO_CHANGE			0
+#define RESTART_AUTO_NEG			(1<<16)
+#define MAX_RX_PACKET_1518BYTE		0
+#define MAX_RX_PACKET_1522BYTE		(1<<17)
+#define MAX_RX_PACKET_1552BYTE		(1<<18)
+#define MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
+#define MAX_RX_PACKET_9192BYTE		(1<<19)
+#define MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
+#define SET_EXT_LOOPBACK			(1<<20)
+#define CLR_EXT_LOOPBACK			0
+#define SET_FULL_DUPLEX_MODE		(1<<21)
+#define SET_HALF_DUPLEX_MODE		0
+#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
+#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
+#define SET_GMII_SPEED_TO_10_100		0
+#define SET_GMII_SPEED_TO_1000		(1<<23)
+#define SET_MII_SPEED_TO_10			0
+#define SET_MII_SPEED_TO_100		(1<<24)
+
+#define MAX_RX_PACKET_MASK			(0x7<<17)
+
+#define	PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		DO_NOT_FORCE_LINK_PASS	|	\
+		ENABLE_AUTO_NEG_FOR_DUPLX	|	\
+		DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
+		ADV_SYMMETRIC_FLOW_CTRL	|	\
+		FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
+		FORCE_BP_MODE_NO_JAM	|	\
 		(1<<9)	/* reserved */			|	\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
-		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		MV643XX_ETH_DTE_ADV_0			|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
-		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
-		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
-		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
-		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
-		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+		DO_NOT_FORCE_LINK_FAIL	|	\
+		RETRANSMIT_16_ATTEMPTS	|	\
+		ENABLE_AUTO_NEG_SPEED_GMII	|	\
+		DTE_ADV_0			|	\
+		DISABLE_AUTO_NEG_BYPASS	|	\
+		AUTO_NEG_NO_CHANGE		|	\
+		MAX_RX_PACKET_9700BYTE	|	\
+		CLR_EXT_LOOPBACK		|	\
+		SET_FULL_DUPLEX_MODE	|	\
+		ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
 
 /* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
-#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
-#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
-#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
-#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
-#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
+#define PORT_STATUS_MODE_10_BIT		(1<<0)
+#define PORT_STATUS_LINK_UP			(1<<1)
+#define PORT_STATUS_FULL_DUPLEX		(1<<2)
+#define PORT_STATUS_FLOW_CONTROL		(1<<3)
+#define PORT_STATUS_GMII_1000		(1<<4)
+#define PORT_STATUS_MII_100			(1<<5)
 /* PSR bit 6 is undocumented */
-#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
-#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
-#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
-#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+#define PORT_STATUS_TX_IN_PROGRESS		(1<<7)
+#define PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
+#define PORT_STATUS_PARTITION		(1<<9)
+#define PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
 /* PSR bits 11-31 are reserved */
 
-#define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
+#define	PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define	PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
 
-#define MV643XX_ETH_DESC_SIZE				64
+#define DESC_SIZE				64
 
 #define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
 #define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
