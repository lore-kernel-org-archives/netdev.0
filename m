From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/4] chelsio: procectomy
Date: Fri, 17 Nov 2006 11:23:41 -0800
Message-ID: <20061117112341.4c61f495@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:47796 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1755846AbWKQUKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 15:10:23 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete removal of proc stuff from chelsio. The orignal driver had a debug
proc interface, but not all the code got removed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/cxgb2.c |   14 --------------
 1 file changed, 14 deletions(-)

--- chelsio-t2.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio-t2/drivers/net/chelsio/cxgb2.c
@@ -45,7 +45,6 @@
 #include <linux/if_vlan.h>
 #include <linux/mii.h>
 #include <linux/sockios.h>
-#include <linux/proc_fs.h>
 #include <linux/dma-mapping.h>
 #include <asm/uaccess.h>
 
@@ -780,17 +779,6 @@ static const struct ethtool_ops t1_ethto
 	.set_tso           = set_tso,
 };
 
-static void cxgb_proc_cleanup(struct adapter *adapter,
-					struct proc_dir_entry *dir)
-{
-	const char *name;
-	name = adapter->name;
-	remove_proc_entry(name, dir);
-}
-//#define chtoe_setup_toedev(adapter) NULL
-#define update_mtu_tab(adapter)
-#define write_smt_entry(adapter, idx)
-
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
 	struct adapter *adapter = dev->priv;
@@ -1156,7 +1144,6 @@ static int __devinit init_one(struct pci
 		if (adapter->regs) iounmap(adapter->regs);
 		for (i = bi->port_number - 1; i >= 0; --i)
 			if (adapter->port[i].dev) {
-				cxgb_proc_cleanup(adapter, proc_root_driver);
 				kfree(adapter->port[i].dev);
 			}
 	}
@@ -1189,7 +1176,6 @@ static void __devexit remove_one(struct 
 		iounmap(adapter->regs);
 		while (--i >= 0)
 			if (adapter->port[i].dev) {
-				cxgb_proc_cleanup(adapter, proc_root_driver);
 				kfree(adapter->port[i].dev);
 			}
 		pci_release_regions(pdev);
