From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in drivers/net/ (others)
Date: Thu, 4 Mar 2004 13:20:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304132012.6dd18b7c.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>


--
~Randy



 linux-264-302-priv-rddunlap/drivers/net/amd8111e.c     |   56 ++++++++---------
 linux-264-302-priv-rddunlap/drivers/net/ariadne.c      |   14 ++--
 linux-264-302-priv-rddunlap/drivers/net/at1700.c       |   22 +++---
 linux-264-302-priv-rddunlap/drivers/net/atari_bionet.c |   12 +--
 linux-264-302-priv-rddunlap/drivers/net/atp.c          |   26 +++----
 linux-264-302-priv-rddunlap/drivers/net/bmac.c         |   44 ++++++-------
 linux-264-302-priv-rddunlap/drivers/net/cs89x0.c       |   40 ++++++------
 linux-264-302-priv-rddunlap/drivers/net/eth16i.c       |   18 ++---
 linux-264-302-priv-rddunlap/drivers/net/fec.c          |   54 ++++++++--------
 linux-264-302-priv-rddunlap/drivers/net/gt96100eth.c   |   42 ++++++------
 linux-264-302-priv-rddunlap/drivers/net/mac89x0.c      |   14 ++--
 linux-264-302-priv-rddunlap/drivers/net/ni5010.c       |   12 +--
 linux-264-302-priv-rddunlap/drivers/net/rrunner.c      |   32 ++++-----
 linux-264-302-priv-rddunlap/drivers/net/sb1000.c       |   14 ++--
 linux-264-302-priv-rddunlap/drivers/net/sb1250-mac.c   |   22 +++---
 linux-264-302-priv-rddunlap/drivers/net/seeq8005.c     |   14 ++--
 linux-264-302-priv-rddunlap/drivers/net/sgiseeq.c      |   16 ++--
 linux-264-302-priv-rddunlap/drivers/net/sk_g16.c       |   18 ++---
 linux-264-302-priv-rddunlap/drivers/net/smc9194.c      |   12 +--
 19 files changed, 241 insertions(+), 241 deletions(-)

diff -puN drivers/net/amd8111e.c~drivers_net_casts drivers/net/amd8111e.c
--- linux-264-302-priv/drivers/net/amd8111e.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/amd8111e.c	2004-03-02 14:52:49.000000000 -0800
@@ -174,7 +174,7 @@ This is the mii register read function p
 */ 
 static int amd8111e_mdio_read(struct net_device * dev, int phy_id, int reg_num)
 {
-	struct amd8111e_priv* lp = dev->priv;
+	struct amd8111e_priv* lp = netdev_priv(dev);
 	unsigned int reg_val;
 
 	amd8111e_read_phy(lp,phy_id,reg_num,&reg_val);
@@ -187,7 +187,7 @@ This is the mii register write function 
 */ 
 static void amd8111e_mdio_write(struct net_device * dev, int phy_id, int reg_num, int val)
 {
-	struct amd8111e_priv* lp = dev->priv;
+	struct amd8111e_priv* lp = netdev_priv(dev);
 
 	amd8111e_write_phy(lp, phy_id, reg_num, val);
 }
@@ -197,7 +197,7 @@ This function will set PHY speed. During
 */
 static void amd8111e_set_ext_phy(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	u32 bmcr,advert,tmp;
 	
 	/* Determine mii register values to set the speed */
@@ -239,7 +239,7 @@ all transmit and receive skbuffs.
 */
 static int amd8111e_free_skbs(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct sk_buff* rx_skbuff;
 	int i;
 
@@ -272,7 +272,7 @@ This will set the receive buffer length 
 */
 static inline void amd8111e_set_rx_buff_len(struct net_device* dev)
 {
-	struct amd8111e_priv* lp = dev->priv;
+	struct amd8111e_priv* lp = netdev_priv(dev);
 	unsigned int mtu = dev->mtu;
 	
 	if (mtu > ETH_DATA_LEN){
@@ -290,7 +290,7 @@ This function will free all the previous
  */
 static int amd8111e_init_ring(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int i;
 
 	lp->rx_idx = lp->tx_idx = 0;
@@ -371,7 +371,7 @@ static int amd8111e_set_coalesce(struct 
 	unsigned int timeout;
 	unsigned int event_count;
 
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	void* mmio = lp->mmio;
 	struct amd8111e_coalesce_conf * coal_conf = &lp->coal_conf;
 
@@ -429,7 +429,7 @@ This function initializes the device reg
 */
 static int amd8111e_restart(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv* )dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	void * mmio = lp->mmio;
 	int i,reg_val;
 
@@ -663,7 +663,7 @@ This function will free all the transmit
 */
 static int amd8111e_tx(struct net_device *dev)
 {
-	struct amd8111e_priv* lp = dev->priv;
+	struct amd8111e_priv* lp = netdev_priv(dev);
 	int tx_index = lp->tx_complete_idx & TX_RING_DR_MOD_MASK;
 	int status;
 	/* Complete all the transmit packet */
@@ -705,7 +705,7 @@ This function will check the ownership o
 */
 static int amd8111e_rx(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct sk_buff *skb,*new_skb;
 	int rx_index = lp->rx_idx & RX_RING_DR_MOD_MASK;
 	int min_pkt_len, status;
@@ -809,7 +809,7 @@ This function will indicate the link sta
 */
 static int amd8111e_link_change(struct net_device* dev)
 {	
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int status0,speed;
 
 	/* read the link change */
@@ -871,7 +871,7 @@ This function reads the mib registers an
 */ 
 static struct net_device_stats *amd8111e_get_stats(struct net_device * dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	void * mmio = lp->mmio;
 	unsigned long flags;
 	/* struct net_device_stats *prev_stats = &lp->prev_stats; */
@@ -966,7 +966,7 @@ according to the datarate and the packet
 */
 static int amd8111e_calc_coalesce(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct amd8111e_coalesce_conf * coal_conf = &lp->coal_conf;
 	int tx_pkt_rate;
 	int rx_pkt_rate;
@@ -1102,7 +1102,7 @@ static irqreturn_t amd8111e_interrupt(in
 {
 
 	struct net_device * dev = (struct net_device *) dev_id;
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	void * mmio = lp->mmio;
 	unsigned int intr0;
 	unsigned int handled = 1;
@@ -1158,7 +1158,7 @@ This function closes the network interfa
 */
 static int amd8111e_close(struct net_device * dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 	
 	spin_lock_irq(&lp->lock);
@@ -1185,7 +1185,7 @@ static int amd8111e_close(struct net_dev
 */
 static int amd8111e_open(struct net_device * dev )
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 
 	if(dev->irq ==0 || request_irq(dev->irq, amd8111e_interrupt, SA_SHIRQ,
 					 dev->name, dev)) 
@@ -1231,7 +1231,7 @@ This function will queue the transmit pa
 
 static int amd8111e_start_xmit(struct sk_buff *skb, struct net_device * dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int tx_index;
 	unsigned long flags;
 
@@ -1338,7 +1338,7 @@ list to the device.
 static void amd8111e_set_multicast_list(struct net_device *dev)
 {
 	struct dev_mc_list* mc_ptr;
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	u32 mc_filter[2] ;
 	int i,bit_num;
 	if(dev->flags & IFF_PROMISC){
@@ -1388,7 +1388,7 @@ This function handles all the  ethtool i
 	
 static int amd8111e_ethtool_ioctl(struct net_device* dev, void* useraddr)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct pci_dev *pci_dev = lp->pci_dev;
 	u32 ethcmd;
 	
@@ -1510,7 +1510,7 @@ static int amd8111e_ethtool_ioctl(struct
 static int amd8111e_ioctl(struct net_device * dev , struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&ifr->ifr_data;
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int err;
 	u32 mii_regval;
 
@@ -1554,7 +1554,7 @@ This function changes the mtu of the dev
 */  
 int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	int err;
 
 	if ((new_mtu < AMD8111E_MIN_MTU) || (new_mtu > AMD8111E_MAX_MTU))
@@ -1584,7 +1584,7 @@ int amd8111e_change_mtu(struct net_devic
 #if AMD8111E_VLAN_TAG_USED
 static void amd8111e_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct  amd8111e_priv *lp = dev->priv;
+	struct  amd8111e_priv *lp = netdev_priv(dev);
 	spin_lock_irq(&lp->lock);
 	lp->vlgrp = grp;
 	spin_unlock_irq(&lp->lock);
@@ -1592,7 +1592,7 @@ static void amd8111e_vlan_rx_register(st
 	
 static void amd8111e_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	spin_lock_irq(&lp->lock);
 	if (lp->vlgrp)
 		lp->vlgrp->vlan_devices[vid] = NULL;
@@ -1623,7 +1623,7 @@ static int amd8111e_enable_link_change(s
 
 static void amd8111e_tx_timeout(struct net_device *dev)
 {
-	struct amd8111e_priv* lp = dev->priv;
+	struct amd8111e_priv* lp = netdev_priv(dev);
 	int err;
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n",
@@ -1637,7 +1637,7 @@ static void amd8111e_tx_timeout(struct n
 static int amd8111e_suspend(struct pci_dev *pci_dev, u32 state)
 {	
 	struct net_device *dev = pci_get_drvdata(pci_dev);
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	
 	if (!netif_running(dev))
 		return 0;
@@ -1680,7 +1680,7 @@ static int amd8111e_suspend(struct pci_d
 static int amd8111e_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	
 	if (!netif_running(dev))
 		return 0;
@@ -1719,7 +1719,7 @@ static void __devexit amd8111e_remove_on
 }
 static void amd8111e_config_ipg(struct net_device* dev)
 {
-	struct amd8111e_priv *lp = dev->priv;
+	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct ipg_info* ipg_data = &lp->ipg_data;
 	void * mmio = lp->mmio;
 	unsigned int prev_col_cnt = ipg_data->col_cnt;
@@ -1841,7 +1841,7 @@ static int __devinit amd8111e_probe_one(
 	dev->vlan_rx_kill_vid = amd8111e_vlan_rx_kill_vid;
 #endif	
 	
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->pci_dev = pdev;
 	lp->amd8111e_net_dev = dev;
 	lp->pm_cap = pm_cap;
diff -puN drivers/net/ariadne.c~drivers_net_casts drivers/net/ariadne.c
--- linux-264-302-priv/drivers/net/ariadne.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/ariadne.c	2004-03-02 14:56:06.000000000 -0800
@@ -184,7 +184,7 @@ static int __devinit ariadne_init_one(st
     }
 
     SET_MODULE_OWNER(dev);
-    priv = dev->priv;
+    priv = netdev_priv(dev);
 
     r1->name = dev->name;
     r2->name = dev->name;
@@ -333,7 +333,7 @@ static int ariadne_open(struct net_devic
 
 static void ariadne_init_ring(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = netdev_priv(dev);
     volatile struct lancedata *lancedata = (struct lancedata *)dev->mem_start;
     int i;
 
@@ -379,7 +379,7 @@ static void ariadne_init_ring(struct net
 
 static int ariadne_close(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = netdev_priv(dev);
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
 
     netif_stop_queue(dev);
@@ -434,7 +434,7 @@ static irqreturn_t ariadne_interrupt(int
     if (!(lance->RDP & INTR))		/* Check if any interrupt has been */
 	return IRQ_NONE;		/* generated by the board. */
 
-    priv = (struct ariadne_private *)dev->priv;
+    priv = netdev_priv(dev);
 
     boguscnt = 10;
     while ((csr0 = lance->RDP) & (ERR|RINT|TINT) && --boguscnt >= 0) {
@@ -589,7 +589,7 @@ static void ariadne_tx_timeout(struct ne
 
 static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = netdev_priv(dev);
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
     int entry;
     unsigned long flags;
@@ -697,7 +697,7 @@ static int ariadne_start_xmit(struct sk_
 
 static int ariadne_rx(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = netdev_priv(dev);
     int entry = priv->cur_rx % RX_RING_SIZE;
     int i;
 
@@ -787,7 +787,7 @@ static int ariadne_rx(struct net_device 
 
 static struct net_device_stats *ariadne_get_stats(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = netdev_priv(dev);
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
     short saved_addr;
     unsigned long flags;
diff -puN drivers/net/at1700.c~drivers_net_casts drivers/net/at1700.c
--- linux-264-302-priv/drivers/net/at1700.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/at1700.c	2004-03-02 13:49:57.000000000 -0800
@@ -241,7 +241,7 @@ static int irq;
 static void cleanup_card(struct net_device *dev)
 {
 #ifdef CONFIG_MCA	
-	struct net_local *lp = dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	if (lp->mca_slot)
 		mca_mark_as_unused(lp->mca_slot);
 #endif	
@@ -319,8 +319,8 @@ static int __init at1700_probe1(struct n
 	char at1700_irqmap[8] = {3, 4, 5, 9, 10, 11, 14, 15};
 	unsigned int i, irq, is_fmv18x = 0, is_at1700 = 0;
 	int slot, ret = -ENODEV;
-	struct net_local *lp = dev->priv;
-	
+	struct net_local *lp = netdev_priv(dev);
+
 #ifndef CONFIG_X86_PC9800
 	if (!request_region(ioaddr, AT1700_IO_EXTENT, dev->name))
 		return -EBUSY;
@@ -618,7 +618,7 @@ static int __init read_eeprom(long ioadd
 
 static int net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Set the configuration register 0 to 32K 100ns. byte-wide memory, 16 bit
@@ -649,7 +649,7 @@ static int net_open(struct net_device *d
 
 static void net_tx_timeout (struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	printk ("%s: transmit timed out with status %04x, %s?\n", dev->name,
@@ -683,7 +683,7 @@ static void net_tx_timeout (struct net_d
 
 static int net_send_packet (struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	short length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	short len = skb->len;
@@ -748,7 +748,7 @@ net_interrupt(int irq, void *dev_id, str
 	}
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 	
 	spin_lock (&lp->lock);
 	
@@ -808,7 +808,7 @@ net_interrupt(int irq, void *dev_id, str
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 5;
 
@@ -891,7 +891,7 @@ net_rx(struct net_device *dev)
 /* The inverse routine to net_open(). */
 static int net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -919,7 +919,7 @@ static int net_close(struct net_device *
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -931,7 +931,7 @@ static void
 set_rx_mode(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	unsigned long flags;
 	int i;
diff -puN drivers/net/atari_bionet.c~drivers_net_casts drivers/net/atari_bionet.c
--- linux-264-302-priv/drivers/net/atari_bionet.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/atari_bionet.c	2004-03-02 13:53:42.000000000 -0800
@@ -408,7 +408,7 @@ struct net_device * __init bionet_probe(
  */
 static int
 bionet_open(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (bionet_debug > 0)
 		printk("bionet_open\n");
@@ -433,7 +433,7 @@ bionet_open(struct net_device *dev) {
 
 static int
 bionet_send_packet(struct sk_buff *skb, struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Block a timer-based transmit from overlapping.  This could better be
@@ -499,7 +499,7 @@ bionet_send_packet(struct sk_buff *skb, 
  */
 static void
 bionet_poll_rx(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int boguscount = 10;
 	int pkt_len, status;
 	unsigned long flags;
@@ -601,7 +601,7 @@ bionet_poll_rx(struct net_device *dev) {
 static void
 bionet_tick(unsigned long data) {
 	struct net_device	 *dev = (struct net_device *)data;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if( bionet_debug > 0 && (lp->open_time++ & 7) == 8 )
 		printk("bionet_tick: %ld\n", lp->open_time);
@@ -616,7 +616,7 @@ bionet_tick(unsigned long data) {
  */
 static int
 bionet_close(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (bionet_debug > 0)
 		printk("bionet_close, open_time=%ld\n", lp->open_time);
@@ -638,7 +638,7 @@ bionet_close(struct net_device *dev) {
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev) 
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
diff -puN drivers/net/atp.c~drivers_net_casts drivers/net/atp.c
--- linux-264-302-priv/drivers/net/atp.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/atp.c	2004-03-02 13:55:41.000000000 -0800
@@ -335,7 +335,7 @@ static int __init atp_probe1(long ioaddr
 	/* Reset the ethernet hardware and activate the printer pass-through. */
 	write_reg_high(ioaddr, CMR1, CMR1h_RESET | CMR1h_MUX);
 
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 	lp->chip_type = RTL8002;
 	lp->addr_mode = CMR2h_Normal;
 	spin_lock_init(&lp->lock);
@@ -432,7 +432,7 @@ static unsigned short __init eeprom_op(l
    */
 static int net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ret;
 
 	/* The interrupt line is turned off (tri-stated) when the device isn't in
@@ -458,7 +458,7 @@ static int net_open(struct net_device *d
    the hardware may have been temporarily detached. */
 static void hardware_init(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
     int i;
 
@@ -541,7 +541,7 @@ static void write_packet(long ioaddr, in
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING "%s: Transmit timed out, %s?\n", dev->name,
@@ -557,7 +557,7 @@ static void tx_timeout(struct net_device
 
 static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int length;
 	unsigned long flags;
@@ -611,7 +611,7 @@ atp_interrupt(int irq, void *dev_instanc
 		return IRQ_NONE;
 	}
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock(&lp->lock);
 
@@ -726,7 +726,7 @@ static void atp_timed_checker(unsigned l
 {
 	struct net_device *dev = (struct net_device *)data;
 	long ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int tickssofar = jiffies - lp->last_rx_time;
 	int i;
 
@@ -740,7 +740,7 @@ static void atp_timed_checker(unsigned l
 		for (i = 0; i < 6; i++)
 			if (read_cmd_byte(ioaddr, PAR0 + i) != atp_timed_dev->dev_addr[i])
 				{
-			struct net_local *lp = (struct net_local *)atp_timed_dev->priv;
+			struct net_local *lp = netdev_priv(atp_timed_dev);
 			write_reg_byte(ioaddr, PAR0 + i, atp_timed_dev->dev_addr[i]);
 			if (i == 2)
 			  lp->stats.tx_errors++;
@@ -762,7 +762,7 @@ static void atp_timed_checker(unsigned l
 /* We have a good packet(s), get it/them out of the buffers. */
 static void net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct rx_header rx_head;
 
@@ -838,7 +838,7 @@ static void read_block(long ioaddr, int 
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -863,7 +863,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -873,7 +873,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_rx_mode_8002(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if ( dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC))) {
@@ -890,7 +890,7 @@ static void set_rx_mode_8002(struct net_
 
 static void set_rx_mode_8012(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	unsigned char new_mode, mc_filter[8]; /* Multicast hash filter */
 	int i;
diff -puN drivers/net/bmac.c~drivers_net_casts drivers/net/bmac.c
--- linux-264-302-priv/drivers/net/bmac.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/bmac.c	2004-03-02 14:04:18.000000000 -0800
@@ -226,7 +226,7 @@ volatile unsigned short bmread(struct ne
 static void
 bmac_enable_and_reset_chip(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *rd = bp->rx_dma;
 	volatile struct dbdma_regs *td = bp->tx_dma;
 
@@ -310,7 +310,7 @@ bmac_mif_write(struct net_device *dev, u
 static void
 bmac_init_registers(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile unsigned short regValue;
 	unsigned short *pWord16;
 	int i;
@@ -405,7 +405,7 @@ bmac_enable_interrupts(struct net_device
 static void
 bmac_start_chip(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *rd = bp->rx_dma;
 	unsigned short	oldConfig;
 
@@ -425,7 +425,7 @@ static void
 bmac_init_phy(struct net_device *dev)
 {
 	unsigned int addr;
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 
 	printk(KERN_DEBUG "phy registers:");
 	for (addr = 0; addr < 32; ++addr) {
@@ -458,7 +458,7 @@ static void bmac_init_chip(struct net_de
 static int bmac_suspend(struct macio_dev *mdev, u32 state)
 {
 	struct net_device* dev = macio_get_drvdata(mdev);	
-	struct bmac_data *bp = dev->priv;	
+	struct bmac_data *bp = netdev_priv(dev);
 	unsigned long flags;
 	unsigned short config;
 	int i;
@@ -508,7 +508,7 @@ static int bmac_suspend(struct macio_dev
 static int bmac_resume(struct macio_dev *mdev)
 {
 	struct net_device* dev = macio_get_drvdata(mdev);	
-	struct bmac_data *bp = dev->priv;	
+	struct bmac_data *bp = netdev_priv(dev);
 
 	/* see if this is enough */
 	if (bp->opened)
@@ -525,7 +525,7 @@ static int bmac_resume(struct macio_dev 
 
 static int bmac_set_address(struct net_device *dev, void *addr)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	unsigned char *p = addr;
 	unsigned short *pWord16;
 	unsigned long flags;
@@ -550,7 +550,7 @@ static int bmac_set_address(struct net_d
 
 static inline void bmac_set_timeout(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bp->lock, flags);
@@ -656,7 +656,7 @@ bmac_init_rx_ring(struct bmac_data *bp)
 
 static int bmac_transmit_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *td = bp->tx_dma;
 	int i;
 
@@ -692,7 +692,7 @@ static int rxintcount;
 static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *rd = bp->rx_dma;
 	volatile struct dbdma_cmd *cp;
 	int i, nb, stat;
@@ -769,7 +769,7 @@ static int txintcount;
 static irqreturn_t bmac_txdma_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_cmd *cp;
 	int stat;
 	unsigned long flags;
@@ -822,7 +822,7 @@ static irqreturn_t bmac_txdma_intr(int i
 
 static struct net_device_stats *bmac_stats(struct net_device *dev)
 {
-	struct bmac_data *p = (struct bmac_data *) dev->priv;
+	struct bmac_data *p = netdev_priv(dev);
 
 	return &p->stats;
 }
@@ -995,7 +995,7 @@ bmac_remove_multi(struct net_device *dev
 static void bmac_set_multicast(struct net_device *dev)
 {
 	struct dev_mc_list *dmi;
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	int num_addrs = dev->mc_count;
 	unsigned short rx_cfg;
 	int i;
@@ -1086,7 +1086,7 @@ static int miscintcount;
 static irqreturn_t bmac_misc_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct bmac_data *bp = (struct bmac_data *)dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	unsigned int status = bmread(dev, STATUS);
 	if (miscintcount++ < 10) {
 		XXDEBUG(("bmac_misc_intr\n"));
@@ -1232,7 +1232,7 @@ bmac_get_station_address(struct net_devi
 
 static void bmac_reset_and_enable(struct net_device *dev)
 {
-	struct bmac_data *bp = dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	unsigned long flags;
 	struct sk_buff *skb;
 	unsigned char *data;
@@ -1288,7 +1288,7 @@ static int __devinit bmac_probe(struct m
 		return -ENOMEM;
 	}
 		
-	bp = (struct bmac_data *) dev->priv;
+	bp = netdev_priv(dev);
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 	macio_set_drvdata(mdev, dev);
@@ -1408,7 +1408,7 @@ out_free:
 
 static int bmac_open(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	/* XXDEBUG(("bmac: enter open\n")); */
 	/* reset the chip */
 	bp->opened = 1;
@@ -1420,7 +1420,7 @@ static int bmac_open(struct net_device *
 
 static int bmac_close(struct net_device *dev)
 {
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *rd = bp->rx_dma;
 	volatile struct dbdma_regs *td = bp->tx_dma;
 	unsigned short config;
@@ -1469,7 +1469,7 @@ static int bmac_close(struct net_device 
 static void
 bmac_start(struct net_device *dev)
 {
-	struct bmac_data *bp = dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	int i;
 	struct sk_buff *skb;
 	unsigned long flags;
@@ -1495,7 +1495,7 @@ bmac_start(struct net_device *dev)
 static int
 bmac_output(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bmac_data *bp = dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	skb_queue_tail(bp->queue, skb);
 	bmac_start(dev);
 	return 0;
@@ -1504,7 +1504,7 @@ bmac_output(struct sk_buff *skb, struct 
 static void bmac_tx_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct bmac_data *bp = (struct bmac_data *) dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs *td = bp->tx_dma;
 	volatile struct dbdma_regs *rd = bp->rx_dma;
 	volatile struct dbdma_cmd *cp;
@@ -1630,7 +1630,7 @@ bmac_proc_info(char *buffer, char **star
 static int __devexit bmac_remove(struct macio_dev *mdev)
 {
 	struct net_device *dev = macio_get_drvdata(mdev);
-	struct bmac_data *bp = dev->priv;
+	struct bmac_data *bp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 
diff -puN drivers/net/cs89x0.c~drivers_net_casts drivers/net/cs89x0.c
--- linux-264-302-priv/drivers/net/cs89x0.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/cs89x0.c	2004-03-02 14:55:07.000000000 -0800
@@ -399,7 +399,7 @@ get_eeprom_cksum(int off, int len, int *
 static int __init
 cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	static unsigned version_printed;
 	int i;
 	unsigned rev_type = 0;
@@ -735,7 +735,7 @@ out1:
 static void
 get_dma_channel(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (lp->dma) {
 		dev->dma = lp->dma;
@@ -757,7 +757,7 @@ get_dma_channel(struct net_device *dev)
 static void
 write_dma(struct net_device *dev, int chip_type, int dma)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	if ((lp->isa_config & ANY_ISA_DMA) == 0)
 		return;
 	if (chip_type == CS8900) {
@@ -770,7 +770,7 @@ write_dma(struct net_device *dev, int ch
 static void
 set_dma_cfg(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (lp->use_dma) {
 		if ((lp->isa_config & ANY_ISA_DMA) == 0) {
@@ -793,7 +793,7 @@ set_dma_cfg(struct net_device *dev)
 static int
 dma_bufcfg(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	if (lp->use_dma)
 		return (lp->isa_config & ANY_ISA_DMA)? RX_DMA_ENBL : 0;
 	else
@@ -804,7 +804,7 @@ static int
 dma_busctl(struct net_device *dev)
 {
 	int retval = 0;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	if (lp->use_dma) {
 		if (lp->isa_config & ANY_ISA_DMA)
 			retval |= RESET_RX_DMA; /* Reset the DMA pointer */
@@ -820,7 +820,7 @@ dma_busctl(struct net_device *dev)
 static void
 dma_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 	unsigned char *bp = lp->rx_dma_ptr;
@@ -882,7 +882,7 @@ skip_this_frame:
 
 void  __init reset_chip(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int reset_start_time;
 
@@ -912,7 +912,7 @@ void  __init reset_chip(struct net_devic
 static void
 control_dc_dc(struct net_device *dev, int on_not_off)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned int selfcontrol;
 	int timenow = jiffies;
 	/* control the DC to DC convertor in the SelfControl register.  
@@ -940,7 +940,7 @@ control_dc_dc(struct net_device *dev, in
 static int
 detect_tp(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int timenow = jiffies;
 	int fdx;
 
@@ -1055,7 +1055,7 @@ send_test_pkt(struct net_device *dev)
 static int
 detect_aui(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (net_debug > 1) printk("%s: Attempting AUI\n", dev->name);
 	control_dc_dc(dev, 0);
@@ -1071,7 +1071,7 @@ detect_aui(struct net_device *dev)
 static int
 detect_bnc(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (net_debug > 1) printk("%s: Attempting BNC\n", dev->name);
 	control_dc_dc(dev, 1);
@@ -1117,7 +1117,7 @@ write_irq(struct net_device *dev, int ch
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int result = 0;
 	int i;
 	int ret;
@@ -1358,7 +1358,7 @@ static void net_timeout(struct net_devic
 
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (net_debug > 3) {
 		printk("%s: sent %d byte packet of type %x\n",
@@ -1419,7 +1419,7 @@ static irqreturn_t net_interrupt(int irq
  	int handled = 0;
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* we MUST read all the events out of the ISQ, otherwise we'll never
            get interrupted again.  As a consequence, we can't have any limit
@@ -1517,7 +1517,7 @@ count_rx_errors(int status, struct net_l
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
@@ -1573,7 +1573,7 @@ static void release_dma_buff(struct net_
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	
@@ -1600,7 +1600,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1614,7 +1614,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1758,7 +1758,7 @@ init_module(void)
 
 	dev->irq = irq;
 	dev->base_addr = io;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 #if ALLOW_DMA
 	if (use_dma) {
diff -puN drivers/net/eth16i.c~drivers_net_casts drivers/net/eth16i.c
--- linux-264-302-priv/drivers/net/eth16i.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/eth16i.c	2004-03-02 14:13:00.000000000 -0800
@@ -486,7 +486,7 @@ out:
 
 static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 {
-	struct eth16i_local *lp = dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	static unsigned version_printed;
 	int retval;
 
@@ -950,7 +950,7 @@ static void eth16i_eeprom_cmd(int ioaddr
 
 static int eth16i_open(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	
 	/* Powerup the chip */
@@ -986,7 +986,7 @@ static int eth16i_open(struct net_device
 
 static int eth16i_close(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	eth16i_reset(dev);
@@ -1012,7 +1012,7 @@ static int eth16i_close(struct net_devic
 
 static void eth16i_timeout(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	/* 
 	   If we get here, some higher level has decided that 
@@ -1053,7 +1053,7 @@ static void eth16i_timeout(struct net_de
 
 static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int status = 0;
 	ushort length = skb->len;
@@ -1130,7 +1130,7 @@ static int eth16i_tx(struct sk_buff *skb
 
 static void eth16i_rx(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = MAX_RX_LOOP;
 
@@ -1232,7 +1232,7 @@ static irqreturn_t eth16i_interrupt(int 
 	int handled = 0;
 
 	ioaddr = dev->base_addr;
-	lp = (struct eth16i_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* Turn off all interrupts from adapter */
 	outw(ETH16I_INTR_OFF, ioaddr + TX_INTR_REG);
@@ -1340,7 +1340,7 @@ static void eth16i_skip_packet(struct ne
 
 static void eth16i_reset(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if(eth16i_debug > 1) 
@@ -1372,7 +1372,7 @@ static void eth16i_multicast(struct net_
 
 static struct net_device_stats *eth16i_get_stats(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
diff -puN drivers/net/fec.c~drivers_net_casts drivers/net/fec.c
--- linux-264-302-priv/drivers/net/fec.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/fec.c	2004-03-02 14:53:25.000000000 -0800
@@ -269,7 +269,7 @@ fec_enet_start_xmit(struct sk_buff *skb,
 	volatile fec_t	*fecp;
 	volatile cbd_t	*bdp;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	fecp = (volatile fec_t*)dev->base_addr;
 
 	if (!fep->link) {
@@ -349,7 +349,7 @@ fec_enet_start_xmit(struct sk_buff *skb,
 static void
 fec_timeout(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	printk("%s: transmit timed out.\n", dev->name);
 	fep->stats.tx_errors++;
@@ -445,7 +445,7 @@ fec_enet_tx(struct net_device *dev)
 	volatile cbd_t	*bdp;
 	struct	sk_buff	*skb;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	spin_lock(&fep->lock);
 	bdp = fep->dirty_tx;
 
@@ -524,7 +524,7 @@ fec_enet_rx(struct net_device *dev)
 	ushort	pkt_len;
 	__u8 *data;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	fecp = (volatile fec_t*)dev->base_addr;
 
 	/* First, grab all of the stats for the incoming packet.
@@ -645,7 +645,7 @@ fec_enet_mii(struct net_device *dev)
 	mii_list_t	*mip;
 	uint		mii_reg;
 
-	fep = (struct fec_enet_private *)dev->priv;
+	fep = netdev_priv(dev);
 	ep = fec_hwp;
 	mii_reg = ep->fec_mii_data;
 	
@@ -675,7 +675,7 @@ mii_queue(struct net_device *dev, int re
 
 	/* Add PHY address to register command.
 	*/
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	regval |= fep->phy_addr << 23;
 
 	retval = 0;
@@ -720,7 +720,7 @@ static void mii_do_cmd(struct net_device
 
 static void mii_parse_sr(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_LINK | PHY_STAT_FAULT | PHY_STAT_ANC);
@@ -735,7 +735,7 @@ static void mii_parse_sr(uint mii_reg, s
 
 static void mii_parse_cr(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_CONF_ANE | PHY_CONF_LOOP);
@@ -748,7 +748,7 @@ static void mii_parse_cr(uint mii_reg, s
 
 static void mii_parse_anar(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_CONF_SPMASK);
@@ -774,7 +774,7 @@ static void mii_parse_anar(uint mii_reg,
 
 static void mii_parse_lxt970_csr(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK);
@@ -841,7 +841,7 @@ static phy_info_t phy_info_lxt970 = {
 
 static void mii_parse_lxt971_sr2(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK | PHY_STAT_LINK | PHY_STAT_ANC);
@@ -919,7 +919,7 @@ static phy_info_t phy_info_lxt971 = {
 
 static void mii_parse_qs6612_pcr(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK);
@@ -983,7 +983,7 @@ static phy_info_t phy_info_qs6612 = {
 
 static void mii_parse_am79c874_dr(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK | PHY_STAT_ANC);
@@ -1280,7 +1280,7 @@ static void __inline__ fec_uncache(unsig
 
 static void mii_display_status(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	if (!fep->link && !fep->old_link) {
@@ -1316,7 +1316,7 @@ static void mii_display_status(struct ne
 
 static void mii_display_config(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	printk("%s: config: auto-negotiation ", dev->name);
@@ -1347,7 +1347,7 @@ static void mii_display_config(struct ne
 
 static void mii_relink(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	int duplex;
 
 	fep->link = (fep->phy_status & PHY_STAT_LINK) ? 1 : 0;
@@ -1372,7 +1372,7 @@ static void mii_relink(struct net_device
 
 static void mii_queue_relink(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	INIT_WORK(&fep->phy_task, (void*)mii_relink, dev);
 	schedule_work(&fep->phy_task);
@@ -1380,7 +1380,7 @@ static void mii_queue_relink(uint mii_re
 
 static void mii_queue_config(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	INIT_WORK(&fep->phy_task, (void*)mii_display_config, dev);
 	schedule_work(&fep->phy_task);
@@ -1403,7 +1403,7 @@ mii_discover_phy3(uint mii_reg, struct n
 	struct fec_enet_private *fep;
 	int	i;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	fep->phy_id |= (mii_reg & 0xffff);
 	printk("fec: PHY @ 0x%x, ID 0x%08x", fep->phy_addr, fep->phy_id);
 
@@ -1431,7 +1431,7 @@ mii_discover_phy(uint mii_reg, struct ne
 	volatile fec_t *fecp;
 	uint phytype;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 	fecp = fec_hwp;
 
 	if (fep->phy_addr < 32) {
@@ -1466,7 +1466,7 @@ mii_link_interrupt(int irq, void * dev_i
 #endif
 {
 	struct	net_device *dev = dev_id;
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	fec_phy_ack_intr();
 
@@ -1482,7 +1482,7 @@ mii_link_interrupt(int irq, void * dev_i
 static int
 fec_enet_open(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
@@ -1531,7 +1531,7 @@ fec_enet_close(struct net_device *dev)
 
 static struct net_device_stats *fec_enet_get_stats(struct net_device *dev)
 {
-	struct fec_enet_private *fep = (struct fec_enet_private *)dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 
 	return &fep->stats;
 }
@@ -1557,7 +1557,7 @@ static void set_multicast_list(struct ne
 	unsigned int i, j, bit, data, crc;
 	unsigned char hash;
 
-	fep = (struct fec_enet_private *)dev->priv;
+	fep = netdev_priv(dev);
 	ep = fec_hwp;
 
 	if (dev->flags&IFF_PROMISC) {
@@ -1643,7 +1643,7 @@ fec_set_mac_address(struct net_device *d
   */
 int __init fec_enet_init(struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	unsigned long	mem_addr;
 	volatile cbd_t	*bdp;
 	cbd_t		*cbd_base;
@@ -1807,7 +1807,7 @@ fec_restart(struct net_device *dev, int 
 
 	fecp = fec_hwp;
 
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 
 	/* Whack a reset.  We should wait for this.
 	*/
@@ -1924,7 +1924,7 @@ fec_stop(struct net_device *dev)
 	struct fec_enet_private *fep;
 
 	fecp = fec_hwp;
-	fep = dev->priv;
+	fep = netdev_priv(dev);
 
 	fecp->fec_x_cntrl = 0x01;	/* Graceful transmit stop */
 
diff -puN drivers/net/gt96100eth.c~drivers_net_casts drivers/net/gt96100eth.c
--- linux-264-302-priv/drivers/net/gt96100eth.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/gt96100eth.c	2004-03-02 14:55:22.000000000 -0800
@@ -277,7 +277,7 @@ read_MII(int phy_addr, u32 reg)
 static void
 dump_tx_desc(int dbg_lvl, struct net_device *dev, int i)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	gt96100_td_t *td = &gp->tx_ring[i];
 
 	dbg(dbg_lvl, "Tx descriptor at 0x%08lx:\n", virt_to_phys(td));
@@ -292,7 +292,7 @@ dump_tx_desc(int dbg_lvl, struct net_dev
 static void
 dump_rx_desc(int dbg_lvl, struct net_device *dev, int i)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	gt96100_rd_t *rd = &gp->rx_ring[i];
 
 	dbg(dbg_lvl, "Rx descriptor at 0x%08lx:\n", virt_to_phys(rd));
@@ -332,7 +332,7 @@ write_MII(int phy_addr, u32 reg, u16 dat
 static void
 dump_tx_ring(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int i;
 
 	dbg(0, "%s: txno/txni/cnt=%d/%d/%d\n", __FUNCTION__,
@@ -345,7 +345,7 @@ dump_tx_ring(struct net_device *dev)
 static void
 dump_rx_ring(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int i;
 
 	dbg(0, "%s: rxno=%d\n", __FUNCTION__, gp->rx_next_out);
@@ -359,7 +359,7 @@ static void
 dump_MII(int dbg_lvl, struct net_device *dev)
 {
 	int i, val;
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
     
 	if (dbg_lvl <= GT96100_DEBUG) {
 		for (i=0; i<7; i++) {
@@ -419,7 +419,7 @@ dump_skb(int dbg_lvl, struct net_device 
 static int
 gt96100_add_hash_entry(struct net_device *dev, unsigned char* addr)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	//u16 hashResult, stmp;
 	//unsigned char ctmp, hash_ea[6];
 	u32 tblEntry1, tblEntry0, *tblEntryAddr;
@@ -544,7 +544,7 @@ update_stats(struct gt96100_private *gp)
 static void
 abort(struct net_device *dev, u32 abort_bits)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int timedout = 100; // wait up to 100 msec for hard stop to complete
 
 	dbg(3, "%s\n", __FUNCTION__);
@@ -582,7 +582,7 @@ abort(struct net_device *dev, u32 abort_
 static void
 hard_stop(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 
 	dbg(3, "%s\n", __FUNCTION__);
 
@@ -598,7 +598,7 @@ hard_stop(struct net_device *dev)
 static void
 enable_ether_irq(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	u32 intMask;
 	/*
 	 * route ethernet interrupt to GT_SERINT0 for port 0,
@@ -631,7 +631,7 @@ enable_ether_irq(struct net_device *dev)
 static void
 disable_ether_irq(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	u32 intMask;
 	int intr_mask_reg = (gp->port_num == 0) ?
 		GT96100_SERINT0_MASK : GT96100_INT0_HIGH_MASK;
@@ -745,7 +745,7 @@ gt96100_probe1(int port_num)
 		goto out1;
 	}
 
-	gp = dev->priv;
+	gp = netdev_priv(dev);
 
 	memset(gp, 0, sizeof(*gp)); // clear it
 
@@ -839,7 +839,7 @@ out:
 static void
 reset_tx(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int i;
 
 	abort(dev, sdcmrAT);
@@ -877,7 +877,7 @@ reset_tx(struct net_device *dev)
 static void
 reset_rx(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int i;
 
 	abort(dev, sdcmrAR);
@@ -934,7 +934,7 @@ gt96100_check_tx_consistent(struct gt961
 static int
 gt96100_init(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	u32 tmp;
 	u16 mii_reg;
     
@@ -1115,7 +1115,7 @@ gt96100_close(struct net_device *dev)
 static int
 gt96100_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	unsigned long flags;
 	int nextIn;
 
@@ -1187,7 +1187,7 @@ gt96100_tx(struct sk_buff *skb, struct n
 static int
 gt96100_rx(struct net_device *dev, u32 status)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int pkt_len, nextOut, cdp;
 	gt96100_rd_t *rd;
@@ -1296,7 +1296,7 @@ gt96100_rx(struct net_device *dev, u32 s
 static void
 gt96100_tx_complete(struct net_device *dev, u32 status)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	int nextOut, cdp;
 	gt96100_td_t *td;
 	u32 cmdstat;
@@ -1385,7 +1385,7 @@ static irqreturn_t
 gt96100_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	u32 status;
     	int handled = 0;
 
@@ -1486,7 +1486,7 @@ gt96100_interrupt(int irq, void *dev_id,
 static void
 gt96100_tx_timeout(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	unsigned long flags;
     
 	spin_lock_irqsave(&gp->lock, flags);
@@ -1511,7 +1511,7 @@ gt96100_tx_timeout(struct net_device *de
 static void
 gt96100_set_rx_mode(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	unsigned long flags;
 	//struct dev_mc_list *mcptr;
     
@@ -1555,7 +1555,7 @@ gt96100_set_rx_mode(struct net_device *d
 static struct net_device_stats *
 gt96100_get_stats(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	dbg(3, "%s: dev=%p\n", __FUNCTION__, dev);
diff -puN drivers/net/mac89x0.c~drivers_net_casts drivers/net/mac89x0.c
--- linux-264-302-priv/drivers/net/mac89x0.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/mac89x0.c	2004-03-02 14:23:13.000000000 -0800
@@ -225,7 +225,7 @@ struct net_device * __init mac89x0_probe
 		goto out;
 
 	/* Initialize the net_device structure. */
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* Fill in the 'dev' fields. */
 	dev->base_addr = ioaddr;
@@ -328,7 +328,7 @@ void __init reset_chip(struct net_device
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int i;
 
 	/* Disable the interrupt for now */
@@ -392,7 +392,7 @@ net_send_packet(struct sk_buff *skb, str
 	if (test_and_set_bit(0, (void*)&dev->tbusy) != 0)
 		printk("%s: Transmitter access conflict.\n", dev->name);
 	else {
-		struct net_local *lp = (struct net_local *)dev->priv;
+		struct net_local *lp = netdev_priv(dev);
 		unsigned long flags;
 
 		if (net_debug > 3)
@@ -446,7 +446,7 @@ static irqreturn_t net_interrupt(int irq
 	dev->interrupt = 1;
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* we MUST read all the events out of the ISQ, otherwise we'll never
            get interrupted again.  As a consequence, we can't have any limit
@@ -505,7 +505,7 @@ static irqreturn_t net_interrupt(int irq
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	int status, length;
 
@@ -571,7 +571,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -585,7 +585,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if(dev->flags&IFF_PROMISC)
 	{
diff -puN drivers/net/ni5010.c~drivers_net_casts drivers/net/ni5010.c
--- linux-264-302-priv/drivers/net/ni5010.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/ni5010.c	2004-03-02 14:24:14.000000000 -0800
@@ -309,7 +309,7 @@ static int __init ni5010_probe1(struct n
 	PRINTK2((KERN_DEBUG "%s: I/O #9 passed!\n", dev->name));
 
 	/* DMA is not supported (yet?), so no use detecting it */
-	lp = (struct ni5010_local*)dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock_init(&lp->lock);
 
@@ -484,7 +484,7 @@ static irqreturn_t ni5010_interrupt(int 
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_interrupt\n", dev->name));
 
 	ioaddr = dev->base_addr;
-	lp = (struct ni5010_local *)dev->priv;
+	lp = netdev_priv(dev);
 	
 	spin_lock(&lp->lock);
 	status = inb(IE_ISTAT); 
@@ -527,7 +527,7 @@ static void dump_packet(void *buf, int l
 /* We have a good packet, get it out of the buffer. */
 static void ni5010_rx(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned char rcv_stat;
 	struct sk_buff *skb;
@@ -592,7 +592,7 @@ static void ni5010_rx(struct net_device 
 
 static int process_xmt_interrupt(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int xmit_stat;
 
@@ -651,7 +651,7 @@ static int ni5010_close(struct net_devic
    closed. */
 static struct net_device_stats *ni5010_get_stats(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = netdev_priv(dev);
 
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_get_stats\n", dev->name));
 	
@@ -693,7 +693,7 @@ static void ni5010_set_multicast_list(st
 
 static void hardware_send_packet(struct net_device *dev, char *buf, int length, int pad)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	unsigned int buf_offs;
diff -puN drivers/net/rrunner.c~drivers_net_casts drivers/net/rrunner.c
--- linux-264-302-priv/drivers/net/rrunner.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/rrunner.c	2004-03-02 14:54:42.000000000 -0800
@@ -108,7 +108,7 @@ static int __devinit rr_init_one(struct 
 		goto out2;
 	}
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -236,7 +236,7 @@ static void __devexit rr_remove_one (str
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct rr_private *rr = dev->priv;
+		struct rr_private *rr = netdev_priv(dev);
 
 		if (!(readl(&rr->regs->HostCtrl) & NIC_HALTED)){
 			printk(KERN_ERR "%s: trying to unload running NIC\n",
@@ -308,7 +308,7 @@ static int rr_reset(struct net_device *d
 	u32 start_pc;
 	int i;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	rr_load_firmware(dev);
@@ -524,7 +524,7 @@ static int __init rr_init(struct net_dev
 	u32 sram_size, rev;
 	int i;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	rev = readl(&regs->FwRev);
@@ -595,7 +595,7 @@ static int rr_init1(struct net_device *d
 	int ecode = 0;
 	short i;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	spin_lock_irqsave(&rrpriv->lock, flags);
@@ -761,7 +761,7 @@ static u32 rr_handle_event(struct net_de
 	struct rr_regs *regs;
 	u32 tmp;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	while (prodidx != eidx){
@@ -960,7 +960,7 @@ static u32 rr_handle_event(struct net_de
 
 static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = netdev_priv(dev);
 	struct rr_regs *regs = rrpriv->regs;
 
 	do {
@@ -1052,7 +1052,7 @@ static irqreturn_t rr_interrupt(int irq,
 	struct net_device *dev = (struct net_device *)dev_id;
 	u32 prodidx, rxindex, eidx, txcsmr, rxlimit, txcon;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	if (!(readl(&regs->HostCtrl) & RR_INT))
@@ -1133,7 +1133,7 @@ static irqreturn_t rr_interrupt(int irq,
 static void rr_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = netdev_priv(dev);
 	struct rr_regs *regs = rrpriv->regs;
 	unsigned long flags;
 
@@ -1160,7 +1160,7 @@ static void rr_timer(unsigned long data)
 
 static int rr_open(struct net_device *dev)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = netdev_priv(dev);
 	struct pci_dev *pdev = rrpriv->pci_dev;
 	struct rr_regs *regs;
 	int ecode = 0;
@@ -1296,7 +1296,7 @@ static void rr_dump(struct net_device *d
 	short i;
 	int len;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	printk("%s: dumping NIC TX rings\n", dev->name);
@@ -1361,7 +1361,7 @@ static int rr_close(struct net_device *d
 
 	netif_stop_queue(dev);
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	/*
@@ -1418,7 +1418,7 @@ static int rr_close(struct net_device *d
 
 static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = netdev_priv(dev);
 	struct rr_regs *regs = rrpriv->regs;
 	struct ring_ctrl *txctrl;
 	unsigned long flags;
@@ -1488,7 +1488,7 @@ static struct net_device_stats *rr_get_s
 {
 	struct rr_private *rrpriv;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 
 	return(&rrpriv->stats);
 }
@@ -1511,7 +1511,7 @@ static int rr_load_firmware(struct net_d
 	u32 p2len, p2size, nr_seg, revision, io, sram_size;
 	struct eeprom *hw = NULL;
 
-	rrpriv = (struct rr_private *)dev->priv;
+	rrpriv = netdev_priv(dev);
 	regs = rrpriv->regs;
 
 	if (dev->flags & IFF_UP)
@@ -1614,7 +1614,7 @@ static int rr_ioctl(struct net_device *d
 	unsigned int i;
 	int error = -EOPNOTSUPP;
 
-	rrpriv = dev->priv;
+	rrpriv = netdev_priv(dev);
 
 	switch(cmd){
 	case SIOCRRGFW:
diff -puN drivers/net/sb1000.c~drivers_net_casts drivers/net/sb1000.c
--- linux-264-302-priv/drivers/net/sb1000.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sb1000.c	2004-03-02 14:29:21.000000000 -0800
@@ -746,7 +746,7 @@ sb1000_rx(struct net_device *dev)
 	int ioaddr, ns;
 	unsigned int skbsize;
 	struct sk_buff *skb;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 	struct net_device_stats *stats = &lp->stats;
 
 	/* SB1000 frame constants */
@@ -905,7 +905,7 @@ sb1000_error_dpc(struct net_device *dev)
 	char *name;
 	unsigned char st[5];
 	int ioaddr[2];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 	const unsigned char Command0[6] = {0x80, 0x26, 0x00, 0x00, 0x00, 0x00};
 	const int ErrorDpcCounterInitialize = 200;
 
@@ -932,7 +932,7 @@ sb1000_open(struct net_device *dev)
 {
 	char *name;
 	int ioaddr[2], status;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 	const unsigned short FirmwareVersion[] = {0x01, 0x01};
 
 	ioaddr[0] = dev->base_addr;
@@ -998,7 +998,7 @@ static int sb1000_dev_ioctl(struct net_d
 	short PID[4];
 	int ioaddr[2], status, frequency;
 	unsigned int stats[5];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 
 	if (!(dev && dev->flags & IFF_UP))
 		return -ENODEV;
@@ -1092,7 +1092,7 @@ static irqreturn_t sb1000_interrupt(int 
 	unsigned char st;
 	int ioaddr[2];
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 
 	const unsigned char Command0[6] = {0x80, 0x2c, 0x00, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
@@ -1148,7 +1148,7 @@ static irqreturn_t sb1000_interrupt(int 
 
 static struct net_device_stats *sb1000_stats(struct net_device *dev)
 {
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1156,7 +1156,7 @@ static int sb1000_close(struct net_devic
 {
 	int i;
 	int ioaddr[2];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = netdev_priv(dev);
 
 	if (sb1000_debug > 2)
 		printk(KERN_DEBUG "%s: Shutting down sb1000.\n", dev->name);
diff -puN drivers/net/sb1250-mac.c~drivers_net_casts drivers/net/sb1250-mac.c
--- linux-264-302-priv/drivers/net/sb1250-mac.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sb1250-mac.c	2004-03-02 14:32:50.000000000 -0800
@@ -2080,7 +2080,7 @@ static int sbmac_set_duplex(struct sbmac
 static irqreturn_t sbmac_intr(int irq,void *dev_instance,struct pt_regs *rgs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct sbmac_softc *sc = (struct sbmac_softc *) (dev->priv);
+	struct sbmac_softc *sc = netdev_priv(dev);
 	uint64_t isr;
 	int handled = 0;
 
@@ -2150,7 +2150,7 @@ static irqreturn_t sbmac_intr(int irq,vo
  ********************************************************************* */
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	
 	/* lock eth irq */
 	spin_lock_irq (&sc->sbm_lock);
@@ -2374,7 +2374,7 @@ static int sbmac_init(struct net_device 
 	int i;
 	int err;
 	
-	sc = (struct sbmac_softc *)dev->priv;
+	sc = netdev_priv(dev);
 	
 	/* Determine controller base address */
 	
@@ -2454,7 +2454,7 @@ static int sbmac_init(struct net_device 
 
 static int sbmac_open(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	
 	if (debug > 1) {
 		printk(KERN_DEBUG "%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
@@ -2609,7 +2609,7 @@ static int sbmac_mii_poll(struct sbmac_s
 static void sbmac_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	int next_tick = HZ;
 	int mii_status;
 
@@ -2655,7 +2655,7 @@ static void sbmac_timer(unsigned long da
 
 static void sbmac_tx_timeout (struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *) dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	
 	spin_lock_irq (&sc->sbm_lock);
 	
@@ -2673,7 +2673,7 @@ static void sbmac_tx_timeout (struct net
 
 static struct net_device_stats *sbmac_get_stats(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned long flags;
 	
 	spin_lock_irqsave(&sc->sbm_lock, flags);
@@ -2691,7 +2691,7 @@ static void sbmac_set_rx_mode(struct net
 {
 	unsigned long flags;
 	int msg_flag = 0;
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 
 	spin_lock_irqsave(&sc->sbm_lock, flags);
 	if ((dev->flags ^ sc->sbm_devflags) & IFF_PROMISC) {
@@ -2726,7 +2726,7 @@ static void sbmac_set_rx_mode(struct net
 
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	u16 *data = (u16 *)&rq->ifr_data;
 	unsigned long flags;
 	int retval;
@@ -2762,7 +2762,7 @@ static int sbmac_mii_ioctl(struct net_de
 
 static int sbmac_close(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned long flags;
 	int irq;
 
@@ -2911,7 +2911,7 @@ sbmac_cleanup_module(void)
 	for (idx = 0; idx < MAX_UNITS; idx++) {
 		dev = dev_sbmac[idx];
 		if (!dev) {
-			struct sbmac_softc *sc = dev->priv;
+			struct sbmac_softc *sc = netdev_priv(dev);
 			unregister_netdev(dev);
 			sbmac_uninitctx(sc);
 			free_netdev(dev);
diff -puN drivers/net/seeq8005.c~drivers_net_casts drivers/net/seeq8005.c
--- linux-264-302-priv/drivers/net/seeq8005.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/seeq8005.c	2004-03-02 14:33:41.000000000 -0800
@@ -357,7 +357,7 @@ out:
    */
 static int seeq8005_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	{
 		 int irqval = request_irq(dev->irq, &seeq8005_interrupt, 0, "seeq8005", dev);
@@ -390,7 +390,7 @@ static void seeq8005_timeout(struct net_
 
 static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	short length = skb->len;
 	unsigned char *buf;
 
@@ -424,7 +424,7 @@ static irqreturn_t seeq8005_interrupt(in
 	int handled = 0;
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	status = inw(SEEQ_STATUS);
 	do {
@@ -462,7 +462,7 @@ static irqreturn_t seeq8005_interrupt(in
 /* We have a good packet(s), get it/them out of the buffers. */
 static void seeq8005_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int boguscount = 10;
 	int pkt_hdr;
 	int ioaddr = dev->base_addr;
@@ -561,7 +561,7 @@ static void seeq8005_rx(struct net_devic
 /* The inverse routine to net_open(). */
 static int seeq8005_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	lp->open_time = 0;
@@ -583,7 +583,7 @@ static int seeq8005_close(struct net_dev
    closed. */
 static struct net_device_stats *seeq8005_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -618,7 +618,7 @@ static void set_multicast_list(struct ne
 
 void seeq8005_init(struct net_device *dev, int startp)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int i;
 	
diff -puN drivers/net/sgiseeq.c~drivers_net_casts drivers/net/sgiseeq.c
--- linux-264-302-priv/drivers/net/sgiseeq.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sgiseeq.c	2004-03-02 14:35:32.000000000 -0800
@@ -151,7 +151,7 @@ static inline void seeq_load_eaddr(struc
 
 static int seeq_init_ring(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	volatile struct sgiseeq_init_block *ib = &sp->srings;
 	int i;
 
@@ -423,7 +423,7 @@ static inline void sgiseeq_tx(struct net
 static irqreturn_t sgiseeq_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct hpc3_ethregs *hregs = sp->hregs;
 	struct sgiseeq_regs *sregs = sp->sregs;
 
@@ -445,7 +445,7 @@ static irqreturn_t sgiseeq_interrupt(int
 
 static int sgiseeq_open(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *)dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct sgiseeq_regs *sregs = sp->sregs;
 
 	int err = init_seeq(dev, sp, sregs);
@@ -459,7 +459,7 @@ static int sgiseeq_open(struct net_devic
 
 static int sgiseeq_close(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct sgiseeq_regs *sregs = sp->sregs;
 
 	netif_stop_queue(dev);
@@ -472,7 +472,7 @@ static int sgiseeq_close(struct net_devi
 
 static inline int sgiseeq_reset(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct sgiseeq_regs *sregs = sp->sregs;
 	int err;
 
@@ -494,7 +494,7 @@ void sgiseeq_my_reset(void)
 
 static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	struct hpc3_ethregs *hregs = sp->hregs;
 	unsigned long flags;
 	struct sgiseeq_tx_desc *td;
@@ -560,7 +560,7 @@ static void timeout(struct net_device *d
 
 static struct net_device_stats *sgiseeq_get_stats(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 
 	return &sp->stats;
 }
@@ -710,7 +710,7 @@ static void __exit sgiseeq_exit(void)
 	struct net_device *next, *dev = root_sgiseeq_dev;
 
 	while (dev) {
-		sp = (struct sgiseeq_private *) dev->priv;
+		sp = netdev_priv(dev);
 		next = sp->next_module;
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
diff -puN drivers/net/sk_g16.c~drivers_net_casts drivers/net/sk_g16.c
--- linux-264-302-priv/drivers/net/sk_g16.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sk_g16.c	2004-03-02 14:37:18.000000000 -0800
@@ -650,7 +650,7 @@ int __init SK_probe(struct net_device *d
     int sk_addr_flag = 0;   /* SK ADDR correct? 1 - no, 0 - yes */
     unsigned int rom_addr;  /* used to store RAM address used for POS_ADDR */
 
-    struct priv *p = dev->priv;         /* SK_G16 private structure */
+    struct priv *p = netdev_priv(dev);	/* SK_G16 private structure */
 
     if (inb(SK_POS0) != SK_IDLOW || inb(SK_POS1) != SK_IDHIGH)
 	return -ENODEV;
@@ -869,7 +869,7 @@ static int SK_open(struct net_device *de
 
     int irqtab[] = SK_IRQS; 
 
-    struct priv *p = (struct priv *)dev->priv;
+    struct priv *p = netdev_priv(dev);
 
     PRINTK(("## %s: At beginning of SK_open(). CSR0: %#06x\n", 
            SK_NAME, SK_read_reg(CSR0)));
@@ -1023,7 +1023,7 @@ static int SK_lance_init(struct net_devi
 {
     int i;
     unsigned long flags;
-    struct priv *p = (struct priv *) dev->priv; 
+    struct priv *p = netdev_priv(dev);
     struct tmd  *tmdp;
     struct rmd  *rmdp;
 
@@ -1196,7 +1196,7 @@ static void SK_timeout(struct net_device
 
 static int SK_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
     struct tmd *tmdp;
     static char pad[64];
 
@@ -1285,7 +1285,7 @@ static irqreturn_t SK_interrupt(int irq,
 {
     int csr0;
     struct net_device *dev = dev_id;
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
 
 
     PRINTK2(("## %s: SK_interrupt(). status: %#06x\n", 
@@ -1355,7 +1355,7 @@ static void SK_txintr(struct net_device 
 {
     int tmdstat;
     struct tmd *tmdp;
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
 
 
     PRINTK2(("## %s: SK_txintr() status: %#06x\n", 
@@ -1469,7 +1469,7 @@ static void SK_rxintr(struct net_device 
 
     struct rmd *rmdp;
     int rmdstat;
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
 
     PRINTK2(("## %s: SK_rxintr(). CSR0: %#06x\n", 
             SK_NAME, SK_read_reg(CSR0)));
@@ -1653,7 +1653,7 @@ static int SK_close(struct net_device *d
 static struct net_device_stats *SK_get_stats(struct net_device *dev)
 {
 
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
 
     PRINTK(("## %s: SK_get_stats(). CSR0: %#06x\n", 
            SK_NAME, SK_read_reg(CSR0)));
@@ -2030,7 +2030,7 @@ void __init SK_print_ram(struct net_devi
 {
 
     int i;    
-    struct priv *p = (struct priv *) dev->priv;
+    struct priv *p = netdev_priv(dev);
 
     printk("## %s: RAM Details.\n"
            "##   RAM at %#08x tmdhead: %#08x rmdhead: %#08x initblock: %#08x\n",
diff -puN drivers/net/smc9194.c~drivers_net_casts drivers/net/smc9194.c
--- linux-264-302-priv/drivers/net/smc9194.c~drivers_net_casts	2004-03-02 13:38:28.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/smc9194.c	2004-03-02 14:38:31.000000000 -0800
@@ -465,7 +465,7 @@ static void smc_setmulticast( int ioaddr
 */
 static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * dev )
 {
-	struct smc_local *lp 	= (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 	unsigned short ioaddr 	= dev->base_addr;
 	word 			length;
 	unsigned short 		numPages;
@@ -576,7 +576,7 @@ static int smc_wait_to_send_packet( stru
 */
 static void smc_hardware_send_packet( struct net_device * dev )
 {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 	byte	 		packet_no;
 	struct sk_buff * 	skb = lp->saved_skb;
 	word			length;
@@ -1150,7 +1150,7 @@ static irqreturn_t smc_interrupt(int irq
 {
 	struct net_device *dev 	= dev_id;
 	int ioaddr 		= dev->base_addr;
-	struct smc_local *lp 	= (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 
 	byte	status;
 	word	card_stats;
@@ -1274,7 +1274,7 @@ static irqreturn_t smc_interrupt(int irq
 */
 static void smc_rcv(struct net_device *dev)
 {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 	int 	ioaddr = dev->base_addr;
 	int 	packet_number;
 	word	status;
@@ -1401,7 +1401,7 @@ done:
 static void smc_tx( struct net_device * dev )
 {
 	int	ioaddr = dev->base_addr;
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 	byte saved_packet;
 	byte packet_no;
 	word tx_status;
@@ -1474,7 +1474,7 @@ static int smc_close(struct net_device *
  . This may be called with the card open or closed.
  .-------------------------------------------------------------*/
 static struct net_device_stats* smc_query_statistics(struct net_device *dev) {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }

_


--
~Randy
