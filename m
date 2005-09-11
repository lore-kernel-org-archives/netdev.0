From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Rename ax25_encapsulate to ax25_hard_header
Date: Sun, 11 Sep 2005 22:37:05 +0100
Message-ID: <20050911213705.GA8914@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename ax25_encapsulate to ax25_hard_header which these days more accurately
describes what the function is supposed to do.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 drivers/net/hamradio/6pack.c      |    4 ++--
 drivers/net/hamradio/baycom_epp.c |    2 +-
 drivers/net/hamradio/bpqether.c   |    2 +-
 drivers/net/hamradio/dmascc.c     |    2 +-
 drivers/net/hamradio/hdlcdrv.c    |    2 +-
 drivers/net/hamradio/mkiss.c      |    2 +-
 drivers/net/hamradio/scc.c        |    2 +-
 drivers/net/hamradio/yam.c        |    2 +-
 include/net/ax25.h                |    2 +-
 net/ax25/af_ax25.c                |    2 +-
 net/ax25/ax25_ip.c                |    6 +++---
 11 files changed, 14 insertions(+), 14 deletions(-)

Index: net-2.6.git/drivers/net/hamradio/6pack.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/6pack.c
+++ net-2.6.git/drivers/net/hamradio/6pack.c
@@ -416,7 +416,7 @@ static void sp_setup(struct net_device *
 	dev->open		= sp_open_dev;
 	dev->destructor		= free_netdev;
 	dev->stop		= sp_close;
-	dev->hard_header	= ax25_encapsulate;
+	dev->hard_header	= ax25_hard_header;
 	dev->get_stats	        = sp_get_stats;
 	dev->set_mac_address    = sp_set_mac_address;
 	dev->hard_header_len	= AX25_MAX_HEADER_LEN;
Index: net-2.6.git/drivers/net/hamradio/baycom_epp.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/baycom_epp.c
+++ net-2.6.git/drivers/net/hamradio/baycom_epp.c
@@ -1171,7 +1171,7 @@ static void baycom_probe(struct net_devi
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
-	dev->hard_header = ax25_encapsulate;
+	dev->hard_header = ax25_hard_header;
 	dev->rebuild_header = ax25_rebuild_header;
 	dev->set_mac_address = baycom_set_mac_address;
 	
Index: net-2.6.git/drivers/net/hamradio/bpqether.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/bpqether.c
+++ net-2.6.git/drivers/net/hamradio/bpqether.c
@@ -488,7 +488,7 @@ static void bpq_setup(struct net_device 
 	dev->flags      = 0;
 
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-	dev->hard_header     = ax25_encapsulate;
+	dev->hard_header     = ax25_hard_header;
 	dev->rebuild_header  = ax25_rebuild_header;
 #endif
 
Index: net-2.6.git/drivers/net/hamradio/dmascc.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/dmascc.c
+++ net-2.6.git/drivers/net/hamradio/dmascc.c
@@ -600,7 +600,7 @@ static int __init setup_adapter(int card
 		dev->do_ioctl = scc_ioctl;
 		dev->hard_start_xmit = scc_send_packet;
 		dev->get_stats = scc_get_stats;
-		dev->hard_header = ax25_encapsulate;
+		dev->hard_header = ax25_hard_header;
 		dev->rebuild_header = ax25_rebuild_header;
 		dev->set_mac_address = scc_set_mac_address;
 	}
Index: net-2.6.git/drivers/net/hamradio/hdlcdrv.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/hdlcdrv.c
+++ net-2.6.git/drivers/net/hamradio/hdlcdrv.c
@@ -701,7 +701,7 @@ static void hdlcdrv_setup(struct net_dev
 
 	s->skb = NULL;
 	
-	dev->hard_header = ax25_encapsulate;
+	dev->hard_header = ax25_hard_header;
 	dev->rebuild_header = ax25_rebuild_header;
 	dev->set_mac_address = hdlcdrv_set_mac_address;
 	
Index: net-2.6.git/drivers/net/hamradio/mkiss.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/mkiss.c
+++ net-2.6.git/drivers/net/hamradio/mkiss.c
@@ -500,7 +500,7 @@ static int ax_header(struct sk_buff *skb
 {
 #ifdef CONFIG_INET
 	if (type != htons(ETH_P_AX25))
-		return ax25_encapsulate(skb, dev, type, daddr, saddr, len);
+		return ax25_hard_header(skb, dev, type, daddr, saddr, len);
 #endif
 	return 0;
 }
Index: net-2.6.git/drivers/net/hamradio/scc.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/scc.c
+++ net-2.6.git/drivers/net/hamradio/scc.c
@@ -1557,7 +1557,7 @@ static void scc_net_setup(struct net_dev
 	dev->stop	     = scc_net_close;
 
 	dev->hard_start_xmit = scc_net_tx;
-	dev->hard_header     = ax25_encapsulate;
+	dev->hard_header     = ax25_hard_header;
 	dev->rebuild_header  = ax25_rebuild_header;
 	dev->set_mac_address = scc_net_set_mac_address;
 	dev->get_stats       = scc_net_get_stats;
Index: net-2.6.git/drivers/net/hamradio/yam.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/yam.c
+++ net-2.6.git/drivers/net/hamradio/yam.c
@@ -1108,7 +1108,7 @@ static void yam_setup(struct net_device 
 
 	skb_queue_head_init(&yp->send_queue);
 
-	dev->hard_header = ax25_encapsulate;
+	dev->hard_header = ax25_hard_header;
 	dev->rebuild_header = ax25_rebuild_header;
 
 	dev->set_mac_address = yam_set_mac_address;
Index: net-2.6.git/include/net/ax25.h
===================================================================
--- net-2.6.git.orig/include/net/ax25.h
+++ net-2.6.git/include/net/ax25.h
@@ -328,7 +328,7 @@ extern int  ax25_rx_iframe(ax25_cb *, st
 extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
 
 /* ax25_ip.c */
-extern int  ax25_encapsulate(struct sk_buff *, struct net_device *, unsigned short, void *, void *, unsigned int);
+extern int  ax25_hard_header(struct sk_buff *, struct net_device *, unsigned short, void *, void *, unsigned int);
 extern int  ax25_rebuild_header(struct sk_buff *);
 
 /* ax25_out.c */
Index: net-2.6.git/net/ax25/af_ax25.c
===================================================================
--- net-2.6.git.orig/net/ax25/af_ax25.c
+++ net-2.6.git/net/ax25/af_ax25.c
@@ -1980,7 +1980,7 @@ static struct notifier_block ax25_dev_no
 	.notifier_call =ax25_device_event,
 };
 
-EXPORT_SYMBOL(ax25_encapsulate);
+EXPORT_SYMBOL(ax25_hard_header);
 EXPORT_SYMBOL(ax25_rebuild_header);
 EXPORT_SYMBOL(ax25_findbyuid);
 EXPORT_SYMBOL(ax25_find_cb);
Index: net-2.6.git/net/ax25/ax25_ip.c
===================================================================
--- net-2.6.git.orig/net/ax25/ax25_ip.c
+++ net-2.6.git/net/ax25/ax25_ip.c
@@ -47,7 +47,7 @@
 
 #ifdef CONFIG_INET
 
-int ax25_encapsulate(struct sk_buff *skb, struct net_device *dev, unsigned short type, void *daddr, void *saddr, unsigned len)
+int ax25_hard_header(struct sk_buff *skb, struct net_device *dev, unsigned short type, void *daddr, void *saddr, unsigned len)
 {
 	unsigned char *buff;
 
@@ -88,7 +88,7 @@ int ax25_encapsulate(struct sk_buff *skb
   		*buff++ = AX25_P_ARP;
   		break;
   	default:
-  		printk(KERN_ERR "AX.25: ax25_encapsulate - wrong protocol type 0x%2.2x\n", type);
+  		printk(KERN_ERR "AX.25: ax25_hard_header - wrong protocol type 0x%2.2x\n", type);
   		*buff++ = 0;
   		break;
  	}
@@ -209,7 +209,7 @@ put:
 
 #else	/* INET */
 
-int ax25_encapsulate(struct sk_buff *skb, struct net_device *dev, unsigned short type, void *daddr, void *saddr, unsigned len)
+int ax25_hard_header(struct sk_buff *skb, struct net_device *dev, unsigned short type, void *daddr, void *saddr, unsigned len)
 {
 	return -AX25_HEADER_LEN;
 }
