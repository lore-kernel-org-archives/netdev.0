From: maks attems <janitor@sternwelten.at>
Subject: [patch] compile fix 3c59x for eisa without pci
Date: Fri, 10 Sep 2004 01:40:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909234050.GK1927@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

drivers/net/3c59x.c: In function `vortex_ioctl':
drivers/net/3c59x.c:2916: warning: dereferencing `void *' pointer
drivers/net/3c59x.c:2916: error: request for member `current_state' in something not a structure or union
make[3]: *** [drivers/net/3c59x.o] Error 1
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make: *** [stamp-build] Error 2

# CONFIG_PCI is not set
CONFIG_EISA=y

compile fix below, quite an ugly addition of ifdefs.
please tell me if better method exists.


--- kernel-source-2.6.8/drivers/net/3c59x.c	2004-08-14 07:36:10.000000000 +0200
+++ b/drivers/net/3c59x.c	2004-09-10 01:29:14.000000000 +0200
@@ -900,7 +900,9 @@ static void dump_tx_ring(struct net_devi
 static void update_stats(long ioaddr, struct net_device *dev);
 static struct net_device_stats *vortex_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
+#ifdef CONFIG_PCI
 static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+#endif
 static void vortex_tx_timeout(struct net_device *dev);
 static void acpi_set_WOL(struct net_device *dev);
 static struct ethtool_ops vortex_ethtool_ops;
@@ -1468,7 +1470,9 @@ static int __devinit vortex_probe1(struc
 
 	dev->stop = vortex_close;
 	dev->get_stats = vortex_get_stats;
+#ifdef CONFIG_PCI
 	dev->do_ioctl = vortex_ioctl;
+#endif
 	dev->ethtool_ops = &vortex_ethtool_ops;
 	dev->set_multicast_list = set_rx_mode;
 	dev->tx_timeout = vortex_tx_timeout;
@@ -2868,6 +2872,7 @@ static struct ethtool_ops vortex_ethtool
 	.get_drvinfo =		vortex_get_drvinfo,
 };
 
+#ifdef CONFIG_PCI
 static int vortex_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct vortex_private *vp = netdev_priv(dev);
@@ -2925,6 +2930,7 @@ static int vortex_ioctl(struct net_devic
 
 	return err;
 }
+#endif
 
 
 /* Pre-Cyclone chips have no documented multicast filter, so the only
