From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-8
Date: Tue, 26 Aug 2008 22:18:47 +0800
Message-ID: <48B410C7.4040106@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60057 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756425AbYHZOVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:14 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 2ff1818..7151b3b 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -292,7 +292,7 @@ static int ali_ircc_open(int i, chipio_t *info)
 		return -ENOMEM;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
    
@@ -665,7 +665,7 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 		
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
-	self = dev->priv;
+	self = netdev_priv(dev);
 	
 	spin_lock(&self->lock);
 	
@@ -1333,7 +1333,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1396,7 +1396,7 @@ static int ali_ircc_net_close(struct net_device *dev)
 		
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -1436,7 +1436,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	netif_stop_queue(dev);
@@ -1960,7 +1960,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return 0;);
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	iobase = self->io.sir_base;
@@ -2028,7 +2028,7 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -2114,7 +2114,7 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 
 static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev)
 {
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) dev->priv;
+	struct ali_ircc_cb *self = netdev_priv(dev);
 	
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 69d16b3..687c2d5 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -979,7 +979,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
   unsigned long flags;
   struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
 
-  self = (struct toshoboe_cb *) dev->priv;
+  self = netdev_priv(dev);
 
   IRDA_ASSERT (self != NULL, return 0; );
 
@@ -1384,7 +1384,7 @@ toshoboe_net_close (struct net_device *dev)
   IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (dev != NULL, return -1; );
-  self = (struct toshoboe_cb *) dev->priv;
+  self = netdev_priv(dev);
 
   /* Stop device */
   netif_stop_queue(dev);
@@ -1422,7 +1422,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 
   IRDA_ASSERT (dev != NULL, return -1; );
 
-  self = dev->priv;
+  self = netdev_priv(dev);
 
   IRDA_ASSERT (self != NULL, return -1; );
 
@@ -1546,7 +1546,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
       return -ENOMEM;
     }
 
-  self = dev->priv;
+  self = netdev_priv(dev);
   self->netdev = dev;
   self->pdev = pci_dev;
   self->base = pci_resource_start(pci_dev,0);
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index b5d6b9a..3c8f6f1 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -384,7 +384,7 @@ static void speed_bulk_callback(struct urb *urb)
  */
 static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct irda_usb_cb *self = netdev->priv;
+	struct irda_usb_cb *self = netdev_priv(netdev);
 	struct urb *urb = self->tx_urb;
 	unsigned long flags;
 	s32 speed;
@@ -628,7 +628,7 @@ static void write_bulk_callback(struct urb *urb)
 static void irda_usb_net_timeout(struct net_device *netdev)
 {
 	unsigned long flags;
-	struct irda_usb_cb *self = netdev->priv;
+	struct irda_usb_cb *self = netdev_priv(netdev);
 	struct urb *urb;
 	int	done = 0;	/* If we have made any progress */
 
@@ -1175,7 +1175,7 @@ static int irda_usb_net_open(struct net_device *netdev)
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
-	self = (struct irda_usb_cb *) netdev->priv;
+	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	spin_lock_irqsave(&self->lock, flags);
@@ -1257,7 +1257,7 @@ static int irda_usb_net_close(struct net_device *netdev)
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
-	self = (struct irda_usb_cb *) netdev->priv;
+	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	/* Clear this flag *before* unlinking the urbs and *before*
@@ -1306,7 +1306,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
@@ -1348,7 +1348,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  */
 static struct net_device_stats *irda_usb_net_get_stats(struct net_device *dev)
 {
-	struct irda_usb_cb *self = dev->priv;
+	struct irda_usb_cb *self = netdev_priv(dev);
 	return &self->stats;
 }
 
@@ -1641,7 +1641,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 		goto err_out;
 
 	SET_NETDEV_DEV(net, &intf->dev);
-	self = net->priv;
+	self = netdev_priv(net);
 	self->netdev = net;
 	spin_lock_init(&self->lock);
 	init_timer(&self->rx_defer_timer);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 8583d95..84961fe 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -373,7 +373,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 		return -ENOMEM;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
    
@@ -1354,7 +1354,7 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	__s32 speed;
 	__u8 bank;
 	
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
@@ -1427,7 +1427,7 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	__u8 bank;
 	int mtt, diff;
 	
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	netif_stop_queue(dev);
@@ -2085,7 +2085,7 @@ static irqreturn_t nsc_ircc_interrupt(int irq, void *dev_id)
 	__u8 bsr, eir;
 	int iobase;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	spin_lock(&self->lock);	
 
@@ -2166,7 +2166,7 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -2229,7 +2229,7 @@ static int nsc_ircc_net_close(struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -2275,7 +2275,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -2310,7 +2310,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static struct net_device_stats *nsc_ircc_net_get_stats(struct net_device *dev)
 {
-	struct nsc_ircc_cb *self = (struct nsc_ircc_cb *) dev->priv;
+	struct nsc_ircc_cb *self = netdev_priv(dev);
 	
 	return &self->stats;
 }
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index a951889..f74b540 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -298,7 +298,7 @@ static int sa1100_irda_suspend(struct platform_device *pdev, pm_message_t state)
 	if (!dev)
 		return 0;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	if (si->open) {
 		/*
 		 * Stop the transmit queue
@@ -323,7 +323,7 @@ static int sa1100_irda_resume(struct platform_device *pdev)
 	if (!dev)
 		return 0;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	if (si->open) {
 		/*
 		 * If we missed a speed change, initialise at the new speed
@@ -359,7 +359,7 @@ static int sa1100_irda_resume(struct platform_device *pdev)
  */
 static void sa1100_irda_hpsir_irq(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int status;
 
 	status = Ser2UTSR0;
@@ -534,7 +534,7 @@ static void sa1100_irda_fir_error(struct sa1100_irda *si, struct net_device *dev
  */
 static void sa1100_irda_fir_irq(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 
 	/*
 	 * Stop RX DMA
@@ -582,7 +582,7 @@ static void sa1100_irda_fir_irq(struct net_device *dev)
 static irqreturn_t sa1100_irda_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	if (IS_FIR(((struct sa1100_irda *)dev->priv)))
+	if (IS_FIR(((struct sa1100_irda *)netdev_priv(dev))))
 		sa1100_irda_fir_irq(dev);
 	else
 		sa1100_irda_hpsir_irq(dev);
@@ -595,7 +595,7 @@ static irqreturn_t sa1100_irda_irq(int irq, void *dev_id)
 static void sa1100_irda_txdma_irq(void *id)
 {
 	struct net_device *dev = id;
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	struct sk_buff *skb = si->txskb;
 
 	si->txskb = NULL;
@@ -649,7 +649,7 @@ static void sa1100_irda_txdma_irq(void *id)
 
 static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int speed = irda_get_next_speed(skb);
 
 	/*
@@ -724,7 +724,7 @@ static int
 sa1100_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 {
 	struct if_irda_req *rq = (struct if_irda_req *)ifreq;
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int ret = -EOPNOTSUPP;
 
 	switch (cmd) {
@@ -766,13 +766,13 @@ sa1100_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 
 static struct net_device_stats *sa1100_irda_stats(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	return &si->stats;
 }
 
 static int sa1100_irda_start(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int err;
 
 	si->speed = 9600;
@@ -835,7 +835,7 @@ err_irq:
 
 static int sa1100_irda_stop(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 
 	disable_irq(dev->irq);
 	sa1100_irda_shutdown(si);
@@ -908,7 +908,7 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 	if (!dev)
 		goto err_mem_4;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
@@ -987,7 +987,7 @@ static int sa1100_irda_remove(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (dev) {
-		struct sa1100_irda *si = dev->priv;
+		struct sa1100_irda *si = netdev_priv(dev);
 		unregister_netdev(dev);
 		kfree(si->tx_buff.head);
 		kfree(si->rx_buff.head);
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 3f32909..ceef040 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -584,14 +584,14 @@ EXPORT_SYMBOL(sirdev_receive);
 
 static struct net_device_stats *sirdev_get_stats(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 
 	return (dev) ? &dev->stats : NULL;
 }
 
 static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	unsigned long flags;
 	int actual = 0;
 	int err;
@@ -683,7 +683,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 static int sirdev_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct if_irda_req *irq = (struct if_irda_req *) rq;
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
@@ -795,7 +795,7 @@ static void sirdev_free_buffers(struct sir_dev *dev)
 
 static int sirdev_open(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	const struct sir_driver *drv = dev->drv;
 
 	if (!drv)
@@ -840,7 +840,7 @@ errout_dec:
 
 static int sirdev_close(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	const struct sir_driver *drv;
 
 //	IRDA_DEBUG(0, "%s\n", __func__);
@@ -896,7 +896,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __func__);
 		goto out;
 	}
-	dev = ndev->priv;
+	dev = netdev_priv(ndev);
 
 	irda_init_max_qos_capabilies(&dev->qos);
 	dev->qos.baud_rate.bits = IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 84e609e..74c78cf 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -334,7 +334,7 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	if (dev == NULL) 
 		return -ENOMEM;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
 
@@ -824,7 +824,7 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	u16 iobase;
 	__u32 speed;
 
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
 
@@ -896,7 +896,7 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	__u32 speed;
 	unsigned long flags;
 
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	if (self->st_fifo.len)
@@ -1349,7 +1349,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct via_ircc_cb *self = dev->priv;
+	struct via_ircc_cb *self = netdev_priv(dev);
 	int iobase;
 	u8 iHostIntType, iRxIntType, iTxIntType;
 
@@ -1522,7 +1522,7 @@ static int via_ircc_net_open(struct net_device *dev)
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	self->stats.rx_packets = 0;
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
@@ -1589,7 +1589,7 @@ static int via_ircc_net_close(struct net_device *dev)
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -1628,7 +1628,7 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
 		   cmd);
@@ -1663,7 +1663,7 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 static struct net_device_stats *via_ircc_net_get_stats(struct net_device
 						       *dev)
 {
-	struct via_ircc_cb *self = (struct via_ircc_cb *) dev->priv;
+	struct via_ircc_cb *self = netdev_priv(dev);
 
 	return &self->stats;
 }
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 18f4b3a..1e205cc 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -178,7 +178,7 @@ static void vlsi_proc_pdev(struct seq_file *seq, struct pci_dev *pdev)
 		
 static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	u8 byte;
 	u16 word;
 	unsigned delta1, delta2;
@@ -346,7 +346,7 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
 static int vlsi_seq_show(struct seq_file *seq, void *v)
 {
 	struct net_device *ndev = seq->private;
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned long flags;
 
 	seq_printf(seq, "\n%s %s\n\n", DRIVER_NAME, DRIVER_VERSION);
@@ -543,7 +543,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	struct sk_buff	*skb;
 	int		ret = 0;
 	struct net_device *ndev = (struct net_device *)pci_get_drvdata(r->pdev);
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
 	/* dma buffer now owned by the CPU */
@@ -638,7 +638,7 @@ static void vlsi_fill_rx(struct vlsi_ring *r)
 
 static void vlsi_rx_interrupt(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring *r = idev->rx_ring;
 	struct ring_descr *rd;
 	int ret;
@@ -856,7 +856,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 
 static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring	*r = idev->tx_ring;
 	struct ring_descr *rd;
 	unsigned long flags;
@@ -1063,7 +1063,7 @@ drop:
 
 static void vlsi_tx_interrupt(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring	*r = idev->tx_ring;
 	struct ring_descr	*rd;
 	unsigned	iobase;
@@ -1262,7 +1262,7 @@ static inline void vlsi_clear_regs(unsigned iobase)
 static int vlsi_init_chip(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned	iobase;
 	u16 ptr;
 
@@ -1376,14 +1376,14 @@ static int vlsi_stop_hw(vlsi_irda_dev_t *idev)
 
 static struct net_device_stats * vlsi_get_stats(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	return &idev->stats;
 }
 
 static void vlsi_tx_timeout(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 
 	vlsi_reg_debug(ndev->base_addr, __func__);
@@ -1408,7 +1408,7 @@ static void vlsi_tx_timeout(struct net_device *ndev)
 
 static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct if_irda_req *irq = (struct if_irda_req *) rq;
 	unsigned long flags;
 	u16 fifocnt;
@@ -1458,7 +1458,7 @@ static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned	iobase;
 	u8		irintr;
 	int 		boguscount = 5;
@@ -1499,7 +1499,7 @@ static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 
 static int vlsi_open(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	int	err = -EAGAIN;
 	char	hwname[32];
 
@@ -1558,7 +1558,7 @@ errout:
 
 static int vlsi_close(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	netif_stop_queue(ndev);
 
@@ -1581,7 +1581,7 @@ static int vlsi_close(struct net_device *ndev)
 
 static int vlsi_irda_init(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct pci_dev *pdev = idev->pdev;
 
 	ndev->irq = pdev->irq;
@@ -1656,7 +1656,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_disable;
 	}
 
-	idev = ndev->priv;
+	idev = netdev_priv(ndev);
 
 	spin_lock_init(&idev->lock);
 	mutex_init(&idev->mtx);
@@ -1713,7 +1713,7 @@ static void __devexit vlsi_irda_remove(struct pci_dev *pdev)
 
 	unregister_netdev(ndev);
 
-	idev = ndev->priv;
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (idev->proc_entry) {
 		remove_proc_entry(ndev->name, vlsi_proc_root);
@@ -1748,7 +1748,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 			   __func__, pci_name(pdev));
 		return 0;
 	}
-	idev = ndev->priv;	
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state != 0) {			/* already suspended */
 		if (state.event > pdev->current_state) {	/* simply go deeper */
@@ -1787,7 +1787,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 			   __func__, pci_name(pdev));
 		return 0;
 	}
-	idev = ndev->priv;	
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state == 0) {
 		mutex_unlock(&idev->mtx);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 002a6d7..e178452 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -178,7 +178,7 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 		goto err_out;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	spin_lock_init(&self->lock);
    
 
@@ -497,7 +497,7 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u8 set;
 	int mtt;
 	
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 
 	iobase = self->io.fir_base;
 
@@ -1119,7 +1119,7 @@ static irqreturn_t w83977af_interrupt(int irq, void *dev_id)
 	__u8 set, icr, isr;
 	int iobase;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	iobase = self->io.fir_base;
 
@@ -1192,7 +1192,7 @@ static int w83977af_net_open(struct net_device *dev)
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1256,7 +1256,7 @@ static int w83977af_net_close(struct net_device *dev)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1303,7 +1303,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -1339,7 +1339,7 @@ out:
 
 static struct net_device_stats *w83977af_net_get_stats(struct net_device *dev)
 {
-	struct w83977af_ir *self = (struct w83977af_ir *) dev->priv;
+	struct w83977af_ir *self = netdev_priv(dev);
 	
 	return &self->stats;
 }



