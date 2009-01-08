From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 37/42] synclink: convert devices to new API (rev2)
Date: Thu, 08 Jan 2009 23:55:58 +0100
Message-ID: <m3tz89jtkx.fsf@maximus.localdomain>
References: <20090107003316.784424362@vyatta.com>
	<20090107003349.468715485@vyatta.com>
	<20090107154835.37f4de4c@extreme>
	<20090107.180802.118061961.davem@davemloft.net>
	<m3y6xljtvi.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53880 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755750AbZAHW4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 17:56:04 -0500
In-Reply-To: <m3y6xljtvi.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Thu\, 08 Jan 2009 23\:49\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>   git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-david
>       WAN: Generic HDLC now uses IFF_WAN_HDLC private flag.
>       WAN: Allow hw HDLC drivers to override dev->get_stats.
>       Fix a comment in include/linux/netdevice.h.
>       WAN: Convert generic HDLC drivers to netdev_ops.
>       WAN: Fix NAPI interface in IXP4xx HSS driver.

The above is equal to:

diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index dc073e1..5608a1e 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -4311,10 +4311,17 @@ static void hdlcdev_rx(MGSLPC_INFO *info, char *buf, int size)
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -4341,11 +4348,8 @@ static int hdlcdev_init(MGSLPC_INFO *info)
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
-	dev->watchdog_timeo = 10*HZ;
+	dev->netdev_ops	    = &hdlcdev_ops;
+	dev->watchdog_timeo = 10 * HZ;
 	dev->tx_queue_len   = 50;
 
 	/* generic HDLC layer callbacks and settings */
diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index b8063d4..0057a8f 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -8007,10 +8007,17 @@ static void hdlcdev_rx(struct mgsl_struct *info, char *buf, int size)
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -8038,11 +8045,8 @@ static int hdlcdev_init(struct mgsl_struct *info)
 	dev->dma       = info->dma_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
-	dev->watchdog_timeo = 10*HZ;
+	dev->netdev_ops     = &hdlcdev_ops;
+	dev->watchdog_timeo = 10 * HZ;
 	dev->tx_queue_len   = 50;
 
 	/* generic HDLC layer callbacks and settings */
diff --git a/drivers/char/synclink_gt.c b/drivers/char/synclink_gt.c
index 53544e2..faf163d 100644
--- a/drivers/char/synclink_gt.c
+++ b/drivers/char/synclink_gt.c
@@ -1766,10 +1766,17 @@ static void hdlcdev_rx(struct slgt_info *info, char *buf, int size)
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -1797,11 +1804,8 @@ static int hdlcdev_init(struct slgt_info *info)
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
-	dev->watchdog_timeo = 10*HZ;
+	dev->netdev_ops	    = &hdlcdev_ops;
+	dev->watchdog_timeo = 10 * HZ;
 	dev->tx_queue_len   = 50;
 
 	/* generic HDLC layer callbacks and settings */
diff --git a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
index 7b0c5b2..8eb6c89 100644
--- a/drivers/char/synclinkmp.c
+++ b/drivers/char/synclinkmp.c
@@ -1907,10 +1907,17 @@ static void hdlcdev_rx(SLMP_INFO *info, char *buf, int size)
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -1938,11 +1945,8 @@ static int hdlcdev_init(SLMP_INFO *info)
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
-	dev->watchdog_timeo = 10*HZ;
+	dev->netdev_ops	    = &hdlcdev_ops;
+	dev->watchdog_timeo = 10 * HZ;
 	dev->tx_queue_len   = 50;
 
 	/* generic HDLC layer callbacks and settings */
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index b468979..9693b0f 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -296,7 +296,13 @@ static void c101_destroy_card(card_t *card)
 	kfree(card);
 }
 
-
+static const struct net_device_ops c101_ops = {
+	.ndo_open       = c101_open,
+	.ndo_stop       = c101_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = c101_ioctl,
+};
 
 static int __init c101_run(unsigned long irq, unsigned long winbase)
 {
@@ -367,9 +373,7 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 	dev->mem_start = winbase;
 	dev->mem_end = winbase + C101_MAPPED_RAM_SIZE - 1;
 	dev->tx_queue_len = 50;
-	dev->do_ioctl = c101_ioctl;
-	dev->open = c101_open;
-	dev->stop = c101_close;
+	dev->netdev_ops = &c101_ops;
 	hdlc->attach = sca_attach;
 	hdlc->xmit = sca_xmit;
 	card->settings.clock_type = CLOCK_EXT;
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index d80b72e..0d7ba11 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -427,6 +427,15 @@ static void __exit cosa_exit(void)
 }
 module_exit(cosa_exit);
 
+static const struct net_device_ops cosa_ops = {
+	.ndo_open       = cosa_net_open,
+	.ndo_stop       = cosa_net_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = cosa_net_ioctl,
+	.ndo_tx_timeout = cosa_net_timeout,
+};
+
 static int cosa_probe(int base, int irq, int dma)
 {
 	struct cosa_data *cosa = cosa_cards+nr_cards;
@@ -575,10 +584,7 @@ static int cosa_probe(int base, int irq, int dma)
 		}
 		dev_to_hdlc(chan->netdev)->attach = cosa_net_attach;
 		dev_to_hdlc(chan->netdev)->xmit = cosa_net_tx;
-		chan->netdev->open = cosa_net_open;
-		chan->netdev->stop = cosa_net_close;
-		chan->netdev->do_ioctl = cosa_net_ioctl;
-		chan->netdev->tx_timeout = cosa_net_timeout;
+		chan->netdev->netdev_ops = &cosa_ops;
 		chan->netdev->watchdog_timeo = TX_TIMEOUT;
 		chan->netdev->base_addr = chan->cosa->datareg;
 		chan->netdev->irq = chan->cosa->irq;
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 888025d..8face5d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -883,6 +883,15 @@ static inline int dscc4_set_quartz(struct dscc4_dev_priv *dpriv, int hz)
 	return ret;
 }
 
+static const struct net_device_ops dscc4_ops = {
+	.ndo_open       = dscc4_open,
+	.ndo_stop       = dscc4_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = dscc4_ioctl,
+	.ndo_tx_timeout = dscc4_tx_timeout,
+};
+
 static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 {
 	struct dscc4_pci_priv *ppriv;
@@ -916,13 +925,8 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 		hdlc_device *hdlc = dev_to_hdlc(d);
 
 	        d->base_addr = (unsigned long)ioaddr;
-		d->init = NULL;
 	        d->irq = pdev->irq;
-	        d->open = dscc4_open;
-	        d->stop = dscc4_close;
-		d->set_multicast_list = NULL;
-	        d->do_ioctl = dscc4_ioctl;
-		d->tx_timeout = dscc4_tx_timeout;
+		d->netdev_ops = &dscc4_ops;
 		d->watchdog_timeo = TX_TIMEOUT;
 		SET_NETDEV_DEV(d, &pdev->dev);
 
@@ -1048,7 +1052,7 @@ static int dscc4_open(struct net_device *dev)
 	struct dscc4_pci_priv *ppriv;
 	int ret = -EAGAIN;
 
-	if ((dscc4_loopback_check(dpriv) < 0) || !dev->hard_start_xmit)
+	if ((dscc4_loopback_check(dpriv) < 0))
 		goto err;
 
 	if ((ret = hdlc_open(dev)))
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 48a2c9d..00945f7 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2424,6 +2424,15 @@ fst_init_card(struct fst_card_info *card)
 	       type_strings[card->type], card->irq, card->nports);
 }
 
+static const struct net_device_ops fst_ops = {
+	.ndo_open       = fst_open,
+	.ndo_stop       = fst_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = fst_ioctl,
+	.ndo_tx_timeout = fst_tx_timeout,
+};
+
 /*
  *      Initialise card when detected.
  *      Returns 0 to indicate success, or errno otherwise.
@@ -2565,12 +2574,9 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
                 dev->base_addr   = card->pci_conf;
                 dev->irq         = card->irq;
 
-                dev->tx_queue_len          = FST_TX_QUEUE_LEN;
-                dev->open                  = fst_open;
-                dev->stop                  = fst_close;
-                dev->do_ioctl              = fst_ioctl;
-                dev->watchdog_timeo        = FST_TX_TIMEOUT;
-                dev->tx_timeout            = fst_tx_timeout;
+		dev->netdev_ops = &fst_ops;
+		dev->tx_queue_len = FST_TX_QUEUE_LEN;
+		dev->watchdog_timeo = FST_TX_TIMEOUT;
                 hdlc->attach = fst_attach;
                 hdlc->xmit   = fst_start_xmit;
 	}
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 1f2a140..43da8bd 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -44,7 +44,7 @@ static const char* version = "HDLC support module revision 1.22";
 
 static struct hdlc_proto *first_proto;
 
-static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
+int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 68) || (new_mtu > HDLC_MAX_MTU))
 		return -EINVAL;
@@ -52,15 +52,6 @@ static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-
-
-static struct net_device_stats *hdlc_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
-
-
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *p, struct net_device *orig_dev)
 {
@@ -75,7 +66,15 @@ static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 	return hdlc->proto->netif_rx(skb);
 }
 
+int hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	hdlc_device *hdlc = dev_to_hdlc(dev);
+
+	if (hdlc->proto->xmit)
+		return hdlc->proto->xmit(skb, dev);
 
+	return hdlc->xmit(skb, dev); /* call hardware driver directly */
+}
 
 static inline void hdlc_proto_start(struct net_device *dev)
 {
@@ -102,11 +101,11 @@ static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 	hdlc_device *hdlc;
 	unsigned long flags;
 	int on;
- 
+
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
-	if (dev->get_stats != hdlc_get_stats)
+	if (!(dev->priv_flags & IFF_WAN_HDLC))
 		return NOTIFY_DONE; /* not an HDLC device */
 
 	if (event != NETDEV_CHANGE)
@@ -233,15 +232,13 @@ static void hdlc_setup_dev(struct net_device *dev)
 	/* Re-init all variables changed by HDLC protocol drivers,
 	 * including ether_setup() called from hdlc_raw_eth.c.
 	 */
-	dev->get_stats		 = hdlc_get_stats;
 	dev->flags		 = IFF_POINTOPOINT | IFF_NOARP;
+	dev->priv_flags		 = IFF_WAN_HDLC;
 	dev->mtu		 = HDLC_MAX_MTU;
 	dev->type		 = ARPHRD_RAWHDLC;
 	dev->hard_header_len	 = 16;
 	dev->addr_len		 = 0;
 	dev->header_ops		 = &hdlc_null_ops;
-
-	dev->change_mtu		 = hdlc_change_mtu;
 }
 
 static void hdlc_setup(struct net_device *dev)
@@ -339,6 +336,8 @@ MODULE_AUTHOR("Krzysztof Halasa <khc@pm.waw.pl>");
 MODULE_DESCRIPTION("HDLC support module");
 MODULE_LICENSE("GPL v2");
 
+EXPORT_SYMBOL(hdlc_change_mtu);
+EXPORT_SYMBOL(hdlc_start_xmit);
 EXPORT_SYMBOL(hdlc_open);
 EXPORT_SYMBOL(hdlc_close);
 EXPORT_SYMBOL(hdlc_ioctl);
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 44e64b1..af3fd4f 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -382,7 +382,6 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 
 		memcpy(&state(hdlc)->settings, &new_settings, size);
 		spin_lock_init(&state(hdlc)->lock);
-		dev->hard_start_xmit = hdlc->xmit;
 		dev->header_ops = &cisco_header_ops;
 		dev->type = ARPHRD_CISCO;
 		netif_dormant_on(dev);
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index f1ddd7c..70e57ce 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -444,18 +444,6 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-
-
-static int pvc_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > HDLC_MAX_MTU))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
-
-
 static inline void fr_log_dlci_active(pvc_device *pvc)
 {
 	printk(KERN_INFO "%s: DLCI %d [%s%s%s]%s %s\n",
@@ -1068,6 +1056,14 @@ static void pvc_setup(struct net_device *dev)
 	dev->addr_len = 2;
 }
 
+static const struct net_device_ops pvc_ops = {
+	.ndo_open       = pvc_open,
+	.ndo_stop       = pvc_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = pvc_xmit,
+	.ndo_do_ioctl   = pvc_ioctl,
+};
+
 static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 {
 	hdlc_device *hdlc = dev_to_hdlc(frad);
@@ -1104,11 +1100,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
-	dev->hard_start_xmit = pvc_xmit;
-	dev->open = pvc_open;
-	dev->stop = pvc_close;
-	dev->do_ioctl = pvc_ioctl;
-	dev->change_mtu = pvc_change_mtu;
+	dev->netdev_ops = &pvc_ops;
 	dev->mtu = HDLC_MAX_MTU;
 	dev->tx_queue_len = 0;
 	dev->ml_priv = pvc;
@@ -1260,8 +1252,6 @@ static int fr_ioctl(struct net_device *dev, struct ifreq *ifr)
 			state(hdlc)->dce_pvc_count = 0;
 		}
 		memcpy(&state(hdlc)->settings, &new_settings, size);
-
-		dev->hard_start_xmit = hdlc->xmit;
 		dev->type = ARPHRD_FRAD;
 		return 0;
 
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 57fe714..7b8a5ea 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -558,7 +558,6 @@ out:
 	return NET_RX_DROP;
 }
 
-
 static void ppp_timer(unsigned long arg)
 {
 	struct proto *proto = (struct proto *)arg;
@@ -679,7 +678,6 @@ static int ppp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		ppp->keepalive_interval = 10;
 		ppp->keepalive_timeout = 60;
 
-		dev->hard_start_xmit = hdlc->xmit;
 		dev->hard_header_len = sizeof(struct hdlc_header);
 		dev->header_ops = &ppp_header_ops;
 		dev->type = ARPHRD_PPP;
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index 8612311..6e92c64 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -30,8 +30,6 @@ static __be16 raw_type_trans(struct sk_buff *skb, struct net_device *dev)
 	return __constant_htons(ETH_P_IP);
 }
 
-
-
 static struct hdlc_proto proto = {
 	.type_trans	= raw_type_trans,
 	.ioctl		= raw_ioctl,
@@ -86,7 +84,6 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 		memcpy(hdlc->state, &new_settings, size);
-		dev->hard_start_xmit = hdlc->xmit;
 		dev->type = ARPHRD_RAWHDLC;
 		netif_dormant_off(dev);
 		return 0;
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index a13fc32..49e68f5 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -45,6 +45,7 @@ static int eth_tx(struct sk_buff *skb, struct net_device *dev)
 
 static struct hdlc_proto proto = {
 	.type_trans	= eth_type_trans,
+	.xmit		= eth_tx,
 	.ioctl		= raw_eth_ioctl,
 	.module		= THIS_MODULE,
 };
@@ -56,9 +57,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 	const size_t size = sizeof(raw_hdlc_proto);
 	raw_hdlc_proto new_settings;
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	int result;
-	int (*old_ch_mtu)(struct net_device *, int);
-	int old_qlen;
+	int result, old_qlen;
 
 	switch (ifr->ifr_settings.type) {
 	case IF_GET_PROTO:
@@ -99,11 +98,8 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 		memcpy(hdlc->state, &new_settings, size);
-		dev->hard_start_xmit = eth_tx;
-		old_ch_mtu = dev->change_mtu;
 		old_qlen = dev->tx_queue_len;
 		ether_setup(dev);
-		dev->change_mtu = old_ch_mtu;
 		dev->tx_queue_len = old_qlen;
 		random_ether_addr(dev->dev_addr);
 		netif_dormant_off(dev);
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index cbcbf6f..b1dc29e 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -184,6 +184,7 @@ static struct hdlc_proto proto = {
 	.close		= x25_close,
 	.ioctl		= x25_ioctl,
 	.netif_rx	= x25_rx,
+	.xmit		= x25_xmit,
 	.module		= THIS_MODULE,
 };
 
@@ -213,7 +214,6 @@ static int x25_ioctl(struct net_device *dev, struct ifreq *ifr)
 
 		if ((result = attach_hdlc_protocol(dev, &proto, 0)))
 			return result;
-		dev->hard_start_xmit = x25_xmit;
 		dev->type = ARPHRD_X25;
 		netif_dormant_off(dev);
 		return 0;
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index af54f0c..567d4f5 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -173,6 +173,14 @@ static int hostess_attach(struct net_device *dev, unsigned short encoding,
  *	Description block for a Comtrol Hostess SV11 card
  */
 
+static const struct net_device_ops hostess_ops = {
+	.ndo_open       = hostess_open,
+	.ndo_stop       = hostess_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hostess_ioctl,
+};
+
 static struct z8530_dev *sv11_init(int iobase, int irq)
 {
 	struct z8530_dev *sv;
@@ -267,9 +275,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 
 	dev_to_hdlc(netdev)->attach = hostess_attach;
 	dev_to_hdlc(netdev)->xmit = hostess_queue_xmit;
-	netdev->open = hostess_open;
-	netdev->stop = hostess_close;
-	netdev->do_ioctl = hostess_ioctl;
+	netdev->netdev_ops = &hostess_ops;
 	netdev->base_addr = iobase;
 	netdev->irq = irq;
 
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index 2dc2416..7e8bbba 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -622,7 +622,7 @@ static void hss_hdlc_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: hss_hdlc_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(queue_ids[port->id].rx);
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 }
 
 static int hss_hdlc_poll(struct napi_struct *napi, int budget)
@@ -651,7 +651,7 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
 			printk(KERN_DEBUG "%s: hss_hdlc_poll"
 			       " netif_rx_complete\n", dev->name);
 #endif
-			netif_rx_complete(dev, napi);
+			netif_rx_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
 			    netif_rx_reschedule(napi)) {
@@ -1069,7 +1069,7 @@ static int hss_hdlc_open(struct net_device *dev)
 	hss_start_hdlc(port);
 
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 	return 0;
 
 err_unlock:
@@ -1230,6 +1230,14 @@ static int hss_hdlc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
  * initialization
  ****************************************************************************/
 
+static const struct net_device_ops hss_hdlc_ops = {
+	.ndo_open       = hss_hdlc_open,
+	.ndo_stop       = hss_hdlc_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = hss_hdlc_ioctl,
+};
+
 static int __devinit hss_init_one(struct platform_device *pdev)
 {
 	struct port *port;
@@ -1254,9 +1262,7 @@ static int __devinit hss_init_one(struct platform_device *pdev)
 	hdlc = dev_to_hdlc(dev);
 	hdlc->attach = hss_hdlc_attach;
 	hdlc->xmit = hss_hdlc_xmit;
-	dev->open = hss_hdlc_open;
-	dev->stop = hss_hdlc_close;
-	dev->do_ioctl = hss_hdlc_ioctl;
+	dev->netdev_ops = &hss_hdlc_ops;
 	dev->tx_queue_len = 100;
 	port->clock_type = CLOCK_EXT;
 	port->clock_rate = 2048000;
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index feac3b9..45b1822 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -806,6 +806,16 @@ static int lmc_attach(struct net_device *dev, unsigned short encoding,
 	return -EINVAL;
 }
 
+static const struct net_device_ops lmc_ops = {
+	.ndo_open       = lmc_open,
+	.ndo_stop       = lmc_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = lmc_ioctl,
+	.ndo_tx_timeout = lmc_driver_timeout,
+	.ndo_get_stats  = lmc_get_stats,
+};
+
 static int __devinit lmc_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -849,11 +859,7 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
 	dev->type = ARPHRD_HDLC;
 	dev_to_hdlc(dev)->xmit = lmc_start_xmit;
 	dev_to_hdlc(dev)->attach = lmc_attach;
-	dev->open = lmc_open;
-	dev->stop = lmc_close;
-	dev->get_stats = lmc_get_stats;
-	dev->do_ioctl = lmc_ioctl;
-	dev->tx_timeout = lmc_driver_timeout;
+	dev->netdev_ops = &lmc_ops;
 	dev->watchdog_timeo = HZ; /* 1 second */
 	dev->tx_queue_len = 100;
 	sc->lmc_device = dev;
@@ -1059,9 +1065,6 @@ static int lmc_open(struct net_device *dev)
     if ((err = lmc_proto_open(sc)) != 0)
 	    return err;
 
-    dev->do_ioctl = lmc_ioctl;
-
-
     netif_start_queue(dev);
     sc->extra_stats.tx_tbusy0++;
 
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/lmc_proto.c
index 94b4c20..044a481 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/lmc_proto.c
@@ -51,30 +51,15 @@
 void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
 {
     lmc_trace(sc->lmc_device, "lmc_proto_attach in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        {
-            struct net_device *dev = sc->lmc_device;
-            dev->do_ioctl = lmc_ioctl;
-        }
-        break;
-    case LMC_NET:
-        {
+    if (sc->if_type == LMC_NET) {
             struct net_device *dev = sc->lmc_device;
             /*
 	     * They set a few basics because they don't use HDLC
              */
             dev->flags |= IFF_POINTOPOINT;
-
             dev->hard_header_len = 0;
             dev->addr_len = 0;
         }
-    case LMC_RAW: /* Setup the task queue, maybe we should notify someone? */
-        {
-        }
-    default:
-        break;
-    }
     lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
 
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 697715a..83da596 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -324,7 +324,13 @@ static void n2_destroy_card(card_t *card)
 	kfree(card);
 }
 
-
+static const struct net_device_ops n2_ops = {
+	.ndo_open       = n2_open,
+	.ndo_stop       = n2_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = n2_ioctl,
+};
 
 static int __init n2_run(unsigned long io, unsigned long irq,
 			 unsigned long winbase, long valid0, long valid1)
@@ -460,9 +466,7 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 		dev->mem_start = winbase;
 		dev->mem_end = winbase + USE_WINDOWSIZE - 1;
 		dev->tx_queue_len = 50;
-		dev->do_ioctl = n2_ioctl;
-		dev->open = n2_open;
-		dev->stop = n2_close;
+		dev->netdev_ops = &n2_ops;
 		hdlc->attach = sca_attach;
 		hdlc->xmit = sca_xmit;
 		port->settings.clock_type = CLOCK_EXT;
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index f247e5d..60ece54 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -287,7 +287,13 @@ static void pc300_pci_remove_one(struct pci_dev *pdev)
 	kfree(card);
 }
 
-
+static const struct net_device_ops pc300_ops = {
+	.ndo_open       = pc300_open,
+	.ndo_stop       = pc300_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = pc300_ioctl,
+};
 
 static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
@@ -448,9 +454,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 		dev->mem_start = ramphys;
 		dev->mem_end = ramphys + ramsize - 1;
 		dev->tx_queue_len = 50;
-		dev->do_ioctl = pc300_ioctl;
-		dev->open = pc300_open;
-		dev->stop = pc300_close;
+		dev->netdev_ops = &pc300_ops;
 		hdlc->attach = sca_attach;
 		hdlc->xmit = sca_xmit;
 		port->settings.clock_type = CLOCK_EXT;
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index 1104d3a..e035d8c 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -265,7 +265,13 @@ static void pci200_pci_remove_one(struct pci_dev *pdev)
 	kfree(card);
 }
 
-
+static const struct net_device_ops pci200_ops = {
+	.ndo_open       = pci200_open,
+	.ndo_stop       = pci200_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = pci200_ioctl,
+};
 
 static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
@@ -395,9 +401,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 		dev->mem_start = ramphys;
 		dev->mem_end = ramphys + ramsize - 1;
 		dev->tx_queue_len = 50;
-		dev->do_ioctl = pci200_ioctl;
-		dev->open = pci200_open;
-		dev->stop = pci200_close;
+		dev->netdev_ops = &pci200_ops;
 		hdlc->attach = sca_attach;
 		hdlc->xmit = sca_xmit;
 		port->settings.clock_type = CLOCK_EXT;
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 0941a26..23b2690 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -169,6 +169,14 @@ static int sealevel_attach(struct net_device *dev, unsigned short encoding,
 	return -EINVAL;
 }
 
+static const struct net_device_ops sealevel_ops = {
+	.ndo_open       = sealevel_open,
+	.ndo_stop       = sealevel_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = sealevel_ioctl,
+};
+
 static int slvl_setup(struct slvl_device *sv, int iobase, int irq)
 {
 	struct net_device *dev = alloc_hdlcdev(sv);
@@ -177,9 +185,7 @@ static int slvl_setup(struct slvl_device *sv, int iobase, int irq)
 
 	dev_to_hdlc(dev)->attach = sealevel_attach;
 	dev_to_hdlc(dev)->xmit = sealevel_queue_xmit;
-	dev->open = sealevel_open;
-	dev->stop = sealevel_close;
-	dev->do_ioctl = sealevel_ioctl;
+	dev->netdev_ops = &sealevel_ops;
 	dev->base_addr = iobase;
 	dev->irq = irq;
 
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 4bffb67..887acb0 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -547,6 +547,15 @@ static void wanxl_pci_remove_one(struct pci_dev *pdev)
 
 #include "wanxlfw.inc"
 
+static const struct net_device_ops wanxl_ops = {
+	.ndo_open       = wanxl_open,
+	.ndo_stop       = wanxl_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_start_xmit = hdlc_start_xmit,
+	.ndo_do_ioctl   = wanxl_ioctl,
+	.ndo_get_stats  = wanxl_get_stats,
+};
+
 static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 					const struct pci_device_id *ent)
 {
@@ -777,12 +786,9 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 		hdlc = dev_to_hdlc(dev);
 		spin_lock_init(&port->lock);
 		dev->tx_queue_len = 50;
-		dev->do_ioctl = wanxl_ioctl;
-		dev->open = wanxl_open;
-		dev->stop = wanxl_close;
+		dev->netdev_ops = &wanxl_ops;
 		hdlc->attach = wanxl_attach;
 		hdlc->xmit = wanxl_xmit;
-		dev->get_stats = wanxl_get_stats;
 		port->card = card;
 		port->node = i;
 		get_status(port)->clocking = CLOCK_EXT;
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index fd47a15..6a6e701 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -38,6 +38,7 @@ struct hdlc_proto {
 	int (*ioctl)(struct net_device *dev, struct ifreq *ifr);
 	__be16 (*type_trans)(struct sk_buff *skb, struct net_device *dev);
 	int (*netif_rx)(struct sk_buff *skb);
+	int (*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct module *module;
 	struct hdlc_proto *next; /* next protocol in the list */
 };
@@ -102,6 +103,10 @@ static __inline__ void debug_frame(const struct sk_buff *skb)
 int hdlc_open(struct net_device *dev);
 /* Must be called by hardware driver when HDLC device is being closed */
 void hdlc_close(struct net_device *dev);
+/* May be used by hardware driver */
+int hdlc_change_mtu(struct net_device *dev, int new_mtu);
+/* Must be pointed to by hw driver's dev->netdev_ops->ndo_start_xmit */
+int hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			 size_t size);
diff --git a/include/linux/if.h b/include/linux/if.h
index 2a6e296..1108f3e 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -66,6 +66,7 @@
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
 #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
+#define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 114091b..353d2e6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -467,7 +467,7 @@ struct netdev_queue {
  *     This function is called when network device transistions to the down
  *     state.
  *
- * int (*ndo_hard_start_xmit)(struct sk_buff *skb, struct net_device *dev);
+ * int (*ndo_start_xmit)(struct sk_buff *skb, struct net_device *dev);
  *	Called when a packet needs to be transmitted.
  *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY, or NETDEV_TX_LOCKED,
  *	Required can not be NULL.

-- 
Krzysztof Halasa
