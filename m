From: Joe Perches <joe@perches.com>
Subject: [PATCH 8/8] wan: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:35 -0700
Message-ID: <5cf2455d1dc5fc426caddce617d1ba01f67d8c47.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/hostess_sv11.c |   11 +++---
 drivers/net/wan/lapbether.c    |   18 +++++-----
 drivers/net/wan/pc300_drv.c    |    4 ++-
 drivers/net/wan/sbni.c         |   67 +++++++++++++++++++---------------------
 drivers/net/wan/sealevel.c     |   11 +++---
 drivers/net/wan/x25_asy.c      |   47 ++++++++++++++--------------
 drivers/net/wan/z85230.c       |   34 ++++++++++----------
 7 files changed, 96 insertions(+), 96 deletions(-)

diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index e817583..3d80e42 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -20,6 +20,8 @@
  *	Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -192,8 +194,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	 */
 
 	if (!request_region(iobase, 8, "Comtrol SV11")) {
-		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n",
-		       iobase);
+		pr_warn("I/O 0x%X already in use\n", iobase);
 		return NULL;
 	}
 
@@ -221,7 +222,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 
 	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
 			"Hostess SV11", sv) < 0) {
-		printk(KERN_WARNING "hostess: IRQ %d already in use.\n", irq);
+		pr_warn("IRQ %d already in use\n", irq);
 		goto err_irq;
 	}
 
@@ -255,7 +256,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	 */
 
 	if (z8530_init(sv)) {
-		printk(KERN_ERR "Z8530 series device not found.\n");
+		pr_err("Z8530 series device not found\n");
 		enable_irq(irq);
 		goto free_dma;
 	}
@@ -282,7 +283,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	netdev->irq = irq;
 
 	if (register_hdlc_device(netdev)) {
-		printk(KERN_ERR "hostess: unable to register HDLC device.\n");
+		pr_err("unable to register HDLC device\n");
 		free_netdev(netdev);
 		goto free_dma;
 	}
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index eec463f..a817081 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -20,6 +20,8 @@
  *	2000-11-14	Henner Eisen	dev_hold/put, NETDEV_GOING_DOWN support
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -165,13 +167,11 @@ static netdev_tx_t lapbeth_xmit(struct sk_buff *skb,
 		break;
 	case X25_IFACE_CONNECT:
 		if ((err = lapb_connect_request(dev)) != LAPB_OK)
-			printk(KERN_ERR "lapbeth: lapb_connect_request "
-			       "error: %d\n", err);
+			pr_err("lapb_connect_request error: %d\n", err);
 		goto drop;
 	case X25_IFACE_DISCONNECT:
 		if ((err = lapb_disconnect_request(dev)) != LAPB_OK)
-			printk(KERN_ERR "lapbeth: lapb_disconnect_request "
-			       "err: %d\n", err);
+			pr_err("lapb_disconnect_request err: %d\n", err);
 		/* Fall thru */
 	default:
 		goto drop;
@@ -180,7 +180,7 @@ static netdev_tx_t lapbeth_xmit(struct sk_buff *skb,
 	skb_pull(skb, 1);
 
 	if ((err = lapb_data_request(dev, skb)) != LAPB_OK) {
-		printk(KERN_ERR "lapbeth: lapb_data_request error - %d\n", err);
+		pr_err("lapb_data_request error - %d\n", err);
 		goto drop;
 	}
 out:
@@ -220,7 +220,7 @@ static void lapbeth_connected(struct net_device *dev, int reason)
 	struct sk_buff *skb = dev_alloc_skb(1);
 
 	if (!skb) {
-		printk(KERN_ERR "lapbeth: out of memory\n");
+		pr_err("out of memory\n");
 		return;
 	}
 
@@ -237,7 +237,7 @@ static void lapbeth_disconnected(struct net_device *dev, int reason)
 	struct sk_buff *skb = dev_alloc_skb(1);
 
 	if (!skb) {
-		printk(KERN_ERR "lapbeth: out of memory\n");
+		pr_err("out of memory\n");
 		return;
 	}
 
@@ -277,7 +277,7 @@ static int lapbeth_open(struct net_device *dev)
 	int err;
 
 	if ((err = lapb_register(dev, &lapbeth_callbacks)) != LAPB_OK) {
-		printk(KERN_ERR "lapbeth: lapb_register error - %d\n", err);
+		pr_err("lapb_register error: %d\n", err);
 		return -ENODEV;
 	}
 
@@ -292,7 +292,7 @@ static int lapbeth_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if ((err = lapb_unregister(dev)) != LAPB_OK)
-		printk(KERN_ERR "lapbeth: lapb_unregister error - %d\n", err);
+		pr_err("lapb_unregister error: %d\n", err);
 
 	return 0;
 }
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 9617d3d..1eeedd6 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -212,6 +212,8 @@ static const char rcsid[] =
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -3242,7 +3244,7 @@ static inline void show_version(void)
 	rcsdate++;
 	tmp = strrchr(rcsdate, ' ');
 	*tmp = '\0';
-	printk(KERN_INFO "Cyclades-PC300 driver %s %s\n", rcsvers, rcsdate);
+	pr_info("Cyclades-PC300 driver %s %s\n", rcsvers, rcsdate);
 }				/* show_version */
 
 static const struct net_device_ops cpc_netdev_ops = {
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index cff13a9..40e95fa 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -37,6 +37,8 @@
  *	Known problem: this driver wasn't tested on multiprocessor machine.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/ptrace.h>
@@ -200,8 +202,8 @@ sbni_isa_probe( struct net_device  *dev )
 
 		return  0;
 	else {
-		printk( KERN_ERR "sbni: base address 0x%lx is busy, or adapter "
-			"is malfunctional!\n", dev->base_addr );
+		pr_err("base address 0x%lx is busy, or adapter is malfunctional!\n",
+		       dev->base_addr);
 		return  -ENODEV;
 	}
 }
@@ -226,7 +228,6 @@ static void __init sbni_devsetup(struct net_device *dev)
 int __init sbni_probe(int unit)
 {
 	struct net_device *dev;
-	static unsigned  version_printed __initdata = 0;
 	int err;
 
 	dev = alloc_netdev(sizeof(struct net_local), "sbni", sbni_devsetup);
@@ -250,8 +251,7 @@ int __init sbni_probe(int unit)
 		free_netdev(dev);
 		return err;
 	}
-	if( version_printed++ == 0 )
-		printk( KERN_INFO "%s", version );
+	pr_info_once("%s", version);
 	return 0;
 }
 
@@ -326,9 +326,9 @@ sbni_pci_probe( struct net_device  *dev )
 		}
 
 		if (pci_irq_line <= 0 || pci_irq_line >= nr_irqs)
-			printk( KERN_WARNING
-	"  WARNING: The PCI BIOS assigned this PCI card to IRQ %d, which is unlikely to work!.\n"
-	" You should use the PCI BIOS setup to assign a valid IRQ line.\n",
+			pr_warn(
+"WARNING: The PCI BIOS assigned this PCI card to IRQ %d, which is unlikely to work!.\n"
+"You should use the PCI BIOS setup to assign a valid IRQ line.\n",
 				pci_irq_line );
 
 		/* avoiding re-enable dual adapters */
@@ -372,8 +372,7 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 		outb( 0, ioaddr + CSR0 );
 
 		if( !irq ) {
-			printk( KERN_ERR "%s: can't detect device irq!\n",
-				dev->name );
+			pr_err("%s: can't detect device irq!\n", dev->name);
 			release_region( ioaddr, SBNI_IO_EXTENT );
 			return NULL;
 		}
@@ -386,7 +385,7 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 	/* Fill in sbni-specific dev fields. */
 	nl = netdev_priv(dev);
 	if( !nl ) {
-		printk( KERN_ERR "%s: unable to get memory!\n", dev->name );
+		pr_err("%s: unable to get memory!\n", dev->name);
 		release_region( ioaddr, SBNI_IO_EXTENT );
 		return NULL;
 	}
@@ -415,21 +414,21 @@ sbni_probe1( struct net_device  *dev,  unsigned long  ioaddr,  int  irq )
 	if( inb( ioaddr + CSR0 ) & 0x01 )
 		nl->state |= FL_SLOW_MODE;
 
-	printk( KERN_NOTICE "%s: ioaddr %#lx, irq %d, "
-		"MAC: 00:ff:01:%02x:%02x:%02x\n", 
-		dev->name, dev->base_addr, dev->irq,
-		((u8 *) dev->dev_addr) [3],
-		((u8 *) dev->dev_addr) [4],
-		((u8 *) dev->dev_addr) [5] );
+	pr_notice("%s: ioaddr %#lx, irq %d, MAC: 00:ff:01:%02x:%02x:%02x\n",
+		  dev->name, dev->base_addr, dev->irq,
+		  ((u8 *)dev->dev_addr)[3],
+		  ((u8 *)dev->dev_addr)[4],
+		  ((u8 *)dev->dev_addr)[5]);
 
-	printk( KERN_NOTICE "%s: speed %d, receive level ", dev->name,
-		( (nl->state & FL_SLOW_MODE)  ?  500000 : 2000000)
-		/ (1 << nl->csr1.rate) );
+	pr_notice("%s: speed %d",
+		  dev->name,
+		  ((nl->state & FL_SLOW_MODE) ? 500000 : 2000000)
+		  / (1 << nl->csr1.rate));
 
 	if( nl->delta_rxl == 0 )
-		printk( "0x%x (fixed)\n", nl->cur_rxl_index ); 
+		pr_cont(", receive level 0x%x (fixed)\n", nl->cur_rxl_index);
 	else
-		printk( "(auto)\n");
+		pr_cont(", receive level (auto)\n");
 
 #ifdef CONFIG_SBNI_MULTILINE
 	nl->master = dev;
@@ -568,7 +567,7 @@ handle_channel( struct net_device  *dev )
 		 */
 		csr0 = inb( ioaddr + CSR0 );
 		if( !(csr0 & TR_RDY)  ||  (csr0 & RC_RDY) )
-			printk( KERN_ERR "%s: internal error!\n", dev->name );
+			netdev_err(dev, "internal error!\n");
 
 		/* if state & FL_NEED_RESEND != 0 then tx_frameno != 0 */
 		if( req_ans  ||  nl->tx_frameno != 0 )
@@ -851,7 +850,7 @@ prepare_to_send( struct sk_buff  *skb,  struct net_device  *dev )
 
 	/* nl->tx_buf_p == NULL here! */
 	if( nl->tx_buf_p )
-		printk( KERN_ERR "%s: memory leak!\n", dev->name );
+		netdev_err(dev, "memory leak!\n");
 
 	nl->outpos = 0;
 	nl->state &= ~(FL_WAIT_ACK | FL_NEED_RESEND);
@@ -1179,16 +1178,15 @@ sbni_open( struct net_device  *dev )
 
 				((struct net_local *) (netdev_priv(*p)))
 					->second = dev;
-				printk( KERN_NOTICE "%s: using shared irq "
-					"with %s\n", dev->name, (*p)->name );
+				netdev_notice(dev, "using shared irq with %s\n",
+					      (*p)->name);
 				nl->state |= FL_SECONDARY;
 				goto  handler_attached;
 			}
 	}
 
 	if( request_irq(dev->irq, sbni_interrupt, IRQF_SHARED, dev->name, dev) ) {
-		printk( KERN_ERR "%s: unable to get IRQ %d.\n",
-			dev->name, dev->irq );
+		netdev_err(dev, "unable to get IRQ %d\n", dev->irq);
 		return  -EAGAIN;
 	}
 
@@ -1220,8 +1218,8 @@ sbni_close( struct net_device  *dev )
 	struct net_local  *nl = netdev_priv(dev);
 
 	if( nl->second  &&  nl->second->flags & IFF_UP ) {
-		printk( KERN_NOTICE "Secondary channel (%s) is active!\n",
-			nl->second->name );
+		netdev_notice(dev, "Secondary channel (%s) is active!\n",
+			      nl->second->name);
 		return  -EBUSY;
 	}
 
@@ -1363,8 +1361,8 @@ sbni_ioctl( struct net_device  *dev,  struct ifreq  *ifr,  int  cmd )
 			return -EFAULT;
 		slave_dev = dev_get_by_name(&init_net, slave_name );
 		if( !slave_dev  ||  !(slave_dev->flags & IFF_UP) ) {
-			printk( KERN_ERR "%s: trying to enslave non-active "
-				"device %s\n", dev->name, slave_name );
+			netdev_err(dev, "trying to enslave non-active device %s\n",
+				   slave_name);
 			return  -EPERM;
 		}
 
@@ -1417,8 +1415,7 @@ enslave( struct net_device  *dev,  struct net_device  *slave_dev )
 
 	spin_unlock( &snl->lock );
 	spin_unlock( &nl->lock );
-	printk( KERN_NOTICE "%s: slave device (%s) attached.\n",
-		dev->name, slave_dev->name );
+	netdev_notice(dev, "slave device (%s) attached\n", slave_dev->name);
 	return  0;
 }
 
@@ -1547,7 +1544,7 @@ sbni_setup( char  *p )
 				break;
 	}
 bad_param:
-	printk( KERN_ERR "Error in sbni kernel parameter!\n" );
+	pr_err("Error in sbni kernel parameter!\n");
 	return 0;
 }
 
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index e91457d..0b4fd05 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -12,6 +12,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -190,7 +192,7 @@ static int slvl_setup(struct slvl_device *sv, int iobase, int irq)
 	dev->irq = irq;
 
 	if (register_hdlc_device(dev)) {
-		printk(KERN_ERR "sealevel: unable to register HDLC device\n");
+		pr_err("unable to register HDLC device\n");
 		free_netdev(dev);
 		return -1;
 	}
@@ -215,8 +217,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	 */
 
 	if (!request_region(iobase, 8, "Sealevel 4021")) {
-		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n",
-		       iobase);
+		pr_warn("I/O 0x%X already in use\n", iobase);
 		return NULL;
 	}
 
@@ -267,7 +268,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 
 	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
 			"SeaLevel", dev) < 0) {
-		printk(KERN_WARNING "sealevel: IRQ %d already in use.\n", irq);
+		pr_warn("IRQ %d already in use\n", irq);
 		goto err_request_irq;
 	}
 
@@ -292,7 +293,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	 */
 
 	if (z8530_init(dev) != 0) {
-		printk(KERN_ERR "Z8530 series device not found.\n");
+		pr_err("Z8530 series device not found\n");
 		enable_irq(irq);
 		goto free_hw;
 	}
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 24297b2..46ceb3a 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -14,6 +14,8 @@
  *	2000-10-29	Henner Eisen	lapb_data_indication() return status.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 
 #include <asm/system.h>
@@ -96,7 +98,7 @@ static struct x25_asy *x25_asy_alloc(void)
 			x25_asy_devs[i] = dev;
 			return sl;
 		} else {
-			printk(KERN_WARNING "x25_asy_alloc() - register_netdev() failure.\n");
+			pr_warn("%s(): register_netdev() failure\n", __func__);
 			free_netdev(dev);
 		}
 	}
@@ -114,8 +116,7 @@ static void x25_asy_free(struct x25_asy *sl)
 	sl->xbuff = NULL;
 
 	if (!test_and_clear_bit(SLF_INUSE, &sl->flags))
-		printk(KERN_ERR "%s: x25_asy_free for already free unit.\n",
-			sl->dev->name);
+		netdev_err(sl->dev, "x25_asy_free for already free unit\n");
 }
 
 static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
@@ -128,8 +129,7 @@ static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 	rbuff = kmalloc(len + 4, GFP_ATOMIC);
 
 	if (xbuff == NULL || rbuff == NULL) {
-		printk(KERN_WARNING "%s: unable to grow X.25 buffers, MTU change cancelled.\n",
-		       dev->name);
+		netdev_warn(dev, "unable to grow X.25 buffers, MTU change cancelled\n");
 		kfree(xbuff);
 		kfree(rbuff);
 		return -ENOMEM;
@@ -198,8 +198,7 @@ static void x25_asy_bump(struct x25_asy *sl)
 
 	skb = dev_alloc_skb(count+1);
 	if (skb == NULL) {
-		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n",
-			sl->dev->name);
+		netdev_warn(sl->dev, "memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -287,9 +286,9 @@ static void x25_asy_timeout(struct net_device *dev)
 		/* May be we must check transmitter timeout here ?
 		 *      14 Oct 1994 Dmitry Gorodchanin.
 		 */
-		printk(KERN_WARNING "%s: transmit timed out, %s?\n", dev->name,
-		       (tty_chars_in_buffer(sl->tty) || sl->xleft) ?
-		       "bad line quality" : "driver error");
+		netdev_warn(dev, "transmit timed out, %s?\n",
+			    (tty_chars_in_buffer(sl->tty) || sl->xleft) ?
+			    "bad line quality" : "driver error");
 		sl->xleft = 0;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
 		x25_asy_unlock(sl);
@@ -306,8 +305,7 @@ static netdev_tx_t x25_asy_xmit(struct sk_buff *skb,
 	int err;
 
 	if (!netif_running(sl->dev)) {
-		printk(KERN_ERR "%s: xmit call when iface is down\n",
-			dev->name);
+		netdev_err(dev, "xmit call when iface is down\n");
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -318,13 +316,15 @@ static netdev_tx_t x25_asy_xmit(struct sk_buff *skb,
 	case X25_IFACE_CONNECT: /* Connection request .. do nothing */
 		err = lapb_connect_request(dev);
 		if (err != LAPB_OK)
-			printk(KERN_ERR "x25_asy: lapb_connect_request error - %d\n", err);
+			netdev_err(dev, "lapb_connect_request error: %d\n",
+				   err);
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	case X25_IFACE_DISCONNECT: /* do nothing - hang up ?? */
 		err = lapb_disconnect_request(dev);
 		if (err != LAPB_OK)
-			printk(KERN_ERR "x25_asy: lapb_disconnect_request error - %d\n", err);
+			netdev_err(dev, "lapb_disconnect_request error: %d\n",
+				   err);
 	default:
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
@@ -343,7 +343,7 @@ static netdev_tx_t x25_asy_xmit(struct sk_buff *skb,
 
 	err = lapb_data_request(dev, skb);
 	if (err != LAPB_OK) {
-		printk(KERN_ERR "x25_asy: lapb_data_request error - %d\n", err);
+		netdev_err(dev, "lapb_data_request error: %d\n", err);
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -378,7 +378,7 @@ static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(sl->dev) || sl->tty == NULL) {
 		spin_unlock(&sl->lock);
-		printk(KERN_ERR "x25_asy: tbusy drop\n");
+		netdev_err(dev, "tbusy drop\n");
 		kfree_skb(skb);
 		return;
 	}
@@ -404,7 +404,7 @@ static void x25_asy_connected(struct net_device *dev, int reason)
 
 	skb = dev_alloc_skb(1);
 	if (skb == NULL) {
-		printk(KERN_ERR "x25_asy: out of memory\n");
+		netdev_err(dev, "out of memory\n");
 		return;
 	}
 
@@ -423,7 +423,7 @@ static void x25_asy_disconnected(struct net_device *dev, int reason)
 
 	skb = dev_alloc_skb(1);
 	if (skb == NULL) {
-		printk(KERN_ERR "x25_asy: out of memory\n");
+		netdev_err(dev, "out of memory\n");
 		return;
 	}
 
@@ -603,8 +603,8 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 
 	err = lapb_unregister(sl->dev);
 	if (err != LAPB_OK)
-		printk(KERN_ERR "x25_asy_close: lapb_unregister error -%d\n",
-			err);
+		pr_err("x25_asy_close: lapb_unregister error: %d\n",
+		       err);
 
 	tty->disc_data = NULL;
 	sl->tty = NULL;
@@ -782,14 +782,13 @@ static int __init init_x25_asy(void)
 	if (x25_asy_maxdev < 4)
 		x25_asy_maxdev = 4; /* Sanity */
 
-	printk(KERN_INFO "X.25 async: version 0.00 ALPHA "
-			"(dynamic channels, max=%d).\n", x25_asy_maxdev);
+	pr_info("X.25 async: version 0.00 ALPHA (dynamic channels, max=%d)\n",
+		x25_asy_maxdev);
 
 	x25_asy_devs = kcalloc(x25_asy_maxdev, sizeof(struct net_device *),
 				GFP_KERNEL);
 	if (!x25_asy_devs) {
-		printk(KERN_WARNING "X25 async: Can't allocate x25_asy_ctrls[] "
-				"array! Uaargh! (-> No X.25 available)\n");
+		pr_warn("Can't allocate x25_asy_ctrls[] array! Uaargh! (-> No X.25 available)\n");
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 0806232..0e57690 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -36,6 +36,8 @@
  *	Synchronous mode without DMA is unlikely to pass about 2400 baud.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -365,7 +367,7 @@ static void z8530_rx(struct z8530_channel *c)
 				c->count=0;
 				if(stat&Rx_OVR)
 				{
-					printk(KERN_WARNING "%s: overrun\n", c->dev->name);
+					pr_warn("%s: overrun\n", c->dev->name);
 					c->rx_overrun++;
 				}
 				if(stat&CRC_ERR)
@@ -464,12 +466,12 @@ static void z8530_status(struct z8530_channel *chan)
 	if (altered & chan->dcdcheck)
 	{
 		if (status & chan->dcdcheck) {
-			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
+			pr_info("%s: DCD raised\n", chan->dev->name);
 			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
 			if (chan->netdevice)
 				netif_carrier_on(chan->netdevice);
 		} else {
-			printk(KERN_INFO "%s: DCD lost\n", chan->dev->name);
+			pr_info("%s: DCD lost\n", chan->dev->name);
 			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
 			if (chan->netdevice)
@@ -538,12 +540,12 @@ static void z8530_dma_tx(struct z8530_channel *chan)
 {
 	if(!chan->dma_tx)
 	{
-		printk(KERN_WARNING "Hey who turned the DMA off?\n");
+		pr_warn("Hey who turned the DMA off?\n");
 		z8530_tx(chan);
 		return;
 	}
 	/* This shouldn't occur in DMA mode */
-	printk(KERN_ERR "DMA tx - bogus event!\n");
+	pr_err("DMA tx - bogus event!\n");
 	z8530_tx(chan);
 }
 
@@ -585,12 +587,12 @@ static void z8530_dma_status(struct z8530_channel *chan)
 	if (altered & chan->dcdcheck)
 	{
 		if (status & chan->dcdcheck) {
-			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
+			pr_info("%s: DCD raised\n", chan->dev->name);
 			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
 			if (chan->netdevice)
 				netif_carrier_on(chan->netdevice);
 		} else {
-			printk(KERN_INFO "%s:DCD lost\n", chan->dev->name);
+			pr_info("%s: DCD lost\n", chan->dev->name);
 			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
 			if (chan->netdevice)
@@ -712,7 +714,7 @@ irqreturn_t z8530_interrupt(int irq, void *dev_id)
 	
 	if(locker)
 	{
-		printk(KERN_ERR "IRQ re-enter\n");
+		pr_err("IRQ re-enter\n");
 		return IRQ_NONE;
 	}
 	locker=1;
@@ -758,7 +760,8 @@ irqreturn_t z8530_interrupt(int irq, void *dev_id)
 	}
 	spin_unlock(&dev->lock);
 	if(work==5000)
-		printk(KERN_ERR "%s: interrupt jammed - abort(0x%X)!\n", dev->name, intr);
+		pr_err("%s: interrupt jammed - abort(0x%X)!\n",
+		       dev->name, intr);
 	/* Ok all done */
 	locker=0;
 	return IRQ_HANDLED;
@@ -1225,7 +1228,7 @@ static const char *z8530_type_name[]={
 
 void z8530_describe(struct z8530_dev *dev, char *mapping, unsigned long io)
 {
-	printk(KERN_INFO "%s: %s found at %s 0x%lX, IRQ %d.\n",
+	pr_info("%s: %s found at %s 0x%lX, IRQ %d\n",
 		dev->name, 
 		z8530_type_name[dev->type],
 		mapping,
@@ -1621,8 +1624,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 		else
 			/* Can't occur as we dont reenable the DMA irq until
 			   after the flip is done */
-			printk(KERN_WARNING "%s: DMA flip overrun!\n",
-			       c->netdevice->name);
+			netdev_warn(c->netdevice, "DMA flip overrun!\n");
 
 		release_dma_lock(flags);
 
@@ -1637,8 +1639,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 		skb = dev_alloc_skb(ct);
 		if (skb == NULL) {
 			c->netdevice->stats.rx_dropped++;
-			printk(KERN_WARNING "%s: Memory squeeze.\n",
-			       c->netdevice->name);
+			netdev_warn(c->netdevice, "Memory squeeze\n");
 		} else {
 			skb_put(skb, ct);
 			skb_copy_to_linear_data(skb, rxb, ct);
@@ -1678,8 +1679,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 
 		c->skb2 = dev_alloc_skb(c->mtu);
 		if (c->skb2 == NULL)
-			printk(KERN_WARNING "%s: memory squeeze.\n",
-			       c->netdevice->name);
+			netdev_warn(c->netdevice, "memory squeeze\n");
 		else
 			skb_put(c->skb2, c->mtu);
 		c->netdevice->stats.rx_packets++;
@@ -1693,7 +1693,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 		c->rx_function(c, skb);
 	} else {
 		c->netdevice->stats.rx_dropped++;
-		printk(KERN_ERR "%s: Lost a frame\n", c->netdevice->name);
+		netdev_err(c->netdevice, "Lost a frame\n");
 	}
 }
 
-- 
1.7.6.rc1
