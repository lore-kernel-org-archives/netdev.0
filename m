From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Subject: [PATCH] r8169 ethtool support.
Date: 04 Jan 2004 18:59:51 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073210391.3555.7.camel@l5ac210.l5.laser5.co.jp>
Reply-To: krishnakumar@naturesoft.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The following patch introduces ethtool
support for the r8169 driver. Only
the driver info operation will be supported.

I dont have the hardware with me, hence
has done only a compilation test.

The patch is against the latest 
2.6.x experimental net driver queue, which
is based on 2.6.0-bk2.

If found okay, please do apply.

Regards,
KK.

Diffstat output:
----------------
r8169.c |   15 +++++++++++++++
1 files changed, 15 insertions(+)

The patch
---------

--- linux-2.6.0-bk2.netdrv.exp/drivers/net/r8169.orig.c	2004-01-04
18:47:10.000000000 +0900
+++ linux-2.6.0-bk2.netdrv.exp/drivers/net/r8169.c	2004-01-04
18:43:06.000000000 +0900
@@ -40,6 +40,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
+#include <linux/ethtool.h>
 #include <linux/crc32.h>
 #include <linux/init.h>
 
@@ -382,6 +383,19 @@
 	return value;
 }
 
+static void rtl8169_get_drvinfo (struct net_device *dev, struct
ethtool_drvinfo *info)
+{
+	struct rtl8169_private *tp = dev->priv;
+
+	strcpy (info->driver, RTL8169_DRIVER_NAME);
+	strcpy (info->version, RTL8169_VERSION );
+	strcpy (info->bus_info, pci_name(tp->pci_dev));
+}
+
+static struct ethtool_ops rtl8169_ethtool_ops = {
+	.get_drvinfo		= rtl8169_get_drvinfo,
+};
+
 static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int
bitnum,
 				       int bitval)
 {
@@ -793,6 +807,7 @@
 	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
 	dev->get_stats = rtl8169_get_stats;
+	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;



-- 
Home Page: http://puggy.symonds.net/~krishnakumar/
