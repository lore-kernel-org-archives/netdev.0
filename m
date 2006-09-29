From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 4/6]: powerpc/cell spidernet ethtool -i version number info.
Date: Fri, 29 Sep 2006 18:21:39 -0500
Message-ID: <20060929232139.GL6433@austin.ibm.com>
References: <20060929230552.GG6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:7401 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750833AbWI2XVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 19:21:41 -0400
To: jeff@garzik.org, akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20060929230552.GG6433@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds version information as reported by 
ethtool -i to the Spidernet driver.

From: James K Lewis <jklewis@us.ibm.com>
Signed-off-by: James K Lewis <jklewis@us.ibm.com>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

----
 drivers/net/spider_net.c         |    3 +++
 drivers/net/spider_net.h         |    2 ++
 drivers/net/spider_net_ethtool.c |    2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6.18-mm2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net.c	2006-09-29 15:05:05.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net.c	2006-09-29 16:33:39.000000000 -0500
@@ -55,6 +55,7 @@ MODULE_AUTHOR("Utz Bacher <utz.bacher@de
 	      "<Jens.Osterkamp@de.ibm.com>");
 MODULE_DESCRIPTION("Spider Southbridge Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(VERSION);
 
 static int rx_descriptors = SPIDER_NET_RX_DESCRIPTORS_DEFAULT;
 static int tx_descriptors = SPIDER_NET_TX_DESCRIPTORS_DEFAULT;
@@ -2303,6 +2304,8 @@ static struct pci_driver spider_net_driv
  */
 static int __init spider_net_init(void)
 {
+	printk("spidernet Version %s.\n",VERSION);
+
 	if (rx_descriptors < SPIDER_NET_RX_DESCRIPTORS_MIN) {
 		rx_descriptors = SPIDER_NET_RX_DESCRIPTORS_MIN;
 		pr_info("adjusting rx descriptors to %i.\n", rx_descriptors);
Index: linux-2.6.18-mm2/drivers/net/spider_net.h
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net.h	2006-09-29 15:01:55.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net.h	2006-09-29 15:18:12.000000000 -0500
@@ -24,6 +24,8 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
+#define VERSION "1.1 A"
+
 #include "sungem_phy.h"
 
 extern int spider_net_stop(struct net_device *netdev);
Index: linux-2.6.18-mm2/drivers/net/spider_net_ethtool.c
===================================================================
--- linux-2.6.18-mm2.orig/drivers/net/spider_net_ethtool.c	2006-09-29 14:11:18.000000000 -0500
+++ linux-2.6.18-mm2/drivers/net/spider_net_ethtool.c	2006-09-29 15:18:12.000000000 -0500
@@ -76,7 +76,7 @@ spider_net_ethtool_get_drvinfo(struct ne
 	/* clear and fill out info */
 	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
 	strncpy(drvinfo->driver, spider_net_driver_name, 32);
-	strncpy(drvinfo->version, "0.1", 32);
+	strncpy(drvinfo->version, VERSION, 32);
 	strcpy(drvinfo->fw_version, "no information");
 	strncpy(drvinfo->bus_info, pci_name(card->pdev), 32);
 }
