From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 1/5] tlan: use netdev_priv (rev 2)
Date: Tue, 19 Oct 2004 11:18:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019111818.3586fc7f@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	2004-10-19 11:03:02 -07:00
+++ b/drivers/net/tlan.c	2004-10-19 11:03:02 -07:00
@@ -382,7 +382,7 @@
 static inline void
 TLan_SetTimer( struct net_device *dev, u32 ticks, u32 type )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 	
 	if (!in_irq())
@@ -438,7 +438,7 @@
 static void __devexit tlan_remove_one( struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata( pdev );
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	
 	unregister_netdev( dev );
 
@@ -557,7 +557,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 
 	priv->pciDev = pdev;
 	
@@ -693,7 +693,7 @@
 	
 	while( tlan_have_eisa ) {
 		dev = TLan_Eisa_Devices;
-		priv = dev->priv;
+		priv = netdev_priv(dev);
 		if (priv->dmaStorage) {
 			pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage, priv->dmaStorageDMA );
 		}
@@ -854,7 +854,7 @@
 	int		i;
 	TLanPrivateInfo	*priv;
 
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 	
 	if ( bbuf ) {
 		dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
@@ -937,7 +937,7 @@
 
 static int TLan_Open( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		err;
 	
 	priv->tlanRev = TLan_DioRead8( dev->base_addr, TLAN_DEF_REVISION );
@@ -983,7 +983,7 @@
 
 static int TLan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 	u32 phy   = priv->phy[priv->phyNum];
 	
@@ -1062,7 +1062,7 @@
 
 static int TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	TLanList	*tail_list;
 	dma_addr_t	tail_list_phys;
 	u8		*tail_buffer;
@@ -1170,7 +1170,7 @@
 	TLanPrivateInfo *priv;
 
 	dev = dev_id;
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 
 	spin_lock(&priv->lock);
 
@@ -1211,7 +1211,7 @@
 
 static int TLan_Close(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	priv->neg_be_verbose = 0;
@@ -1251,7 +1251,7 @@
 
 static struct net_device_stats *TLan_GetStats( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int i;
 
 	/* Should only read stats if open ? */
@@ -1270,7 +1270,7 @@
 			TLan_PrintList( priv->txList + i, "TX", i );
 	}
 	
-	return ( &( (TLanPrivateInfo *) dev->priv )->stats );
+	return ( &( (TLanPrivateInfo *) netdev_priv(dev) )->stats );
 
 } /* TLan_GetStats */
 
@@ -1405,7 +1405,7 @@
 
 u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		eoc = 0;
 	TLanList	*head_list;
 	dma_addr_t	head_list_phys;
@@ -1527,7 +1527,7 @@
 
 u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack = 0;
 	int		eoc = 0;
 	u8		*head_buffer;
@@ -1694,7 +1694,7 @@
 
 u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	TLanList		*head_list;
 	dma_addr_t		head_list_phys;
 	u32			ack = 1;
@@ -1742,7 +1742,7 @@
 
 u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 {	
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack;
 	u32		error;
 	u8		net_sts;
@@ -1817,7 +1817,7 @@
 
 u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	dma_addr_t	head_list_phys;
 	u32		ack = 1;
 
@@ -1878,7 +1878,7 @@
 void TLan_Timer( unsigned long data )
 {
 	struct net_device	*dev = (struct net_device *) data;
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		elapsed;
 	unsigned long	flags = 0;
 
@@ -1958,7 +1958,7 @@
 
 void TLan_ResetLists( struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
 	TLanList	*list;
 	dma_addr_t	list_phys;
@@ -2018,7 +2018,7 @@
 
 void TLan_FreeLists( struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
 	TLanList	*list;
 	struct sk_buff	*skb;
@@ -2138,7 +2138,7 @@
 
 void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
 	u32		rx_good, rx_over;
 	u32		def_tx, crc, code;
@@ -2214,7 +2214,7 @@
 void
 TLan_ResetAdapter( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		i;
 	u32		addr;
 	u32		data;
@@ -2300,7 +2300,7 @@
 void
 TLan_FinishReset( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u8		data;
 	u32		phy;
 	u8		sio;
@@ -2464,7 +2464,7 @@
 
 void TLan_PhyPrint( struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16 i, data0, data1, data2, data3, phy;
 
 	phy = priv->phy[priv->phyNum];
@@ -2513,7 +2513,7 @@
 
 void TLan_PhyDetect( struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		control;
 	u16		hi;
 	u16		lo;
@@ -2560,7 +2560,7 @@
 
 void TLan_PhyPowerDown( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
 
 	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Powering down PHY(s).\n", dev->name );
@@ -2585,7 +2585,7 @@
 
 void TLan_PhyPowerUp( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
 
 	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Powering up PHY.\n", dev->name );
@@ -2606,7 +2606,7 @@
 
 void TLan_PhyReset( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		phy;
 	u16		value;
 
@@ -2634,7 +2634,7 @@
 
 void TLan_PhyStartLink( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		ability;
 	u16		control;
 	u16		data;
@@ -2721,7 +2721,7 @@
 
 void TLan_PhyFinishAutoNeg( struct net_device *dev )
 {
-	TLanPrivateInfo	*priv = dev->priv;
+	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		an_adv;
 	u16		an_lpa;
 	u16		data;
@@ -2805,7 +2805,7 @@
 
 void TLan_PhyMonitor( struct net_device *dev )
 {
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16     phy;
 	u16     phy_status;
 
@@ -2882,7 +2882,7 @@
  	u32	i;
 	int	err;
 	int	minten;
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 
 	err = FALSE;
@@ -3051,7 +3051,7 @@
 	u16	sio;
 	int	minten;
 	unsigned long flags = 0;
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 
 	outw(TLAN_NET_SIO, dev->base_addr + TLAN_DIO_ADR);
 	sio = dev->base_addr + TLAN_DIO_DATA + TLAN_NET_SIO;
@@ -3278,7 +3278,7 @@
 int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
 {
 	int err;
-	TLanPrivateInfo *priv = dev->priv;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 	int ret=0;
 
