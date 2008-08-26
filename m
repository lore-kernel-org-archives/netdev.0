From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-7
Date: Tue, 26 Aug 2008 22:18:43 +0800
Message-ID: <48B410C3.3090404@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56091 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756599AbYHZOVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:09 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index a03fe1f..8879522 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -527,7 +527,7 @@ retry:
 
 static int ibmveth_open(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	u64 mac_address = 0;
 	int rxq_entries = 1;
 	unsigned long lpar_rc;
@@ -666,7 +666,7 @@ static int ibmveth_open(struct net_device *netdev)
 
 static int ibmveth_close(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long lpar_rc;
 
 	ibmveth_debug_printk("close starting\n");
@@ -722,7 +722,7 @@ static u32 netdev_get_link(struct net_device *dev) {
 
 static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if (data)
 		adapter->rx_csum = 1;
@@ -741,7 +741,7 @@ static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
 
 static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if (data) {
 		dev->features |= NETIF_F_IP_CSUM;
@@ -753,7 +753,7 @@ static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data)
 static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
 				    void (*done) (struct net_device *, u32))
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	u64 set_attr, clr_attr, ret_attr;
 	long ret;
 	int rc1 = 0, rc2 = 0;
@@ -805,7 +805,7 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
 
 static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if ((data && adapter->rx_csum) || (!data && !adapter->rx_csum))
 		return 0;
@@ -815,7 +815,7 @@ static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
 
 static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rc = 0;
 
 	if (data && (dev->features & NETIF_F_IP_CSUM))
@@ -833,7 +833,7 @@ static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
 
 static u32 ibmveth_get_rx_csum(struct net_device *dev)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	return adapter->rx_csum;
 }
 
@@ -862,7 +862,7 @@ static void ibmveth_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	int i;
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++)
 		data[i] = IBMVETH_GET_STAT(adapter, ibmveth_stats[i].offset);
@@ -889,7 +889,7 @@ static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 	unsigned long correlator;
@@ -1044,7 +1044,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *netdev = dev_instance;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
@@ -1058,7 +1058,7 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 
 static void ibmveth_set_multicast_list(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if((netdev->flags & IFF_PROMISC) || (netdev->mc_count > adapter->mcastFilterSize)) {
@@ -1106,7 +1106,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	struct vio_dev *viodev = adapter->vdev;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
 	int i;
@@ -1158,7 +1158,7 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void ibmveth_poll_controller(struct net_device *dev)
 {
-	ibmveth_replenish_task(dev->priv);
+	ibmveth_replenish_task(netdev_priv(dev));
 	ibmveth_interrupt(dev->irq, dev);
 }
 #endif
@@ -1240,7 +1240,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	if(!netdev)
 		return -ENOMEM;
 
-	adapter = netdev->priv;
+	adapter = netdev_priv(netdev);
 	dev->dev.driver_data = netdev;
 
 	adapter->vdev = dev;
@@ -1336,7 +1336,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 static int __devexit ibmveth_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev->dev.driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
 	for(i = 0; i<IbmVethNumBufferPools; i++)
@@ -1471,7 +1471,7 @@ const char * buf, size_t count)
 						      kobj);
 	struct net_device *netdev =
 	    container_of(kobj->parent, struct device, kobj)->driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long value = simple_strtol(buf, NULL, 10);
 	long rc;
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 11aee13..e7ce024 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -101,8 +101,8 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((struct igb_adapter *)netdev->priv)->num_rx_queues + \
-	 ((struct igb_adapter *)netdev->priv)->num_tx_queues) * \
+	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues + \
+	 ((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
 	(sizeof(struct igb_queue_stats) / sizeof(u64)))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 8e0ca9f..b13af97 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -329,7 +329,7 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
         printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
-	memset(dev->priv, 0, sizeof(struct ni5010_local));
+	memset(netdev_priv(dev), 0, sizeof(struct ni5010_local));
 
 	dev->open		= ni5010_open;
 	dev->stop		= ni5010_close;
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index b9a882d..aee6c35 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -214,7 +214,7 @@ struct priv {
 /* wait for command with timeout: */
 static void wait_for_scb_cmd(struct net_device *dev)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 	for (i = 0; i < 16384; i++) {
 		if (readb(&p->scb->cmd_cuc) == 0)
@@ -233,7 +233,7 @@ static void wait_for_scb_cmd(struct net_device *dev)
 
 static void wait_for_scb_cmd_ruc(struct net_device *dev)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 	for (i = 0; i < 16384; i++) {
 		if (readb(&p->scb->cmd_ruc) == 0)
@@ -298,7 +298,7 @@ static int ni52_open(struct net_device *dev)
 static int check_iscp(struct net_device *dev, void __iomem *addr)
 {
 	struct iscp_struct __iomem *iscp = addr;
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	memset_io(iscp, 0, sizeof(struct iscp_struct));
 
 	writel(make24(iscp), &p->scp->iscp);
@@ -318,7 +318,7 @@ static int check_iscp(struct net_device *dev, void __iomem *addr)
  */
 static int check586(struct net_device *dev, unsigned size)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 
 	p->mapped = ioremap(dev->mem_start, size);
@@ -354,7 +354,7 @@ Enodev:
  */
 static void alloc586(struct net_device *dev)
 {
-	struct priv *p =	(struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	ni_reset586();
 	mdelay(32);
@@ -400,7 +400,7 @@ struct net_device * __init ni52_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	p = dev->priv;
+	p = netdev_priv(dev);
 
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
@@ -446,7 +446,7 @@ out:
 static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, size, retval;
-	struct priv *priv = dev->priv;
+	struct priv *priv = netdev_priv(dev);
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
@@ -588,7 +588,7 @@ static int init586(struct net_device *dev)
 {
 	void __iomem *ptr;
 	int i, result = 0;
-	struct priv *p = (struct priv *)dev->priv;
+	struct priv *p = netdev_priv(dev);
 	struct configure_cmd_struct __iomem *cfg_cmd;
 	struct iasetup_cmd_struct __iomem *ias_cmd;
 	struct tdr_cmd_struct __iomem *tdr_cmd;
@@ -829,7 +829,7 @@ static void __iomem *alloc_rfa(struct net_device *dev, void __iomem *ptr)
 	struct rfd_struct __iomem *rfd = ptr;
 	struct rbd_struct __iomem *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset_io(rfd, 0,
 		sizeof(struct rfd_struct) * (p->num_recv_buffs + rfdadd));
@@ -878,7 +878,7 @@ static irqreturn_t ni52_interrupt(int irq, void *dev_id)
 	int cnt = 0;
 	struct priv *p;
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	if (debuglevel > 1)
 		printk("I");
@@ -950,7 +950,7 @@ static void ni52_rcv_int(struct net_device *dev)
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct __iomem *rbd;
-	struct priv *p = (struct priv *)dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (debuglevel > 0)
 		printk("R");
@@ -1040,7 +1040,7 @@ static void ni52_rcv_int(struct net_device *dev)
 
 static void ni52_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -1065,7 +1065,7 @@ static void ni52_rnr_int(struct net_device *dev)
 static void ni52_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (debuglevel > 0)
 		printk("X");
@@ -1113,7 +1113,7 @@ static void ni52_xmt_int(struct net_device *dev)
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	wait_for_scb_cmd(dev);
 	wait_for_scb_cmd_ruc(dev);
@@ -1126,7 +1126,7 @@ static void startrecv586(struct net_device *dev)
 
 static void ni52_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 #ifndef NO_NOPCOMMANDS
 	if (readb(&p->scb->cus) & CU_ACTIVE) { /* COMMAND-UNIT active? */
 		netif_wake_queue(dev);
@@ -1177,7 +1177,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (skb->len > XMIT_BUFF_SIZE) {
 		printk(KERN_ERR "%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n", dev->name, XMIT_BUFF_SIZE, skb->len);
@@ -1274,7 +1274,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *ni52_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	/* Get error-statistics from the ni82586 */
@@ -1337,7 +1337,7 @@ int __init init_module(void)
 
 void __exit cleanup_module(void)
 {
-	struct priv *p = dev_ni52->priv;
+	struct priv *p = netdev_priv(dev_ni52);
 	unregister_netdev(dev_ni52);
 	iounmap(p->mapped);
 	release_region(dev_ni52->base_addr, NI52_TOTAL_SIZE);



