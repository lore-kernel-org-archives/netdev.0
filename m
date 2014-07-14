From: varkabhadram@gmail.com
Subject: [PATCH net-next v2 6/6] ethernet: amd: fix 'foo* bar'
Date: Mon, 14 Jul 2014 11:55:47 +0530
Message-ID: <1405319147-5212-7-git-send-email-varkabhadram@gmail.com>
References: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:64083 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbaGNG14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 02:27:56 -0400
In-Reply-To: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch fix the 'foo*' bar with 'foo *bar'
and (foo*) with (foo *).

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |   76 ++++++++++++++++++-----------------
 1 file changed, 40 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 3e41568..0b885e2 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -109,7 +109,8 @@ module_param_array(dynamic_ipg, bool, NULL, 0);
 MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disable");
 
 /* This function will read the PHY registers. */
-static int amd8111e_read_phy(struct amd8111e_priv* lp, int phy_id, int reg, u32* val)
+static int amd8111e_read_phy(struct amd8111e_priv *lp,
+			     int phy_id, int reg, u32 *val)
 {
 	void __iomem *mmio = lp->mmio;
 	unsigned int reg_val;
@@ -137,7 +138,8 @@ err_phy_read:
 }
 
 /* This function will write into PHY registers. */
-static int amd8111e_write_phy(struct amd8111e_priv* lp,int phy_id, int reg, u32 val)
+static int amd8111e_write_phy(struct amd8111e_priv *lp,
+			      int phy_id, int reg, u32 val)
 {
 	unsigned int repeat = REPEAT_CNT;
 	void __iomem *mmio = lp->mmio;
@@ -166,9 +168,9 @@ err_phy_write:
 }
 
 /* This is the mii register read function provided to the mii interface. */
-static int amd8111e_mdio_read(struct net_device * dev, int phy_id, int reg_num)
+static int amd8111e_mdio_read(struct net_device *dev, int phy_id, int reg_num)
 {
-	struct amd8111e_priv* lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	unsigned int reg_val;
 
 	amd8111e_read_phy(lp,phy_id,reg_num,&reg_val);
@@ -177,9 +179,10 @@ static int amd8111e_mdio_read(struct net_device * dev, int phy_id, int reg_num)
 }
 
 /* This is the mii register write function provided to the mii interface. */
-static void amd8111e_mdio_write(struct net_device * dev, int phy_id, int reg_num, int val)
+static void amd8111e_mdio_write(struct net_device *dev,
+				int phy_id, int reg_num, int val)
 {
-	struct amd8111e_priv* lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = netdev_priv(dev);
 
 	amd8111e_write_phy(lp, phy_id, reg_num, val);
 }
@@ -231,7 +234,7 @@ static void amd8111e_set_ext_phy(struct net_device *dev)
 static int amd8111e_free_skbs(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	struct sk_buff* rx_skbuff;
+	struct sk_buff *rx_skbuff;
 	int i;
 
 	/* Freeing transmit skbs */
@@ -261,9 +264,9 @@ static int amd8111e_free_skbs(struct net_device *dev)
 /* This will set the receive buffer length corresponding
  * to the mtu size of networkinterface.
  */
-static inline void amd8111e_set_rx_buff_len(struct net_device* dev)
+static inline void amd8111e_set_rx_buff_len(struct net_device *dev)
 {
-	struct amd8111e_priv* lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	unsigned int mtu = dev->mtu;
 
 	if (mtu > ETH_DATA_LEN){
@@ -366,14 +369,14 @@ err_no_mem:
 /* This function will set the interrupt coalescing according
  * to the input arguments
  */
-static int amd8111e_set_coalesce(struct net_device * dev, enum coal_mode cmod)
+static int amd8111e_set_coalesce(struct net_device *dev, enum coal_mode cmod)
 {
 	unsigned int timeout;
 	unsigned int event_count;
 
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
-	struct amd8111e_coalesce_conf * coal_conf = &lp->coal_conf;
+	struct amd8111e_coalesce_conf *coal_conf = &lp->coal_conf;
 
 
 	switch(cmod)
@@ -502,7 +505,7 @@ static int amd8111e_restart(struct net_device *dev)
 }
 
 /* This function clears necessary the device registers. */
-static void amd8111e_init_hw_default( struct amd8111e_priv* lp)
+static void amd8111e_init_hw_default(struct amd8111e_priv *lp)
 {
 	unsigned int reg_val;
 	unsigned int logic_filter[2] ={0,};
@@ -572,7 +575,7 @@ static void amd8111e_init_hw_default( struct amd8111e_priv* lp)
 	writew(MIB_CLEAR, mmio + MIB_ADDR);
 
 	/* Clear LARF */
-	amd8111e_writeq(*(u64*)logic_filter,mmio+LADRF);
+	amd8111e_writeq(*(u64 *)logic_filter, mmio + LADRF);
 
 	/* SRAM_SIZE register */
 	reg_val = readl(mmio + SRAM_SIZE);
@@ -593,7 +596,7 @@ static void amd8111e_init_hw_default( struct amd8111e_priv* lp)
 /* This function disables the interrupt and clears all the pending
  * interrupts in INT0
  */
-static void amd8111e_disable_interrupt(struct amd8111e_priv* lp)
+static void amd8111e_disable_interrupt(struct amd8111e_priv *lp)
 {
 	u32 intr0;
 
@@ -610,7 +613,7 @@ static void amd8111e_disable_interrupt(struct amd8111e_priv* lp)
 }
 
 /* This function stops the chip. */
-static void amd8111e_stop_chip(struct amd8111e_priv* lp)
+static void amd8111e_stop_chip(struct amd8111e_priv *lp)
 {
 	writel(RUN, lp->mmio + CMD0);
 
@@ -619,7 +622,7 @@ static void amd8111e_stop_chip(struct amd8111e_priv* lp)
 }
 
 /* This function frees the  transmiter and receiver descriptor rings. */
-static void amd8111e_free_ring(struct amd8111e_priv* lp)
+static void amd8111e_free_ring(struct amd8111e_priv *lp)
 {
 	/* Free transmit and receive descriptor rings */
 	if(lp->rx_ring){
@@ -645,7 +648,7 @@ static void amd8111e_free_ring(struct amd8111e_priv* lp)
  */
 static int amd8111e_tx(struct net_device *dev)
 {
-	struct amd8111e_priv* lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int tx_index = lp->tx_complete_idx & TX_RING_DR_MOD_MASK;
 	int status;
 	/* Complete all the transmit packet */
@@ -815,7 +818,7 @@ rx_not_empty:
 }
 
 /* This function will indicate the link status to the kernel. */
-static int amd8111e_link_change(struct net_device* dev)
+static int amd8111e_link_change(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int status0,speed;
@@ -979,7 +982,7 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 static int amd8111e_calc_coalesce(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	struct amd8111e_coalesce_conf * coal_conf = &lp->coal_conf;
+	struct amd8111e_coalesce_conf *coal_conf = &lp->coal_conf;
 	int tx_pkt_rate;
 	int rx_pkt_rate;
 	int tx_data_rate;
@@ -1114,7 +1117,7 @@ static int amd8111e_calc_coalesce(struct net_device *dev)
 static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 {
 
-	struct net_device * dev = (struct net_device *) dev_id;
+	struct net_device *dev = (struct net_device *)dev_id;
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
 	unsigned int intr0, intren0;
@@ -1191,7 +1194,7 @@ static void amd8111e_poll(struct net_device *dev)
  * the statistics so that most recent statistics will be
  * available after the interface is down.
  */
-static int amd8111e_close(struct net_device * dev)
+static int amd8111e_close(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
@@ -1225,7 +1228,7 @@ static int amd8111e_close(struct net_device * dev)
 /* This function opens new interface.It requests irq for the device,
  * initializes the device,buffers and descriptors, and starts the device.
  */
-static int amd8111e_open(struct net_device * dev )
+static int amd8111e_open(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 
@@ -1264,7 +1267,7 @@ static int amd8111e_open(struct net_device * dev )
 /* This function checks if there is any transmit  descriptors
  * available to queue more packet.
  */
-static int amd8111e_tx_queue_avail(struct amd8111e_priv* lp )
+static int amd8111e_tx_queue_avail(struct amd8111e_priv *lp)
 {
 	int tx_index = lp->tx_idx & TX_BUFF_MOD_MASK;
 	if (lp->tx_skbuff[tx_index])
@@ -1280,7 +1283,7 @@ static int amd8111e_tx_queue_avail(struct amd8111e_priv* lp )
  * byte count, ownership to hardware etc.
  */
 static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
-				       struct net_device * dev)
+				       struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int tx_index;
@@ -1368,14 +1371,14 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 		/* get all multicast packet */
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 		lp->options |= OPTION_MULTICAST_ENABLE;
-		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
+		amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 		return;
 	}
 	if (netdev_mc_empty(dev)) {
 		/* get only own packets */
 		mc_filter[1] = mc_filter[0] = 0;
 		lp->options &= ~OPTION_MULTICAST_ENABLE;
-		amd8111e_writeq(*(u64*)mc_filter,lp->mmio + LADRF);
+		amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 		/* disable promiscuous mode */
 		writel(PROM, lp->mmio + CMD2);
 		return;
@@ -1387,14 +1390,15 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 		bit_num = (ether_crc_le(ETH_ALEN, ha->addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
 	}
-	amd8111e_writeq(*(u64*)mc_filter,lp->mmio+ LADRF);
+	amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 
 	/* To eliminate PCI posting bug */
 	readl(lp->mmio + CMD2);
 
 }
 
-static void amd8111e_get_drvinfo(struct net_device* dev, struct ethtool_drvinfo *info)
+static void amd8111e_get_drvinfo(struct net_device *dev,
+				 struct ethtool_drvinfo *info)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct pci_dev *pci_dev = lp->pci_dev;
@@ -1490,7 +1494,7 @@ static const struct ethtool_ops ops = {
  * gets/sets driver speed, gets memory mapped register values, forces
  * auto negotiation, sets/gets WOL options for ethtool application.
  */
-static int amd8111e_ioctl(struct net_device * dev , struct ifreq *ifr, int cmd)
+static int amd8111e_ioctl(struct net_device *dev , struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
 	struct amd8111e_priv *lp = netdev_priv(dev);
@@ -1577,7 +1581,7 @@ static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 	return err;
 }
 
-static int amd8111e_enable_magicpkt(struct amd8111e_priv* lp)
+static int amd8111e_enable_magicpkt(struct amd8111e_priv *lp)
 {
 	writel( VAL1|MPPLBA, lp->mmio + CMD3);
 	writel( VAL0|MPEN_SW, lp->mmio + CMD7);
@@ -1587,7 +1591,7 @@ static int amd8111e_enable_magicpkt(struct amd8111e_priv* lp)
 	return 0;
 }
 
-static int amd8111e_enable_link_change(struct amd8111e_priv* lp)
+static int amd8111e_enable_link_change(struct amd8111e_priv *lp)
 {
 
 	/* Adapter is already stoped/suspended/interrupt-disabled */
@@ -1605,7 +1609,7 @@ static int amd8111e_enable_link_change(struct amd8111e_priv* lp)
  */
 static void amd8111e_tx_timeout(struct net_device *dev)
 {
-	struct amd8111e_priv* lp = netdev_priv(dev);
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int err;
 
 	netdev_err(dev, "transmit timed out, resetting\n");
@@ -1686,10 +1690,10 @@ static int amd8111e_resume(struct pci_dev *pci_dev)
 	return 0;
 }
 
-static void amd8111e_config_ipg(struct net_device* dev)
+static void amd8111e_config_ipg(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	struct ipg_info* ipg_data = &lp->ipg_data;
+	struct ipg_info *ipg_data = &lp->ipg_data;
 	void __iomem *mmio = lp->mmio;
 	unsigned int prev_col_cnt = ipg_data->col_cnt;
 	unsigned int total_col_cnt;
@@ -1787,8 +1791,8 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 {
 	int err, i;
 	unsigned long reg_addr,reg_len;
-	struct amd8111e_priv* lp;
-	struct net_device* dev;
+	struct amd8111e_priv *lp;
+	struct net_device *dev;
 
 	err = pci_enable_device(pdev);
 	if(err){
-- 
1.7.9.5
