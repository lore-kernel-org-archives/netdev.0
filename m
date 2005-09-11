From: Ralf Baechle <ralf@linux-mips.org>
Subject: Hamradio driver cleanups
Date: Sun, 11 Sep 2005 22:29:13 +0100
Message-ID: <20050911212913.GA8786@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Misc related cleanups in hamradio drivers:

 o Use symbolic constants instead of magic numbers
 o Don't try to handle the case where AX.25 isn't configured - the kernel
   configuration doesn't permit that.
 o Remove useless headers

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 drivers/net/hamradio/baycom_epp.c |   15 ++-------------
 drivers/net/hamradio/dmascc.c     |    8 ++++----
 drivers/net/hamradio/hdlcdrv.c    |   14 +-------------
 drivers/net/hamradio/yam.c        |   26 ++++++--------------------
 4 files changed, 13 insertions(+), 50 deletions(-)

Index: net-2.6.git/drivers/net/hamradio/hdlcdrv.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/hdlcdrv.c
+++ net-2.6.git/drivers/net/hamradio/hdlcdrv.c
@@ -42,7 +42,6 @@
 
 /*****************************************************************************/
 
-#include <linux/config.h>
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/net.h>
@@ -52,20 +51,14 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
-#include <asm/uaccess.h>
 
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
-#include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/hdlcdrv.h>
-/* prototypes for ax25_encapsulate and ax25_rebuild_header */
 #include <net/ax25.h> 
+#include <asm/uaccess.h>
 
-/* make genksyms happy */
-#include <linux/ip.h>
-#include <linux/udp.h>
-#include <linux/tcp.h>
 #include <linux/crc-ccitt.h>
 
 /* --------------------------------------------------------------------- */
@@ -708,13 +701,8 @@ static void hdlcdrv_setup(struct net_dev
 
 	s->skb = NULL;
 	
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	dev->hard_header = ax25_encapsulate;
 	dev->rebuild_header = ax25_rebuild_header;
-#else /* CONFIG_AX25 || CONFIG_AX25_MODULE */
-	dev->hard_header = NULL;
-	dev->rebuild_header = NULL;
-#endif /* CONFIG_AX25 || CONFIG_AX25_MODULE */
 	dev->set_mac_address = hdlcdrv_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
Index: net-2.6.git/drivers/net/hamradio/baycom_epp.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/baycom_epp.c
+++ net-2.6.git/drivers/net/hamradio/baycom_epp.c
@@ -40,7 +40,7 @@
 
 /*****************************************************************************/
 
-#include <linux/config.h>
+#include <linux/crc-ccitt.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -48,18 +48,12 @@
 #include <linux/workqueue.h>
 #include <linux/fs.h>
 #include <linux/parport.h>
-#include <linux/smp_lock.h>
-#include <asm/uaccess.h>
 #include <linux/if_arp.h>
-#include <linux/kmod.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
 #include <linux/jiffies.h>
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-/* prototypes for ax25_encapsulate and ax25_rebuild_header */
 #include <net/ax25.h> 
-#endif /* CONFIG_AX25 || CONFIG_AX25_MODULE */
-#include <linux/crc-ccitt.h>
+#include <asm/uaccess.h>
 
 /* --------------------------------------------------------------------- */
 
@@ -1177,13 +1171,8 @@ static void baycom_probe(struct net_devi
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	dev->hard_header = ax25_encapsulate;
 	dev->rebuild_header = ax25_rebuild_header;
-#else /* CONFIG_AX25 || CONFIG_AX25_MODULE */
-	dev->hard_header = NULL;
-	dev->rebuild_header = NULL;
-#endif /* CONFIG_AX25 || CONFIG_AX25_MODULE */
 	dev->set_mac_address = baycom_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
Index: net-2.6.git/drivers/net/hamradio/yam.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/yam.c
+++ net-2.6.git/drivers/net/hamradio/yam.c
@@ -60,15 +60,7 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-/* prototypes for ax25_encapsulate and ax25_rebuild_header */
 #include <net/ax25.h>
-#endif	/* CONFIG_AX25 || CONFIG_AX25_MODULE */
-
-/* make genksyms happy */
-#include <linux/ip.h>
-#include <linux/udp.h>
-#include <linux/tcp.h>
 
 #include <linux/kernel.h>
 #include <linux/proc_fs.h>
@@ -1116,23 +1108,17 @@ static void yam_setup(struct net_device 
 
 	skb_queue_head_init(&yp->send_queue);
 
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	dev->hard_header = ax25_encapsulate;
 	dev->rebuild_header = ax25_rebuild_header;
-#else							/* CONFIG_AX25 || CONFIG_AX25_MODULE */
-	dev->hard_header = NULL;
-	dev->rebuild_header = NULL;
-#endif							/* CONFIG_AX25 || CONFIG_AX25_MODULE */
 
 	dev->set_mac_address = yam_set_mac_address;
 
-	dev->type = ARPHRD_AX25;	/* AF_AX25 device */
-	dev->hard_header_len = 73;	/* We do digipeaters now */
-	dev->mtu = 256;				/* AX25 is the default */
-	dev->addr_len = 7;			/* sizeof an ax.25 address */
-	memcpy(dev->broadcast, ax25_bcast, 7);
-	memcpy(dev->dev_addr, ax25_test, 7);
-
+	dev->type = ARPHRD_AX25;
+	dev->hard_header_len = AX25_MAX_HEADER_LEN;
+	dev->mtu = AX25_MTU;
+	dev->addr_len = AX25_ADDR_LEN;
+	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, ax25_test, AX25_ADDR_LEN);
 }
 
 static int __init yam_init_driver(void)
Index: net-2.6.git/drivers/net/hamradio/dmascc.c
===================================================================
--- net-2.6.git.orig/drivers/net/hamradio/dmascc.c
+++ net-2.6.git/drivers/net/hamradio/dmascc.c
@@ -449,12 +449,12 @@ module_exit(dmascc_exit);
 static void dev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_AX25;
-	dev->hard_header_len = 73;
+	dev->hard_header_len = AX25_MAX_HEADER_LEN;
 	dev->mtu = 1500;
-	dev->addr_len = 7;
+	dev->addr_len = AX25_ADDR_LEN;
 	dev->tx_queue_len = 64;
-	memcpy(dev->broadcast, ax25_broadcast, 7);
-	memcpy(dev->dev_addr, ax25_test, 7);
+	memcpy(dev->broadcast, ax25_broadcast, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, ax25_test, AX25_ADDR_LEN);
 }
 
 static int __init setup_adapter(int card_base, int type, int n)
