From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 1/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 19:37:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329193710.A5411@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040329193604.A4744@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Mar 29, 2004 at 07:36:04PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool driver info (Krishnakumar R. <krishnakumar@naturesoft.net>).



 drivers/net/r8169.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)

diff -puN drivers/net/r8169.c~r8169-ethtool-introduction drivers/net/r8169.c
--- linux-2.6.5-rc2-mm5/drivers/net/r8169.c~r8169-ethtool-introduction	2004-03-29 18:42:10.000000000 +0200
+++ linux-2.6.5-rc2-mm5-fr/drivers/net/r8169.c	2004-03-29 18:42:10.000000000 +0200
@@ -40,6 +40,7 @@ VERSION 1.2	<2002/11/30>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
+#include <linux/ethtool.h>
 #include <linux/crc32.h>
 #include <linux/init.h>
 
@@ -382,6 +383,20 @@ mdio_read(void *ioaddr, int RegAddr)
 	return value;
 }
 
+static void rtl8169_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *info)
+{
+	struct rtl8169_private *tp = dev->priv;
+
+	strcpy(info->driver, RTL8169_DRIVER_NAME);
+	strcpy(info->version, RTL8169_VERSION);
+	strcpy(info->bus_info, pci_name(tp->pci_dev));
+}
+
+static struct ethtool_ops rtl8169_ethtool_ops = {
+	.get_drvinfo		= rtl8169_get_drvinfo,
+};
+
 static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int bitnum,
 				       int bitval)
 {
@@ -793,6 +808,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
 	dev->get_stats = rtl8169_get_stats;
+	dev->ethtool_ops = &rtl8169_ethtool_ops;
 	dev->stop = rtl8169_close;
 	dev->tx_timeout = rtl8169_tx_timeout;
 	dev->set_multicast_list = rtl8169_set_rx_mode;

_
