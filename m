From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [KJ] [Patch] convert drivers/net to kzalloc/kcalloc
Date: Tue, 04 Apr 2006 18:39:27 +0200
Message-ID: <1144168767.11325.5.camel@alice>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============05565745605062844=="
Cc: netdev@vger.kernel.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel-janitors@lists.osdl.org
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============05565745605062844==
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hi,

this patch converts drivers/net to kzalloc and kcalloc usage.
Compile tested with allyesconfig on i386

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.17-rc1/drivers/net/bonding/bond_main.c.orig	2006-04-04 12:12:12.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/bonding/bond_main.c	2006-04-04 12:12:40.000000000 +0200
@@ -1323,14 +1323,12 @@ int bond_enslave(struct net_device *bond
 		goto err_undo_flags;
 	}
 
-	new_slave = kmalloc(sizeof(struct slave), GFP_KERNEL);
+	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
 		res = -ENOMEM;
 		goto err_undo_flags;
 	}
 
-	memset(new_slave, 0, sizeof(struct slave));
-
 	/* save slave's original flags before calling
 	 * netdev_set_master and dev_open
 	 */
--- linux-2.6.17-rc1/drivers/net/chelsio/mv88x201x.c.orig	2006-04-04 12:13:03.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/chelsio/mv88x201x.c	2006-04-04 12:13:13.000000000 +0200
@@ -205,11 +205,10 @@ static struct cphy *mv88x201x_phy_create
 					 struct mdio_ops *mdio_ops)
 {
 	u32 val;
-	struct cphy *cphy = kmalloc(sizeof(*cphy), GFP_KERNEL);
+	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
 	if (!cphy)
 		return NULL;
-	memset(cphy, 0, sizeof(*cphy));
 	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);
 
 	/* Commands the PHY to enable XFP's clock. */
--- linux-2.6.17-rc1/drivers/net/chelsio/sge.c.orig	2006-04-04 12:13:46.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/chelsio/sge.c	2006-04-04 12:14:43.000000000 +0200
@@ -336,10 +336,9 @@ static int alloc_rx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct freelQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -464,10 +463,9 @@ static int alloc_tx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct cmdQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -1648,11 +1646,10 @@ static void espibug_workaround(void *dat
 struct sge * __devinit t1_sge_create(struct adapter *adapter,
 				     struct sge_params *p)
 {
-	struct sge *sge = kmalloc(sizeof(*sge), GFP_KERNEL);
+	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
 
 	if (!sge)
 		return NULL;
-	memset(sge, 0, sizeof(*sge));
 
 	sge->adapter = adapter;
 	sge->netdev = adapter->port[0].dev;
--- linux-2.6.17-rc1/drivers/net/e100.c.orig	2006-04-04 12:14:56.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/e100.c	2006-04-04 12:16:11.000000000 +0200
@@ -1931,9 +1931,8 @@ static int e100_rx_alloc_list(struct nic
 	nic->rx_to_use = nic->rx_to_clean = NULL;
 	nic->ru_running = RU_UNINITIALIZED;
 
-	if(!(nic->rxs = kmalloc(sizeof(struct rx) * count, GFP_ATOMIC)))
+	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
 		return -ENOMEM;
-	memset(nic->rxs, 0, sizeof(struct rx) * count);
 
 	for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 		rx->next = (i + 1 < count) ? rx + 1 : nic->rxs;
--- linux-2.6.17-rc1/drivers/net/e1000/e1000_ethtool.c.orig	2006-04-04 12:16:24.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/e1000/e1000_ethtool.c	2006-04-04 12:18:47.000000000 +0200
@@ -636,20 +636,18 @@ e1000_set_ringparam(struct net_device *n
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	adapter->tx_ring = kmalloc(tx_ring_size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(tx_ring_size, GFP_KERNEL);
 	if (!adapter->tx_ring) {
 		err = -ENOMEM;
 		goto err_setup_rx;
 	}
-	memset(adapter->tx_ring, 0, tx_ring_size);
 
-	adapter->rx_ring = kmalloc(rx_ring_size, GFP_KERNEL);
+	adapter->rx_ring = kzalloc(rx_ring_size, GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		err = -ENOMEM;
 		goto err_setup_rx;
 	}
-	memset(adapter->rx_ring, 0, rx_ring_size);
 
 	txdr = adapter->tx_ring;
 	rxdr = adapter->rx_ring;
@@ -1013,11 +1011,10 @@ e1000_setup_desc_rings(struct e1000_adap
 		txdr->count = E1000_DEFAULT_TXD;
 
 	size = txdr->count * sizeof(struct e1000_buffer);
-	if (!(txdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(txdr->buffer_info = kzalloc(size, GFP_KERNEL))) {
 		ret_val = 1;
 		goto err_nomem;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	E1000_ROUNDUP(txdr->size, 4096);
@@ -1069,11 +1066,10 @@ e1000_setup_desc_rings(struct e1000_adap
 		rxdr->count = E1000_DEFAULT_RXD;
 
 	size = rxdr->count * sizeof(struct e1000_buffer);
-	if (!(rxdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(rxdr->buffer_info = kzalloc(size, GFP_KERNEL))) {
 		ret_val = 4;
 		goto err_nomem;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
 	if (!(rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma))) {
--- linux-2.6.17-rc1/drivers/net/e1000/e1000_main.c.orig	2006-04-04 12:18:56.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/e1000/e1000_main.c	2006-04-04 12:47:47.000000000 +0200
@@ -1055,28 +1055,25 @@ e1000_alloc_queues(struct e1000_adapter 
 	int size;
 
 	size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
-	adapter->tx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(size, GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
-	memset(adapter->tx_ring, 0, size);
 
 	size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
-	adapter->rx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->rx_ring = kzalloc(size, GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->rx_ring, 0, size);
 
 #ifdef CONFIG_E1000_NAPI
 	size = sizeof(struct net_device) * adapter->num_rx_queues;
-	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+	adapter->polling_netdev = kzalloc(size, GFP_KERNEL);
 	if (!adapter->polling_netdev) {
 		kfree(adapter->tx_ring);
 		kfree(adapter->rx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->polling_netdev, 0, size);
 #endif
 
 	return E1000_SUCCESS;
@@ -1450,17 +1447,16 @@ e1000_setup_rx_resources(struct e1000_ad
 	memset(rxdr->buffer_info, 0, size);
 
 	size = sizeof(struct e1000_ps_page) * rxdr->count;
-	rxdr->ps_page = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page = kzalloc(size, GFP_KERNEL);
 	if (!rxdr->ps_page) {
 		vfree(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page, 0, size);
 
 	size = sizeof(struct e1000_ps_page_dma) * rxdr->count;
-	rxdr->ps_page_dma = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page_dma = kzalloc(size, GFP_KERNEL);
 	if (!rxdr->ps_page_dma) {
 		vfree(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
@@ -1468,7 +1464,6 @@ e1000_setup_rx_resources(struct e1000_ad
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page_dma, 0, size);
 
 	if (adapter->hw.mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
--- linux-2.6.17-rc1/drivers/net/fs_enet/fs_enet-mii.c.orig	2006-04-04 12:20:25.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/fs_enet/fs_enet-mii.c	2006-04-04 12:20:36.000000000 +0200
@@ -389,12 +389,11 @@ static struct fs_enet_mii_bus *create_bu
 	struct fs_enet_mii_bus *bus;
 	int ret = 0;
 
-	bus = kmalloc(sizeof(*bus), GFP_KERNEL);
+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
 	if (bus == NULL) {
 		ret = -ENOMEM;
 		goto err;
 	}
-	memset(bus, 0, sizeof(*bus));
 	spin_lock_init(&bus->mii_lock);
 	bus->bus_info = bi;
 	bus->refs = 0;
--- linux-2.6.17-rc1/drivers/net/irda/irda-usb.c.orig	2006-04-04 12:20:47.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/irda/irda-usb.c	2006-04-04 12:21:17.000000000 +0200
@@ -1344,10 +1344,9 @@ static inline struct irda_class_desc *ir
 	struct irda_class_desc *desc;
 	int ret;
 
-	desc = kmalloc(sizeof (*desc), GFP_KERNEL);
+	desc = kzalloc(sizeof (*desc), GFP_KERNEL);
 	if (desc == NULL) 
 		return NULL;
-	memset(desc, 0, sizeof(*desc));
 
 	/* USB-IrDA class spec 1.0:
 	 *	6.1.3: Standard "Get Descriptor" Device Request is not
@@ -1496,12 +1495,10 @@ static int irda_usb_probe(struct usb_int
 	/* Don't change this buffer size and allocation without doing
 	 * some heavy and complete testing. Don't ask why :-(
 	 * Jean II */
-	self->speed_buff = (char *) kmalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
+	self->speed_buff = kzalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
 	if (self->speed_buff == NULL) 
 		goto err_out_3;
 
-	memset(self->speed_buff, 0, IRDA_USB_SPEED_MTU);
-
 	ret = irda_usb_open(self);
 	if (ret) 
 		goto err_out_4;
--- linux-2.6.17-rc1/drivers/net/irda/irtty-sir.c.orig	2006-04-04 12:21:43.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/irda/irtty-sir.c	2006-04-04 12:22:01.000000000 +0200
@@ -505,10 +505,9 @@ static int irtty_open(struct tty_struct 
 	}
 
 	/* allocate private device info block */
-	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		goto out_put;
-	memset(priv, 0, sizeof(*priv));
 
 	priv->magic = IRTTY_MAGIC;
 	priv->tty = tty;
--- linux-2.6.17-rc1/drivers/net/irda/vlsi_ir.c.orig	2006-04-04 12:22:11.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/irda/vlsi_ir.c	2006-04-04 12:22:53.000000000 +0200
@@ -413,10 +413,9 @@ static struct vlsi_ring *vlsi_alloc_ring
 	if (!size  ||  ((size-1)&size)!=0)	/* must be >0 and power of 2 */
 		return NULL;
 
-	r = kmalloc(sizeof(*r) + size * sizeof(struct ring_descr), GFP_KERNEL);
+	r = kzalloc(sizeof(*r) + size * sizeof(struct ring_descr), GFP_KERNEL);
 	if (!r)
 		return NULL;
-	memset(r, 0, sizeof(*r));
 
 	r->pdev = pdev;
 	r->dir = dir;
@@ -429,7 +428,6 @@ static struct vlsi_ring *vlsi_alloc_ring
 
 	for (i = 0; i < size; i++) {
 		rd = r->rd + i;
-		memset(rd, 0, sizeof(*rd));
 		rd->hw = hwmap + i;
 		rd->buf = kmalloc(len, GFP_KERNEL|GFP_DMA);
 		if (rd->buf == NULL
--- linux-2.6.17-rc1/drivers/net/iseries_veth.c.orig	2006-04-04 12:23:08.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/iseries_veth.c	2006-04-04 12:23:49.000000000 +0200
@@ -820,10 +820,9 @@ static int veth_init_connection(u8 rlp)
 	     || ! HvLpConfig_doLpsCommunicateOnVirtualLan(this_lp, rlp) )
 		return 0;
 
-	cnx = kmalloc(sizeof(*cnx), GFP_KERNEL);
+	cnx = kzalloc(sizeof(*cnx), GFP_KERNEL);
 	if (! cnx)
 		return -ENOMEM;
-	memset(cnx, 0, sizeof(*cnx));
 
 	cnx->remote_lp = rlp;
 	spin_lock_init(&cnx->lock);
@@ -850,14 +849,13 @@ static int veth_init_connection(u8 rlp)
 	if (rc != 0)
 		return rc;
 
-	msgs = kmalloc(VETH_NUMBUFFERS * sizeof(struct veth_msg), GFP_KERNEL);
+	msgs = kzalloc(VETH_NUMBUFFERS * sizeof(struct veth_msg), GFP_KERNEL);
 	if (! msgs) {
 		veth_error("Can't allocate buffers for LPAR %d.\n", rlp);
 		return -ENOMEM;
 	}
 
 	cnx->msgs = msgs;
-	memset(msgs, 0, VETH_NUMBUFFERS * sizeof(struct veth_msg));
 
 	for (i = 0; i < VETH_NUMBUFFERS; i++) {
 		msgs[i].token = i;
--- linux-2.6.17-rc1/drivers/net/lance.c.orig	2006-04-04 12:23:57.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/lance.c	2006-04-04 12:24:19.000000000 +0200
@@ -532,11 +532,10 @@ static int __init lance_probe1(struct ne
 	dev->base_addr = ioaddr;
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
 		
-	lp = kmalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
+	lp = kzalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
 	if(lp==NULL)
 		return -ENODEV;
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
-	memset(lp, 0, sizeof(*lp));
 	dev->priv = lp;
 	lp->name = chipname;
 	lp->rx_buffs = (unsigned long)kmalloc(PKT_BUF_SZ*RX_RING_SIZE,
--- linux-2.6.17-rc1/drivers/net/loopback.c.orig	2006-04-04 12:24:31.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/loopback.c	2006-04-04 12:24:49.000000000 +0200
@@ -224,9 +224,8 @@ int __init loopback_init(void)
 	struct net_device_stats *stats;
 
 	/* Can survive without statistics */
-	stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
+	stats = kzalloc(sizeof(struct net_device_stats), GFP_KERNEL);
 	if (stats) {
-		memset(stats, 0, sizeof(struct net_device_stats));
 		loopback_dev.priv = stats;
 		loopback_dev.get_stats = &get_stats;
 	}
--- linux-2.6.17-rc1/drivers/net/mipsnet.c.orig	2006-04-04 12:24:58.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/mipsnet.c	2006-04-04 12:25:08.000000000 +0200
@@ -323,12 +323,11 @@ static int __init mipsnet_init_module(vo
 		goto out;
 	}
 
-        if (!(pldev = kmalloc (sizeof (*pldev), GFP_KERNEL))) {
+        if (!(pldev = kzalloc (sizeof (*pldev), GFP_KERNEL))) {
 		err = -ENOMEM;
 		goto out_unregister_driver;
 	}
 
-	memset (pldev, 0, sizeof (*pldev));
 	pldev->name		= mipsnet_string;
 	pldev->id		= 0;
 	pldev->dev.release	= mipsnet_platform_release;
--- linux-2.6.17-rc1/drivers/net/pcmcia/ibmtr_cs.c.orig	2006-04-04 12:25:34.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/pcmcia/ibmtr_cs.c	2006-04-04 12:25:43.000000000 +0200
@@ -146,9 +146,8 @@ static int ibmtr_attach(struct pcmcia_de
     DEBUG(0, "ibmtr_attach()\n");
 
     /* Create new token-ring device */
-    info = kmalloc(sizeof(*info), GFP_KERNEL); 
+    info = kzalloc(sizeof(*info), GFP_KERNEL); 
     if (!info) return -ENOMEM;
-    memset(info,0,sizeof(*info));
     dev = alloc_trdev(sizeof(struct tok_info));
     if (!dev) {
 	kfree(info);
--- linux-2.6.17-rc1/drivers/net/ppp_async.c.orig	2006-04-04 12:25:57.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/ppp_async.c	2006-04-04 12:26:06.000000000 +0200
@@ -159,12 +159,11 @@ ppp_asynctty_open(struct tty_struct *tty
 	int err;
 
 	err = -ENOMEM;
-	ap = kmalloc(sizeof(*ap), GFP_KERNEL);
+	ap = kzalloc(sizeof(*ap), GFP_KERNEL);
 	if (ap == 0)
 		goto out;
 
 	/* initialize the asyncppp structure */
-	memset(ap, 0, sizeof(*ap));
 	ap->tty = tty;
 	ap->mru = PPP_MRU;
 	spin_lock_init(&ap->xmit_lock);
--- linux-2.6.17-rc1/drivers/net/ppp_deflate.c.orig	2006-04-04 12:26:14.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/ppp_deflate.c	2006-04-04 12:26:50.000000000 +0200
@@ -121,12 +121,10 @@ static void *z_comp_alloc(unsigned char 
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
 		return NULL;
 
-	state = (struct ppp_deflate_state *) kmalloc(sizeof(*state),
-						     GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		return NULL;
 
-	memset (state, 0, sizeof (struct ppp_deflate_state));
 	state->strm.next_in   = NULL;
 	state->w_size         = w_size;
 	state->strm.workspace = vmalloc(zlib_deflate_workspacesize());
@@ -341,11 +339,10 @@ static void *z_decomp_alloc(unsigned cha
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
 		return NULL;
 
-	state = (struct ppp_deflate_state *) kmalloc(sizeof(*state), GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		return NULL;
 
-	memset (state, 0, sizeof (struct ppp_deflate_state));
 	state->w_size         = w_size;
 	state->strm.next_out  = NULL;
 	state->strm.workspace = kmalloc(zlib_inflate_workspacesize(),
--- linux-2.6.17-rc1/drivers/net/ppp_generic.c.orig	2006-04-04 12:26:58.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/ppp_generic.c	2006-04-04 12:27:59.000000000 +0200
@@ -2006,10 +2006,9 @@ ppp_register_channel(struct ppp_channel 
 {
 	struct channel *pch;
 
-	pch = kmalloc(sizeof(struct channel), GFP_KERNEL);
+	pch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (pch == 0)
 		return -ENOMEM;
-	memset(pch, 0, sizeof(struct channel));
 	pch->ppp = NULL;
 	pch->chan = chan;
 	chan->ppp = pch;
@@ -2419,13 +2418,12 @@ ppp_create_interface(int unit, int *retp
 	int ret = -ENOMEM;
 	int i;
 
-	ppp = kmalloc(sizeof(struct ppp), GFP_KERNEL);
+	ppp = kzalloc(sizeof(struct ppp), GFP_KERNEL);
 	if (!ppp)
 		goto out;
 	dev = alloc_netdev(0, "", ppp_setup);
 	if (!dev)
 		goto out1;
-	memset(ppp, 0, sizeof(struct ppp));
 
 	ppp->mru = PPP_MRU;
 	init_ppp_file(&ppp->file, INTERFACE);
@@ -2717,8 +2715,7 @@ static void cardmap_set(struct cardmap *
 	if (p == NULL || (nr >> p->shift) >= CARDMAP_WIDTH) {
 		do {
 			/* need a new top level */
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
 			np->ptr[0] = p;
 			if (p != NULL) {
 				np->shift = p->shift + CARDMAP_ORDER;
@@ -2732,8 +2729,7 @@ static void cardmap_set(struct cardmap *
 	while (p->shift > 0) {
 		i = (nr >> p->shift) & CARDMAP_MASK;
 		if (p->ptr[i] == NULL) {
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
 			np->shift = p->shift - CARDMAP_ORDER;
 			np->parent = p;
 			p->ptr[i] = np;
--- linux-2.6.17-rc1/drivers/net/ppp_mppe.c.orig	2006-04-04 12:28:10.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/ppp_mppe.c	2006-04-04 12:28:24.000000000 +0200
@@ -191,12 +191,10 @@ static void *mppe_alloc(unsigned char *o
 	    || options[0] != CI_MPPE || options[1] != CILEN_MPPE)
 		goto out;
 
-	state = (struct ppp_mppe_state *) kmalloc(sizeof(*state), GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		goto out;
 
-	memset(state, 0, sizeof(*state));
-
 	state->arc4 = crypto_alloc_tfm("arc4", 0);
 	if (!state->arc4)
 		goto out_free;
--- linux-2.6.17-rc1/drivers/net/ppp_synctty.c.orig	2006-04-04 12:28:31.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/ppp_synctty.c	2006-04-04 12:28:47.000000000 +0200
@@ -207,13 +207,12 @@ ppp_sync_open(struct tty_struct *tty)
 	struct syncppp *ap;
 	int err;
 
-	ap = kmalloc(sizeof(*ap), GFP_KERNEL);
+	ap = kzalloc(sizeof(*ap), GFP_KERNEL);
 	err = -ENOMEM;
 	if (ap == 0)
 		goto out;
 
 	/* initialize the syncppp structure */
-	memset(ap, 0, sizeof(*ap));
 	ap->tty = tty;
 	ap->mru = PPP_MRU;
 	spin_lock_init(&ap->xmit_lock);
--- linux-2.6.17-rc1/drivers/net/s2io.c.orig	2006-04-04 12:28:55.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/s2io.c	2006-04-04 12:29:56.000000000 +0200
@@ -407,14 +407,13 @@ static int init_shared_mem(struct s2io_n
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int fifo_len = config->tx_cfg[i].fifo_len;
 		int list_holder_size = fifo_len * sizeof(list_info_hold_t);
-		mac_control->fifos[i].list_info = kmalloc(list_holder_size,
+		mac_control->fifos[i].list_info = kzalloc(list_holder_size,
 							  GFP_KERNEL);
 		if (!mac_control->fifos[i].list_info) {
 			DBG_PRINT(ERR_DBG,
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
-		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
@@ -3229,24 +3228,21 @@ static int s2io_enable_msi_x(nic_t *nic)
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 
-	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
+	nic->entries = kzalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		return -ENOMEM;
 	}
-	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
-		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
+		kzalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		kfree(nic->entries);
 		return -ENOMEM;
 	}
-	memset(nic->s2io_entries, 0,
-	       MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
 	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
 		nic->entries[i].entry = i;
--- linux-2.6.17-rc1/drivers/net/sb1250-mac.c.orig	2006-04-04 12:30:04.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/sb1250-mac.c	2006-04-04 12:30:51.000000000 +0200
@@ -757,9 +757,8 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 */
 
 	d->sbdma_ctxtable = (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
-
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+		kcalloc(d->sbdma_maxdescr, sizeof(struct sk_buff *),
+		GFP_KERNEL);
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*
--- linux-2.6.17-rc1/drivers/net/shaper.c.orig	2006-04-04 12:31:00.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/shaper.c	2006-04-04 12:31:10.000000000 +0200
@@ -601,10 +601,9 @@ static int __init shaper_init(void)
 		return -ENODEV;
 
 	alloc_size = sizeof(*dev) * shapers;
-	devs = kmalloc(alloc_size, GFP_KERNEL);
+	devs = kzalloc(alloc_size, GFP_KERNEL);
 	if (!devs)
 		return -ENOMEM;
-	memset(devs, 0, alloc_size);
 
 	for (i = 0; i < shapers; i++) {
 
--- linux-2.6.17-rc1/drivers/net/slhc.c.orig	2006-04-04 12:31:21.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/slhc.c	2006-04-04 12:31:56.000000000 +0200
@@ -95,27 +95,23 @@ slhc_init(int rslots, int tslots)
 	register struct cstate *ts;
 	struct slcompress *comp;
 
-	comp = (struct slcompress *)kmalloc(sizeof(struct slcompress),
-					    GFP_KERNEL);
+	comp = kzalloc(sizeof(struct slcompress), GFP_KERNEL);
 	if (! comp)
 		goto out_fail;
-	memset(comp, 0, sizeof(struct slcompress));
 
 	if ( rslots > 0  &&  rslots < 256 ) {
 		size_t rsize = rslots * sizeof(struct cstate);
-		comp->rstate = (struct cstate *) kmalloc(rsize, GFP_KERNEL);
+		comp->rstate = kzalloc(rsize, GFP_KERNEL);
 		if (! comp->rstate)
 			goto out_free;
-		memset(comp->rstate, 0, rsize);
 		comp->rslot_limit = rslots - 1;
 	}
 
 	if ( tslots > 0  &&  tslots < 256 ) {
 		size_t tsize = tslots * sizeof(struct cstate);
-		comp->tstate = (struct cstate *) kmalloc(tsize, GFP_KERNEL);
+		comp->tstate = kzalloc(tsize, GFP_KERNEL);
 		if (! comp->tstate)
 			goto out_free2;
-		memset(comp->tstate, 0, tsize);
 		comp->tslot_limit = tslots - 1;
 	}
 
--- linux-2.6.17-rc1/drivers/net/via-velocity.c.orig	2006-04-04 12:32:12.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/via-velocity.c	2006-04-04 12:32:45.000000000 +0200
@@ -1072,10 +1072,9 @@ static int velocity_init_rd_ring(struct 
 	unsigned int rsize = sizeof(struct velocity_rd_info) * 
 					vptr->options.numrx;
 
-	vptr->rd_info = kmalloc(rsize, GFP_KERNEL);
+	vptr->rd_info = kzalloc(rsize, GFP_KERNEL);
 	if(vptr->rd_info == NULL)
 		goto out;
-	memset(vptr->rd_info, 0, rsize);
 
 	vptr->rd_filled = vptr->rd_dirty = vptr->rd_curr = 0;
 
@@ -1146,14 +1145,13 @@ static int velocity_init_td_ring(struct 
 	for (j = 0; j < vptr->num_txq; j++) {
 		curr = vptr->td_pool_dma[j];
 
-		vptr->td_infos[j] = kmalloc(tsize, GFP_KERNEL);
+		vptr->td_infos[j] = kzalloc(tsize, GFP_KERNEL);
 		if(vptr->td_infos[j] == NULL)
 		{
 			while(--j >= 0)
 				kfree(vptr->td_infos[j]);
 			return -ENOMEM;
 		}
-		memset(vptr->td_infos[j], 0, tsize);
 
 		for (i = 0; i < vptr->options.numtx; i++, curr += sizeof(struct tx_desc)) {
 			td = &(vptr->td_rings[j][i]);
--- linux-2.6.17-rc1/drivers/net/wan/c101.c.orig	2006-04-04 12:32:57.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/c101.c	2006-04-04 12:33:08.000000000 +0200
@@ -309,12 +309,11 @@ static int __init c101_run(unsigned long
 		return -ENODEV;
 	}
 
-	card = kmalloc(sizeof(card_t), GFP_KERNEL);
+	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk(KERN_ERR "c101: unable to allocate memory\n");
 		return -ENOBUFS;
 	}
-	memset(card, 0, sizeof(card_t));
 
 	card->dev = alloc_hdlcdev(card);
 	if (!card->dev) {
--- linux-2.6.17-rc1/drivers/net/wan/cosa.c.orig	2006-04-04 12:33:19.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/cosa.c	2006-04-04 12:33:47.000000000 +0200
@@ -587,13 +587,12 @@ static int cosa_probe(int base, int irq,
 	sprintf(cosa->name, "cosa%d", cosa->num);
 
 	/* Initialize the per-channel data */
-	cosa->chan = kmalloc(sizeof(struct channel_data)*cosa->nchannels,
+	cosa->chan = kcalloc(cosa->nchannels, sizeof(struct channel_data),
 			     GFP_KERNEL);
 	if (!cosa->chan) {
 	        err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(cosa->chan, 0, sizeof(struct channel_data)*cosa->nchannels);
 	for (i=0; i<cosa->nchannels; i++) {
 		cosa->chan[i].cosa = cosa;
 		cosa->chan[i].num = i;
--- linux-2.6.17-rc1/drivers/net/wan/cycx_main.c.orig	2006-04-04 12:33:56.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/cycx_main.c	2006-04-04 12:34:20.000000000 +0200
@@ -114,13 +114,11 @@ static int __init cycx_init(void)
 	/* Verify number of cards and allocate adapter data space */
 	cycx_ncards = min_t(int, cycx_ncards, CYCX_MAX_CARDS);
 	cycx_ncards = max_t(int, cycx_ncards, 1);
-	cycx_card_array = kmalloc(sizeof(struct cycx_device) * cycx_ncards,
+	cycx_card_array = kcalloc(cycx_ncards, sizeof(struct cycx_device), 
 				  GFP_KERNEL);
 	if (!cycx_card_array)
 		goto out;
 
-	memset(cycx_card_array, 0, sizeof(struct cycx_device) * cycx_ncards);
-
 	/* Register adapters with WAN router */
 	for (cnt = 0; cnt < cycx_ncards; ++cnt) {
 		struct cycx_device *card = &cycx_card_array[cnt];
--- linux-2.6.17-rc1/drivers/net/wan/cycx_x25.c.orig	2006-04-04 12:34:28.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/cycx_x25.c	2006-04-04 12:34:51.000000000 +0200
@@ -376,11 +376,10 @@ static int cycx_wan_new_if(struct wan_de
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(struct cycx_x25_channel), GFP_KERNEL);
+	chan = kzalloc(sizeof(struct cycx_x25_channel), GFP_KERNEL);
 	if (!chan)
 		return -ENOMEM;
 
-	memset(chan, 0, sizeof(*chan));
 	strcpy(chan->name, conf->name);
 	chan->card = card;
 	chan->link = conf->port;
--- linux-2.6.17-rc1/drivers/net/wan/dscc4.c.orig	2006-04-04 12:35:00.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/dscc4.c	2006-04-04 12:35:34.000000000 +0200
@@ -890,12 +890,11 @@ static int dscc4_found1(struct pci_dev *
 	struct dscc4_dev_priv *root;
 	int i, ret = -ENOMEM;
 
-	root = kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
+	root = kcalloc(dev_per_card, sizeof(*root), GFP_KERNEL);
 	if (!root) {
 		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
 		goto err_out;
 	}
-	memset(root, 0, dev_per_card*sizeof(*root));
 
 	for (i = 0; i < dev_per_card; i++) {
 		root[i].dev = alloc_hdlcdev(root + i);
@@ -903,12 +902,11 @@ static int dscc4_found1(struct pci_dev *
 			goto err_free_dev;
 	}
 
-	ppriv = kmalloc(sizeof(*ppriv), GFP_KERNEL);
+	ppriv = kzalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
 		goto err_free_dev;
 	}
-	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
 
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
--- linux-2.6.17-rc1/drivers/net/wan/farsync.c.orig	2006-04-04 12:35:43.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/farsync.c	2006-04-04 12:35:54.000000000 +0200
@@ -2476,13 +2476,12 @@ fst_add_one(struct pci_dev *pdev, const 
 	}
 
 	/* Allocate driver private data */
-	card = kmalloc(sizeof (struct fst_card_info), GFP_KERNEL);
+	card = kzalloc(sizeof (struct fst_card_info), GFP_KERNEL);
 	if (card == NULL) {
 		printk_err("FarSync card found but insufficient memory for"
 			   " driver storage\n");
 		return -ENOMEM;
 	}
-	memset(card, 0, sizeof (struct fst_card_info));
 
 	/* Try to enable the device */
 	if ((err = pci_enable_device(pdev)) != 0) {
--- linux-2.6.17-rc1/drivers/net/wan/hdlc_fr.c.orig	2006-04-04 12:36:06.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/hdlc_fr.c	2006-04-04 12:36:21.000000000 +0200
@@ -159,11 +159,10 @@ static inline pvc_device* add_pvc(struct
 		pvc_p = &(*pvc_p)->next;
 	}
 
-	pvc = kmalloc(sizeof(pvc_device), GFP_ATOMIC);
+	pvc = kzalloc(sizeof(pvc_device), GFP_ATOMIC);
 	if (!pvc)
 		return NULL;
 
-	memset(pvc, 0, sizeof(pvc_device));
 	pvc->dlci = dlci;
 	pvc->master = dev;
 	pvc->next = *pvc_p;	/* Put it in the chain */
--- linux-2.6.17-rc1/drivers/net/wan/hostess_sv11.c.orig	2006-04-04 12:36:28.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/hostess_sv11.c	2006-04-04 12:36:46.000000000 +0200
@@ -231,11 +231,10 @@ static struct sv11_device *sv11_init(int
 		return NULL;
 	}
 	
-	sv=(struct sv11_device *)kmalloc(sizeof(struct sv11_device), GFP_KERNEL);
+	sv = kzalloc(sizeof(struct sv11_device), GFP_KERNEL);
 	if(!sv)
 		goto fail3;
 			
-	memset(sv, 0, sizeof(*sv));
 	sv->if_ptr=&sv->netdev;
 	
 	sv->netdev.dev = alloc_netdev(0, "hdlc%d", sv11_setup);
--- linux-2.6.17-rc1/drivers/net/wan/n2.c.orig	2006-04-04 12:36:55.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/n2.c	2006-04-04 12:37:02.000000000 +0200
@@ -351,12 +351,11 @@ static int __init n2_run(unsigned long i
 		return -ENODEV;
 	}
 
-	card = kmalloc(sizeof(card_t), GFP_KERNEL);
+	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk(KERN_ERR "n2: unable to allocate memory\n");
 		return -ENOBUFS;
 	}
-	memset(card, 0, sizeof(card_t));
 
 	card->ports[0].dev = alloc_hdlcdev(&card->ports[0]);
 	card->ports[1].dev = alloc_hdlcdev(&card->ports[1]);
--- linux-2.6.17-rc1/drivers/net/wan/sdla.c.orig	2006-04-04 12:37:10.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdla.c	2006-04-04 12:37:30.000000000 +0200
@@ -1203,10 +1203,9 @@ static int sdla_xfer(struct net_device *
 		
 	if (read)
 	{	
-		temp = kmalloc(mem.len, GFP_KERNEL);
+		temp = kzalloc(mem.len, GFP_KERNEL);
 		if (!temp)
 			return(-ENOMEM);
-		memset(temp, 0, mem.len);
 		sdla_read(dev, mem.addr, temp, mem.len);
 		if(copy_to_user(mem.data, temp, mem.len))
 		{
--- linux-2.6.17-rc1/drivers/net/wan/sdla_chdlc.c.orig	2006-04-04 12:37:38.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdla_chdlc.c	2006-04-04 12:37:56.000000000 +0200
@@ -679,13 +679,11 @@ static int new_if(struct wan_device* wan
 	}
 		
 	/* allocate and initialize private data */
-	chdlc_priv_area = kmalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
+	chdlc_priv_area = kzalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
 	
 	if(chdlc_priv_area == NULL) 
 		return -ENOMEM;
 
-	memset(chdlc_priv_area, 0, sizeof(chdlc_private_area_t));
-
 	chdlc_priv_area->card = card; 
 	chdlc_priv_area->common.sk = NULL;
 	chdlc_priv_area->common.func = NULL;	
--- linux-2.6.17-rc1/drivers/net/wan/sdla_fr.c.orig	2006-04-04 12:38:09.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdla_fr.c	2006-04-04 12:38:42.000000000 +0200
@@ -812,12 +812,11 @@ static int new_if(struct wan_device* wan
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(fr_channel_t), GFP_KERNEL);
+	chan = kzalloc(sizeof(fr_channel_t), GFP_KERNEL);
 
 	if (chan == NULL)
 		return -ENOMEM;
 
-	memset(chan, 0, sizeof(fr_channel_t));
 	strcpy(chan->name, conf->name);
 	chan->card = card;
 
@@ -1214,8 +1213,7 @@ static int if_open(struct net_device* de
 	INIT_WORK(&chan->common.wanpipe_work, (void *)fr_bh, dev);
 
 	/* Allocate and initialize BH circular buffer */
-	chan->bh_head = kmalloc((sizeof(bh_data_t)*MAX_BH_BUFF),GFP_ATOMIC);
-	memset(chan->bh_head,0,(sizeof(bh_data_t)*MAX_BH_BUFF));
+	chan->bh_head = kzalloc((sizeof(bh_data_t)*MAX_BH_BUFF),GFP_ATOMIC);
 	atomic_set(&chan->bh_buff_used, 0);
 
 	netif_start_queue(dev);
--- linux-2.6.17-rc1/drivers/net/wan/sdla_ppp.c.orig	2006-04-04 12:38:49.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdla_ppp.c	2006-04-04 12:39:19.000000000 +0200
@@ -528,13 +528,11 @@ static int new_if(struct wan_device *wan
 	}
 
 	/* allocate and initialize private data */
-	ppp_priv_area = kmalloc(sizeof(ppp_private_area_t), GFP_KERNEL);
+	ppp_priv_area = kzalloc(sizeof(ppp_private_area_t), GFP_KERNEL);
 	
 	if( ppp_priv_area == NULL )
 		return	-ENOMEM;
 	
-	memset(ppp_priv_area, 0, sizeof(ppp_private_area_t));
-	
 	ppp_priv_area->card = card; 
 	
 	/* initialize data */
--- linux-2.6.17-rc1/drivers/net/wan/sdla_x25.c.orig	2006-04-04 12:39:26.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdla_x25.c	2006-04-04 12:40:11.000000000 +0200
@@ -926,13 +926,11 @@ static int new_if(struct wan_device* wan
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(x25_channel_t), GFP_ATOMIC);
+	chan = kzalloc(sizeof(x25_channel_t), GFP_ATOMIC);
 	if (chan == NULL){
 		return -ENOMEM;
 	}
 	
-	memset(chan, 0, sizeof(x25_channel_t));
-
 	/* Bug Fix: Seg Err on PVC startup
 	 * It must be here since bind_lcn_to_dev expects 
 	 * it bellow */
@@ -1194,7 +1192,7 @@ static int if_open(struct net_device* de
 
 	/* Allocate and initialize BH circular buffer */
 	/* Add 1 to MAX_BH_BUFF so we don't have test with (MAX_BH_BUFF-1) */
-	chan->bh_head = kmalloc((sizeof(bh_data_t)*(MAX_BH_BUFF+1)),GFP_ATOMIC);
+	chan->bh_head = kzalloc((sizeof(bh_data_t)*(MAX_BH_BUFF+1)),GFP_ATOMIC);
 
 	if (chan->bh_head == NULL){
 		printk(KERN_INFO "%s: ERROR, failed to allocate memory ! BH_BUFFERS !\n",
@@ -1202,7 +1200,6 @@ static int if_open(struct net_device* de
 
 		return -ENOBUFS;
 	}
-	memset(chan->bh_head,0,(sizeof(bh_data_t)*(MAX_BH_BUFF+1)));
 	atomic_set(&chan->bh_buff_used, 0);
 
 	/* Increment the number of interfaces */
--- linux-2.6.17-rc1/drivers/net/wan/sdlamain.c.orig	2006-04-04 12:40:20.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sdlamain.c	2006-04-04 12:40:43.000000000 +0200
@@ -257,14 +257,12 @@ static int __init wanpipe_init(void)
 	}
 	
 	/* Verify number of cards and allocate adapter data space */
-	card_array = kmalloc(sizeof(sdla_t) * ncards, GFP_KERNEL);
+	card_array = kcalloc(ncards, sizeof(sdla_t), GFP_KERNEL);
 	if (card_array == NULL) {
 		destroy_workqueue(wanpipe_wq);
 		return -ENOMEM;
 	}
 
-	memset(card_array, 0, sizeof(sdla_t) * ncards);
-
 	/* Register adapters with WAN router */
 	for (cnt = 0; cnt < ncards; ++ cnt) {
 		sdla_t* card = &card_array[cnt];
--- linux-2.6.17-rc1/drivers/net/wan/sealevel.c.orig	2006-04-04 12:40:51.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/sealevel.c	2006-04-04 12:41:01.000000000 +0200
@@ -270,11 +270,10 @@ static __init struct slvl_board *slvl_in
 		return NULL;
 	}
 	
-	b = kmalloc(sizeof(struct slvl_board), GFP_KERNEL);
+	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
 	if(!b)
 		goto fail3;
 
-	memset(b, 0, sizeof(*b));
 	if (!(b->dev[0]= slvl_alloc(iobase, irq)))
 		goto fail2;
 
--- linux-2.6.17-rc1/drivers/net/wan/wanpipe_multppp.c.orig	2006-04-04 12:41:10.000000000 +0200
+++ linux-2.6.17-rc1/drivers/net/wan/wanpipe_multppp.c	2006-04-04 12:41:22.000000000 +0200
@@ -539,13 +539,11 @@ static int new_if(struct wan_device* wan
 	}
 		
 	/* allocate and initialize private data */
-	chdlc_priv_area = kmalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
+	chdlc_priv_area = kzalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
 	
 	if(chdlc_priv_area == NULL) 
 		return -ENOMEM;
 
-	memset(chdlc_priv_area, 0, sizeof(chdlc_private_area_t));
-
 	chdlc_priv_area->card = card; 
 
 	/* initialize data */



--===============05565745605062844==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============05565745605062844==--
