From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Wed, 18 Jun 2008 00:20:45 -0400
Message-ID: <20080618042045.GA30789@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:45350 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758103AbYFREUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 00:20:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 Documentation/networking/bonding.txt  |   14 +-
 MAINTAINERS                           |   18 +-
 drivers/net/Kconfig                   |    1 -
 drivers/net/Makefile                  |    1 -
 drivers/net/bonding/bond_main.c       |   66 +-
 drivers/net/bonding/bond_sysfs.c      |   22 +-
 drivers/net/bonding/bonding.h         |    4 +-
 drivers/net/ibm_emac/Kconfig          |   70 -
 drivers/net/ibm_emac/Makefile         |   11 -
 drivers/net/ibm_emac/ibm_emac.h       |  329 ---
 drivers/net/ibm_emac/ibm_emac_core.c  | 2263 ----------------
 drivers/net/ibm_emac/ibm_emac_core.h  |  222 --
 drivers/net/ibm_emac/ibm_emac_debug.c |  211 --
 drivers/net/ibm_emac/ibm_emac_debug.h |   62 -
 drivers/net/ibm_emac/ibm_emac_mal.c   |  570 ----
 drivers/net/ibm_emac/ibm_emac_mal.h   |  267 --
 drivers/net/ibm_emac/ibm_emac_phy.c   |  398 ---
 drivers/net/ibm_emac/ibm_emac_phy.h   |   80 -
 drivers/net/ibm_emac/ibm_emac_rgmii.c |  200 --
 drivers/net/ibm_emac/ibm_emac_rgmii.h |   64 -
 drivers/net/ibm_emac/ibm_emac_tah.c   |  110 -
 drivers/net/ibm_emac/ibm_emac_tah.h   |   87 -
 drivers/net/ibm_emac/ibm_emac_zmii.c  |  253 --
 drivers/net/ibm_emac/ibm_emac_zmii.h  |   82 -
 drivers/net/mv643xx_eth.c             | 4557 ++++++++++++++-------------------
 drivers/net/sky2.c                    |   66 +-
 drivers/net/sky2.h                    |    1 +
 include/linux/mv643xx_eth.h           |   65 +-
 include/linux/netdevice.h             |    4 +
 include/linux/notifier.h              |    1 +
 net/core/dev.c                        |    6 +
 net/core/net-sysfs.c                  |   13 +
 32 files changed, 2060 insertions(+), 8058 deletions(-)
 delete mode 100644 drivers/net/ibm_emac/Kconfig
 delete mode 100644 drivers/net/ibm_emac/Makefile
 delete mode 100644 drivers/net/ibm_emac/ibm_emac.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.h

Dale Farnsworth (1):
      mv643xx_eth: new maintainer

Jay Vosburgh (2):
      bonding: Rework / fix multiple gratuitous ARP support
      bonding: Allow setting max_bonds to zero

Jeff Kirsher (1):
      MAINTAINERS

Josh Boyer (1):
      ibm_emac: Remove the ibm_emac driver

Lennert Buytenhek (38):
      mv643xx_eth: reverse topological sort of functions
      mv643xx_eth: trim unnecessary includes
      mv643xx_eth: shorten reg names
      mv643xx_eth: get rid of individual port config register bit defines
      mv643xx_eth: get rid of individual port config extend register bit defines
      mv643xx_eth: delete unused SDMA config register bit defines
      mv643xx_eth: delete unused port serial control register bit defines
      mv643xx_eth: nuke port status register bit defines
      mv643xx_eth: remove unused DESC_SIZE define
      mv643xx_eth: clarify irq masking and unmasking
      mv643xx_eth: move PHY wait defines into callers
      mv643xx_eth: get rid of RX_BUF_OFFSET
      mv643xx_eth: move MIB offset defines into their only user
      mv643xx_eth: remove port serial status register bit defines
      mv643xx_eth: clean up rx/tx descriptor field defines
      mv643xx_eth: get rid of ETH_/ethernet_/eth_ prefixes
      mv643xx_eth: use 'mv643xx_eth_' prefix consistently
      mv643xx_eth: kill superfluous comments
      mv643xx_eth: kill ->rx_resource_err
      mv643xx_eth: get rid of hungarian variable naming
      mv643xx_eth: move port_receive() into its only caller
      mv643xx_eth: move rx_return_buff() into its only caller
      mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
      mv643xx_eth: kill private unused instance of struct net_device_stats
      mv643xx_eth: massively simplify multicast address crc8 computation
      mv643xx_eth: split out rx queue state
      mv643xx_eth: split out tx queue state
      mv643xx_eth: remove write-only interrupt coalescing variables
      mv643xx_eth: general cleanup
      mv643xx_eth: add tx rate control
      mv643xx_eth: allow multiple RX queues
      mv643xx_eth: allow multiple TX queues
      mv643xx_eth: work around TX hang hardware issue
      mv643xx_eth: detect extended rx coal register field
      mv643xx_eth: detect alternate TX BW control register location
      mv643xx_eth: be more agressive about RX refill
      mv643xx_eth: add PHY-less mode
      mv643xx_eth: update driver version and author fields

Or Gerlitz (3):
      net/core: add NETDEV_BONDING_FAILOVER event
      bonding: bond_change_active_slave() cleanup under active-backup
      bonding: deliver netdev event for fail-over under the active-backup mode

Stephen Hemminger (5):
      sky2: phy setup changes
      sky2: chip version printout
      sky2: use DEFINE_PCI_DEVICE_TABLE
      sky2: 88E8057 chip support
      sky2: version 1.22

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 8e6b8d3..7fa7fe7 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -376,7 +376,8 @@ max_bonds
 	Specifies the number of bonding devices to create for this
 	instance of the bonding driver.  E.g., if max_bonds is 3, and
 	the bonding driver is not already loaded, then bond0, bond1
-	and bond2 will be created.  The default value is 1.
+	and bond2 will be created.  The default value is 1.  Specifying
+	a value of 0 will load bonding, but will not create any devices.
 
 miimon
 
@@ -539,6 +540,17 @@ mode
 		swapped with the new curr_active_slave that was
 		chosen.
 
+num_grat_arp
+
+	Specifies the number of gratuitous ARPs to be issued after a
+	failover event.  One gratuitous ARP is issued immediately after
+	the failover, subsequent ARPs are sent at a rate of one per link
+	monitor interval (arp_interval or miimon, whichever is active).
+
+	The valid range is 0 - 255; the default value is 1.  This option
+	affects only the active-backup mode.  This option was added for
+	bonding version 3.3.0.
+
 primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
diff --git a/MAINTAINERS b/MAINTAINERS
index cd587ee..d0ea6ec 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2147,6 +2147,8 @@ P:	Jesse Brandeburg
 M:	jesse.brandeburg@intel.com
 P:	Bruce Allan
 M:	bruce.w.allan@intel.com
+P:	PJ Waskiewicz
+M:	peter.p.waskiewicz.jr@intel.com
 P:	John Ronciak
 M:	john.ronciak@intel.com
 L:	e1000-devel@lists.sourceforge.net
@@ -2690,12 +2692,10 @@ L:	libertas-dev@lists.infradead.org
 S:	Maintained
 
 MARVELL MV643XX ETHERNET DRIVER
-P:	Dale Farnsworth
-M:	dale@farnsworth.org
-P:	Manish Lachwani
-M:	mlachwani@mvista.com
+P:	Lennert Buytenhek
+M:	buytenh@marvell.com
 L:	netdev@vger.kernel.org
-S:	Odd Fixes for 2.4; Maintained for 2.6.
+S:	Supported
 
 MATROX FRAMEBUFFER DRIVER
 P:	Petr Vandrovec
@@ -3233,14 +3233,6 @@ L:	linux-kernel@vger.kernel.org
 T:	git git.infradead.org/battery-2.6.git
 S:	Maintained
 
-POWERPC 4xx EMAC DRIVER
-P:	Eugene Surovegin
-M:	ebs@ebshome.net
-W:	http://kernel.ebshome.net/emac/
-L:	linuxppc-dev@ozlabs.org
-L:	netdev@vger.kernel.org
-S:	Maintained
-
 PNP SUPPORT
 P:	Adam Belay
 M:	ambx1@neo.rr.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 20b5367..0e0f669 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1255,7 +1255,6 @@ config IBMVETH
 	  To compile this driver as a module, choose M here. The module will
 	  be called ibmveth.
 
-source "drivers/net/ibm_emac/Kconfig"
 source "drivers/net/ibm_newemac/Kconfig"
 
 config NET_PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c96fe20..c9faa46 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -4,7 +4,6 @@
 
 obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_E1000E) += e1000e/
-obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_IGB) += igb/
 obj-$(CONFIG_IXGBE) += ixgbe/
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5b4af3c..d57b65d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1189,22 +1189,21 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
-		}
 
-		if (new_active && bond->params.fail_over_mac)
-			bond_do_fail_over_mac(bond, new_active, old_active);
+			if (bond->params.fail_over_mac)
+				bond_do_fail_over_mac(bond, new_active,
+						      old_active);
 
-		bond->send_grat_arp = bond->params.num_grat_arp;
-		if (bond->curr_active_slave &&
-			test_bit(__LINK_STATE_LINKWATCH_PENDING,
-					&bond->curr_active_slave->dev->state)) {
-			dprintk("delaying gratuitous arp on %s\n",
-				bond->curr_active_slave->dev->name);
-		} else {
-			if (bond->send_grat_arp > 0) {
-				bond_send_gratuitous_arp(bond);
-				bond->send_grat_arp--;
-			}
+			bond->send_grat_arp = bond->params.num_grat_arp;
+			bond_send_gratuitous_arp(bond);
+
+			write_unlock_bh(&bond->curr_slave_lock);
+			read_unlock(&bond->lock);
+
+			netdev_bonding_change(bond->dev);
+
+			read_lock(&bond->lock);
+			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
 }
@@ -2235,17 +2234,6 @@ static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 	 * program could monitor the link itself if needed.
 	 */
 
-	if (bond->send_grat_arp) {
-		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING,
-				&bond->curr_active_slave->dev->state))
-			dprintk("Needs to send gratuitous arp but not yet\n");
-		else {
-			dprintk("sending delayed gratuitous arp on on %s\n",
-				bond->curr_active_slave->dev->name);
-			bond_send_gratuitous_arp(bond);
-			bond->send_grat_arp--;
-		}
-	}
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2486,6 +2474,13 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->lock);
 		return;
 	}
+
+	if (bond->send_grat_arp) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_arp(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (__bond_mii_monitor(bond, 0)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -2651,6 +2646,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 /*
  * Kick out a gratuitous ARP for an IP on the bonding master plus one
  * for each VLAN above us.
+ *
+ * Caller must hold curr_slave_lock for read or better
  */
 static void bond_send_gratuitous_arp(struct bonding *bond)
 {
@@ -2660,9 +2657,13 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 
 	dprintk("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
 				slave ? slave->dev->name : "NULL");
-	if (!slave)
+
+	if (!slave || !bond->send_grat_arp ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
 		return;
 
+	bond->send_grat_arp--;
+
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
 				bond->master_ip, 0);
@@ -3166,6 +3167,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
+	if (bond->send_grat_arp) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_arp(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3840,6 +3847,7 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_lock_bh(&bond->lock);
 
+	bond->send_grat_arp = 0;
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -4742,11 +4750,11 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
-	if (max_bonds < 1 || max_bonds > INT_MAX) {
+	if (max_bonds < 0 || max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
 		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
-		       max_bonds, 1, INT_MAX, BOND_DEFAULT_MAX_BONDS);
+		       max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
 
@@ -4945,7 +4953,7 @@ static int bond_check_params(struct bond_params *params)
 
 		printk("\n");
 
-	} else {
+	} else if (max_bonds) {
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dd265c6..6caac0f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -53,7 +53,6 @@ extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
 
 static int expected_refcount = -1;
-static struct class *netdev_class;
 /*--------------------------- Data Structures -----------------------------*/
 
 /* Bonding sysfs lock.  Why can't we just use the subsystem lock?
@@ -1447,19 +1446,9 @@ static struct attribute_group bonding_group = {
  */
 int bond_create_sysfs(void)
 {
-	int ret = 0;
-	struct bonding *firstbond;
-
-	/* get the netdev class pointer */
-	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
-	if (!firstbond)
-		return -ENODEV;
-
-	netdev_class = firstbond->dev->dev.class;
-	if (!netdev_class)
-		return -ENODEV;
+	int ret;
 
-	ret = class_create_file(netdev_class, &class_attr_bonding_masters);
+	ret = netdev_class_create_file(&class_attr_bonding_masters);
 	/*
 	 * Permit multiple loads of the module by ignoring failures to
 	 * create the bonding_masters sysfs file.  Bonding devices
@@ -1478,10 +1467,6 @@ int bond_create_sysfs(void)
 			printk(KERN_ERR
 			       "network device named %s already exists in sysfs",
 			       class_attr_bonding_masters.attr.name);
-		else {
-			netdev_class = NULL;
-			return 0;
-		}
 	}
 
 	return ret;
@@ -1493,8 +1478,7 @@ int bond_create_sysfs(void)
  */
 void bond_destroy_sysfs(void)
 {
-	if (netdev_class)
-		class_remove_file(netdev_class, &class_attr_bonding_masters);
+	netdev_class_remove_file(&class_attr_bonding_masters);
 }
 
 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 89fd996..fb730ec 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.5"
-#define DRV_RELDATE	"March 21, 2008"
+#define DRV_VERSION	"3.3.0"
+#define DRV_RELDATE	"June 10, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/ibm_emac/Kconfig b/drivers/net/ibm_emac/Kconfig
deleted file mode 100644
index f61c480..0000000
--- a/drivers/net/ibm_emac/Kconfig
+++ /dev/null
@@ -1,70 +0,0 @@
-config IBM_EMAC
-	tristate "PowerPC 4xx on-chip Ethernet support"
-	depends on 4xx && !PPC_MERGE
-	help
-	  This driver supports the PowerPC 4xx EMAC family of on-chip
-          Ethernet controllers.
-
-config IBM_EMAC_RXB
-	int "Number of receive buffers"
-	depends on IBM_EMAC
-	default "128"
-
-config IBM_EMAC_TXB
-	int "Number of transmit buffers"
-	depends on IBM_EMAC
-	default "64"
-
-config IBM_EMAC_POLL_WEIGHT
-	int "MAL NAPI polling weight"
-	depends on IBM_EMAC
-	default "32"
-
-config IBM_EMAC_RX_COPY_THRESHOLD
-	int "RX skb copy threshold (bytes)"
-	depends on IBM_EMAC
-	default "256"
-
-config IBM_EMAC_RX_SKB_HEADROOM
-	int "Additional RX skb headroom (bytes)"
-	depends on IBM_EMAC
-	default "0"
-	help
-	  Additional receive skb headroom. Note, that driver
-	  will always reserve at least 2 bytes to make IP header
-	  aligned, so usually there is no need to add any additional
-	  headroom.
-
-	  If unsure, set to 0.
-
-config IBM_EMAC_PHY_RX_CLK_FIX
-	bool "PHY Rx clock workaround"
-	depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
-	help
-	  Enable this if EMAC attached to a PHY which doesn't generate
-	  RX clock if there is no link, if this is the case, you will
-	  see "TX disable timeout" or "RX disable timeout" in the system
-	  log.
-
-	  If unsure, say N.
-
-config IBM_EMAC_DEBUG
-	bool "Debugging"
-	depends on IBM_EMAC
-	default n
-
-config IBM_EMAC_ZMII
-	bool
-	depends on IBM_EMAC && (NP405H || NP405L || 44x)
-	default y
-
-config IBM_EMAC_RGMII
-	bool
-	depends on IBM_EMAC && 440GX
-	default y
-
-config IBM_EMAC_TAH
-	bool
-	depends on IBM_EMAC && 440GX
-	default y
-
diff --git a/drivers/net/ibm_emac/Makefile b/drivers/net/ibm_emac/Makefile
deleted file mode 100644
index f98ddf0..0000000
--- a/drivers/net/ibm_emac/Makefile
+++ /dev/null
@@ -1,11 +0,0 @@
-#
-# Makefile for the PowerPC 4xx on-chip ethernet driver
-#
-
-obj-$(CONFIG_IBM_EMAC) += ibm_emac.o
-
-ibm_emac-objs := ibm_emac_mal.o ibm_emac_core.o ibm_emac_phy.o 
-ibm_emac-$(CONFIG_IBM_EMAC_ZMII) += ibm_emac_zmii.o
-ibm_emac-$(CONFIG_IBM_EMAC_RGMII) += ibm_emac_rgmii.o
-ibm_emac-$(CONFIG_IBM_EMAC_TAH) += ibm_emac_tah.o
-ibm_emac-$(CONFIG_IBM_EMAC_DEBUG) += ibm_emac_debug.o
diff --git a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
deleted file mode 100644
index 97ed22b..0000000
--- a/drivers/net/ibm_emac/ibm_emac.h
+++ /dev/null
@@ -1,329 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac.h
- *
- * Register definitions for PowerPC 4xx on-chip ethernet contoller
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Matt Porter <mporter@kernel.crashing.org>
- *      Armin Kuster <akuster@mvista.com>
- * 	Copyright 2002-2004 MontaVista Software Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __IBM_EMAC_H_
-#define __IBM_EMAC_H_
-
-#include <linux/types.h>
-
-/* This is a simple check to prevent use of this driver on non-tested SoCs */
-#if !defined(CONFIG_405GP) && !defined(CONFIG_405GPR) && !defined(CONFIG_405EP) && \
-    !defined(CONFIG_440GP) && !defined(CONFIG_440GX) && !defined(CONFIG_440SP) && \
-    !defined(CONFIG_440EP) && !defined(CONFIG_NP405H) && !defined(CONFIG_440SPE) && \
-    !defined(CONFIG_440GR)
-#error	"Unknown SoC. Please, check chip user manual and make sure EMAC defines are OK"
-#endif
-
-/* EMAC registers 		Write Access rules */
-struct emac_regs {
-	u32 mr0;		/* special 	*/
-	u32 mr1;		/* Reset 	*/
-	u32 tmr0;		/* special 	*/
-	u32 tmr1;		/* special 	*/
-	u32 rmr;		/* Reset 	*/
-	u32 isr;		/* Always 	*/
-	u32 iser;		/* Reset 	*/
-	u32 iahr;		/* Reset, R, T 	*/
-	u32 ialr;		/* Reset, R, T 	*/
-	u32 vtpid;		/* Reset, R, T 	*/
-	u32 vtci;		/* Reset, R, T 	*/
-	u32 ptr;		/* Reset,    T 	*/
-	u32 iaht1;		/* Reset, R	*/
-	u32 iaht2;		/* Reset, R	*/
-	u32 iaht3;		/* Reset, R	*/
-	u32 iaht4;		/* Reset, R	*/
-	u32 gaht1;		/* Reset, R	*/
-	u32 gaht2;		/* Reset, R	*/
-	u32 gaht3;		/* Reset, R	*/
-	u32 gaht4;		/* Reset, R	*/
-	u32 lsah;
-	u32 lsal;
-	u32 ipgvr;		/* Reset,    T 	*/
-	u32 stacr;		/* special 	*/
-	u32 trtr;		/* special 	*/
-	u32 rwmr;		/* Reset 	*/
-	u32 octx;
-	u32 ocrx;
-	u32 ipcr;
-};
-
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_ETHTOOL_REGS_VER		0
-#define EMAC_ETHTOOL_REGS_SIZE		(sizeof(struct emac_regs) - sizeof(u32))
-#else
-#define EMAC_ETHTOOL_REGS_VER		1
-#define EMAC_ETHTOOL_REGS_SIZE		sizeof(struct emac_regs)
-#endif
-
-/* EMACx_MR0 */
-#define EMAC_MR0_RXI			0x80000000
-#define EMAC_MR0_TXI			0x40000000
-#define EMAC_MR0_SRST			0x20000000
-#define EMAC_MR0_TXE			0x10000000
-#define EMAC_MR0_RXE			0x08000000
-#define EMAC_MR0_WKE			0x04000000
-
-/* EMACx_MR1 */
-#define EMAC_MR1_FDE			0x80000000
-#define EMAC_MR1_ILE			0x40000000
-#define EMAC_MR1_VLE			0x20000000
-#define EMAC_MR1_EIFC			0x10000000
-#define EMAC_MR1_APP			0x08000000
-#define EMAC_MR1_IST			0x01000000
-
-#define EMAC_MR1_MF_MASK		0x00c00000
-#define EMAC_MR1_MF_10			0x00000000
-#define EMAC_MR1_MF_100			0x00400000
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_MR1_MF_1000		0x00000000
-#define EMAC_MR1_MF_1000GPCS		0x00000000
-#define EMAC_MR1_MF_IPPA(id)		0x00000000
-#else
-#define EMAC_MR1_MF_1000		0x00800000
-#define EMAC_MR1_MF_1000GPCS		0x00c00000
-#define EMAC_MR1_MF_IPPA(id)		(((id) & 0x1f) << 6)
-#endif
-
-#define EMAC_TX_FIFO_SIZE		2048
-
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_MR1_RFS_4K			0x00300000
-#define EMAC_MR1_RFS_16K		0x00000000
-#define EMAC_RX_FIFO_SIZE(gige)		4096
-#define EMAC_MR1_TFS_2K			0x00080000
-#define EMAC_MR1_TR0_MULT		0x00008000
-#define EMAC_MR1_JPSM			0x00000000
-#define EMAC_MR1_MWSW_001		0x00000000
-#define EMAC_MR1_BASE(opb)		(EMAC_MR1_TFS_2K | EMAC_MR1_TR0_MULT)
-#else
-#define EMAC_MR1_RFS_4K			0x00180000
-#define EMAC_MR1_RFS_16K		0x00280000
-#define EMAC_RX_FIFO_SIZE(gige)		((gige) ? 16384 : 4096)
-#define EMAC_MR1_TFS_2K			0x00020000
-#define EMAC_MR1_TR			0x00008000
-#define EMAC_MR1_MWSW_001		0x00001000
-#define EMAC_MR1_JPSM			0x00000800
-#define EMAC_MR1_OBCI_MASK		0x00000038
-#define EMAC_MR1_OBCI_50		0x00000000
-#define EMAC_MR1_OBCI_66		0x00000008
-#define EMAC_MR1_OBCI_83		0x00000010
-#define EMAC_MR1_OBCI_100		0x00000018
-#define EMAC_MR1_OBCI_100P		0x00000020
-#define EMAC_MR1_OBCI(freq)		((freq) <= 50  ? EMAC_MR1_OBCI_50 : \
-					 (freq) <= 66  ? EMAC_MR1_OBCI_66 : \
-					 (freq) <= 83  ? EMAC_MR1_OBCI_83 : \
-					 (freq) <= 100 ? EMAC_MR1_OBCI_100 : EMAC_MR1_OBCI_100P)
-#define EMAC_MR1_BASE(opb)		(EMAC_MR1_TFS_2K | EMAC_MR1_TR | \
-					 EMAC_MR1_OBCI(opb))
-#endif
-
-/* EMACx_TMR0 */
-#define EMAC_TMR0_GNP			0x80000000
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_TMR0_DEFAULT		0x00000000	
-#else
-#define EMAC_TMR0_TFAE_2_32		0x00000001
-#define EMAC_TMR0_TFAE_4_64		0x00000002
-#define EMAC_TMR0_TFAE_8_128		0x00000003
-#define EMAC_TMR0_TFAE_16_256		0x00000004
-#define EMAC_TMR0_TFAE_32_512		0x00000005
-#define EMAC_TMR0_TFAE_64_1024		0x00000006
-#define EMAC_TMR0_TFAE_128_2048		0x00000007
-#define EMAC_TMR0_DEFAULT		EMAC_TMR0_TFAE_2_32
-#endif
-#define EMAC_TMR0_XMIT			(EMAC_TMR0_GNP | EMAC_TMR0_DEFAULT)
-
-/* EMACx_TMR1 */
-
-/* IBM manuals are not very clear here. 
- * This is my interpretation of how things are. --ebs
- */
-#if defined(CONFIG_40x)
-#define EMAC_FIFO_ENTRY_SIZE		8
-#define EMAC_MAL_BURST_SIZE		(16 * 4)
-#else
-#define EMAC_FIFO_ENTRY_SIZE		16
-#define EMAC_MAL_BURST_SIZE		(64 * 4)
-#endif
-
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_TMR1(l,h)			(((l) << 27) | (((h) & 0xff) << 16))
-#else
-#define EMAC_TMR1(l,h)			(((l) << 27) | (((h) & 0x3ff) << 14))
-#endif
-
-/* EMACx_RMR */
-#define EMAC_RMR_SP			0x80000000
-#define EMAC_RMR_SFCS			0x40000000
-#define EMAC_RMR_RRP			0x20000000
-#define EMAC_RMR_RFP			0x10000000
-#define EMAC_RMR_ROP			0x08000000
-#define EMAC_RMR_RPIR			0x04000000
-#define EMAC_RMR_PPP			0x02000000
-#define EMAC_RMR_PME			0x01000000
-#define EMAC_RMR_PMME			0x00800000
-#define EMAC_RMR_IAE			0x00400000
-#define EMAC_RMR_MIAE			0x00200000
-#define EMAC_RMR_BAE			0x00100000
-#define EMAC_RMR_MAE			0x00080000
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_RMR_BASE			0x00000000
-#else
-#define EMAC_RMR_RFAF_2_32		0x00000001
-#define EMAC_RMR_RFAF_4_64		0x00000002
-#define EMAC_RMR_RFAF_8_128		0x00000003
-#define EMAC_RMR_RFAF_16_256		0x00000004
-#define EMAC_RMR_RFAF_32_512		0x00000005
-#define EMAC_RMR_RFAF_64_1024		0x00000006
-#define EMAC_RMR_RFAF_128_2048		0x00000007
-#define EMAC_RMR_BASE			EMAC_RMR_RFAF_128_2048
-#endif
-
-/* EMACx_ISR & EMACx_ISER */
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_ISR_TXPE			0x00000000
-#define EMAC_ISR_RXPE			0x00000000
-#define EMAC_ISR_TXUE			0x00000000
-#define EMAC_ISR_RXOE			0x00000000
-#else
-#define EMAC_ISR_TXPE			0x20000000
-#define EMAC_ISR_RXPE			0x10000000
-#define EMAC_ISR_TXUE			0x08000000
-#define EMAC_ISR_RXOE			0x04000000
-#endif
-#define EMAC_ISR_OVR			0x02000000
-#define EMAC_ISR_PP			0x01000000
-#define EMAC_ISR_BP			0x00800000
-#define EMAC_ISR_RP			0x00400000
-#define EMAC_ISR_SE			0x00200000
-#define EMAC_ISR_ALE			0x00100000
-#define EMAC_ISR_BFCS			0x00080000
-#define EMAC_ISR_PTLE			0x00040000
-#define EMAC_ISR_ORE			0x00020000
-#define EMAC_ISR_IRE			0x00010000
-#define EMAC_ISR_SQE			0x00000080
-#define EMAC_ISR_TE			0x00000040
-#define EMAC_ISR_MOS			0x00000002
-#define EMAC_ISR_MOF			0x00000001
-
-/* EMACx_STACR */
-#define EMAC_STACR_PHYD_MASK		0xffff
-#define EMAC_STACR_PHYD_SHIFT		16
-#define EMAC_STACR_OC			0x00008000
-#define EMAC_STACR_PHYE			0x00004000
-#define EMAC_STACR_STAC_MASK		0x00003000
-#define EMAC_STACR_STAC_READ		0x00001000
-#define EMAC_STACR_STAC_WRITE		0x00002000
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_STACR_OPBC_MASK		0x00000C00
-#define EMAC_STACR_OPBC_50		0x00000000
-#define EMAC_STACR_OPBC_66		0x00000400
-#define EMAC_STACR_OPBC_83		0x00000800
-#define EMAC_STACR_OPBC_100		0x00000C00
-#define EMAC_STACR_OPBC(freq)		((freq) <= 50 ? EMAC_STACR_OPBC_50 : \
-					 (freq) <= 66 ? EMAC_STACR_OPBC_66 : \
-					 (freq) <= 83 ? EMAC_STACR_OPBC_83 : EMAC_STACR_OPBC_100)
-#define EMAC_STACR_BASE(opb)		EMAC_STACR_OPBC(opb)
-#else
-#define EMAC_STACR_BASE(opb)		0x00000000
-#endif
-#define EMAC_STACR_PCDA_MASK		0x1f
-#define EMAC_STACR_PCDA_SHIFT		5
-#define EMAC_STACR_PRA_MASK		0x1f
-
-/*
- * For the 440SPe, AMCC inexplicably changed the polarity of
- * the "operation complete" bit in the MII control register.
- */
-#if defined(CONFIG_440SPE)
-static inline int emac_phy_done(u32 stacr)
-{
-	return !(stacr & EMAC_STACR_OC);
-};
-#define EMAC_STACR_START 		EMAC_STACR_OC
-
-#else /* CONFIG_440SPE */
-static inline int emac_phy_done(u32 stacr)
-{
-	return stacr & EMAC_STACR_OC;
-};
-#define EMAC_STACR_START 		0
-#endif /* !CONFIG_440SPE */
-
-/* EMACx_TRTR */
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_TRTR_SHIFT			27
-#else
-#define EMAC_TRTR_SHIFT			24
-#endif
-#define EMAC_TRTR(size)			((((size) >> 6) - 1) << EMAC_TRTR_SHIFT)
-
-/* EMACx_RWMR */
-#if !defined(CONFIG_IBM_EMAC4)
-#define EMAC_RWMR(l,h)			(((l) << 23) | ( ((h) & 0x1ff) << 7))	
-#else
-#define EMAC_RWMR(l,h)			(((l) << 22) | ( ((h) & 0x3ff) << 6))	
-#endif
-
-/* EMAC specific TX descriptor control fields (write access) */
-#define EMAC_TX_CTRL_GFCS		0x0200
-#define EMAC_TX_CTRL_GP			0x0100
-#define EMAC_TX_CTRL_ISA		0x0080
-#define EMAC_TX_CTRL_RSA		0x0040
-#define EMAC_TX_CTRL_IVT		0x0020
-#define EMAC_TX_CTRL_RVT		0x0010
-#define EMAC_TX_CTRL_TAH_CSUM		0x000e
-
-/* EMAC specific TX descriptor status fields (read access) */
-#define EMAC_TX_ST_BFCS			0x0200
-#define EMAC_TX_ST_LCS			0x0080
-#define EMAC_TX_ST_ED			0x0040
-#define EMAC_TX_ST_EC			0x0020
-#define EMAC_TX_ST_LC			0x0010
-#define EMAC_TX_ST_MC			0x0008
-#define EMAC_TX_ST_SC			0x0004
-#define EMAC_TX_ST_UR			0x0002
-#define EMAC_TX_ST_SQE			0x0001
-#if !defined(CONFIG_IBM_EMAC_TAH)
-#define EMAC_IS_BAD_TX(v)		((v) & (EMAC_TX_ST_LCS | EMAC_TX_ST_ED | \
-					 EMAC_TX_ST_EC | EMAC_TX_ST_LC | \
-					 EMAC_TX_ST_MC | EMAC_TX_ST_UR))
-#else
-#define EMAC_IS_BAD_TX(v)		((v) & (EMAC_TX_ST_LCS | EMAC_TX_ST_ED | \
-					 EMAC_TX_ST_EC | EMAC_TX_ST_LC))
-#endif					 
-
-/* EMAC specific RX descriptor status fields (read access) */
-#define EMAC_RX_ST_OE			0x0200
-#define EMAC_RX_ST_PP			0x0100
-#define EMAC_RX_ST_BP			0x0080
-#define EMAC_RX_ST_RP			0x0040
-#define EMAC_RX_ST_SE			0x0020
-#define EMAC_RX_ST_AE			0x0010
-#define EMAC_RX_ST_BFCS			0x0008
-#define EMAC_RX_ST_PTL			0x0004
-#define EMAC_RX_ST_ORE			0x0002
-#define EMAC_RX_ST_IRE			0x0001
-#define EMAC_RX_TAH_BAD_CSUM		0x0003
-#define EMAC_BAD_RX_MASK		(EMAC_RX_ST_OE | EMAC_RX_ST_BP | \
-					 EMAC_RX_ST_RP | EMAC_RX_ST_SE | \
-					 EMAC_RX_ST_AE | EMAC_RX_ST_BFCS | \
-					 EMAC_RX_ST_PTL | EMAC_RX_ST_ORE | \
-					 EMAC_RX_ST_IRE )
-#endif /* __IBM_EMAC_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
deleted file mode 100644
index 73664f2..0000000
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ /dev/null
@@ -1,2263 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_core.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- * 	Matt Porter <mporter@kernel.crashing.org>
- *	(c) 2003 Benjamin Herrenschmidt <benh@kernel.crashing.org>
- *      Armin Kuster <akuster@mvista.com>
- * 	Johnnie Peters <jpeters@mvista.com>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/delay.h>
-#include <linux/init.h>
-#include <linux/types.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/crc32.h>
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/bitops.h>
-
-#include <asm/processor.h>
-#include <asm/io.h>
-#include <asm/dma.h>
-#include <asm/uaccess.h>
-#include <asm/ocp.h>
-
-#include "ibm_emac_core.h"
-#include "ibm_emac_debug.h"
-
-/*
- * Lack of dma_unmap_???? calls is intentional.
- *
- * API-correct usage requires additional support state information to be 
- * maintained for every RX and TX buffer descriptor (BD). Unfortunately, due to
- * EMAC design (e.g. TX buffer passed from network stack can be split into
- * several BDs, dma_map_single/dma_map_page can be used to map particular BD),
- * maintaining such information will add additional overhead.
- * Current DMA API implementation for 4xx processors only ensures cache coherency
- * and dma_unmap_???? routines are empty and are likely to stay this way.
- * I decided to omit dma_unmap_??? calls because I don't want to add additional
- * complexity just for the sake of following some abstract API, when it doesn't
- * add any real benefit to the driver. I understand that this decision maybe 
- * controversial, but I really tried to make code API-correct and efficient 
- * at the same time and didn't come up with code I liked :(.                --ebs
- */
-
-#define DRV_NAME        "emac"
-#define DRV_VERSION     "3.54"
-#define DRV_DESC        "PPC 4xx OCP EMAC driver"
-
-MODULE_DESCRIPTION(DRV_DESC);
-MODULE_AUTHOR
-    ("Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>");
-MODULE_LICENSE("GPL");
-
-/* minimum number of free TX descriptors required to wake up TX process */
-#define EMAC_TX_WAKEUP_THRESH		(NUM_TX_BUFF / 4)
-
-/* If packet size is less than this number, we allocate small skb and copy packet 
- * contents into it instead of just sending original big skb up
- */
-#define EMAC_RX_COPY_THRESH		CONFIG_IBM_EMAC_RX_COPY_THRESHOLD
-
-/* Since multiple EMACs share MDIO lines in various ways, we need
- * to avoid re-using the same PHY ID in cases where the arch didn't
- * setup precise phy_map entries
- */
-static u32 busy_phy_map;
-
-#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX) && \
-    (defined(CONFIG_405EP) || defined(CONFIG_440EP) || defined(CONFIG_440GR))
-/* 405EP has "EMAC to PHY Control Register" (CPC0_EPCTL) which can help us
- * with PHY RX clock problem.
- * 440EP/440GR has more sane SDR0_MFR register implementation than 440GX, which
- * also allows controlling each EMAC clock
- */
-static inline void EMAC_RX_CLK_TX(int idx)
-{
-	unsigned long flags;
-	local_irq_save(flags);
-
-#if defined(CONFIG_405EP)
-	mtdcr(0xf3, mfdcr(0xf3) | (1 << idx));
-#else /* CONFIG_440EP || CONFIG_440GR */
-	SDR_WRITE(DCRN_SDR_MFR, SDR_READ(DCRN_SDR_MFR) | (0x08000000 >> idx));
-#endif
-
-	local_irq_restore(flags);
-}
-
-static inline void EMAC_RX_CLK_DEFAULT(int idx)
-{
-	unsigned long flags;
-	local_irq_save(flags);
-
-#if defined(CONFIG_405EP)
-	mtdcr(0xf3, mfdcr(0xf3) & ~(1 << idx));
-#else /* CONFIG_440EP */
-	SDR_WRITE(DCRN_SDR_MFR, SDR_READ(DCRN_SDR_MFR) & ~(0x08000000 >> idx));
-#endif
-
-	local_irq_restore(flags);
-}
-#else
-#define EMAC_RX_CLK_TX(idx)		((void)0)
-#define EMAC_RX_CLK_DEFAULT(idx)	((void)0)
-#endif
-
-#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX) && defined(CONFIG_440GX)
-/* We can switch Ethernet clock to the internal source through SDR0_MFR[ECS],
- * unfortunately this is less flexible than 440EP case, because it's a global 
- * setting for all EMACs, therefore we do this clock trick only during probe.
- */
-#define EMAC_CLK_INTERNAL		SDR_WRITE(DCRN_SDR_MFR, \
-					    SDR_READ(DCRN_SDR_MFR) | 0x08000000)
-#define EMAC_CLK_EXTERNAL		SDR_WRITE(DCRN_SDR_MFR, \
-					    SDR_READ(DCRN_SDR_MFR) & ~0x08000000)
-#else
-#define EMAC_CLK_INTERNAL		((void)0)
-#define EMAC_CLK_EXTERNAL		((void)0)
-#endif
-
-/* I don't want to litter system log with timeout errors 
- * when we have brain-damaged PHY.
- */
-static inline void emac_report_timeout_error(struct ocp_enet_private *dev,
-					     const char *error)
-{
-#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX)
-	DBG("%d: %s" NL, dev->def->index, error);
-#else
-	if (net_ratelimit())
-		printk(KERN_ERR "emac%d: %s\n", dev->def->index, error);
-#endif
-}
-
-/* PHY polling intervals */
-#define PHY_POLL_LINK_ON	HZ
-#define PHY_POLL_LINK_OFF	(HZ / 5)
-
-/* Graceful stop timeouts in us. 
- * We should allow up to 1 frame time (full-duplex, ignoring collisions) 
- */
-#define STOP_TIMEOUT_10		1230	
-#define STOP_TIMEOUT_100	124
-#define STOP_TIMEOUT_1000	13
-#define STOP_TIMEOUT_1000_JUMBO	73
-
-/* Please, keep in sync with struct ibm_emac_stats/ibm_emac_error_stats */
-static const char emac_stats_keys[EMAC_ETHTOOL_STATS_COUNT][ETH_GSTRING_LEN] = {
-	"rx_packets", "rx_bytes", "tx_packets", "tx_bytes", "rx_packets_csum",
-	"tx_packets_csum", "tx_undo", "rx_dropped_stack", "rx_dropped_oom",
-	"rx_dropped_error", "rx_dropped_resize", "rx_dropped_mtu",
-	"rx_stopped", "rx_bd_errors", "rx_bd_overrun", "rx_bd_bad_packet",
-	"rx_bd_runt_packet", "rx_bd_short_event", "rx_bd_alignment_error",
-	"rx_bd_bad_fcs", "rx_bd_packet_too_long", "rx_bd_out_of_range",
-	"rx_bd_in_range", "rx_parity", "rx_fifo_overrun", "rx_overrun",
-	"rx_bad_packet", "rx_runt_packet", "rx_short_event",
-	"rx_alignment_error", "rx_bad_fcs", "rx_packet_too_long",
-	"rx_out_of_range", "rx_in_range", "tx_dropped", "tx_bd_errors",
-	"tx_bd_bad_fcs", "tx_bd_carrier_loss", "tx_bd_excessive_deferral",
-	"tx_bd_excessive_collisions", "tx_bd_late_collision",
-	"tx_bd_multple_collisions", "tx_bd_single_collision",
-	"tx_bd_underrun", "tx_bd_sqe", "tx_parity", "tx_underrun", "tx_sqe",
-	"tx_errors"
-};
-
-static irqreturn_t emac_irq(int irq, void *dev_instance);
-static void emac_clean_tx_ring(struct ocp_enet_private *dev);
-
-static inline int emac_phy_supports_gige(int phy_mode)
-{
-	return  phy_mode == PHY_MODE_GMII ||
-		phy_mode == PHY_MODE_RGMII ||
-		phy_mode == PHY_MODE_TBI ||
-		phy_mode == PHY_MODE_RTBI;
-}
-
-static inline int emac_phy_gpcs(int phy_mode)
-{
-	return  phy_mode == PHY_MODE_TBI ||
-		phy_mode == PHY_MODE_RTBI;
-}
-
-static inline void emac_tx_enable(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	u32 r;
-
-	local_irq_save(flags);
-
-	DBG("%d: tx_enable" NL, dev->def->index);
-
-	r = in_be32(&p->mr0);
-	if (!(r & EMAC_MR0_TXE))
-		out_be32(&p->mr0, r | EMAC_MR0_TXE);
-	local_irq_restore(flags);
-}
-
-static void emac_tx_disable(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	u32 r;
-
-	local_irq_save(flags);
-
-	DBG("%d: tx_disable" NL, dev->def->index);
-
-	r = in_be32(&p->mr0);
-	if (r & EMAC_MR0_TXE) {
-		int n = dev->stop_timeout;
-		out_be32(&p->mr0, r & ~EMAC_MR0_TXE);
-		while (!(in_be32(&p->mr0) & EMAC_MR0_TXI) && n) {
-			udelay(1);
-			--n;
-		}	
-		if (unlikely(!n))
-			emac_report_timeout_error(dev, "TX disable timeout");
-	}
-	local_irq_restore(flags);
-}
-
-static void emac_rx_enable(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	u32 r;
-
-	local_irq_save(flags);
-	if (unlikely(dev->commac.rx_stopped))
-		goto out;
-
-	DBG("%d: rx_enable" NL, dev->def->index);
-
-	r = in_be32(&p->mr0);
-	if (!(r & EMAC_MR0_RXE)) {
-		if (unlikely(!(r & EMAC_MR0_RXI))) {
-			/* Wait if previous async disable is still in progress */
-			int n = dev->stop_timeout;
-			while (!(r = in_be32(&p->mr0) & EMAC_MR0_RXI) && n) {
-				udelay(1);
-				--n;
-			}	
-			if (unlikely(!n))
-				emac_report_timeout_error(dev,
-							  "RX disable timeout");
-		}
-		out_be32(&p->mr0, r | EMAC_MR0_RXE);
-	}
-      out:
-	local_irq_restore(flags);
-}
-
-static void emac_rx_disable(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	u32 r;
-
-	local_irq_save(flags);
-
-	DBG("%d: rx_disable" NL, dev->def->index);
-
-	r = in_be32(&p->mr0);
-	if (r & EMAC_MR0_RXE) {
-		int n = dev->stop_timeout;
-		out_be32(&p->mr0, r & ~EMAC_MR0_RXE);
-		while (!(in_be32(&p->mr0) & EMAC_MR0_RXI) && n) {
-			udelay(1);
-			--n;
-		}	
-		if (unlikely(!n))
-			emac_report_timeout_error(dev, "RX disable timeout");
-	}
-	local_irq_restore(flags);
-}
-
-static inline void emac_rx_disable_async(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	u32 r;
-
-	local_irq_save(flags);
-
-	DBG("%d: rx_disable_async" NL, dev->def->index);
-
-	r = in_be32(&p->mr0);
-	if (r & EMAC_MR0_RXE)
-		out_be32(&p->mr0, r & ~EMAC_MR0_RXE);
-	local_irq_restore(flags);
-}
-
-static int emac_reset(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	unsigned long flags;
-	int n = 20;
-
-	DBG("%d: reset" NL, dev->def->index);
-
-	local_irq_save(flags);
-
-	if (!dev->reset_failed) {
-		/* 40x erratum suggests stopping RX channel before reset,
-		 * we stop TX as well
-		 */
-		emac_rx_disable(dev);
-		emac_tx_disable(dev);
-	}
-
-	out_be32(&p->mr0, EMAC_MR0_SRST);
-	while ((in_be32(&p->mr0) & EMAC_MR0_SRST) && n)
-		--n;
-	local_irq_restore(flags);
-
-	if (n) {
-		dev->reset_failed = 0;
-		return 0;
-	} else {
-		emac_report_timeout_error(dev, "reset timeout");
-		dev->reset_failed = 1;
-		return -ETIMEDOUT;
-	}
-}
-
-static void emac_hash_mc(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	u16 gaht[4] = { 0 };
-	struct dev_mc_list *dmi;
-
-	DBG("%d: hash_mc %d" NL, dev->def->index, dev->ndev->mc_count);
-
-	for (dmi = dev->ndev->mc_list; dmi; dmi = dmi->next) {
-		int bit;
-		DECLARE_MAC_BUF(mac);
-		DBG2("%d: mc %s" NL,
-		     dev->def->index, print_mac(mac, dmi->dmi_addr));
-
-		bit = 63 - (ether_crc(ETH_ALEN, dmi->dmi_addr) >> 26);
-		gaht[bit >> 4] |= 0x8000 >> (bit & 0x0f);
-	}
-	out_be32(&p->gaht1, gaht[0]);
-	out_be32(&p->gaht2, gaht[1]);
-	out_be32(&p->gaht3, gaht[2]);
-	out_be32(&p->gaht4, gaht[3]);
-}
-
-static inline u32 emac_iff2rmr(struct net_device *ndev)
-{
-	u32 r = EMAC_RMR_SP | EMAC_RMR_SFCS | EMAC_RMR_IAE | EMAC_RMR_BAE |
-	    EMAC_RMR_BASE;
-
-	if (ndev->flags & IFF_PROMISC)
-		r |= EMAC_RMR_PME;
-	else if (ndev->flags & IFF_ALLMULTI || ndev->mc_count > 32)
-		r |= EMAC_RMR_PMME;
-	else if (ndev->mc_count > 0)
-		r |= EMAC_RMR_MAE;
-
-	return r;
-}
-
-static inline int emac_opb_mhz(void)
-{
-	return (ocp_sys_info.opb_bus_freq + 500000) / 1000000;
-}
-
-/* BHs disabled */
-static int emac_configure(struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	struct net_device *ndev = dev->ndev;
-	int gige;
-	u32 r;
-
-	DBG("%d: configure" NL, dev->def->index);
-
-	if (emac_reset(dev) < 0)
-		return -ETIMEDOUT;
-
-	tah_reset(dev->tah_dev);
-
-	/* Mode register */
-	r = EMAC_MR1_BASE(emac_opb_mhz()) | EMAC_MR1_VLE | EMAC_MR1_IST;
-	if (dev->phy.duplex == DUPLEX_FULL)
-		r |= EMAC_MR1_FDE | EMAC_MR1_MWSW_001;
-	dev->stop_timeout = STOP_TIMEOUT_10;
-	switch (dev->phy.speed) {
-	case SPEED_1000:
-		if (emac_phy_gpcs(dev->phy.mode)) {
-			r |= EMAC_MR1_MF_1000GPCS |
-			    EMAC_MR1_MF_IPPA(dev->phy.address);
-
-			/* Put some arbitrary OUI, Manuf & Rev IDs so we can
-			 * identify this GPCS PHY later.
-			 */
-			out_be32(&p->ipcr, 0xdeadbeef);
-		} else
-			r |= EMAC_MR1_MF_1000;
-		r |= EMAC_MR1_RFS_16K;
-		gige = 1;
-
-		if (dev->ndev->mtu > ETH_DATA_LEN) {
-			r |= EMAC_MR1_JPSM;
-			dev->stop_timeout = STOP_TIMEOUT_1000_JUMBO;
-		} else
-			dev->stop_timeout = STOP_TIMEOUT_1000;
-		break;
-	case SPEED_100:
-		r |= EMAC_MR1_MF_100;
-		dev->stop_timeout = STOP_TIMEOUT_100;
-		/* Fall through */
-	default:
-		r |= EMAC_MR1_RFS_4K;
-		gige = 0;
-		break;
-	}
-
-	if (dev->rgmii_dev)
-		rgmii_set_speed(dev->rgmii_dev, dev->rgmii_input,
-				dev->phy.speed);
-	else
-		zmii_set_speed(dev->zmii_dev, dev->zmii_input, dev->phy.speed);
-
-#if !defined(CONFIG_40x)
-	/* on 40x erratum forces us to NOT use integrated flow control, 
-	 * let's hope it works on 44x ;)
-	 */
-	if (dev->phy.duplex == DUPLEX_FULL) {
-		if (dev->phy.pause)
-			r |= EMAC_MR1_EIFC | EMAC_MR1_APP;
-		else if (dev->phy.asym_pause)
-			r |= EMAC_MR1_APP;
-	}
-#endif
-	out_be32(&p->mr1, r);
-
-	/* Set individual MAC address */
-	out_be32(&p->iahr, (ndev->dev_addr[0] << 8) | ndev->dev_addr[1]);
-	out_be32(&p->ialr, (ndev->dev_addr[2] << 24) |
-		 (ndev->dev_addr[3] << 16) | (ndev->dev_addr[4] << 8) |
-		 ndev->dev_addr[5]);
-
-	/* VLAN Tag Protocol ID */
-	out_be32(&p->vtpid, 0x8100);
-
-	/* Receive mode register */
-	r = emac_iff2rmr(ndev);
-	if (r & EMAC_RMR_MAE)
-		emac_hash_mc(dev);
-	out_be32(&p->rmr, r);
-
-	/* FIFOs thresholds */
-	r = EMAC_TMR1((EMAC_MAL_BURST_SIZE / EMAC_FIFO_ENTRY_SIZE) + 1,
-		      EMAC_TX_FIFO_SIZE / 2 / EMAC_FIFO_ENTRY_SIZE);
-	out_be32(&p->tmr1, r);
-	out_be32(&p->trtr, EMAC_TRTR(EMAC_TX_FIFO_SIZE / 2));
-
-	/* PAUSE frame is sent when RX FIFO reaches its high-water mark,
-	   there should be still enough space in FIFO to allow the our link
-	   partner time to process this frame and also time to send PAUSE 
-	   frame itself.
-
-	   Here is the worst case scenario for the RX FIFO "headroom"
-	   (from "The Switch Book") (100Mbps, without preamble, inter-frame gap):
-
-	   1) One maximum-length frame on TX                    1522 bytes
-	   2) One PAUSE frame time                                64 bytes
-	   3) PAUSE frame decode time allowance                   64 bytes
-	   4) One maximum-length frame on RX                    1522 bytes
-	   5) Round-trip propagation delay of the link (100Mb)    15 bytes
-	   ----------       
-	   3187 bytes
-
-	   I chose to set high-water mark to RX_FIFO_SIZE / 4 (1024 bytes)
-	   low-water mark  to RX_FIFO_SIZE / 8 (512 bytes)
-	 */
-	r = EMAC_RWMR(EMAC_RX_FIFO_SIZE(gige) / 8 / EMAC_FIFO_ENTRY_SIZE,
-		      EMAC_RX_FIFO_SIZE(gige) / 4 / EMAC_FIFO_ENTRY_SIZE);
-	out_be32(&p->rwmr, r);
-
-	/* Set PAUSE timer to the maximum */
-	out_be32(&p->ptr, 0xffff);
-
-	/* IRQ sources */
-	out_be32(&p->iser, EMAC_ISR_TXPE | EMAC_ISR_RXPE | /* EMAC_ISR_TXUE |
-		 EMAC_ISR_RXOE | */ EMAC_ISR_OVR | EMAC_ISR_BP | EMAC_ISR_SE |
-		 EMAC_ISR_ALE | EMAC_ISR_BFCS | EMAC_ISR_PTLE | EMAC_ISR_ORE |
-		 EMAC_ISR_IRE | EMAC_ISR_TE);
-		 
-	/* We need to take GPCS PHY out of isolate mode after EMAC reset */
-	if (emac_phy_gpcs(dev->phy.mode)) 
-		mii_reset_phy(&dev->phy);
-		 
-	return 0;
-}
-
-/* BHs disabled */
-static void emac_reinitialize(struct ocp_enet_private *dev)
-{
-	DBG("%d: reinitialize" NL, dev->def->index);
-
-	if (!emac_configure(dev)) {
-		emac_tx_enable(dev);
-		emac_rx_enable(dev);
-	}
-}
-
-/* BHs disabled */
-static void emac_full_tx_reset(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-	DBG("%d: full_tx_reset" NL, dev->def->index);
-
-	emac_tx_disable(dev);
-	mal_disable_tx_channel(dev->mal, emacdata->mal_tx_chan);
-	emac_clean_tx_ring(dev);
-	dev->tx_cnt = dev->tx_slot = dev->ack_slot = 0;
-
-	emac_configure(dev);
-
-	mal_enable_tx_channel(dev->mal, emacdata->mal_tx_chan);
-	emac_tx_enable(dev);
-	emac_rx_enable(dev);
-
-	netif_wake_queue(ndev);
-}
-
-static int __emac_mdio_read(struct ocp_enet_private *dev, u8 id, u8 reg)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	u32 r;
-	int n;
-
-	DBG2("%d: mdio_read(%02x,%02x)" NL, dev->def->index, id, reg);
-
-	/* Enable proper MDIO port */
-	zmii_enable_mdio(dev->zmii_dev, dev->zmii_input);
-
-	/* Wait for management interface to become idle */
-	n = 10;
-	while (!emac_phy_done(in_be32(&p->stacr))) {
-		udelay(1);
-		if (!--n)
-			goto to;
-	}
-
-	/* Issue read command */
-	out_be32(&p->stacr,
-		 EMAC_STACR_BASE(emac_opb_mhz()) | EMAC_STACR_STAC_READ |
-		 (reg & EMAC_STACR_PRA_MASK)
-		 | ((id & EMAC_STACR_PCDA_MASK) << EMAC_STACR_PCDA_SHIFT)
-		 | EMAC_STACR_START);
-
-	/* Wait for read to complete */
-	n = 100;
-	while (!emac_phy_done(r = in_be32(&p->stacr))) {
-		udelay(1);
-		if (!--n)
-			goto to;
-	}
-
-	if (unlikely(r & EMAC_STACR_PHYE)) {
-		DBG("%d: mdio_read(%02x, %02x) failed" NL, dev->def->index,
-		    id, reg);
-		return -EREMOTEIO;
-	}
-
-	r = ((r >> EMAC_STACR_PHYD_SHIFT) & EMAC_STACR_PHYD_MASK);
-	DBG2("%d: mdio_read -> %04x" NL, dev->def->index, r);
-	return r;
-      to:
-	DBG("%d: MII management interface timeout (read)" NL, dev->def->index);
-	return -ETIMEDOUT;
-}
-
-static void __emac_mdio_write(struct ocp_enet_private *dev, u8 id, u8 reg,
-			      u16 val)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	int n;
-
-	DBG2("%d: mdio_write(%02x,%02x,%04x)" NL, dev->def->index, id, reg,
-	     val);
-
-	/* Enable proper MDIO port */
-	zmii_enable_mdio(dev->zmii_dev, dev->zmii_input);
-
-	/* Wait for management interface to be idle */
-	n = 10;
-	while (!emac_phy_done(in_be32(&p->stacr))) {
-		udelay(1);
-		if (!--n)
-			goto to;
-	}
-
-	/* Issue write command */
-	out_be32(&p->stacr,
-		 EMAC_STACR_BASE(emac_opb_mhz()) | EMAC_STACR_STAC_WRITE |
-		 (reg & EMAC_STACR_PRA_MASK) |
-		 ((id & EMAC_STACR_PCDA_MASK) << EMAC_STACR_PCDA_SHIFT) |
-		 (val << EMAC_STACR_PHYD_SHIFT) | EMAC_STACR_START);
-
-	/* Wait for write to complete */
-	n = 100;
-	while (!emac_phy_done(in_be32(&p->stacr))) {
-		udelay(1);
-		if (!--n)
-			goto to;
-	}
-	return;
-      to:
-	DBG("%d: MII management interface timeout (write)" NL, dev->def->index);
-}
-
-static int emac_mdio_read(struct net_device *ndev, int id, int reg)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	int res;
-
-	local_bh_disable();
-	res = __emac_mdio_read(dev->mdio_dev ? dev->mdio_dev : dev, (u8) id,
-			       (u8) reg);
-	local_bh_enable();
-	return res;
-}
-
-static void emac_mdio_write(struct net_device *ndev, int id, int reg, int val)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-
-	local_bh_disable();
-	__emac_mdio_write(dev->mdio_dev ? dev->mdio_dev : dev, (u8) id,
-			  (u8) reg, (u16) val);
-	local_bh_enable();
-}
-
-/* BHs disabled */
-static void emac_set_multicast_list(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct emac_regs __iomem *p = dev->emacp;
-	u32 rmr = emac_iff2rmr(ndev);
-
-	DBG("%d: multicast %08x" NL, dev->def->index, rmr);
-	BUG_ON(!netif_running(dev->ndev));
-
-	/* I decided to relax register access rules here to avoid
-	 * full EMAC reset.
-	 *
-	 * There is a real problem with EMAC4 core if we use MWSW_001 bit 
-	 * in MR1 register and do a full EMAC reset.
-	 * One TX BD status update is delayed and, after EMAC reset, it 
-	 * never happens, resulting in TX hung (it'll be recovered by TX 
-	 * timeout handler eventually, but this is just gross).
-	 * So we either have to do full TX reset or try to cheat here :)
-	 *
-	 * The only required change is to RX mode register, so I *think* all
-	 * we need is just to stop RX channel. This seems to work on all
-	 * tested SoCs.                                                --ebs
-	 */
-	emac_rx_disable(dev);
-	if (rmr & EMAC_RMR_MAE)
-		emac_hash_mc(dev);
-	out_be32(&p->rmr, rmr);
-	emac_rx_enable(dev);
-}
-
-/* BHs disabled */
-static int emac_resize_rx_ring(struct ocp_enet_private *dev, int new_mtu)
-{
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-	int rx_sync_size = emac_rx_sync_size(new_mtu);
-	int rx_skb_size = emac_rx_skb_size(new_mtu);
-	int i, ret = 0;
-
-	emac_rx_disable(dev);
-	mal_disable_rx_channel(dev->mal, emacdata->mal_rx_chan);
-
-	if (dev->rx_sg_skb) {
-		++dev->estats.rx_dropped_resize;
-		dev_kfree_skb(dev->rx_sg_skb);
-		dev->rx_sg_skb = NULL;
-	}
-
-	/* Make a first pass over RX ring and mark BDs ready, dropping 
-	 * non-processed packets on the way. We need this as a separate pass
-	 * to simplify error recovery in the case of allocation failure later.
-	 */
-	for (i = 0; i < NUM_RX_BUFF; ++i) {
-		if (dev->rx_desc[i].ctrl & MAL_RX_CTRL_FIRST)
-			++dev->estats.rx_dropped_resize;
-
-		dev->rx_desc[i].data_len = 0;
-		dev->rx_desc[i].ctrl = MAL_RX_CTRL_EMPTY |
-		    (i == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
-	}
-
-	/* Reallocate RX ring only if bigger skb buffers are required */
-	if (rx_skb_size <= dev->rx_skb_size)
-		goto skip;
-
-	/* Second pass, allocate new skbs */
-	for (i = 0; i < NUM_RX_BUFF; ++i) {
-		struct sk_buff *skb = alloc_skb(rx_skb_size, GFP_ATOMIC);
-		if (!skb) {
-			ret = -ENOMEM;
-			goto oom;
-		}
-
-		BUG_ON(!dev->rx_skb[i]);
-		dev_kfree_skb(dev->rx_skb[i]);
-
-		skb_reserve(skb, EMAC_RX_SKB_HEADROOM + 2);
-		dev->rx_desc[i].data_ptr =
-		    dma_map_single(dev->ldev, skb->data - 2, rx_sync_size,
-				   DMA_FROM_DEVICE) + 2;
-		dev->rx_skb[i] = skb;
-	}
-      skip:
-	/* Check if we need to change "Jumbo" bit in MR1 */
-	if ((new_mtu > ETH_DATA_LEN) ^ (dev->ndev->mtu > ETH_DATA_LEN)) {
-		/* This is to prevent starting RX channel in emac_rx_enable() */
-		dev->commac.rx_stopped = 1;
-
-		dev->ndev->mtu = new_mtu;
-		emac_full_tx_reset(dev->ndev);
-	}
-
-	mal_set_rcbs(dev->mal, emacdata->mal_rx_chan, emac_rx_size(new_mtu));
-      oom:
-	/* Restart RX */
-	dev->commac.rx_stopped = dev->rx_slot = 0;
-	mal_enable_rx_channel(dev->mal, emacdata->mal_rx_chan);
-	emac_rx_enable(dev);
-
-	return ret;
-}
-
-/* Process ctx, rtnl_lock semaphore */
-static int emac_change_mtu(struct net_device *ndev, int new_mtu)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	int ret = 0;
-
-	if (new_mtu < EMAC_MIN_MTU || new_mtu > EMAC_MAX_MTU)
-		return -EINVAL;
-
-	DBG("%d: change_mtu(%d)" NL, dev->def->index, new_mtu);
-
-	local_bh_disable();
-	if (netif_running(ndev)) {
-		/* Check if we really need to reinitalize RX ring */
-		if (emac_rx_skb_size(ndev->mtu) != emac_rx_skb_size(new_mtu))
-			ret = emac_resize_rx_ring(dev, new_mtu);
-	}
-
-	if (!ret) {
-		ndev->mtu = new_mtu;
-		dev->rx_skb_size = emac_rx_skb_size(new_mtu);
-		dev->rx_sync_size = emac_rx_sync_size(new_mtu);
-	}	
-	local_bh_enable();
-
-	return ret;
-}
-
-static void emac_clean_tx_ring(struct ocp_enet_private *dev)
-{
-	int i;
-	for (i = 0; i < NUM_TX_BUFF; ++i) {
-		if (dev->tx_skb[i]) {
-			dev_kfree_skb(dev->tx_skb[i]);
-			dev->tx_skb[i] = NULL;
-			if (dev->tx_desc[i].ctrl & MAL_TX_CTRL_READY)
-				++dev->estats.tx_dropped;
-		}
-		dev->tx_desc[i].ctrl = 0;
-		dev->tx_desc[i].data_ptr = 0;
-	}
-}
-
-static void emac_clean_rx_ring(struct ocp_enet_private *dev)
-{
-	int i;
-	for (i = 0; i < NUM_RX_BUFF; ++i)
-		if (dev->rx_skb[i]) {
-			dev->rx_desc[i].ctrl = 0;
-			dev_kfree_skb(dev->rx_skb[i]);
-			dev->rx_skb[i] = NULL;
-			dev->rx_desc[i].data_ptr = 0;
-		}
-
-	if (dev->rx_sg_skb) {
-		dev_kfree_skb(dev->rx_sg_skb);
-		dev->rx_sg_skb = NULL;
-	}
-}
-
-static inline int emac_alloc_rx_skb(struct ocp_enet_private *dev, int slot,
-				    gfp_t flags)
-{
-	struct sk_buff *skb = alloc_skb(dev->rx_skb_size, flags);
-	if (unlikely(!skb))
-		return -ENOMEM;
-
-	dev->rx_skb[slot] = skb;
-	dev->rx_desc[slot].data_len = 0;
-
-	skb_reserve(skb, EMAC_RX_SKB_HEADROOM + 2);
-	dev->rx_desc[slot].data_ptr = 
-	    dma_map_single(dev->ldev, skb->data - 2, dev->rx_sync_size, 
-			   DMA_FROM_DEVICE) + 2;
-	barrier();
-	dev->rx_desc[slot].ctrl = MAL_RX_CTRL_EMPTY |
-	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
-
-	return 0;
-}
-
-static void emac_print_link_status(struct ocp_enet_private *dev)
-{
-	if (netif_carrier_ok(dev->ndev))
-		printk(KERN_INFO "%s: link is up, %d %s%s\n",
-		       dev->ndev->name, dev->phy.speed,
-		       dev->phy.duplex == DUPLEX_FULL ? "FDX" : "HDX",
-		       dev->phy.pause ? ", pause enabled" :
-		       dev->phy.asym_pause ? ", assymetric pause enabled" : "");
-	else
-		printk(KERN_INFO "%s: link is down\n", dev->ndev->name);
-}
-
-/* Process ctx, rtnl_lock semaphore */
-static int emac_open(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-	int err, i;
-
-	DBG("%d: open" NL, dev->def->index);
-
-	/* Setup error IRQ handler */
-	err = request_irq(dev->def->irq, emac_irq, 0, "EMAC", dev);
-	if (err) {
-		printk(KERN_ERR "%s: failed to request IRQ %d\n",
-		       ndev->name, dev->def->irq);
-		return err;
-	}
-
-	/* Allocate RX ring */
-	for (i = 0; i < NUM_RX_BUFF; ++i)
-		if (emac_alloc_rx_skb(dev, i, GFP_KERNEL)) {
-			printk(KERN_ERR "%s: failed to allocate RX ring\n",
-			       ndev->name);
-			goto oom;
-		}
-
-	local_bh_disable();
-	dev->tx_cnt = dev->tx_slot = dev->ack_slot = dev->rx_slot =
-	    dev->commac.rx_stopped = 0;
-	dev->rx_sg_skb = NULL;
-
-	if (dev->phy.address >= 0) {
-		int link_poll_interval;
-		if (dev->phy.def->ops->poll_link(&dev->phy)) {
-			dev->phy.def->ops->read_link(&dev->phy);
-			EMAC_RX_CLK_DEFAULT(dev->def->index);
-			netif_carrier_on(dev->ndev);
-			link_poll_interval = PHY_POLL_LINK_ON;
-		} else {
-			EMAC_RX_CLK_TX(dev->def->index);
-			netif_carrier_off(dev->ndev);
-			link_poll_interval = PHY_POLL_LINK_OFF;
-		}
-		mod_timer(&dev->link_timer, jiffies + link_poll_interval);
-		emac_print_link_status(dev);
-	} else
-		netif_carrier_on(dev->ndev);
-
-	emac_configure(dev);
-	mal_poll_add(dev->mal, &dev->commac);
-	mal_enable_tx_channel(dev->mal, emacdata->mal_tx_chan);
-	mal_set_rcbs(dev->mal, emacdata->mal_rx_chan, emac_rx_size(ndev->mtu));
-	mal_enable_rx_channel(dev->mal, emacdata->mal_rx_chan);
-	emac_tx_enable(dev);
-	emac_rx_enable(dev);
-	netif_start_queue(ndev);
-	local_bh_enable();
-
-	return 0;
-      oom:
-	emac_clean_rx_ring(dev);
-	free_irq(dev->def->irq, dev);
-	return -ENOMEM;
-}
-
-/* BHs disabled */
-static int emac_link_differs(struct ocp_enet_private *dev)
-{
-	u32 r = in_be32(&dev->emacp->mr1);
-
-	int duplex = r & EMAC_MR1_FDE ? DUPLEX_FULL : DUPLEX_HALF;
-	int speed, pause, asym_pause;
-
-	if (r & EMAC_MR1_MF_1000)
-		speed = SPEED_1000;
-	else if (r & EMAC_MR1_MF_100)
-		speed = SPEED_100;
-	else
-		speed = SPEED_10;
-
-	switch (r & (EMAC_MR1_EIFC | EMAC_MR1_APP)) {
-	case (EMAC_MR1_EIFC | EMAC_MR1_APP):
-		pause = 1;
-		asym_pause = 0;
-		break;
-	case EMAC_MR1_APP:
-		pause = 0;
-		asym_pause = 1;
-		break;
-	default:
-		pause = asym_pause = 0;
-	}
-	return speed != dev->phy.speed || duplex != dev->phy.duplex ||
-	    pause != dev->phy.pause || asym_pause != dev->phy.asym_pause;
-}
-
-/* BHs disabled */
-static void emac_link_timer(unsigned long data)
-{
-	struct ocp_enet_private *dev = (struct ocp_enet_private *)data;
-	int link_poll_interval;
-
-	DBG2("%d: link timer" NL, dev->def->index);
-
-	if (dev->phy.def->ops->poll_link(&dev->phy)) {
-		if (!netif_carrier_ok(dev->ndev)) {
-			EMAC_RX_CLK_DEFAULT(dev->def->index);
-
-			/* Get new link parameters */
-			dev->phy.def->ops->read_link(&dev->phy);
-
-			if (dev->tah_dev || emac_link_differs(dev))
-				emac_full_tx_reset(dev->ndev);
-
-			netif_carrier_on(dev->ndev);
-			emac_print_link_status(dev);
-		}
-		link_poll_interval = PHY_POLL_LINK_ON;
-	} else {
-		if (netif_carrier_ok(dev->ndev)) {
-			EMAC_RX_CLK_TX(dev->def->index);
-#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX)
-			emac_reinitialize(dev);
-#endif
-			netif_carrier_off(dev->ndev);
-			emac_print_link_status(dev);
-		}
-
-		/* Retry reset if the previous attempt failed.
-		 * This is needed mostly for CONFIG_IBM_EMAC_PHY_RX_CLK_FIX
-		 * case, but I left it here because it shouldn't trigger for
-		 * sane PHYs anyway.
-		 */
-		if (unlikely(dev->reset_failed))
-			emac_reinitialize(dev);
-
-		link_poll_interval = PHY_POLL_LINK_OFF;
-	}
-	mod_timer(&dev->link_timer, jiffies + link_poll_interval);
-}
-
-/* BHs disabled */
-static void emac_force_link_update(struct ocp_enet_private *dev)
-{
-	netif_carrier_off(dev->ndev);
-	if (timer_pending(&dev->link_timer))
-		mod_timer(&dev->link_timer, jiffies + PHY_POLL_LINK_OFF);
-}
-
-/* Process ctx, rtnl_lock semaphore */
-static int emac_close(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-	DBG("%d: close" NL, dev->def->index);
-
-	local_bh_disable();
-
-	if (dev->phy.address >= 0)
-		del_timer_sync(&dev->link_timer);
-
-	netif_stop_queue(ndev);
-	emac_rx_disable(dev);
-	emac_tx_disable(dev);
-	mal_disable_rx_channel(dev->mal, emacdata->mal_rx_chan);
-	mal_disable_tx_channel(dev->mal, emacdata->mal_tx_chan);
-	mal_poll_del(dev->mal, &dev->commac);
-	local_bh_enable();
-
-	emac_clean_tx_ring(dev);
-	emac_clean_rx_ring(dev);
-	free_irq(dev->def->irq, dev);
-
-	return 0;
-}
-
-static inline u16 emac_tx_csum(struct ocp_enet_private *dev,
-			       struct sk_buff *skb)
-{
-#if defined(CONFIG_IBM_EMAC_TAH)
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		++dev->stats.tx_packets_csum;
-		return EMAC_TX_CTRL_TAH_CSUM;
-	}
-#endif
-	return 0;
-}
-
-static inline int emac_xmit_finish(struct ocp_enet_private *dev, int len)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	struct net_device *ndev = dev->ndev;
-
-	/* Send the packet out */
-	out_be32(&p->tmr0, EMAC_TMR0_XMIT);
-
-	if (unlikely(++dev->tx_cnt == NUM_TX_BUFF)) {
-		netif_stop_queue(ndev);
-		DBG2("%d: stopped TX queue" NL, dev->def->index);
-	}
-
-	ndev->trans_start = jiffies;
-	++dev->stats.tx_packets;
-	dev->stats.tx_bytes += len;
-
-	return 0;
-}
-
-/* BHs disabled */
-static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	unsigned int len = skb->len;
-	int slot;
-
-	u16 ctrl = EMAC_TX_CTRL_GFCS | EMAC_TX_CTRL_GP | MAL_TX_CTRL_READY |
-	    MAL_TX_CTRL_LAST | emac_tx_csum(dev, skb);
-
-	slot = dev->tx_slot++;
-	if (dev->tx_slot == NUM_TX_BUFF) {
-		dev->tx_slot = 0;
-		ctrl |= MAL_TX_CTRL_WRAP;
-	}
-
-	DBG2("%d: xmit(%u) %d" NL, dev->def->index, len, slot);
-
-	dev->tx_skb[slot] = skb;
-	dev->tx_desc[slot].data_ptr = dma_map_single(dev->ldev, skb->data, len,
-						     DMA_TO_DEVICE);
-	dev->tx_desc[slot].data_len = (u16) len;
-	barrier();
-	dev->tx_desc[slot].ctrl = ctrl;
-
-	return emac_xmit_finish(dev, len);
-}
-
-#if defined(CONFIG_IBM_EMAC_TAH)
-static inline int emac_xmit_split(struct ocp_enet_private *dev, int slot,
-				  u32 pd, int len, int last, u16 base_ctrl)
-{
-	while (1) {
-		u16 ctrl = base_ctrl;
-		int chunk = min(len, MAL_MAX_TX_SIZE);
-		len -= chunk;
-
-		slot = (slot + 1) % NUM_TX_BUFF;
-
-		if (last && !len)
-			ctrl |= MAL_TX_CTRL_LAST;
-		if (slot == NUM_TX_BUFF - 1)
-			ctrl |= MAL_TX_CTRL_WRAP;
-
-		dev->tx_skb[slot] = NULL;
-		dev->tx_desc[slot].data_ptr = pd;
-		dev->tx_desc[slot].data_len = (u16) chunk;
-		dev->tx_desc[slot].ctrl = ctrl;
-		++dev->tx_cnt;
-
-		if (!len)
-			break;
-
-		pd += chunk;
-	}
-	return slot;
-}
-
-/* BHs disabled (SG version for TAH equipped EMACs) */
-static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	int nr_frags = skb_shinfo(skb)->nr_frags;
-	int len = skb->len, chunk;
-	int slot, i;
-	u16 ctrl;
-	u32 pd;
-
-	/* This is common "fast" path */
-	if (likely(!nr_frags && len <= MAL_MAX_TX_SIZE))
-		return emac_start_xmit(skb, ndev);
-
-	len -= skb->data_len;
-
-	/* Note, this is only an *estimation*, we can still run out of empty
-	 * slots because of the additional fragmentation into
-	 * MAL_MAX_TX_SIZE-sized chunks
-	 */
-	if (unlikely(dev->tx_cnt + nr_frags + mal_tx_chunks(len) > NUM_TX_BUFF))
-		goto stop_queue;
-
-	ctrl = EMAC_TX_CTRL_GFCS | EMAC_TX_CTRL_GP | MAL_TX_CTRL_READY |
-	    emac_tx_csum(dev, skb);
-	slot = dev->tx_slot;
-
-	/* skb data */
-	dev->tx_skb[slot] = NULL;
-	chunk = min(len, MAL_MAX_TX_SIZE);
-	dev->tx_desc[slot].data_ptr = pd =
-	    dma_map_single(dev->ldev, skb->data, len, DMA_TO_DEVICE);
-	dev->tx_desc[slot].data_len = (u16) chunk;
-	len -= chunk;
-	if (unlikely(len))
-		slot = emac_xmit_split(dev, slot, pd + chunk, len, !nr_frags,
-				       ctrl);
-	/* skb fragments */
-	for (i = 0; i < nr_frags; ++i) {
-		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
-		len = frag->size;
-
-		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >= NUM_TX_BUFF))
-			goto undo_frame;
-
-		pd = dma_map_page(dev->ldev, frag->page, frag->page_offset, len,
-				  DMA_TO_DEVICE);
-
-		slot = emac_xmit_split(dev, slot, pd, len, i == nr_frags - 1,
-				       ctrl);
-	}
-
-	DBG2("%d: xmit_sg(%u) %d - %d" NL, dev->def->index, skb->len,
-	     dev->tx_slot, slot);
-
-	/* Attach skb to the last slot so we don't release it too early */
-	dev->tx_skb[slot] = skb;
-
-	/* Send the packet out */
-	if (dev->tx_slot == NUM_TX_BUFF - 1)
-		ctrl |= MAL_TX_CTRL_WRAP;
-	barrier();
-	dev->tx_desc[dev->tx_slot].ctrl = ctrl;
-	dev->tx_slot = (slot + 1) % NUM_TX_BUFF;
-
-	return emac_xmit_finish(dev, skb->len);
-
-      undo_frame:
-	/* Well, too bad. Our previous estimation was overly optimistic. 
-	 * Undo everything.
-	 */
-	while (slot != dev->tx_slot) {
-		dev->tx_desc[slot].ctrl = 0;
-		--dev->tx_cnt;
-		if (--slot < 0)
-			slot = NUM_TX_BUFF - 1;
-	}
-	++dev->estats.tx_undo;
-
-      stop_queue:
-	netif_stop_queue(ndev);
-	DBG2("%d: stopped TX queue" NL, dev->def->index);
-	return 1;
-}
-#else
-# define emac_start_xmit_sg	emac_start_xmit
-#endif	/* !defined(CONFIG_IBM_EMAC_TAH) */
-
-/* BHs disabled */
-static void emac_parse_tx_error(struct ocp_enet_private *dev, u16 ctrl)
-{
-	struct ibm_emac_error_stats *st = &dev->estats;
-	DBG("%d: BD TX error %04x" NL, dev->def->index, ctrl);
-
-	++st->tx_bd_errors;
-	if (ctrl & EMAC_TX_ST_BFCS)
-		++st->tx_bd_bad_fcs;
-	if (ctrl & EMAC_TX_ST_LCS)
-		++st->tx_bd_carrier_loss;
-	if (ctrl & EMAC_TX_ST_ED)
-		++st->tx_bd_excessive_deferral;
-	if (ctrl & EMAC_TX_ST_EC)
-		++st->tx_bd_excessive_collisions;
-	if (ctrl & EMAC_TX_ST_LC)
-		++st->tx_bd_late_collision;
-	if (ctrl & EMAC_TX_ST_MC)
-		++st->tx_bd_multple_collisions;
-	if (ctrl & EMAC_TX_ST_SC)
-		++st->tx_bd_single_collision;
-	if (ctrl & EMAC_TX_ST_UR)
-		++st->tx_bd_underrun;
-	if (ctrl & EMAC_TX_ST_SQE)
-		++st->tx_bd_sqe;
-}
-
-static void emac_poll_tx(void *param)
-{
-	struct ocp_enet_private *dev = param;
-	DBG2("%d: poll_tx, %d %d" NL, dev->def->index, dev->tx_cnt,
-	     dev->ack_slot);
-
-	if (dev->tx_cnt) {
-		u16 ctrl;
-		int slot = dev->ack_slot, n = 0;
-	      again:
-		ctrl = dev->tx_desc[slot].ctrl;
-		if (!(ctrl & MAL_TX_CTRL_READY)) {
-			struct sk_buff *skb = dev->tx_skb[slot];
-			++n;
-
-			if (skb) {
-				dev_kfree_skb(skb);
-				dev->tx_skb[slot] = NULL;
-			}
-			slot = (slot + 1) % NUM_TX_BUFF;
-
-			if (unlikely(EMAC_IS_BAD_TX(ctrl)))
-				emac_parse_tx_error(dev, ctrl);
-
-			if (--dev->tx_cnt)
-				goto again;
-		}
-		if (n) {
-			dev->ack_slot = slot;
-			if (netif_queue_stopped(dev->ndev) &&
-			    dev->tx_cnt < EMAC_TX_WAKEUP_THRESH)
-				netif_wake_queue(dev->ndev);
-
-			DBG2("%d: tx %d pkts" NL, dev->def->index, n);
-		}
-	}
-}
-
-static inline void emac_recycle_rx_skb(struct ocp_enet_private *dev, int slot,
-				       int len)
-{
-	struct sk_buff *skb = dev->rx_skb[slot];
-	DBG2("%d: recycle %d %d" NL, dev->def->index, slot, len);
-
-	if (len) 
-		dma_map_single(dev->ldev, skb->data - 2, 
-			       EMAC_DMA_ALIGN(len + 2), DMA_FROM_DEVICE);
-
-	dev->rx_desc[slot].data_len = 0;
-	barrier();
-	dev->rx_desc[slot].ctrl = MAL_RX_CTRL_EMPTY |
-	    (slot == (NUM_RX_BUFF - 1) ? MAL_RX_CTRL_WRAP : 0);
-}
-
-static void emac_parse_rx_error(struct ocp_enet_private *dev, u16 ctrl)
-{
-	struct ibm_emac_error_stats *st = &dev->estats;
-	DBG("%d: BD RX error %04x" NL, dev->def->index, ctrl);
-
-	++st->rx_bd_errors;
-	if (ctrl & EMAC_RX_ST_OE)
-		++st->rx_bd_overrun;
-	if (ctrl & EMAC_RX_ST_BP)
-		++st->rx_bd_bad_packet;
-	if (ctrl & EMAC_RX_ST_RP)
-		++st->rx_bd_runt_packet;
-	if (ctrl & EMAC_RX_ST_SE)
-		++st->rx_bd_short_event;
-	if (ctrl & EMAC_RX_ST_AE)
-		++st->rx_bd_alignment_error;
-	if (ctrl & EMAC_RX_ST_BFCS)
-		++st->rx_bd_bad_fcs;
-	if (ctrl & EMAC_RX_ST_PTL)
-		++st->rx_bd_packet_too_long;
-	if (ctrl & EMAC_RX_ST_ORE)
-		++st->rx_bd_out_of_range;
-	if (ctrl & EMAC_RX_ST_IRE)
-		++st->rx_bd_in_range;
-}
-
-static inline void emac_rx_csum(struct ocp_enet_private *dev,
-				struct sk_buff *skb, u16 ctrl)
-{
-#if defined(CONFIG_IBM_EMAC_TAH)
-	if (!ctrl && dev->tah_dev) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		++dev->stats.rx_packets_csum;
-	}
-#endif
-}
-
-static inline int emac_rx_sg_append(struct ocp_enet_private *dev, int slot)
-{
-	if (likely(dev->rx_sg_skb != NULL)) {
-		int len = dev->rx_desc[slot].data_len;
-		int tot_len = dev->rx_sg_skb->len + len;
-
-		if (unlikely(tot_len + 2 > dev->rx_skb_size)) {
-			++dev->estats.rx_dropped_mtu;
-			dev_kfree_skb(dev->rx_sg_skb);
-			dev->rx_sg_skb = NULL;
-		} else {
-			cacheable_memcpy(skb_tail_pointer(dev->rx_sg_skb),
-					 dev->rx_skb[slot]->data, len);
-			skb_put(dev->rx_sg_skb, len);
-			emac_recycle_rx_skb(dev, slot, len);
-			return 0;
-		}
-	}
-	emac_recycle_rx_skb(dev, slot, 0);
-	return -1;
-}
-
-/* BHs disabled */
-static int emac_poll_rx(void *param, int budget)
-{
-	struct ocp_enet_private *dev = param;
-	int slot = dev->rx_slot, received = 0;
-
-	DBG2("%d: poll_rx(%d)" NL, dev->def->index, budget);
-
-      again:
-	while (budget > 0) {
-		int len;
-		struct sk_buff *skb;
-		u16 ctrl = dev->rx_desc[slot].ctrl;
-
-		if (ctrl & MAL_RX_CTRL_EMPTY)
-			break;
-
-		skb = dev->rx_skb[slot];
-		barrier();
-		len = dev->rx_desc[slot].data_len;
-
-		if (unlikely(!MAL_IS_SINGLE_RX(ctrl)))
-			goto sg;
-
-		ctrl &= EMAC_BAD_RX_MASK;
-		if (unlikely(ctrl && ctrl != EMAC_RX_TAH_BAD_CSUM)) {
-			emac_parse_rx_error(dev, ctrl);
-			++dev->estats.rx_dropped_error;
-			emac_recycle_rx_skb(dev, slot, 0);
-			len = 0;
-			goto next;
-		}
-
-		if (len && len < EMAC_RX_COPY_THRESH) {
-			struct sk_buff *copy_skb =
-			    alloc_skb(len + EMAC_RX_SKB_HEADROOM + 2, GFP_ATOMIC);
-			if (unlikely(!copy_skb))
-				goto oom;
-
-			skb_reserve(copy_skb, EMAC_RX_SKB_HEADROOM + 2);
-			cacheable_memcpy(copy_skb->data - 2, skb->data - 2,
-					 len + 2);
-			emac_recycle_rx_skb(dev, slot, len);
-			skb = copy_skb;
-		} else if (unlikely(emac_alloc_rx_skb(dev, slot, GFP_ATOMIC)))
-			goto oom;
-
-		skb_put(skb, len);
-	      push_packet:
-		skb->protocol = eth_type_trans(skb, dev->ndev);
-		emac_rx_csum(dev, skb, ctrl);
-
-		if (unlikely(netif_receive_skb(skb) == NET_RX_DROP))
-			++dev->estats.rx_dropped_stack;
-	      next:
-		++dev->stats.rx_packets;
-	      skip:
-		dev->stats.rx_bytes += len;
-		slot = (slot + 1) % NUM_RX_BUFF;
-		--budget;
-		++received;
-		continue;
-	      sg:
-		if (ctrl & MAL_RX_CTRL_FIRST) {
-			BUG_ON(dev->rx_sg_skb);
-			if (unlikely(emac_alloc_rx_skb(dev, slot, GFP_ATOMIC))) {
-				DBG("%d: rx OOM %d" NL, dev->def->index, slot);
-				++dev->estats.rx_dropped_oom;
-				emac_recycle_rx_skb(dev, slot, 0);
-			} else {
-				dev->rx_sg_skb = skb;
-				skb_put(skb, len);
-			}
-		} else if (!emac_rx_sg_append(dev, slot) &&
-			   (ctrl & MAL_RX_CTRL_LAST)) {
-
-			skb = dev->rx_sg_skb;
-			dev->rx_sg_skb = NULL;
-
-			ctrl &= EMAC_BAD_RX_MASK;
-			if (unlikely(ctrl && ctrl != EMAC_RX_TAH_BAD_CSUM)) {
-				emac_parse_rx_error(dev, ctrl);
-				++dev->estats.rx_dropped_error;
-				dev_kfree_skb(skb);
-				len = 0;
-			} else
-				goto push_packet;
-		}
-		goto skip;
-	      oom:
-		DBG("%d: rx OOM %d" NL, dev->def->index, slot);
-		/* Drop the packet and recycle skb */
-		++dev->estats.rx_dropped_oom;
-		emac_recycle_rx_skb(dev, slot, 0);
-		goto next;
-	}
-
-	if (received) {
-		DBG2("%d: rx %d BDs" NL, dev->def->index, received);
-		dev->rx_slot = slot;
-	}
-
-	if (unlikely(budget && dev->commac.rx_stopped)) {
-		struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-		barrier();
-		if (!(dev->rx_desc[slot].ctrl & MAL_RX_CTRL_EMPTY)) {
-			DBG2("%d: rx restart" NL, dev->def->index);
-			received = 0;
-			goto again;
-		}
-
-		if (dev->rx_sg_skb) {
-			DBG2("%d: dropping partial rx packet" NL,
-			     dev->def->index);
-			++dev->estats.rx_dropped_error;
-			dev_kfree_skb(dev->rx_sg_skb);
-			dev->rx_sg_skb = NULL;
-		}
-
-		dev->commac.rx_stopped = 0;
-		mal_enable_rx_channel(dev->mal, emacdata->mal_rx_chan);
-		emac_rx_enable(dev);
-		dev->rx_slot = 0;
-	}
-	return received;
-}
-
-/* BHs disabled */
-static int emac_peek_rx(void *param)
-{
-	struct ocp_enet_private *dev = param;
-	return !(dev->rx_desc[dev->rx_slot].ctrl & MAL_RX_CTRL_EMPTY);
-}
-
-/* BHs disabled */
-static int emac_peek_rx_sg(void *param)
-{
-	struct ocp_enet_private *dev = param;
-	int slot = dev->rx_slot;
-	while (1) {
-		u16 ctrl = dev->rx_desc[slot].ctrl;
-		if (ctrl & MAL_RX_CTRL_EMPTY)
-			return 0;
-		else if (ctrl & MAL_RX_CTRL_LAST)
-			return 1;
-
-		slot = (slot + 1) % NUM_RX_BUFF;
-
-		/* I'm just being paranoid here :) */
-		if (unlikely(slot == dev->rx_slot))
-			return 0;
-	}
-}
-
-/* Hard IRQ */
-static void emac_rxde(void *param)
-{
-	struct ocp_enet_private *dev = param;
-	++dev->estats.rx_stopped;
-	emac_rx_disable_async(dev);
-}
-
-/* Hard IRQ */
-static irqreturn_t emac_irq(int irq, void *dev_instance)
-{
-	struct ocp_enet_private *dev = dev_instance;
-	struct emac_regs __iomem *p = dev->emacp;
-	struct ibm_emac_error_stats *st = &dev->estats;
-
-	u32 isr = in_be32(&p->isr);
-	out_be32(&p->isr, isr);
-
-	DBG("%d: isr = %08x" NL, dev->def->index, isr);
-
-	if (isr & EMAC_ISR_TXPE)
-		++st->tx_parity;
-	if (isr & EMAC_ISR_RXPE)
-		++st->rx_parity;
-	if (isr & EMAC_ISR_TXUE)
-		++st->tx_underrun;
-	if (isr & EMAC_ISR_RXOE)
-		++st->rx_fifo_overrun;
-	if (isr & EMAC_ISR_OVR)
-		++st->rx_overrun;
-	if (isr & EMAC_ISR_BP)
-		++st->rx_bad_packet;
-	if (isr & EMAC_ISR_RP)
-		++st->rx_runt_packet;
-	if (isr & EMAC_ISR_SE)
-		++st->rx_short_event;
-	if (isr & EMAC_ISR_ALE)
-		++st->rx_alignment_error;
-	if (isr & EMAC_ISR_BFCS)
-		++st->rx_bad_fcs;
-	if (isr & EMAC_ISR_PTLE)
-		++st->rx_packet_too_long;
-	if (isr & EMAC_ISR_ORE)
-		++st->rx_out_of_range;
-	if (isr & EMAC_ISR_IRE)
-		++st->rx_in_range;
-	if (isr & EMAC_ISR_SQE)
-		++st->tx_sqe;
-	if (isr & EMAC_ISR_TE)
-		++st->tx_errors;
-
-	return IRQ_HANDLED;
-}
-
-static struct net_device_stats *emac_stats(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct ibm_emac_stats *st = &dev->stats;
-	struct ibm_emac_error_stats *est = &dev->estats;
-	struct net_device_stats *nst = &dev->nstats;
-
-	DBG2("%d: stats" NL, dev->def->index);
-
-	/* Compute "legacy" statistics */
-	local_irq_disable();
-	nst->rx_packets = (unsigned long)st->rx_packets;
-	nst->rx_bytes = (unsigned long)st->rx_bytes;
-	nst->tx_packets = (unsigned long)st->tx_packets;
-	nst->tx_bytes = (unsigned long)st->tx_bytes;
-	nst->rx_dropped = (unsigned long)(est->rx_dropped_oom +
-					  est->rx_dropped_error +
-					  est->rx_dropped_resize +
-					  est->rx_dropped_mtu);
-	nst->tx_dropped = (unsigned long)est->tx_dropped;
-
-	nst->rx_errors = (unsigned long)est->rx_bd_errors;
-	nst->rx_fifo_errors = (unsigned long)(est->rx_bd_overrun +
-					      est->rx_fifo_overrun +
-					      est->rx_overrun);
-	nst->rx_frame_errors = (unsigned long)(est->rx_bd_alignment_error +
-					       est->rx_alignment_error);
-	nst->rx_crc_errors = (unsigned long)(est->rx_bd_bad_fcs +
-					     est->rx_bad_fcs);
-	nst->rx_length_errors = (unsigned long)(est->rx_bd_runt_packet +
-						est->rx_bd_short_event +
-						est->rx_bd_packet_too_long +
-						est->rx_bd_out_of_range +
-						est->rx_bd_in_range +
-						est->rx_runt_packet +
-						est->rx_short_event +
-						est->rx_packet_too_long +
-						est->rx_out_of_range +
-						est->rx_in_range);
-
-	nst->tx_errors = (unsigned long)(est->tx_bd_errors + est->tx_errors);
-	nst->tx_fifo_errors = (unsigned long)(est->tx_bd_underrun +
-					      est->tx_underrun);
-	nst->tx_carrier_errors = (unsigned long)est->tx_bd_carrier_loss;
-	nst->collisions = (unsigned long)(est->tx_bd_excessive_deferral +
-					  est->tx_bd_excessive_collisions +
-					  est->tx_bd_late_collision +
-					  est->tx_bd_multple_collisions);
-	local_irq_enable();
-	return nst;
-}
-
-static void emac_remove(struct ocp_device *ocpdev)
-{
-	struct ocp_enet_private *dev = ocp_get_drvdata(ocpdev);
-
-	DBG("%d: remove" NL, dev->def->index);
-
-	ocp_set_drvdata(ocpdev, NULL);
-	unregister_netdev(dev->ndev);
-
-	tah_fini(dev->tah_dev);
-	rgmii_fini(dev->rgmii_dev, dev->rgmii_input);
-	zmii_fini(dev->zmii_dev, dev->zmii_input);
-
-	emac_dbg_register(dev->def->index, NULL);
-
-	mal_unregister_commac(dev->mal, &dev->commac);
-	iounmap(dev->emacp);
-	kfree(dev->ndev);
-}
-
-static struct mal_commac_ops emac_commac_ops = {
-	.poll_tx = &emac_poll_tx,
-	.poll_rx = &emac_poll_rx,
-	.peek_rx = &emac_peek_rx,
-	.rxde = &emac_rxde,
-};
-
-static struct mal_commac_ops emac_commac_sg_ops = {
-	.poll_tx = &emac_poll_tx,
-	.poll_rx = &emac_poll_rx,
-	.peek_rx = &emac_peek_rx_sg,
-	.rxde = &emac_rxde,
-};
-
-/* Ethtool support */
-static int emac_ethtool_get_settings(struct net_device *ndev,
-				     struct ethtool_cmd *cmd)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-
-	cmd->supported = dev->phy.features;
-	cmd->port = PORT_MII;
-	cmd->phy_address = dev->phy.address;
-	cmd->transceiver =
-	    dev->phy.address >= 0 ? XCVR_EXTERNAL : XCVR_INTERNAL;
-
-	local_bh_disable();
-	cmd->advertising = dev->phy.advertising;
-	cmd->autoneg = dev->phy.autoneg;
-	cmd->speed = dev->phy.speed;
-	cmd->duplex = dev->phy.duplex;
-	local_bh_enable();
-
-	return 0;
-}
-
-static int emac_ethtool_set_settings(struct net_device *ndev,
-				     struct ethtool_cmd *cmd)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	u32 f = dev->phy.features;
-
-	DBG("%d: set_settings(%d, %d, %d, 0x%08x)" NL, dev->def->index,
-	    cmd->autoneg, cmd->speed, cmd->duplex, cmd->advertising);
-
-	/* Basic sanity checks */
-	if (dev->phy.address < 0)
-		return -EOPNOTSUPP;
-	if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
-		return -EINVAL;
-	if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
-		return -EINVAL;
-	if (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL)
-		return -EINVAL;
-
-	if (cmd->autoneg == AUTONEG_DISABLE) {
-		switch (cmd->speed) {
-		case SPEED_10:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_10baseT_Half))
-				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_10baseT_Full))
-				return -EINVAL;
-			break;
-		case SPEED_100:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_100baseT_Half))
-				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_100baseT_Full))
-				return -EINVAL;
-			break;
-		case SPEED_1000:
-			if (cmd->duplex == DUPLEX_HALF
-			    && !(f & SUPPORTED_1000baseT_Half))
-				return -EINVAL;
-			if (cmd->duplex == DUPLEX_FULL
-			    && !(f & SUPPORTED_1000baseT_Full))
-				return -EINVAL;
-			break;
-		default:
-			return -EINVAL;
-		}
-
-		local_bh_disable();
-		dev->phy.def->ops->setup_forced(&dev->phy, cmd->speed,
-						cmd->duplex);
-
-	} else {
-		if (!(f & SUPPORTED_Autoneg))
-			return -EINVAL;
-
-		local_bh_disable();
-		dev->phy.def->ops->setup_aneg(&dev->phy,
-					      (cmd->advertising & f) |
-					      (dev->phy.advertising &
-					       (ADVERTISED_Pause |
-						ADVERTISED_Asym_Pause)));
-	}
-	emac_force_link_update(dev);
-	local_bh_enable();
-
-	return 0;
-}
-
-static void emac_ethtool_get_ringparam(struct net_device *ndev,
-				       struct ethtool_ringparam *rp)
-{
-	rp->rx_max_pending = rp->rx_pending = NUM_RX_BUFF;
-	rp->tx_max_pending = rp->tx_pending = NUM_TX_BUFF;
-}
-
-static void emac_ethtool_get_pauseparam(struct net_device *ndev,
-					struct ethtool_pauseparam *pp)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-
-	local_bh_disable();
-	if ((dev->phy.features & SUPPORTED_Autoneg) &&
-	    (dev->phy.advertising & (ADVERTISED_Pause | ADVERTISED_Asym_Pause)))
-		pp->autoneg = 1;
-
-	if (dev->phy.duplex == DUPLEX_FULL) {
-		if (dev->phy.pause)
-			pp->rx_pause = pp->tx_pause = 1;
-		else if (dev->phy.asym_pause)
-			pp->tx_pause = 1;
-	}
-	local_bh_enable();
-}
-
-static u32 emac_ethtool_get_rx_csum(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	return dev->tah_dev != 0;
-}
-
-static int emac_get_regs_len(struct ocp_enet_private *dev)
-{
-	return sizeof(struct emac_ethtool_regs_subhdr) + EMAC_ETHTOOL_REGS_SIZE;
-}
-
-static int emac_ethtool_get_regs_len(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	return sizeof(struct emac_ethtool_regs_hdr) +
-	    emac_get_regs_len(dev) + mal_get_regs_len(dev->mal) +
-	    zmii_get_regs_len(dev->zmii_dev) +
-	    rgmii_get_regs_len(dev->rgmii_dev) +
-	    tah_get_regs_len(dev->tah_dev);
-}
-
-static void *emac_dump_regs(struct ocp_enet_private *dev, void *buf)
-{
-	struct emac_ethtool_regs_subhdr *hdr = buf;
-
-	hdr->version = EMAC_ETHTOOL_REGS_VER;
-	hdr->index = dev->def->index;
-	memcpy_fromio(hdr + 1, dev->emacp, EMAC_ETHTOOL_REGS_SIZE);
-	return ((void *)(hdr + 1) + EMAC_ETHTOOL_REGS_SIZE);
-}
-
-static void emac_ethtool_get_regs(struct net_device *ndev,
-				  struct ethtool_regs *regs, void *buf)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	struct emac_ethtool_regs_hdr *hdr = buf;
-
-	hdr->components = 0;
-	buf = hdr + 1;
-
-	local_irq_disable();
-	buf = mal_dump_regs(dev->mal, buf);
-	buf = emac_dump_regs(dev, buf);
-	if (dev->zmii_dev) {
-		hdr->components |= EMAC_ETHTOOL_REGS_ZMII;
-		buf = zmii_dump_regs(dev->zmii_dev, buf);
-	}
-	if (dev->rgmii_dev) {
-		hdr->components |= EMAC_ETHTOOL_REGS_RGMII;
-		buf = rgmii_dump_regs(dev->rgmii_dev, buf);
-	}
-	if (dev->tah_dev) {
-		hdr->components |= EMAC_ETHTOOL_REGS_TAH;
-		buf = tah_dump_regs(dev->tah_dev, buf);
-	}
-	local_irq_enable();
-}
-
-static int emac_ethtool_nway_reset(struct net_device *ndev)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	int res = 0;
-
-	DBG("%d: nway_reset" NL, dev->def->index);
-
-	if (dev->phy.address < 0)
-		return -EOPNOTSUPP;
-
-	local_bh_disable();
-	if (!dev->phy.autoneg) {
-		res = -EINVAL;
-		goto out;
-	}
-
-	dev->phy.def->ops->setup_aneg(&dev->phy, dev->phy.advertising);
-	emac_force_link_update(dev);
-
-      out:
-	local_bh_enable();
-	return res;
-}
-
-static int emac_get_sset_count(struct net_device *ndev, int sset)
-{
-	switch (sset) {
-	case ETH_SS_STATS:
-		return EMAC_ETHTOOL_STATS_COUNT;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static void emac_ethtool_get_strings(struct net_device *ndev, u32 stringset,
-				     u8 * buf)
-{
-	if (stringset == ETH_SS_STATS)
-		memcpy(buf, &emac_stats_keys, sizeof(emac_stats_keys));
-}
-
-static void emac_ethtool_get_ethtool_stats(struct net_device *ndev,
-					   struct ethtool_stats *estats,
-					   u64 * tmp_stats)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	local_irq_disable();
-	memcpy(tmp_stats, &dev->stats, sizeof(dev->stats));
-	tmp_stats += sizeof(dev->stats) / sizeof(u64);
-	memcpy(tmp_stats, &dev->estats, sizeof(dev->estats));
-	local_irq_enable();
-}
-
-static void emac_ethtool_get_drvinfo(struct net_device *ndev,
-				     struct ethtool_drvinfo *info)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-
-	strcpy(info->driver, "ibm_emac");
-	strcpy(info->version, DRV_VERSION);
-	info->fw_version[0] = '\0';
-	sprintf(info->bus_info, "PPC 4xx EMAC %d", dev->def->index);
-	info->regdump_len = emac_ethtool_get_regs_len(ndev);
-}
-
-static const struct ethtool_ops emac_ethtool_ops = {
-	.get_settings = emac_ethtool_get_settings,
-	.set_settings = emac_ethtool_set_settings,
-	.get_drvinfo = emac_ethtool_get_drvinfo,
-
-	.get_regs_len = emac_ethtool_get_regs_len,
-	.get_regs = emac_ethtool_get_regs,
-
-	.nway_reset = emac_ethtool_nway_reset,
-
-	.get_ringparam = emac_ethtool_get_ringparam,
-	.get_pauseparam = emac_ethtool_get_pauseparam,
-
-	.get_rx_csum = emac_ethtool_get_rx_csum,
-
-	.get_strings = emac_ethtool_get_strings,
-	.get_sset_count = emac_get_sset_count,
-	.get_ethtool_stats = emac_ethtool_get_ethtool_stats,
-
-	.get_link = ethtool_op_get_link,
-};
-
-static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-{
-	struct ocp_enet_private *dev = ndev->priv;
-	uint16_t *data = (uint16_t *) & rq->ifr_ifru;
-
-	DBG("%d: ioctl %08x" NL, dev->def->index, cmd);
-
-	if (dev->phy.address < 0)
-		return -EOPNOTSUPP;
-
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCDEVPRIVATE:
-		data[0] = dev->phy.address;
-		/* Fall through */
-	case SIOCGMIIREG:
-	case SIOCDEVPRIVATE + 1:
-		data[3] = emac_mdio_read(ndev, dev->phy.address, data[1]);
-		return 0;
-
-	case SIOCSMIIREG:
-	case SIOCDEVPRIVATE + 2:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		emac_mdio_write(ndev, dev->phy.address, data[1], data[2]);
-		return 0;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static int __init emac_probe(struct ocp_device *ocpdev)
-{
-	struct ocp_func_emac_data *emacdata = ocpdev->def->additions;
-	struct net_device *ndev;
-	struct ocp_device *maldev;
-	struct ocp_enet_private *dev;
-	int err, i;
-	DECLARE_MAC_BUF(mac);
-
-	DBG("%d: probe" NL, ocpdev->def->index);
-
-	if (!emacdata) {
-		printk(KERN_ERR "emac%d: Missing additional data!\n",
-		       ocpdev->def->index);
-		return -ENODEV;
-	}
-
-	/* Allocate our net_device structure */
-	ndev = alloc_etherdev(sizeof(struct ocp_enet_private));
-	if (!ndev) {
-		printk(KERN_ERR "emac%d: could not allocate ethernet device!\n",
-		       ocpdev->def->index);
-		return -ENOMEM;
-	}
-	dev = ndev->priv;
-	dev->ndev = ndev;
-	dev->ldev = &ocpdev->dev;
-	dev->def = ocpdev->def;
-
-	/* Find MAL device we are connected to */
-	maldev =
-	    ocp_find_device(OCP_VENDOR_IBM, OCP_FUNC_MAL, emacdata->mal_idx);
-	if (!maldev) {
-		printk(KERN_ERR "emac%d: unknown mal%d device!\n",
-		       dev->def->index, emacdata->mal_idx);
-		err = -ENODEV;
-		goto out;
-	}
-	dev->mal = ocp_get_drvdata(maldev);
-	if (!dev->mal) {
-		printk(KERN_ERR "emac%d: mal%d hasn't been initialized yet!\n",
-		       dev->def->index, emacdata->mal_idx);
-		err = -ENODEV;
-		goto out;
-	}
-
-	/* Register with MAL */
-	dev->commac.ops = &emac_commac_ops;
-	dev->commac.dev = dev;
-	dev->commac.tx_chan_mask = MAL_CHAN_MASK(emacdata->mal_tx_chan);
-	dev->commac.rx_chan_mask = MAL_CHAN_MASK(emacdata->mal_rx_chan);
-	err = mal_register_commac(dev->mal, &dev->commac);
-	if (err) {
-		printk(KERN_ERR "emac%d: failed to register with mal%d!\n",
-		       dev->def->index, emacdata->mal_idx);
-		goto out;
-	}
-	dev->rx_skb_size = emac_rx_skb_size(ndev->mtu);
-	dev->rx_sync_size = emac_rx_sync_size(ndev->mtu);
-
-	/* Get pointers to BD rings */
-	dev->tx_desc =
-	    dev->mal->bd_virt + mal_tx_bd_offset(dev->mal,
-						 emacdata->mal_tx_chan);
-	dev->rx_desc =
-	    dev->mal->bd_virt + mal_rx_bd_offset(dev->mal,
-						 emacdata->mal_rx_chan);
-
-	DBG("%d: tx_desc %p" NL, ocpdev->def->index, dev->tx_desc);
-	DBG("%d: rx_desc %p" NL, ocpdev->def->index, dev->rx_desc);
-
-	/* Clean rings */
-	memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));
-	memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));
-
-	/* If we depend on another EMAC for MDIO, check whether it was probed already */
-	if (emacdata->mdio_idx >= 0 && emacdata->mdio_idx != ocpdev->def->index) {
-		struct ocp_device *mdiodev =
-		    ocp_find_device(OCP_VENDOR_IBM, OCP_FUNC_EMAC,
-				    emacdata->mdio_idx);
-		if (!mdiodev) {
-			printk(KERN_ERR "emac%d: unknown emac%d device!\n",
-			       dev->def->index, emacdata->mdio_idx);
-			err = -ENODEV;
-			goto out2;
-		}
-		dev->mdio_dev = ocp_get_drvdata(mdiodev);
-		if (!dev->mdio_dev) {
-			printk(KERN_ERR
-			       "emac%d: emac%d hasn't been initialized yet!\n",
-			       dev->def->index, emacdata->mdio_idx);
-			err = -ENODEV;
-			goto out2;
-		}
-	}
-
-	/* Attach to ZMII, if needed */
-	if ((err = zmii_attach(dev)) != 0)
-		goto out2;
-
-	/* Attach to RGMII, if needed */
-	if ((err = rgmii_attach(dev)) != 0)
-		goto out3;
-
-	/* Attach to TAH, if needed */
-	if ((err = tah_attach(dev)) != 0)
-		goto out4;
-
-	/* Map EMAC regs */
-	dev->emacp = ioremap(dev->def->paddr, sizeof(struct emac_regs));
-	if (!dev->emacp) {
-		printk(KERN_ERR "emac%d: could not ioremap device registers!\n",
-		       dev->def->index);
-		err = -ENOMEM;
-		goto out5;
-	}
-
-	/* Fill in MAC address */
-	for (i = 0; i < 6; ++i)
-		ndev->dev_addr[i] = emacdata->mac_addr[i];
-
-	/* Set some link defaults before we can find out real parameters */
-	dev->phy.speed = SPEED_100;
-	dev->phy.duplex = DUPLEX_FULL;
-	dev->phy.autoneg = AUTONEG_DISABLE;
-	dev->phy.pause = dev->phy.asym_pause = 0;
-	dev->stop_timeout = STOP_TIMEOUT_100;
-	init_timer(&dev->link_timer);
-	dev->link_timer.function = emac_link_timer;
-	dev->link_timer.data = (unsigned long)dev;
-
-	/* Find PHY if any */
-	dev->phy.dev = ndev;
-	dev->phy.mode = emacdata->phy_mode;
-	if (emacdata->phy_map != 0xffffffff) {
-		u32 phy_map = emacdata->phy_map | busy_phy_map;
-		u32 adv;
-
-		DBG("%d: PHY maps %08x %08x" NL, dev->def->index,
-		    emacdata->phy_map, busy_phy_map);
-
-		EMAC_RX_CLK_TX(dev->def->index);
-
-		dev->phy.mdio_read = emac_mdio_read;
-		dev->phy.mdio_write = emac_mdio_write;
-
-		/* Configure EMAC with defaults so we can at least use MDIO
-		 * This is needed mostly for 440GX
-		 */
-		if (emac_phy_gpcs(dev->phy.mode)) {
-			/* XXX
-			 * Make GPCS PHY address equal to EMAC index.
-			 * We probably should take into account busy_phy_map
-			 * and/or phy_map here.
-			 */
-			dev->phy.address = dev->def->index;
-		}
-		
-		emac_configure(dev);
-
-		for (i = 0; i < 0x20; phy_map >>= 1, ++i)
-			if (!(phy_map & 1)) {
-				int r;
-				busy_phy_map |= 1 << i;
-
-				/* Quick check if there is a PHY at the address */
-				r = emac_mdio_read(dev->ndev, i, MII_BMCR);
-				if (r == 0xffff || r < 0)
-					continue;
-				if (!mii_phy_probe(&dev->phy, i))
-					break;
-			}
-		if (i == 0x20) {
-			printk(KERN_WARNING "emac%d: can't find PHY!\n",
-			       dev->def->index);
-			goto out6;
-		}
-
-		/* Init PHY */
-		if (dev->phy.def->ops->init)
-			dev->phy.def->ops->init(&dev->phy);
-		
-		/* Disable any PHY features not supported by the platform */
-		dev->phy.def->features &= ~emacdata->phy_feat_exc;
-
-		/* Setup initial link parameters */
-		if (dev->phy.features & SUPPORTED_Autoneg) {
-			adv = dev->phy.features;
-#if !defined(CONFIG_40x)
-			adv |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
-#endif
-			/* Restart autonegotiation */
-			dev->phy.def->ops->setup_aneg(&dev->phy, adv);
-		} else {
-			u32 f = dev->phy.def->features;
-			int speed = SPEED_10, fd = DUPLEX_HALF;
-
-			/* Select highest supported speed/duplex */
-			if (f & SUPPORTED_1000baseT_Full) {
-				speed = SPEED_1000;
-				fd = DUPLEX_FULL;
-			} else if (f & SUPPORTED_1000baseT_Half)
-				speed = SPEED_1000;
-			else if (f & SUPPORTED_100baseT_Full) {
-				speed = SPEED_100;
-				fd = DUPLEX_FULL;
-			} else if (f & SUPPORTED_100baseT_Half)
-				speed = SPEED_100;
-			else if (f & SUPPORTED_10baseT_Full)
-				fd = DUPLEX_FULL;
-
-			/* Force link parameters */
-			dev->phy.def->ops->setup_forced(&dev->phy, speed, fd);
-		}
-	} else {
-		emac_reset(dev);
-
-		/* PHY-less configuration.
-		 * XXX I probably should move these settings to emacdata
-		 */
-		dev->phy.address = -1;
-		dev->phy.features = SUPPORTED_100baseT_Full | SUPPORTED_MII;
-		dev->phy.pause = 1;
-	}
-
-	/* Fill in the driver function table */
-	ndev->open = &emac_open;
-	if (dev->tah_dev) {
-		ndev->hard_start_xmit = &emac_start_xmit_sg;
-		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-	} else
-		ndev->hard_start_xmit = &emac_start_xmit;
-	ndev->tx_timeout = &emac_full_tx_reset;
-	ndev->watchdog_timeo = 5 * HZ;
-	ndev->stop = &emac_close;
-	ndev->get_stats = &emac_stats;
-	ndev->set_multicast_list = &emac_set_multicast_list;
-	ndev->do_ioctl = &emac_ioctl;
-	if (emac_phy_supports_gige(emacdata->phy_mode)) {
-		ndev->change_mtu = &emac_change_mtu;
-		dev->commac.ops = &emac_commac_sg_ops;
-	}
-	SET_ETHTOOL_OPS(ndev, &emac_ethtool_ops);
-
-	netif_carrier_off(ndev);
-	netif_stop_queue(ndev);
-
-	err = register_netdev(ndev);
-	if (err) {
-		printk(KERN_ERR "emac%d: failed to register net device (%d)!\n",
-		       dev->def->index, err);
-		goto out6;
-	}
-
-	ocp_set_drvdata(ocpdev, dev);
-
-	printk("%s: emac%d, MAC %s\n",
-	       ndev->name, dev->def->index, print_mac(mac, ndev->dev_addr));
-
-	if (dev->phy.address >= 0)
-		printk("%s: found %s PHY (0x%02x)\n", ndev->name,
-		       dev->phy.def->name, dev->phy.address);
-
-	emac_dbg_register(dev->def->index, dev);
-
-	return 0;
-      out6:
-	iounmap(dev->emacp);
-      out5:
-	tah_fini(dev->tah_dev);
-      out4:
-	rgmii_fini(dev->rgmii_dev, dev->rgmii_input);
-      out3:
-	zmii_fini(dev->zmii_dev, dev->zmii_input);
-      out2:
-	mal_unregister_commac(dev->mal, &dev->commac);
-      out:
-	kfree(ndev);
-	return err;
-}
-
-static struct ocp_device_id emac_ids[] = {
-	{ .vendor = OCP_VENDOR_IBM, .function = OCP_FUNC_EMAC },
-	{ .vendor = OCP_VENDOR_INVALID}
-};
-
-static struct ocp_driver emac_driver = {
-	.name = "emac",
-	.id_table = emac_ids,
-	.probe = emac_probe,
-	.remove = emac_remove,
-};
-
-static int __init emac_init(void)
-{
-	printk(KERN_INFO DRV_DESC ", version " DRV_VERSION "\n");
-
-	DBG(": init" NL);
-
-	if (mal_init())
-		return -ENODEV;
-
-	EMAC_CLK_INTERNAL;
-	if (ocp_register_driver(&emac_driver)) {
-		EMAC_CLK_EXTERNAL;
-		ocp_unregister_driver(&emac_driver);
-		mal_exit();
-		return -ENODEV;
-	}
-	EMAC_CLK_EXTERNAL;
-
-	emac_init_debug();
-	return 0;
-}
-
-static void __exit emac_exit(void)
-{
-	DBG(": exit" NL);
-	ocp_unregister_driver(&emac_driver);
-	mal_exit();
-	emac_fini_debug();
-}
-
-module_init(emac_init);
-module_exit(emac_exit);
diff --git a/drivers/net/ibm_emac/ibm_emac_core.h b/drivers/net/ibm_emac/ibm_emac_core.h
deleted file mode 100644
index dabb94a..0000000
--- a/drivers/net/ibm_emac/ibm_emac_core.h
+++ /dev/null
@@ -1,222 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_core.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Armin Kuster <akuster@mvista.com>
- * 	Johnnie Peters <jpeters@mvista.com>
- *      Copyright 2000, 2001 MontaVista Softare Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __IBM_EMAC_CORE_H_
-#define __IBM_EMAC_CORE_H_
-
-#include <linux/netdevice.h>
-#include <linux/dma-mapping.h>
-#include <asm/ocp.h>
-
-#include "ibm_emac.h"
-#include "ibm_emac_phy.h"
-#include "ibm_emac_zmii.h"
-#include "ibm_emac_rgmii.h"
-#include "ibm_emac_mal.h"
-#include "ibm_emac_tah.h"
-
-#define NUM_TX_BUFF			CONFIG_IBM_EMAC_TXB
-#define NUM_RX_BUFF			CONFIG_IBM_EMAC_RXB
-
-/* Simple sanity check */
-#if NUM_TX_BUFF > 256 || NUM_RX_BUFF > 256
-#error Invalid number of buffer descriptors (greater than 256)
-#endif
-
-// XXX
-#define EMAC_MIN_MTU			46
-#define EMAC_MAX_MTU			9000
-
-/* Maximum L2 header length (VLAN tagged, no FCS) */
-#define EMAC_MTU_OVERHEAD		(6 * 2 + 2 + 4)
-
-/* RX BD size for the given MTU */
-static inline int emac_rx_size(int mtu)
-{
-	if (mtu > ETH_DATA_LEN)
-		return MAL_MAX_RX_SIZE;
-	else
-		return mal_rx_size(ETH_DATA_LEN + EMAC_MTU_OVERHEAD);
-}
-
-#define EMAC_DMA_ALIGN(x)		ALIGN((x), dma_get_cache_alignment())
-
-#define EMAC_RX_SKB_HEADROOM		\
-	EMAC_DMA_ALIGN(CONFIG_IBM_EMAC_RX_SKB_HEADROOM)
-
-/* Size of RX skb for the given MTU */
-static inline int emac_rx_skb_size(int mtu)
-{
-	int size = max(mtu + EMAC_MTU_OVERHEAD, emac_rx_size(mtu));
-	return EMAC_DMA_ALIGN(size + 2) + EMAC_RX_SKB_HEADROOM;
-}
-
-/* RX DMA sync size */
-static inline int emac_rx_sync_size(int mtu)
-{
-	return EMAC_DMA_ALIGN(emac_rx_size(mtu) + 2);
-}
-
-/* Driver statistcs is split into two parts to make it more cache friendly:
- *   - normal statistics (packet count, etc)
- *   - error statistics
- *
- * When statistics is requested by ethtool, these parts are concatenated,
- * normal one goes first.
- *
- * Please, keep these structures in sync with emac_stats_keys.
- */
-
-/* Normal TX/RX Statistics */
-struct ibm_emac_stats {
-	u64 rx_packets;
-	u64 rx_bytes;
-	u64 tx_packets;
-	u64 tx_bytes;
-	u64 rx_packets_csum;
-	u64 tx_packets_csum;
-};
-
-/* Error statistics */
-struct ibm_emac_error_stats {
-	u64 tx_undo;
-
-	/* Software RX Errors */
-	u64 rx_dropped_stack;
-	u64 rx_dropped_oom;
-	u64 rx_dropped_error;
-	u64 rx_dropped_resize;
-	u64 rx_dropped_mtu;
-	u64 rx_stopped;
-	/* BD reported RX errors */
-	u64 rx_bd_errors;
-	u64 rx_bd_overrun;
-	u64 rx_bd_bad_packet;
-	u64 rx_bd_runt_packet;
-	u64 rx_bd_short_event;
-	u64 rx_bd_alignment_error;
-	u64 rx_bd_bad_fcs;
-	u64 rx_bd_packet_too_long;
-	u64 rx_bd_out_of_range;
-	u64 rx_bd_in_range;
-	/* EMAC IRQ reported RX errors */
-	u64 rx_parity;
-	u64 rx_fifo_overrun;
-	u64 rx_overrun;
-	u64 rx_bad_packet;
-	u64 rx_runt_packet;
-	u64 rx_short_event;
-	u64 rx_alignment_error;
-	u64 rx_bad_fcs;
-	u64 rx_packet_too_long;
-	u64 rx_out_of_range;
-	u64 rx_in_range;
-
-	/* Software TX Errors */
-	u64 tx_dropped;
-	/* BD reported TX errors */
-	u64 tx_bd_errors;
-	u64 tx_bd_bad_fcs;
-	u64 tx_bd_carrier_loss;
-	u64 tx_bd_excessive_deferral;
-	u64 tx_bd_excessive_collisions;
-	u64 tx_bd_late_collision;
-	u64 tx_bd_multple_collisions;
-	u64 tx_bd_single_collision;
-	u64 tx_bd_underrun;
-	u64 tx_bd_sqe;
-	/* EMAC IRQ reported TX errors */
-	u64 tx_parity;
-	u64 tx_underrun;
-	u64 tx_sqe;
-	u64 tx_errors;
-};
-
-#define EMAC_ETHTOOL_STATS_COUNT	((sizeof(struct ibm_emac_stats) + \
-					  sizeof(struct ibm_emac_error_stats)) \
-					 / sizeof(u64))
-
-struct ocp_enet_private {
-	struct net_device		*ndev;		/* 0 */
-	struct emac_regs		__iomem *emacp;
-	
-	struct mal_descriptor		*tx_desc;
-	int				tx_cnt;
-	int				tx_slot;
-	int				ack_slot;
-
-	struct mal_descriptor		*rx_desc;
-	int				rx_slot;
-	struct sk_buff			*rx_sg_skb;	/* 1 */
-	int 				rx_skb_size;
-	int				rx_sync_size;
-
-	struct ibm_emac_stats 		stats;
-	struct ocp_device		*tah_dev;
-
-	struct ibm_ocp_mal		*mal;
-	struct mal_commac		commac;
-
-	struct sk_buff			*tx_skb[NUM_TX_BUFF];
-	struct sk_buff			*rx_skb[NUM_RX_BUFF];
-
-	struct ocp_device		*zmii_dev;
-	int				zmii_input;
-	struct ocp_enet_private		*mdio_dev;
-	struct ocp_device		*rgmii_dev;
-	int				rgmii_input;
-
-	struct ocp_def			*def;
-
-	struct mii_phy			phy;
-	struct timer_list		link_timer;
-	int				reset_failed;
-
-	int				stop_timeout;	/* in us */
-
-	struct ibm_emac_error_stats	estats;
-	struct net_device_stats		nstats;
-
-	struct device*			ldev;
-};
-
-/* Ethtool get_regs complex data.
- * We want to get not just EMAC registers, but also MAL, ZMII, RGMII, TAH 
- * when available.
- * 
- * Returned BLOB consists of the ibm_emac_ethtool_regs_hdr, 
- * MAL registers, EMAC registers and optional ZMII, RGMII, TAH registers.
- * Each register component is preceded with emac_ethtool_regs_subhdr.
- * Order of the optional headers follows their relative bit posititions 
- * in emac_ethtool_regs_hdr.components
- */
-#define EMAC_ETHTOOL_REGS_ZMII		0x00000001
-#define EMAC_ETHTOOL_REGS_RGMII		0x00000002
-#define EMAC_ETHTOOL_REGS_TAH		0x00000004
-
-struct emac_ethtool_regs_hdr {
-	u32 components;
-};
-
-struct emac_ethtool_regs_subhdr {
-	u32 version;
-	u32 index;
-};
-
-#endif				/* __IBM_EMAC_CORE_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_debug.c b/drivers/net/ibm_emac/ibm_emac_debug.c
deleted file mode 100644
index 1f70906..0000000
--- a/drivers/net/ibm_emac/ibm_emac_debug.c
+++ /dev/null
@@ -1,211 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_debug.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netdevice.h>
-#include <linux/sysrq.h>
-#include <asm/io.h>
-
-#include "ibm_emac_core.h"
-
-static void emac_desc_dump(int idx, struct ocp_enet_private *p)
-{
-	int i;
-	printk("** EMAC%d TX BDs **\n"
-	       " tx_cnt = %d tx_slot = %d ack_slot = %d\n",
-	       idx, p->tx_cnt, p->tx_slot, p->ack_slot);
-	for (i = 0; i < NUM_TX_BUFF / 2; ++i)
-		printk
-		    ("bd[%2d] 0x%08x %c 0x%04x %4u - bd[%2d] 0x%08x %c 0x%04x %4u\n",
-		     i, p->tx_desc[i].data_ptr, p->tx_skb[i] ? 'V' : ' ',
-		     p->tx_desc[i].ctrl, p->tx_desc[i].data_len,
-		     NUM_TX_BUFF / 2 + i,
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].data_ptr,
-		     p->tx_skb[NUM_TX_BUFF / 2 + i] ? 'V' : ' ',
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].ctrl,
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].data_len);
-
-	printk("** EMAC%d RX BDs **\n"
-	       " rx_slot = %d rx_stopped = %d rx_skb_size = %d rx_sync_size = %d\n"
-	       " rx_sg_skb = 0x%p\n",
-	       idx, p->rx_slot, p->commac.rx_stopped, p->rx_skb_size,
-	       p->rx_sync_size, p->rx_sg_skb);
-	for (i = 0; i < NUM_RX_BUFF / 2; ++i)
-		printk
-		    ("bd[%2d] 0x%08x %c 0x%04x %4u - bd[%2d] 0x%08x %c 0x%04x %4u\n",
-		     i, p->rx_desc[i].data_ptr, p->rx_skb[i] ? 'V' : ' ',
-		     p->rx_desc[i].ctrl, p->rx_desc[i].data_len,
-		     NUM_RX_BUFF / 2 + i,
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].data_ptr,
-		     p->rx_skb[NUM_RX_BUFF / 2 + i] ? 'V' : ' ',
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].ctrl,
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].data_len);
-}
-
-static void emac_mac_dump(int idx, struct ocp_enet_private *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-
-	printk("** EMAC%d registers **\n"
-	       "MR0 = 0x%08x MR1 = 0x%08x TMR0 = 0x%08x TMR1 = 0x%08x\n"
-	       "RMR = 0x%08x ISR = 0x%08x ISER = 0x%08x\n"
-	       "IAR = %04x%08x VTPID = 0x%04x VTCI = 0x%04x\n"
-	       "IAHT: 0x%04x 0x%04x 0x%04x 0x%04x "
-	       "GAHT: 0x%04x 0x%04x 0x%04x 0x%04x\n"
-	       "LSA = %04x%08x IPGVR = 0x%04x\n"
-	       "STACR = 0x%08x TRTR = 0x%08x RWMR = 0x%08x\n"
-	       "OCTX = 0x%08x OCRX = 0x%08x IPCR = 0x%08x\n",
-	       idx, in_be32(&p->mr0), in_be32(&p->mr1),
-	       in_be32(&p->tmr0), in_be32(&p->tmr1),
-	       in_be32(&p->rmr), in_be32(&p->isr), in_be32(&p->iser),
-	       in_be32(&p->iahr), in_be32(&p->ialr), in_be32(&p->vtpid),
-	       in_be32(&p->vtci),
-	       in_be32(&p->iaht1), in_be32(&p->iaht2), in_be32(&p->iaht3),
-	       in_be32(&p->iaht4),
-	       in_be32(&p->gaht1), in_be32(&p->gaht2), in_be32(&p->gaht3),
-	       in_be32(&p->gaht4),
-	       in_be32(&p->lsah), in_be32(&p->lsal), in_be32(&p->ipgvr),
-	       in_be32(&p->stacr), in_be32(&p->trtr), in_be32(&p->rwmr),
-	       in_be32(&p->octx), in_be32(&p->ocrx), in_be32(&p->ipcr)
-	    );
-
-	emac_desc_dump(idx, dev);
-}
-
-static void emac_mal_dump(struct ibm_ocp_mal *mal)
-{
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-	int i;
-
-	printk("** MAL%d Registers **\n"
-	       "CFG = 0x%08x ESR = 0x%08x IER = 0x%08x\n"
-	       "TX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n"
-	       "RX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n",
-	       mal->def->index,
-	       get_mal_dcrn(mal, MAL_CFG), get_mal_dcrn(mal, MAL_ESR),
-	       get_mal_dcrn(mal, MAL_IER),
-	       get_mal_dcrn(mal, MAL_TXCASR), get_mal_dcrn(mal, MAL_TXCARR),
-	       get_mal_dcrn(mal, MAL_TXEOBISR), get_mal_dcrn(mal, MAL_TXDEIR),
-	       get_mal_dcrn(mal, MAL_RXCASR), get_mal_dcrn(mal, MAL_RXCARR),
-	       get_mal_dcrn(mal, MAL_RXEOBISR), get_mal_dcrn(mal, MAL_RXDEIR)
-	    );
-
-	printk("TX|");
-	for (i = 0; i < maldata->num_tx_chans; ++i) {
-		if (i && !(i % 4))
-			printk("\n   ");
-		printk("CTP%d = 0x%08x ", i, get_mal_dcrn(mal, MAL_TXCTPR(i)));
-	}
-	printk("\nRX|");
-	for (i = 0; i < maldata->num_rx_chans; ++i) {
-		if (i && !(i % 4))
-			printk("\n   ");
-		printk("CTP%d = 0x%08x ", i, get_mal_dcrn(mal, MAL_RXCTPR(i)));
-	}
-	printk("\n   ");
-	for (i = 0; i < maldata->num_rx_chans; ++i) {
-		u32 r = get_mal_dcrn(mal, MAL_RCBS(i));
-		if (i && !(i % 3))
-			printk("\n   ");
-		printk("RCBS%d = 0x%08x (%d) ", i, r, r * 16);
-	}
-	printk("\n");
-}
-
-static struct ocp_enet_private *__emacs[4];
-static struct ibm_ocp_mal *__mals[1];
-
-void emac_dbg_register(int idx, struct ocp_enet_private *dev)
-{
-	unsigned long flags;
-
-	if (idx >= ARRAY_SIZE(__emacs)) {
-		printk(KERN_WARNING
-		       "invalid index %d when registering EMAC for debugging\n",
-		       idx);
-		return;
-	}
-
-	local_irq_save(flags);
-	__emacs[idx] = dev;
-	local_irq_restore(flags);
-}
-
-void mal_dbg_register(int idx, struct ibm_ocp_mal *mal)
-{
-	unsigned long flags;
-
-	if (idx >= ARRAY_SIZE(__mals)) {
-		printk(KERN_WARNING
-		       "invalid index %d when registering MAL for debugging\n",
-		       idx);
-		return;
-	}
-
-	local_irq_save(flags);
-	__mals[idx] = mal;
-	local_irq_restore(flags);
-}
-
-void emac_dbg_dump_all(void)
-{
-	unsigned int i;
-	unsigned long flags;
-
-	local_irq_save(flags);
-
-	for (i = 0; i < ARRAY_SIZE(__mals); ++i)
-		if (__mals[i])
-			emac_mal_dump(__mals[i]);
-
-	for (i = 0; i < ARRAY_SIZE(__emacs); ++i)
-		if (__emacs[i])
-			emac_mac_dump(i, __emacs[i]);
-
-	local_irq_restore(flags);
-}
-
-#if defined(CONFIG_MAGIC_SYSRQ)
-static void emac_sysrq_handler(int key, struct tty_struct *tty)
-{
-	emac_dbg_dump_all();
-}
-
-static struct sysrq_key_op emac_sysrq_op = {
-	.handler = emac_sysrq_handler,
-	.help_msg = "emaC",
-	.action_msg = "Show EMAC(s) status",
-};
-
-int __init emac_init_debug(void)
-{
-	return register_sysrq_key('c', &emac_sysrq_op);
-}
-
-void __exit emac_fini_debug(void)
-{
-	unregister_sysrq_key('c', &emac_sysrq_op);
-}
-
-#else
-int __init emac_init_debug(void)
-{
-	return 0;
-}
-void __exit emac_fini_debug(void)
-{
-}
-#endif				/* CONFIG_MAGIC_SYSRQ */
diff --git a/drivers/net/ibm_emac/ibm_emac_debug.h b/drivers/net/ibm_emac/ibm_emac_debug.h
deleted file mode 100644
index 6c7dccc..0000000
--- a/drivers/net/ibm_emac/ibm_emac_debug.h
+++ /dev/null
@@ -1,62 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_debug.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __IBM_EMAC_DEBUG_H_
-#define __IBM_EMAC_DEBUG_H_
-
-#include <linux/init.h>
-#include "ibm_emac_core.h"
-#include "ibm_emac_mal.h"
-
-#if defined(CONFIG_IBM_EMAC_DEBUG)
-void emac_dbg_register(int idx, struct ocp_enet_private *dev);
-void mal_dbg_register(int idx, struct ibm_ocp_mal *mal);
-int emac_init_debug(void) __init;
-void emac_fini_debug(void) __exit;
-void emac_dbg_dump_all(void);
-# define DBG_LEVEL		1
-#else
-# define emac_dbg_register(x,y) ((void)0)
-# define mal_dbg_register(x,y)	((void)0)
-# define emac_init_debug()	((void)0)
-# define emac_fini_debug()	((void)0)
-# define emac_dbg_dump_all()	((void)0)
-# define DBG_LEVEL		0
-#endif
-
-#if DBG_LEVEL > 0
-#  define DBG(f,x...)		printk("emac" f, ##x)
-#  define MAL_DBG(f,x...)	printk("mal" f, ##x)
-#  define ZMII_DBG(f,x...)	printk("zmii" f, ##x)
-#  define RGMII_DBG(f,x...)	printk("rgmii" f, ##x)
-#  define NL			"\n"
-#else
-#  define DBG(f,x...)		((void)0)
-#  define MAL_DBG(f,x...)	((void)0)
-#  define ZMII_DBG(f,x...)	((void)0)
-#  define RGMII_DBG(f,x...)	((void)0)
-#endif
-#if DBG_LEVEL > 1
-#  define DBG2(f,x...) 		DBG(f, ##x)
-#  define MAL_DBG2(f,x...) 	MAL_DBG(f, ##x)
-#  define ZMII_DBG2(f,x...) 	ZMII_DBG(f, ##x)
-#  define RGMII_DBG2(f,x...) 	RGMII_DBG(f, ##x)
-#else
-#  define DBG2(f,x...) 		((void)0)
-#  define MAL_DBG2(f,x...) 	((void)0)
-#  define ZMII_DBG2(f,x...) 	((void)0)
-#  define RGMII_DBG2(f,x...) 	((void)0)
-#endif
-
-#endif				/* __IBM_EMAC_DEBUG_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.c b/drivers/net/ibm_emac/ibm_emac_mal.c
deleted file mode 100644
index dcd8826..0000000
--- a/drivers/net/ibm_emac/ibm_emac_mal.c
+++ /dev/null
@@ -1,570 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_mal.c
- *
- * Memory Access Layer (MAL) support
- * 
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Benjamin Herrenschmidt <benh@kernel.crashing.org>,
- *      David Gibson <hermes@gibson.dropbear.id.au>,
- *
- *      Armin Kuster <akuster@mvista.com>
- *      Copyright 2002 MontaVista Softare Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/netdevice.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-#include <linux/dma-mapping.h>
-
-#include <asm/ocp.h>
-
-#include "ibm_emac_core.h"
-#include "ibm_emac_mal.h"
-#include "ibm_emac_debug.h"
-
-int __init mal_register_commac(struct ibm_ocp_mal *mal,
-			       struct mal_commac *commac)
-{
-	unsigned long flags;
-	local_irq_save(flags);
-
-	MAL_DBG("%d: reg(%08x, %08x)" NL, mal->def->index,
-		commac->tx_chan_mask, commac->rx_chan_mask);
-
-	/* Don't let multiple commacs claim the same channel(s) */
-	if ((mal->tx_chan_mask & commac->tx_chan_mask) ||
-	    (mal->rx_chan_mask & commac->rx_chan_mask)) {
-		local_irq_restore(flags);
-		printk(KERN_WARNING "mal%d: COMMAC channels conflict!\n",
-		       mal->def->index);
-		return -EBUSY;
-	}
-
-	mal->tx_chan_mask |= commac->tx_chan_mask;
-	mal->rx_chan_mask |= commac->rx_chan_mask;
-	list_add(&commac->list, &mal->list);
-
-	local_irq_restore(flags);
-	return 0;
-}
-
-void mal_unregister_commac(struct ibm_ocp_mal *mal, struct mal_commac *commac)
-{
-	unsigned long flags;
-	local_irq_save(flags);
-
-	MAL_DBG("%d: unreg(%08x, %08x)" NL, mal->def->index,
-		commac->tx_chan_mask, commac->rx_chan_mask);
-
-	mal->tx_chan_mask &= ~commac->tx_chan_mask;
-	mal->rx_chan_mask &= ~commac->rx_chan_mask;
-	list_del_init(&commac->list);
-
-	local_irq_restore(flags);
-}
-
-int mal_set_rcbs(struct ibm_ocp_mal *mal, int channel, unsigned long size)
-{
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-	BUG_ON(channel < 0 || channel >= maldata->num_rx_chans ||
-	       size > MAL_MAX_RX_SIZE);
-
-	MAL_DBG("%d: set_rbcs(%d, %lu)" NL, mal->def->index, channel, size);
-
-	if (size & 0xf) {
-		printk(KERN_WARNING
-		       "mal%d: incorrect RX size %lu for the channel %d\n",
-		       mal->def->index, size, channel);
-		return -EINVAL;
-	}
-
-	set_mal_dcrn(mal, MAL_RCBS(channel), size >> 4);
-	return 0;
-}
-
-int mal_tx_bd_offset(struct ibm_ocp_mal *mal, int channel)
-{
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-	BUG_ON(channel < 0 || channel >= maldata->num_tx_chans);
-	return channel * NUM_TX_BUFF;
-}
-
-int mal_rx_bd_offset(struct ibm_ocp_mal *mal, int channel)
-{
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-	BUG_ON(channel < 0 || channel >= maldata->num_rx_chans);
-	return maldata->num_tx_chans * NUM_TX_BUFF + channel * NUM_RX_BUFF;
-}
-
-void mal_enable_tx_channel(struct ibm_ocp_mal *mal, int channel)
-{
-	local_bh_disable();
-	MAL_DBG("%d: enable_tx(%d)" NL, mal->def->index, channel);
-	set_mal_dcrn(mal, MAL_TXCASR,
-		     get_mal_dcrn(mal, MAL_TXCASR) | MAL_CHAN_MASK(channel));
-	local_bh_enable();
-}
-
-void mal_disable_tx_channel(struct ibm_ocp_mal *mal, int channel)
-{
-	set_mal_dcrn(mal, MAL_TXCARR, MAL_CHAN_MASK(channel));
-	MAL_DBG("%d: disable_tx(%d)" NL, mal->def->index, channel);
-}
-
-void mal_enable_rx_channel(struct ibm_ocp_mal *mal, int channel)
-{
-	local_bh_disable();
-	MAL_DBG("%d: enable_rx(%d)" NL, mal->def->index, channel);
-	set_mal_dcrn(mal, MAL_RXCASR,
-		     get_mal_dcrn(mal, MAL_RXCASR) | MAL_CHAN_MASK(channel));
-	local_bh_enable();
-}
-
-void mal_disable_rx_channel(struct ibm_ocp_mal *mal, int channel)
-{
-	set_mal_dcrn(mal, MAL_RXCARR, MAL_CHAN_MASK(channel));
-	MAL_DBG("%d: disable_rx(%d)" NL, mal->def->index, channel);
-}
-
-void mal_poll_add(struct ibm_ocp_mal *mal, struct mal_commac *commac)
-{
-	local_bh_disable();
-	MAL_DBG("%d: poll_add(%p)" NL, mal->def->index, commac);
-	list_add_tail(&commac->poll_list, &mal->poll_list);
-	local_bh_enable();
-}
-
-void mal_poll_del(struct ibm_ocp_mal *mal, struct mal_commac *commac)
-{
-	local_bh_disable();
-	MAL_DBG("%d: poll_del(%p)" NL, mal->def->index, commac);
-	list_del(&commac->poll_list);
-	local_bh_enable();
-}
-
-/* synchronized by mal_poll() */
-static inline void mal_enable_eob_irq(struct ibm_ocp_mal *mal)
-{
-	MAL_DBG2("%d: enable_irq" NL, mal->def->index);
-	set_mal_dcrn(mal, MAL_CFG, get_mal_dcrn(mal, MAL_CFG) | MAL_CFG_EOPIE);
-}
-
-/* synchronized by __LINK_STATE_RX_SCHED bit in ndev->state */
-static inline void mal_disable_eob_irq(struct ibm_ocp_mal *mal)
-{
-	set_mal_dcrn(mal, MAL_CFG, get_mal_dcrn(mal, MAL_CFG) & ~MAL_CFG_EOPIE);
-	MAL_DBG2("%d: disable_irq" NL, mal->def->index);
-}
-
-static irqreturn_t mal_serr(int irq, void *dev_instance)
-{
-	struct ibm_ocp_mal *mal = dev_instance;
-	u32 esr = get_mal_dcrn(mal, MAL_ESR);
-
-	/* Clear the error status register */
-	set_mal_dcrn(mal, MAL_ESR, esr);
-
-	MAL_DBG("%d: SERR %08x" NL, mal->def->index, esr);
-
-	if (esr & MAL_ESR_EVB) {
-		if (esr & MAL_ESR_DE) {
-			/* We ignore Descriptor error,
-			 * TXDE or RXDE interrupt will be generated anyway.
-			 */
-			return IRQ_HANDLED;
-		}
-
-		if (esr & MAL_ESR_PEIN) {
-			/* PLB error, it's probably buggy hardware or
-			 * incorrect physical address in BD (i.e. bug)
-			 */
-			if (net_ratelimit())
-				printk(KERN_ERR
-				       "mal%d: system error, PLB (ESR = 0x%08x)\n",
-				       mal->def->index, esr);
-			return IRQ_HANDLED;
-		}
-
-		/* OPB error, it's probably buggy hardware or incorrect EBC setup */
-		if (net_ratelimit())
-			printk(KERN_ERR
-			       "mal%d: system error, OPB (ESR = 0x%08x)\n",
-			       mal->def->index, esr);
-	}
-	return IRQ_HANDLED;
-}
-
-static inline void mal_schedule_poll(struct ibm_ocp_mal *mal)
-{
-	if (likely(napi_schedule_prep(&mal->napi))) {
-		MAL_DBG2("%d: schedule_poll" NL, mal->def->index);
-		mal_disable_eob_irq(mal);
-		__napi_schedule(&mal->napi);
-	} else
-		MAL_DBG2("%d: already in poll" NL, mal->def->index);
-}
-
-static irqreturn_t mal_txeob(int irq, void *dev_instance)
-{
-	struct ibm_ocp_mal *mal = dev_instance;
-	u32 r = get_mal_dcrn(mal, MAL_TXEOBISR);
-	MAL_DBG2("%d: txeob %08x" NL, mal->def->index, r);
-	mal_schedule_poll(mal);
-	set_mal_dcrn(mal, MAL_TXEOBISR, r);
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t mal_rxeob(int irq, void *dev_instance)
-{
-	struct ibm_ocp_mal *mal = dev_instance;
-	u32 r = get_mal_dcrn(mal, MAL_RXEOBISR);
-	MAL_DBG2("%d: rxeob %08x" NL, mal->def->index, r);
-	mal_schedule_poll(mal);
-	set_mal_dcrn(mal, MAL_RXEOBISR, r);
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t mal_txde(int irq, void *dev_instance)
-{
-	struct ibm_ocp_mal *mal = dev_instance;
-	u32 deir = get_mal_dcrn(mal, MAL_TXDEIR);
-	set_mal_dcrn(mal, MAL_TXDEIR, deir);
-
-	MAL_DBG("%d: txde %08x" NL, mal->def->index, deir);
-
-	if (net_ratelimit())
-		printk(KERN_ERR
-		       "mal%d: TX descriptor error (TXDEIR = 0x%08x)\n",
-		       mal->def->index, deir);
-
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t mal_rxde(int irq, void *dev_instance)
-{
-	struct ibm_ocp_mal *mal = dev_instance;
-	struct list_head *l;
-	u32 deir = get_mal_dcrn(mal, MAL_RXDEIR);
-
-	MAL_DBG("%d: rxde %08x" NL, mal->def->index, deir);
-
-	list_for_each(l, &mal->list) {
-		struct mal_commac *mc = list_entry(l, struct mal_commac, list);
-		if (deir & mc->rx_chan_mask) {
-			mc->rx_stopped = 1;
-			mc->ops->rxde(mc->dev);
-		}
-	}
-
-	mal_schedule_poll(mal);
-	set_mal_dcrn(mal, MAL_RXDEIR, deir);
-
-	return IRQ_HANDLED;
-}
-
-static int mal_poll(struct napi_struct *napi, int budget)
-{
-	struct ibm_ocp_mal *mal = container_of(napi, struct ibm_ocp_mal, napi);
-	struct list_head *l;
-	int received = 0;
-
-	MAL_DBG2("%d: poll(%d) %d ->" NL, mal->def->index, *budget,
-		 rx_work_limit);
-      again:
-	/* Process TX skbs */
-	list_for_each(l, &mal->poll_list) {
-		struct mal_commac *mc =
-		    list_entry(l, struct mal_commac, poll_list);
-		mc->ops->poll_tx(mc->dev);
-	}
-
-	/* Process RX skbs.
-	 * We _might_ need something more smart here to enforce polling fairness.
-	 */
-	list_for_each(l, &mal->poll_list) {
-		struct mal_commac *mc =
-		    list_entry(l, struct mal_commac, poll_list);
-		int n = mc->ops->poll_rx(mc->dev, budget);
-		if (n) {
-			received += n;
-			budget -= n;
-			if (budget <= 0)
-				goto more_work;	// XXX What if this is the last one ?
-		}
-	}
-
-	/* We need to disable IRQs to protect from RXDE IRQ here */
-	local_irq_disable();
-	__napi_complete(napi);
-	mal_enable_eob_irq(mal);
-	local_irq_enable();
-
-	/* Check for "rotting" packet(s) */
-	list_for_each(l, &mal->poll_list) {
-		struct mal_commac *mc =
-		    list_entry(l, struct mal_commac, poll_list);
-		if (unlikely(mc->ops->peek_rx(mc->dev) || mc->rx_stopped)) {
-			MAL_DBG2("%d: rotting packet" NL, mal->def->index);
-			if (napi_reschedule(napi))
-				mal_disable_eob_irq(mal);
-			else
-				MAL_DBG2("%d: already in poll list" NL,
-					 mal->def->index);
-
-			if (budget > 0)
-				goto again;
-			else
-				goto more_work;
-		}
-		mc->ops->poll_tx(mc->dev);
-	}
-
-      more_work:
-	MAL_DBG2("%d: poll() %d <- %d" NL, mal->def->index, budget, received);
-	return received;
-}
-
-static void mal_reset(struct ibm_ocp_mal *mal)
-{
-	int n = 10;
-	MAL_DBG("%d: reset" NL, mal->def->index);
-
-	set_mal_dcrn(mal, MAL_CFG, MAL_CFG_SR);
-
-	/* Wait for reset to complete (1 system clock) */
-	while ((get_mal_dcrn(mal, MAL_CFG) & MAL_CFG_SR) && n)
-		--n;
-
-	if (unlikely(!n))
-		printk(KERN_ERR "mal%d: reset timeout\n", mal->def->index);
-}
-
-int mal_get_regs_len(struct ibm_ocp_mal *mal)
-{
-	return sizeof(struct emac_ethtool_regs_subhdr) +
-	    sizeof(struct ibm_mal_regs);
-}
-
-void *mal_dump_regs(struct ibm_ocp_mal *mal, void *buf)
-{
-	struct emac_ethtool_regs_subhdr *hdr = buf;
-	struct ibm_mal_regs *regs = (struct ibm_mal_regs *)(hdr + 1);
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-	int i;
-
-	hdr->version = MAL_VERSION;
-	hdr->index = mal->def->index;
-
-	regs->tx_count = maldata->num_tx_chans;
-	regs->rx_count = maldata->num_rx_chans;
-
-	regs->cfg = get_mal_dcrn(mal, MAL_CFG);
-	regs->esr = get_mal_dcrn(mal, MAL_ESR);
-	regs->ier = get_mal_dcrn(mal, MAL_IER);
-	regs->tx_casr = get_mal_dcrn(mal, MAL_TXCASR);
-	regs->tx_carr = get_mal_dcrn(mal, MAL_TXCARR);
-	regs->tx_eobisr = get_mal_dcrn(mal, MAL_TXEOBISR);
-	regs->tx_deir = get_mal_dcrn(mal, MAL_TXDEIR);
-	regs->rx_casr = get_mal_dcrn(mal, MAL_RXCASR);
-	regs->rx_carr = get_mal_dcrn(mal, MAL_RXCARR);
-	regs->rx_eobisr = get_mal_dcrn(mal, MAL_RXEOBISR);
-	regs->rx_deir = get_mal_dcrn(mal, MAL_RXDEIR);
-
-	for (i = 0; i < regs->tx_count; ++i)
-		regs->tx_ctpr[i] = get_mal_dcrn(mal, MAL_TXCTPR(i));
-
-	for (i = 0; i < regs->rx_count; ++i) {
-		regs->rx_ctpr[i] = get_mal_dcrn(mal, MAL_RXCTPR(i));
-		regs->rcbs[i] = get_mal_dcrn(mal, MAL_RCBS(i));
-	}
-	return regs + 1;
-}
-
-static int __init mal_probe(struct ocp_device *ocpdev)
-{
-	struct ibm_ocp_mal *mal;
-	struct ocp_func_mal_data *maldata;
-	int err = 0, i, bd_size;
-
-	MAL_DBG("%d: probe" NL, ocpdev->def->index);
-
-	maldata = ocpdev->def->additions;
-	if (maldata == NULL) {
-		printk(KERN_ERR "mal%d: missing additional data!\n",
-		       ocpdev->def->index);
-		return -ENODEV;
-	}
-
-	mal = kzalloc(sizeof(struct ibm_ocp_mal), GFP_KERNEL);
-	if (!mal) {
-		printk(KERN_ERR
-		       "mal%d: out of memory allocating MAL structure!\n",
-		       ocpdev->def->index);
-		return -ENOMEM;
-	}
-
-	/* XXX This only works for native dcr for now */
-	mal->dcrhost = dcr_map(NULL, maldata->dcr_base, 0);
-
-	mal->def = ocpdev->def;
-
-	INIT_LIST_HEAD(&mal->poll_list);
-	mal->napi.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
-	mal->napi.poll = mal_poll;
-
-	INIT_LIST_HEAD(&mal->list);
-
-	/* Load power-on reset defaults */
-	mal_reset(mal);
-
-	/* Set the MAL configuration register */
-	set_mal_dcrn(mal, MAL_CFG, MAL_CFG_DEFAULT | MAL_CFG_PLBB |
-		     MAL_CFG_OPBBL | MAL_CFG_LEA);
-
-	mal_enable_eob_irq(mal);
-
-	/* Allocate space for BD rings */
-	BUG_ON(maldata->num_tx_chans <= 0 || maldata->num_tx_chans > 32);
-	BUG_ON(maldata->num_rx_chans <= 0 || maldata->num_rx_chans > 32);
-	bd_size = sizeof(struct mal_descriptor) *
-	    (NUM_TX_BUFF * maldata->num_tx_chans +
-	     NUM_RX_BUFF * maldata->num_rx_chans);
-	mal->bd_virt =
-	    dma_alloc_coherent(&ocpdev->dev, bd_size, &mal->bd_dma, GFP_KERNEL);
-
-	if (!mal->bd_virt) {
-		printk(KERN_ERR
-		       "mal%d: out of memory allocating RX/TX descriptors!\n",
-		       mal->def->index);
-		err = -ENOMEM;
-		goto fail;
-	}
-	memset(mal->bd_virt, 0, bd_size);
-
-	for (i = 0; i < maldata->num_tx_chans; ++i)
-		set_mal_dcrn(mal, MAL_TXCTPR(i), mal->bd_dma +
-			     sizeof(struct mal_descriptor) *
-			     mal_tx_bd_offset(mal, i));
-
-	for (i = 0; i < maldata->num_rx_chans; ++i)
-		set_mal_dcrn(mal, MAL_RXCTPR(i), mal->bd_dma +
-			     sizeof(struct mal_descriptor) *
-			     mal_rx_bd_offset(mal, i));
-
-	err = request_irq(maldata->serr_irq, mal_serr, 0, "MAL SERR", mal);
-	if (err)
-		goto fail2;
-	err = request_irq(maldata->txde_irq, mal_txde, 0, "MAL TX DE", mal);
-	if (err)
-		goto fail3;
-	err = request_irq(maldata->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
-	if (err)
-		goto fail4;
-	err = request_irq(maldata->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
-	if (err)
-		goto fail5;
-	err = request_irq(maldata->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
-	if (err)
-		goto fail6;
-
-	/* Enable all MAL SERR interrupt sources */
-	set_mal_dcrn(mal, MAL_IER, MAL_IER_EVENTS);
-
-	/* Advertise this instance to the rest of the world */
-	ocp_set_drvdata(ocpdev, mal);
-
-	mal_dbg_register(mal->def->index, mal);
-
-	printk(KERN_INFO "mal%d: initialized, %d TX channels, %d RX channels\n",
-	       mal->def->index, maldata->num_tx_chans, maldata->num_rx_chans);
-	return 0;
-
-      fail6:
-	free_irq(maldata->rxde_irq, mal);
-      fail5:
-	free_irq(maldata->txeob_irq, mal);
-      fail4:
-	free_irq(maldata->txde_irq, mal);
-      fail3:
-	free_irq(maldata->serr_irq, mal);
-      fail2:
-	dma_free_coherent(&ocpdev->dev, bd_size, mal->bd_virt, mal->bd_dma);
-      fail:
-	kfree(mal);
-	return err;
-}
-
-static void __exit mal_remove(struct ocp_device *ocpdev)
-{
-	struct ibm_ocp_mal *mal = ocp_get_drvdata(ocpdev);
-	struct ocp_func_mal_data *maldata = mal->def->additions;
-
-	MAL_DBG("%d: remove" NL, mal->def->index);
-
-	/* Synchronize with scheduled polling */
-	napi_disable(&mal->napi);
-
-	if (!list_empty(&mal->list)) {
-		/* This is *very* bad */
-		printk(KERN_EMERG
-		       "mal%d: commac list is not empty on remove!\n",
-		       mal->def->index);
-	}
-
-	ocp_set_drvdata(ocpdev, NULL);
-
-	free_irq(maldata->serr_irq, mal);
-	free_irq(maldata->txde_irq, mal);
-	free_irq(maldata->txeob_irq, mal);
-	free_irq(maldata->rxde_irq, mal);
-	free_irq(maldata->rxeob_irq, mal);
-
-	mal_reset(mal);
-
-	mal_dbg_register(mal->def->index, NULL);
-
-	dma_free_coherent(&ocpdev->dev,
-			  sizeof(struct mal_descriptor) *
-			  (NUM_TX_BUFF * maldata->num_tx_chans +
-			   NUM_RX_BUFF * maldata->num_rx_chans), mal->bd_virt,
-			  mal->bd_dma);
-
-	kfree(mal);
-}
-
-/* Structure for a device driver */
-static struct ocp_device_id mal_ids[] = {
-	{ .vendor = OCP_VENDOR_IBM, .function = OCP_FUNC_MAL },
-	{ .vendor = OCP_VENDOR_INVALID}
-};
-
-static struct ocp_driver mal_driver = {
-	.name = "mal",
-	.id_table = mal_ids,
-
-	.probe = mal_probe,
-	.remove = mal_remove,
-};
-
-int __init mal_init(void)
-{
-	MAL_DBG(": init" NL);
-	return ocp_register_driver(&mal_driver);
-}
-
-void __exit mal_exit(void)
-{
-	MAL_DBG(": exit" NL);
-	ocp_unregister_driver(&mal_driver);
-}
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
deleted file mode 100644
index b8adbe6..0000000
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ /dev/null
@@ -1,267 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_mal.h
- *
- * Memory Access Layer (MAL) support
- * 
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Armin Kuster <akuster@mvista.com>
- *      Copyright 2002 MontaVista Softare Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __IBM_EMAC_MAL_H_
-#define __IBM_EMAC_MAL_H_
-
-#include <linux/init.h>
-#include <linux/list.h>
-#include <linux/netdevice.h>
-
-#include <asm/io.h>
-#include <asm/dcr.h>
-
-/*
- * These MAL "versions" probably aren't the real versions IBM uses for these 
- * MAL cores, I assigned them just to make #ifdefs in this file nicer and 
- * reflect the fact that 40x and 44x have slightly different MALs. --ebs
- */
-#if defined(CONFIG_405GP) || defined(CONFIG_405GPR) || defined(CONFIG_405EP) || \
-    defined(CONFIG_440EP) || defined(CONFIG_440GR) || defined(CONFIG_NP405H)
-#define MAL_VERSION		1
-#elif defined(CONFIG_440GP) || defined(CONFIG_440GX) || defined(CONFIG_440SP) || \
-      defined(CONFIG_440SPE)
-#define MAL_VERSION		2
-#else
-#error "Unknown SoC, please check chip manual and choose MAL 'version'"
-#endif
-
-/* MALx DCR registers */
-#define	MAL_CFG			0x00
-#define	  MAL_CFG_SR		0x80000000
-#define   MAL_CFG_PLBB		0x00004000
-#define   MAL_CFG_OPBBL		0x00000080
-#define   MAL_CFG_EOPIE		0x00000004
-#define   MAL_CFG_LEA		0x00000002
-#define   MAL_CFG_SD		0x00000001
-#if MAL_VERSION == 1
-#define   MAL_CFG_PLBP_MASK	0x00c00000
-#define   MAL_CFG_PLBP_10	0x00800000
-#define   MAL_CFG_GA		0x00200000
-#define   MAL_CFG_OA		0x00100000
-#define   MAL_CFG_PLBLE		0x00080000
-#define   MAL_CFG_PLBT_MASK	0x00078000
-#define   MAL_CFG_DEFAULT	(MAL_CFG_PLBP_10 | MAL_CFG_PLBT_MASK)
-#elif MAL_VERSION == 2
-#define   MAL_CFG_RPP_MASK	0x00c00000
-#define   MAL_CFG_RPP_10	0x00800000
-#define   MAL_CFG_RMBS_MASK	0x00300000
-#define   MAL_CFG_WPP_MASK	0x000c0000
-#define   MAL_CFG_WPP_10	0x00080000
-#define   MAL_CFG_WMBS_MASK	0x00030000
-#define   MAL_CFG_PLBLE		0x00008000
-#define   MAL_CFG_DEFAULT	(MAL_CFG_RMBS_MASK | MAL_CFG_WMBS_MASK | \
-				 MAL_CFG_RPP_10 | MAL_CFG_WPP_10)
-#else
-#error "Unknown MAL version"
-#endif
-
-#define MAL_ESR			0x01
-#define   MAL_ESR_EVB		0x80000000
-#define   MAL_ESR_CIDT		0x40000000
-#define   MAL_ESR_CID_MASK	0x3e000000
-#define   MAL_ESR_CID_SHIFT	25
-#define   MAL_ESR_DE		0x00100000
-#define   MAL_ESR_OTE		0x00040000
-#define   MAL_ESR_OSE		0x00020000
-#define   MAL_ESR_PEIN		0x00010000
-#define   MAL_ESR_DEI		0x00000010
-#define   MAL_ESR_OTEI		0x00000004
-#define   MAL_ESR_OSEI		0x00000002
-#define   MAL_ESR_PBEI		0x00000001
-#if MAL_VERSION == 1
-#define   MAL_ESR_ONE		0x00080000
-#define   MAL_ESR_ONEI		0x00000008
-#elif MAL_VERSION == 2
-#define   MAL_ESR_PTE		0x00800000
-#define   MAL_ESR_PRE		0x00400000
-#define   MAL_ESR_PWE		0x00200000
-#define   MAL_ESR_PTEI		0x00000080
-#define   MAL_ESR_PREI		0x00000040
-#define   MAL_ESR_PWEI		0x00000020
-#else
-#error "Unknown MAL version"
-#endif
-
-#define MAL_IER			0x02
-#define   MAL_IER_DE		0x00000010
-#define   MAL_IER_OTE		0x00000004
-#define   MAL_IER_OE		0x00000002
-#define   MAL_IER_PE		0x00000001
-#if MAL_VERSION == 1
-#define   MAL_IER_NWE		0x00000008
-#define   MAL_IER_SOC_EVENTS	MAL_IER_NWE
-#elif MAL_VERSION == 2
-#define   MAL_IER_PT		0x00000080
-#define   MAL_IER_PRE		0x00000040
-#define   MAL_IER_PWE		0x00000020
-#define   MAL_IER_SOC_EVENTS	(MAL_IER_PT | MAL_IER_PRE | MAL_IER_PWE)
-#else
-#error "Unknown MAL version"
-#endif
-#define   MAL_IER_EVENTS	(MAL_IER_SOC_EVENTS | MAL_IER_OTE | \
-				 MAL_IER_OTE | MAL_IER_OE | MAL_IER_PE)
-
-#define MAL_TXCASR		0x04
-#define MAL_TXCARR		0x05
-#define MAL_TXEOBISR		0x06
-#define MAL_TXDEIR		0x07
-#define MAL_RXCASR		0x10
-#define MAL_RXCARR		0x11
-#define MAL_RXEOBISR		0x12
-#define MAL_RXDEIR		0x13
-#define MAL_TXCTPR(n)		((n) + 0x20)
-#define MAL_RXCTPR(n)		((n) + 0x40)
-#define MAL_RCBS(n)		((n) + 0x60)
-
-/* In reality MAL can handle TX buffers up to 4095 bytes long, 
- * but this isn't a good round number :) 		 --ebs
- */
-#define MAL_MAX_TX_SIZE		4080
-#define MAL_MAX_RX_SIZE		4080
-
-static inline int mal_rx_size(int len)
-{
-	len = (len + 0xf) & ~0xf;
-	return len > MAL_MAX_RX_SIZE ? MAL_MAX_RX_SIZE : len;
-}
-
-static inline int mal_tx_chunks(int len)
-{
-	return (len + MAL_MAX_TX_SIZE - 1) / MAL_MAX_TX_SIZE;
-}
-
-#define MAL_CHAN_MASK(n)	(0x80000000 >> (n))
-
-/* MAL Buffer Descriptor structure */
-struct mal_descriptor {
-	u16 ctrl;		/* MAL / Commac status control bits */
-	u16 data_len;		/* Max length is 4K-1 (12 bits)     */
-	u32 data_ptr;		/* pointer to actual data buffer    */
-};
-
-/* the following defines are for the MadMAL status and control registers. */
-/* MADMAL transmit and receive status/control bits  */
-#define MAL_RX_CTRL_EMPTY	0x8000
-#define MAL_RX_CTRL_WRAP	0x4000
-#define MAL_RX_CTRL_CM		0x2000
-#define MAL_RX_CTRL_LAST	0x1000
-#define MAL_RX_CTRL_FIRST	0x0800
-#define MAL_RX_CTRL_INTR	0x0400
-#define MAL_RX_CTRL_SINGLE	(MAL_RX_CTRL_LAST | MAL_RX_CTRL_FIRST)
-#define MAL_IS_SINGLE_RX(ctrl)	(((ctrl) & MAL_RX_CTRL_SINGLE) == MAL_RX_CTRL_SINGLE)
-
-#define MAL_TX_CTRL_READY	0x8000
-#define MAL_TX_CTRL_WRAP	0x4000
-#define MAL_TX_CTRL_CM		0x2000
-#define MAL_TX_CTRL_LAST	0x1000
-#define MAL_TX_CTRL_INTR	0x0400
-
-struct mal_commac_ops {
-	void	(*poll_tx) (void *dev);
-	int	(*poll_rx) (void *dev, int budget);
-	int	(*peek_rx) (void *dev);
-	void	(*rxde) (void *dev);
-};
-
-struct mal_commac {
-	struct mal_commac_ops	*ops;
-	void			*dev;
-	struct list_head	poll_list;
-	int			rx_stopped;
-
-	u32			tx_chan_mask;
-	u32			rx_chan_mask;
-	struct list_head	list;
-};
-
-struct ibm_ocp_mal {
-	dcr_host_t		dcrhost;
-
-	struct list_head	poll_list;
-	struct napi_struct	napi;
-
-	struct list_head	list;
-	u32			tx_chan_mask;
-	u32			rx_chan_mask;
-
-	dma_addr_t		bd_dma;
-	struct mal_descriptor	*bd_virt;
-
-	struct ocp_def		*def;
-};
-
-static inline u32 get_mal_dcrn(struct ibm_ocp_mal *mal, int reg)
-{
-	return dcr_read(mal->dcrhost, reg);
-}
-
-static inline void set_mal_dcrn(struct ibm_ocp_mal *mal, int reg, u32 val)
-{
-	dcr_write(mal->dcrhost, reg, val);
-}
-
-/* Register MAL devices */
-int mal_init(void) __init;
-void mal_exit(void) __exit;
-
-int mal_register_commac(struct ibm_ocp_mal *mal,
-			struct mal_commac *commac) __init;
-void mal_unregister_commac(struct ibm_ocp_mal *mal, struct mal_commac *commac);
-int mal_set_rcbs(struct ibm_ocp_mal *mal, int channel, unsigned long size);
-
-/* Returns BD ring offset for a particular channel
-   (in 'struct mal_descriptor' elements)
-*/
-int mal_tx_bd_offset(struct ibm_ocp_mal *mal, int channel);
-int mal_rx_bd_offset(struct ibm_ocp_mal *mal, int channel);
-
-void mal_enable_tx_channel(struct ibm_ocp_mal *mal, int channel);
-void mal_disable_tx_channel(struct ibm_ocp_mal *mal, int channel);
-void mal_enable_rx_channel(struct ibm_ocp_mal *mal, int channel);
-void mal_disable_rx_channel(struct ibm_ocp_mal *mal, int channel);
-
-/* Add/remove EMAC to/from MAL polling list */
-void mal_poll_add(struct ibm_ocp_mal *mal, struct mal_commac *commac);
-void mal_poll_del(struct ibm_ocp_mal *mal, struct mal_commac *commac);
-
-/* Ethtool MAL registers */
-struct ibm_mal_regs {
-	u32 tx_count;
-	u32 rx_count;
-
-	u32 cfg;
-	u32 esr;
-	u32 ier;
-	u32 tx_casr;
-	u32 tx_carr;
-	u32 tx_eobisr;
-	u32 tx_deir;
-	u32 rx_casr;
-	u32 rx_carr;
-	u32 rx_eobisr;
-	u32 rx_deir;
-	u32 tx_ctpr[32];
-	u32 rx_ctpr[32];
-	u32 rcbs[32];
-};
-
-int mal_get_regs_len(struct ibm_ocp_mal *mal);
-void *mal_dump_regs(struct ibm_ocp_mal *mal, void *buf);
-
-#endif				/* __IBM_EMAC_MAL_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_phy.c b/drivers/net/ibm_emac/ibm_emac_phy.c
deleted file mode 100644
index e57862b..0000000
--- a/drivers/net/ibm_emac/ibm_emac_phy.c
+++ /dev/null
@@ -1,398 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_phy.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, PHY support.
- * Borrowed from sungem_phy.c, though I only kept the generic MII
- * driver for now.
- * 
- * This file should be shared with other drivers or eventually
- * merged as the "low level" part of miilib
- * 
- * (c) 2003, Benjamin Herrenscmidt (benh@kernel.crashing.org)
- * (c) 2004-2005, Eugene Surovegin <ebs@ebshome.net>
- *
- */
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/netdevice.h>
-#include <linux/mii.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-
-#include <asm/ocp.h>
-
-#include "ibm_emac_core.h"
-#include "ibm_emac_phy.h"
-
-static inline int phy_read(struct mii_phy *phy, int reg)
-{
-	return phy->mdio_read(phy->dev, phy->address, reg);
-}
-
-static inline void phy_write(struct mii_phy *phy, int reg, int val)
-{
-	phy->mdio_write(phy->dev, phy->address, reg, val);
-}
-
-/*
- * polls MII_BMCR until BMCR_RESET bit clears or operation times out.
- *
- * returns:
- *	>= 0 => success, value in BMCR returned to caller
- *	-EBUSY => failure, RESET bit never cleared
- *	otherwise => failure, lower level PHY read failed
- */
-static int mii_spin_reset_complete(struct mii_phy *phy)
-{
-	int val;
-	int limit = 10000;
-
-	while (limit--) {
-		val = phy_read(phy, MII_BMCR);
-		if (val >= 0 && !(val & BMCR_RESET))
-			return val;	/* success */
-		udelay(10);
-	}
-	if (val & BMCR_RESET)
-		val = -EBUSY;
-
-	if (net_ratelimit())
-		printk(KERN_ERR "emac%d: PHY reset timeout (%d)\n", 
-		       ((struct ocp_enet_private *)phy->dev->priv)->def->index,
-		       val);
-	return val;		    
-}
-
-int mii_reset_phy(struct mii_phy *phy)
-{
-	int val;
-
-	val = phy_read(phy, MII_BMCR);
-	val &= ~BMCR_ISOLATE;
-	val |= BMCR_RESET;
-	phy_write(phy, MII_BMCR, val);
-
-	udelay(300);
-
-	val = mii_spin_reset_complete(phy);
-	if (val >= 0 && (val & BMCR_ISOLATE))
-		phy_write(phy, MII_BMCR, val & ~BMCR_ISOLATE);
-
-	return val < 0;
-}
-
-static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
-{
-	int ctl, adv;
-
-	phy->autoneg = AUTONEG_ENABLE;
-	phy->speed = SPEED_10;
-	phy->duplex = DUPLEX_HALF;
-	phy->pause = phy->asym_pause = 0;
-	phy->advertising = advertise;
-
-	/* Setup standard advertise */
-	adv = phy_read(phy, MII_ADVERTISE);
-	if (adv < 0)
-		return adv;
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
-		 ADVERTISE_PAUSE_ASYM);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	if (advertise & ADVERTISED_Pause)
-		adv |= ADVERTISE_PAUSE_CAP;
-	if (advertise & ADVERTISED_Asym_Pause)
-		adv |= ADVERTISE_PAUSE_ASYM;
-	phy_write(phy, MII_ADVERTISE, adv);
-
-	if (phy->features &
-	    (SUPPORTED_1000baseT_Full | SUPPORTED_1000baseT_Half)) {
-		adv = phy_read(phy, MII_CTRL1000);
-		if (adv < 0)
-			return adv;
-		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
-		if (advertise & ADVERTISED_1000baseT_Full)
-			adv |= ADVERTISE_1000FULL;
-		if (advertise & ADVERTISED_1000baseT_Half)
-			adv |= ADVERTISE_1000HALF;
-		phy_write(phy, MII_CTRL1000, adv);
-	}
-
-	/* Start/Restart aneg */
-	/* on some PHYs (e.g. National DP83843) a write to MII_ADVERTISE
-	 * causes BMCR_RESET to be set on the next read of MII_BMCR, which
-	 * if not checked for causes the PHY to be reset below */
-	ctl = mii_spin_reset_complete(phy);
-	if (ctl < 0)
-		return ctl;
-
-	ctl |= BMCR_ANENABLE | BMCR_ANRESTART;
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int genmii_setup_forced(struct mii_phy *phy, int speed, int fd)
-{
-	int ctl;
-
-	phy->autoneg = AUTONEG_DISABLE;
-	phy->speed = speed;
-	phy->duplex = fd;
-	phy->pause = phy->asym_pause = 0;
-
-	/* First reset the PHY */
-	mii_reset_phy(phy);
-
-	ctl = phy_read(phy, MII_BMCR);
-	if (ctl < 0)
-		return ctl;
-	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE | BMCR_SPEED1000);
-
-	/* Select speed & duplex */
-	switch (speed) {
-	case SPEED_10:
-		break;
-	case SPEED_100:
-		ctl |= BMCR_SPEED100;
-		break;
-	case SPEED_1000:
-		ctl |= BMCR_SPEED1000;
-		break;
-	default:
-		return -EINVAL;
-	}
-	if (fd == DUPLEX_FULL)
-		ctl |= BMCR_FULLDPLX;
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int genmii_poll_link(struct mii_phy *phy)
-{
-	int status;
-
-	/* Clear latched value with dummy read */
-	phy_read(phy, MII_BMSR);
-	status = phy_read(phy, MII_BMSR);
-	if (status < 0 || (status & BMSR_LSTATUS) == 0)
-		return 0;
-	if (phy->autoneg == AUTONEG_ENABLE && !(status & BMSR_ANEGCOMPLETE))
-		return 0;
-	return 1;
-}
-
-static int genmii_read_link(struct mii_phy *phy)
-{
-	if (phy->autoneg == AUTONEG_ENABLE) {
-		int glpa = 0;
-		int lpa = phy_read(phy, MII_LPA) & phy_read(phy, MII_ADVERTISE);
-		if (lpa < 0)
-			return lpa;
-
-		if (phy->features &
-		    (SUPPORTED_1000baseT_Full | SUPPORTED_1000baseT_Half)) {
-			int adv = phy_read(phy, MII_CTRL1000);
-			glpa = phy_read(phy, MII_STAT1000);
-
-			if (glpa < 0 || adv < 0)
-				return adv;
-
-			glpa &= adv << 2;
-		}
-
-		phy->speed = SPEED_10;
-		phy->duplex = DUPLEX_HALF;
-		phy->pause = phy->asym_pause = 0;
-
-		if (glpa & (LPA_1000FULL | LPA_1000HALF)) {
-			phy->speed = SPEED_1000;
-			if (glpa & LPA_1000FULL)
-				phy->duplex = DUPLEX_FULL;
-		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
-			phy->speed = SPEED_100;
-			if (lpa & LPA_100FULL)
-				phy->duplex = DUPLEX_FULL;
-		} else if (lpa & LPA_10FULL)
-			phy->duplex = DUPLEX_FULL;
-
-		if (phy->duplex == DUPLEX_FULL) {
-			phy->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
-			phy->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
-		}
-	} else {
-		int bmcr = phy_read(phy, MII_BMCR);
-		if (bmcr < 0)
-			return bmcr;
-
-		if (bmcr & BMCR_FULLDPLX)
-			phy->duplex = DUPLEX_FULL;
-		else
-			phy->duplex = DUPLEX_HALF;
-		if (bmcr & BMCR_SPEED1000)
-			phy->speed = SPEED_1000;
-		else if (bmcr & BMCR_SPEED100)
-			phy->speed = SPEED_100;
-		else
-			phy->speed = SPEED_10;
-
-		phy->pause = phy->asym_pause = 0;
-	}
-	return 0;
-}
-
-/* Generic implementation for most 10/100/1000 PHYs */
-static struct mii_phy_ops generic_phy_ops = {
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link
-};
-
-static struct mii_phy_def genmii_phy_def = {
-	.phy_id		= 0x00000000,
-	.phy_id_mask	= 0x00000000,
-	.name		= "Generic MII",
-	.ops		= &generic_phy_ops
-};
-
-/* CIS8201 */
-#define MII_CIS8201_10BTCSR	0x16
-#define  TENBTCSR_ECHO_DISABLE	0x2000
-#define MII_CIS8201_EPCR	0x17
-#define  EPCR_MODE_MASK		0x3000
-#define  EPCR_GMII_MODE		0x0000
-#define  EPCR_RGMII_MODE	0x1000
-#define  EPCR_TBI_MODE		0x2000
-#define  EPCR_RTBI_MODE		0x3000
-#define MII_CIS8201_ACSR	0x1c
-#define  ACSR_PIN_PRIO_SELECT	0x0004
-
-static int cis8201_init(struct mii_phy *phy)
-{
-	int epcr;
-
-	epcr = phy_read(phy, MII_CIS8201_EPCR);
-	if (epcr < 0)
-		return epcr;
-
-	epcr &= ~EPCR_MODE_MASK;
-
-	switch (phy->mode) {
-	case PHY_MODE_TBI:
-		epcr |= EPCR_TBI_MODE;
-		break;
-	case PHY_MODE_RTBI:
-		epcr |= EPCR_RTBI_MODE;
-		break;
-	case PHY_MODE_GMII:
-		epcr |= EPCR_GMII_MODE;
-		break;
-	case PHY_MODE_RGMII:
-	default:
-		epcr |= EPCR_RGMII_MODE;
-	}
-
-	phy_write(phy, MII_CIS8201_EPCR, epcr);
-	
-	/* MII regs override strap pins */
-	phy_write(phy, MII_CIS8201_ACSR, 
-		  phy_read(phy, MII_CIS8201_ACSR) | ACSR_PIN_PRIO_SELECT);
-
-	/* Disable TX_EN -> CRS echo mode, otherwise 10/HDX doesn't work */
-	phy_write(phy, MII_CIS8201_10BTCSR,
-		  phy_read(phy, MII_CIS8201_10BTCSR) | TENBTCSR_ECHO_DISABLE);
-
-	return 0;
-}
-
-static struct mii_phy_ops cis8201_phy_ops = {
-	.init		= cis8201_init,
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link
-};
-
-static struct mii_phy_def cis8201_phy_def = {
-	.phy_id		= 0x000fc410,
-	.phy_id_mask	= 0x000ffff0,
-	.name		= "CIS8201 Gigabit Ethernet",
-	.ops		= &cis8201_phy_ops
-};
-
-static struct mii_phy_def *mii_phy_table[] = {
-	&cis8201_phy_def,
-	&genmii_phy_def,
-	NULL
-};
-
-int mii_phy_probe(struct mii_phy *phy, int address)
-{
-	struct mii_phy_def *def;
-	int i;
-	int id;
-
-	phy->autoneg = AUTONEG_DISABLE;
-	phy->advertising = 0;
-	phy->address = address;
-	phy->speed = SPEED_10;
-	phy->duplex = DUPLEX_HALF;
-	phy->pause = phy->asym_pause = 0;
-
-	/* Take PHY out of isolate mode and reset it. */
-	if (mii_reset_phy(phy))
-		return -ENODEV;
-
-	/* Read ID and find matching entry */
-	id = (phy_read(phy, MII_PHYSID1) << 16) | phy_read(phy, MII_PHYSID2);
-	if (id < 0)
-		return -ENODEV;
-	for (i = 0; (def = mii_phy_table[i]) != NULL; i++)
-		if ((id & def->phy_id_mask) == def->phy_id)
-			break;
-	/* Should never be NULL (we have a generic entry), but... */
-	if (!def)
-		return -ENODEV;
-
-	phy->def = def;
-
-	/* Determine PHY features if needed */
-	phy->features = def->features;
-	if (!phy->features) {
-		u16 bmsr = phy_read(phy, MII_BMSR);
-		if (bmsr & BMSR_ANEGCAPABLE)
-			phy->features |= SUPPORTED_Autoneg;
-		if (bmsr & BMSR_10HALF)
-			phy->features |= SUPPORTED_10baseT_Half;
-		if (bmsr & BMSR_10FULL)
-			phy->features |= SUPPORTED_10baseT_Full;
-		if (bmsr & BMSR_100HALF)
-			phy->features |= SUPPORTED_100baseT_Half;
-		if (bmsr & BMSR_100FULL)
-			phy->features |= SUPPORTED_100baseT_Full;
-		if (bmsr & BMSR_ESTATEN) {
-			u16 esr = phy_read(phy, MII_ESTATUS);
-			if (esr & ESTATUS_1000_TFULL)
-				phy->features |= SUPPORTED_1000baseT_Full;
-			if (esr & ESTATUS_1000_THALF)
-				phy->features |= SUPPORTED_1000baseT_Half;
-		}
-		phy->features |= SUPPORTED_MII;
-	}
-
-	/* Setup default advertising */
-	phy->advertising = phy->features;
-
-	return 0;
-}
-
-MODULE_LICENSE("GPL");
diff --git a/drivers/net/ibm_emac/ibm_emac_phy.h b/drivers/net/ibm_emac/ibm_emac_phy.h
deleted file mode 100644
index a70e0fe..0000000
--- a/drivers/net/ibm_emac/ibm_emac_phy.h
+++ /dev/null
@@ -1,80 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_phy.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, PHY support
- *
- * Benjamin Herrenschmidt <benh@kernel.crashing.org>
- * February 2003
- *
- * Minor additions by Eugene Surovegin <ebs@ebshome.net>, 2004
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- * This file basically duplicates sungem_phy.{c,h} with different PHYs
- * supported. I'm looking into merging that in a single mii layer more
- * flexible than mii.c 
- */
-
-#ifndef _IBM_OCP_PHY_H_
-#define _IBM_OCP_PHY_H_
-
-struct mii_phy;
-
-/* Operations supported by any kind of PHY */
-struct mii_phy_ops {
-	int (*init) (struct mii_phy * phy);
-	int (*suspend) (struct mii_phy * phy, int wol_options);
-	int (*setup_aneg) (struct mii_phy * phy, u32 advertise);
-	int (*setup_forced) (struct mii_phy * phy, int speed, int fd);
-	int (*poll_link) (struct mii_phy * phy);
-	int (*read_link) (struct mii_phy * phy);
-};
-
-/* Structure used to statically define an mii/gii based PHY */
-struct mii_phy_def {
-	u32 phy_id;		/* Concatenated ID1 << 16 | ID2 */
-	u32 phy_id_mask;	/* Significant bits */
-	u32 features;		/* Ethtool SUPPORTED_* defines or 
-				   0 for autodetect */
-	int magic_aneg;		/* Autoneg does all speed test for us */
-	const char *name;
-	const struct mii_phy_ops *ops;
-};
-
-/* An instance of a PHY, partially borrowed from mii_if_info */
-struct mii_phy {
-	struct mii_phy_def *def;
-	u32 advertising;	/* Ethtool ADVERTISED_* defines */
-	u32 features;		/* Copied from mii_phy_def.features 
-				   or determined automaticaly */
-	int address;		/* PHY address */
-	int mode;		/* PHY mode */
-
-	/* 1: autoneg enabled, 0: disabled */
-	int autoneg;
-
-	/* forced speed & duplex (no autoneg)
-	 * partner speed & duplex & pause (autoneg)
-	 */
-	int speed;
-	int duplex;
-	int pause;
-	int asym_pause;
-
-	/* Provided by host chip */
-	struct net_device *dev;
-	int (*mdio_read) (struct net_device * dev, int addr, int reg);
-	void (*mdio_write) (struct net_device * dev, int addr, int reg,
-			    int val);
-};
-
-/* Pass in a struct mii_phy with dev, mdio_read and mdio_write
- * filled, the remaining fields will be filled on return
- */
-int mii_phy_probe(struct mii_phy *phy, int address);
-int mii_reset_phy(struct mii_phy *phy);
-
-#endif				/* _IBM_OCP_PHY_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_rgmii.c b/drivers/net/ibm_emac/ibm_emac_rgmii.c
deleted file mode 100644
index 9dbb5e5..0000000
--- a/drivers/net/ibm_emac/ibm_emac_rgmii.c
+++ /dev/null
@@ -1,200 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_rgmii.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- * 	Matt Porter <mporter@kernel.crashing.org>
- * 	Copyright 2004 MontaVista Software, Inc.
- * 
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/kernel.h>
-#include <linux/ethtool.h>
-#include <asm/io.h>
-
-#include "ibm_emac_core.h"
-#include "ibm_emac_debug.h"
-
-/* RGMIIx_FER */
-#define RGMII_FER_MASK(idx)	(0x7 << ((idx) * 4))
-#define RGMII_FER_RTBI(idx)	(0x4 << ((idx) * 4))
-#define RGMII_FER_RGMII(idx)	(0x5 << ((idx) * 4))
-#define RGMII_FER_TBI(idx)	(0x6 << ((idx) * 4))
-#define RGMII_FER_GMII(idx)	(0x7 << ((idx) * 4))
-
-/* RGMIIx_SSR */
-#define RGMII_SSR_MASK(idx)	(0x7 << ((idx) * 8))
-#define RGMII_SSR_100(idx)	(0x2 << ((idx) * 8))
-#define RGMII_SSR_1000(idx)	(0x4 << ((idx) * 8))
-
-/* RGMII bridge supports only GMII/TBI and RGMII/RTBI PHYs */
-static inline int rgmii_valid_mode(int phy_mode)
-{
-	return  phy_mode == PHY_MODE_GMII ||
-		phy_mode == PHY_MODE_RGMII ||
-		phy_mode == PHY_MODE_TBI ||
-		phy_mode == PHY_MODE_RTBI;
-}
-
-static inline const char *rgmii_mode_name(int mode)
-{
-	switch (mode) {
-	case PHY_MODE_RGMII:
-		return "RGMII";
-	case PHY_MODE_TBI:
-		return "TBI";
-	case PHY_MODE_GMII:
-		return "GMII";
-	case PHY_MODE_RTBI:
-		return "RTBI";
-	default:
-		BUG();
-	}
-}
-
-static inline u32 rgmii_mode_mask(int mode, int input)
-{
-	switch (mode) {
-	case PHY_MODE_RGMII:
-		return RGMII_FER_RGMII(input);
-	case PHY_MODE_TBI:
-		return RGMII_FER_TBI(input);
-	case PHY_MODE_GMII:
-		return RGMII_FER_GMII(input);
-	case PHY_MODE_RTBI:
-		return RGMII_FER_RTBI(input);
-	default:
-		BUG();
-	}
-}
-
-static int __init rgmii_init(struct ocp_device *ocpdev, int input, int mode)
-{
-	struct ibm_ocp_rgmii *dev = ocp_get_drvdata(ocpdev);
-	struct rgmii_regs *p;
-
-	RGMII_DBG("%d: init(%d, %d)" NL, ocpdev->def->index, input, mode);
-
-	if (!dev) {
-		dev = kzalloc(sizeof(struct ibm_ocp_rgmii), GFP_KERNEL);
-		if (!dev) {
-			printk(KERN_ERR
-			       "rgmii%d: couldn't allocate device structure!\n",
-			       ocpdev->def->index);
-			return -ENOMEM;
-		}
-
-		p = (struct rgmii_regs *)ioremap(ocpdev->def->paddr,
-						 sizeof(struct rgmii_regs));
-		if (!p) {
-			printk(KERN_ERR
-			       "rgmii%d: could not ioremap device registers!\n",
-			       ocpdev->def->index);
-			kfree(dev);
-			return -ENOMEM;
-		}
-
-		dev->base = p;
-		ocp_set_drvdata(ocpdev, dev);
-
-		/* Disable all inputs by default */
-		out_be32(&p->fer, 0);
-	} else
-		p = dev->base;
-
-	/* Enable this input */
-	out_be32(&p->fer, in_be32(&p->fer) | rgmii_mode_mask(mode, input));
-
-	printk(KERN_NOTICE "rgmii%d: input %d in %s mode\n",
-	       ocpdev->def->index, input, rgmii_mode_name(mode));
-
-	++dev->users;
-	return 0;
-}
-
-int __init rgmii_attach(void *emac)
-{
-	struct ocp_enet_private *dev = emac;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-	/* Check if we need to attach to a RGMII */
-	if (emacdata->rgmii_idx >= 0 && rgmii_valid_mode(emacdata->phy_mode)) {
-		dev->rgmii_input = emacdata->rgmii_mux;
-		dev->rgmii_dev =
-		    ocp_find_device(OCP_VENDOR_IBM, OCP_FUNC_RGMII,
-				    emacdata->rgmii_idx);
-		if (!dev->rgmii_dev) {
-			printk(KERN_ERR "emac%d: unknown rgmii%d!\n",
-			       dev->def->index, emacdata->rgmii_idx);
-			return -ENODEV;
-		}
-		if (rgmii_init
-		    (dev->rgmii_dev, dev->rgmii_input, emacdata->phy_mode)) {
-			printk(KERN_ERR
-			       "emac%d: rgmii%d initialization failed!\n",
-			       dev->def->index, emacdata->rgmii_idx);
-			return -ENODEV;
-		}
-	}
-	return 0;
-}
-
-void rgmii_set_speed(struct ocp_device *ocpdev, int input, int speed)
-{
-	struct ibm_ocp_rgmii *dev = ocp_get_drvdata(ocpdev);
-	u32 ssr = in_be32(&dev->base->ssr) & ~RGMII_SSR_MASK(input);
-
-	RGMII_DBG("%d: speed(%d, %d)" NL, ocpdev->def->index, input, speed);
-
-	if (speed == SPEED_1000)
-		ssr |= RGMII_SSR_1000(input);
-	else if (speed == SPEED_100)
-		ssr |= RGMII_SSR_100(input);
-
-	out_be32(&dev->base->ssr, ssr);
-}
-
-void __rgmii_fini(struct ocp_device *ocpdev, int input)
-{
-	struct ibm_ocp_rgmii *dev = ocp_get_drvdata(ocpdev);
-	BUG_ON(!dev || dev->users == 0);
-
-	RGMII_DBG("%d: fini(%d)" NL, ocpdev->def->index, input);
-
-	/* Disable this input */
-	out_be32(&dev->base->fer,
-		 in_be32(&dev->base->fer) & ~RGMII_FER_MASK(input));
-
-	if (!--dev->users) {
-		/* Free everything if this is the last user */
-		ocp_set_drvdata(ocpdev, NULL);
-		iounmap((void *)dev->base);
-		kfree(dev);
-	}
-}
-
-int __rgmii_get_regs_len(struct ocp_device *ocpdev)
-{
-	return sizeof(struct emac_ethtool_regs_subhdr) +
-	    sizeof(struct rgmii_regs);
-}
-
-void *rgmii_dump_regs(struct ocp_device *ocpdev, void *buf)
-{
-	struct ibm_ocp_rgmii *dev = ocp_get_drvdata(ocpdev);
-	struct emac_ethtool_regs_subhdr *hdr = buf;
-	struct rgmii_regs *regs = (struct rgmii_regs *)(hdr + 1);
-
-	hdr->version = 0;
-	hdr->index = ocpdev->def->index;
-	memcpy_fromio(regs, dev->base, sizeof(struct rgmii_regs));
-	return regs + 1;
-}
diff --git a/drivers/net/ibm_emac/ibm_emac_rgmii.h b/drivers/net/ibm_emac/ibm_emac_rgmii.h
deleted file mode 100644
index 971e458..0000000
--- a/drivers/net/ibm_emac/ibm_emac_rgmii.h
+++ /dev/null
@@ -1,64 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_rgmii.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
- *
- * Based on ocp_zmii.h/ibm_emac_zmii.h
- * Armin Kuster akuster@mvista.com
- *
- * Copyright 2004 MontaVista Software, Inc.
- * Matt Porter <mporter@kernel.crashing.org>
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- */
-
-#ifndef _IBM_EMAC_RGMII_H_
-#define _IBM_EMAC_RGMII_H_
-
-
-/* RGMII bridge */
-struct rgmii_regs {
-	u32 fer;		/* Function enable register */
-	u32 ssr;		/* Speed select register */
-};
-
-/* RGMII device */
-struct ibm_ocp_rgmii {
-	struct rgmii_regs __iomem *base;
-	int users;		/* number of EMACs using this RGMII bridge */
-};
-
-#ifdef CONFIG_IBM_EMAC_RGMII
-int rgmii_attach(void *emac) __init;
-
-void __rgmii_fini(struct ocp_device *ocpdev, int input);
-static inline void rgmii_fini(struct ocp_device *ocpdev, int input)
-{
-	if (ocpdev)
-		__rgmii_fini(ocpdev, input);
-}
-
-void rgmii_set_speed(struct ocp_device *ocpdev, int input, int speed);
-
-int __rgmii_get_regs_len(struct ocp_device *ocpdev);
-static inline int rgmii_get_regs_len(struct ocp_device *ocpdev)
-{
-	return ocpdev ? __rgmii_get_regs_len(ocpdev) : 0;
-}
-
-void *rgmii_dump_regs(struct ocp_device *ocpdev, void *buf);
-#else
-# define rgmii_attach(x)	0
-# define rgmii_fini(x,y)	((void)0)
-# define rgmii_set_speed(x,y,z)	((void)0)
-# define rgmii_get_regs_len(x)	0
-# define rgmii_dump_regs(x,buf)	(buf)
-#endif				/* !CONFIG_IBM_EMAC_RGMII */
-
-#endif				/* _IBM_EMAC_RGMII_H_ */
diff --git a/drivers/net/ibm_emac/ibm_emac_tah.c b/drivers/net/ibm_emac/ibm_emac_tah.c
deleted file mode 100644
index 3c2d5ba..0000000
--- a/drivers/net/ibm_emac/ibm_emac_tah.c
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_tah.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
- *
- * Copyright 2004 MontaVista Software, Inc.
- * Matt Porter <mporter@kernel.crashing.org>
- *
- * Copyright (c) 2005 Eugene Surovegin <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- */
-#include <asm/io.h>
-
-#include "ibm_emac_core.h"
-
-static int __init tah_init(struct ocp_device *ocpdev)
-{
-	struct tah_regs *p;
-
-	if (ocp_get_drvdata(ocpdev)) {
-		printk(KERN_ERR "tah%d: already in use!\n", ocpdev->def->index);
-		return -EBUSY;
-	}
-
-	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
-	p = (struct tah_regs *)ioremap(ocpdev->def->paddr, sizeof(*p));
-	if (!p) {
-		printk(KERN_ERR "tah%d: could not ioremap device registers!\n",
-		       ocpdev->def->index);
-		return -ENOMEM;
-	}
-	ocp_set_drvdata(ocpdev, p);
-	__tah_reset(ocpdev);
-
-	return 0;
-}
-
-int __init tah_attach(void *emac)
-{
-	struct ocp_enet_private *dev = emac;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-	/* Check if we need to attach to a TAH */
-	if (emacdata->tah_idx >= 0) {
-		dev->tah_dev = ocp_find_device(OCP_ANY_ID, OCP_FUNC_TAH,
-					       emacdata->tah_idx);
-		if (!dev->tah_dev) {
-			printk(KERN_ERR "emac%d: unknown tah%d!\n",
-			       dev->def->index, emacdata->tah_idx);
-			return -ENODEV;
-		}
-		if (tah_init(dev->tah_dev)) {
-			printk(KERN_ERR
-			       "emac%d: tah%d initialization failed!\n",
-			       dev->def->index, emacdata->tah_idx);
-			return -ENODEV;
-		}
-	}
-	return 0;
-}
-
-void __tah_fini(struct ocp_device *ocpdev)
-{
-	struct tah_regs *p = ocp_get_drvdata(ocpdev);
-	BUG_ON(!p);
-	ocp_set_drvdata(ocpdev, NULL);
-	iounmap((void *)p);
-}
-
-void __tah_reset(struct ocp_device *ocpdev)
-{
-	struct tah_regs *p = ocp_get_drvdata(ocpdev);
-	int n;
-
-	/* Reset TAH */
-	out_be32(&p->mr, TAH_MR_SR);
-	n = 100;
-	while ((in_be32(&p->mr) & TAH_MR_SR) && n)
-		--n;
-
-	if (unlikely(!n))
-		printk(KERN_ERR "tah%d: reset timeout\n", ocpdev->def->index);
-
-	/* 10KB TAH TX FIFO accomodates the max MTU of 9000 */
-	out_be32(&p->mr,
-		 TAH_MR_CVR | TAH_MR_ST_768 | TAH_MR_TFS_10KB | TAH_MR_DTFP |
-		 TAH_MR_DIG);
-}
-
-int __tah_get_regs_len(struct ocp_device *ocpdev)
-{
-	return sizeof(struct emac_ethtool_regs_subhdr) +
-	    sizeof(struct tah_regs);
-}
-
-void *tah_dump_regs(struct ocp_device *ocpdev, void *buf)
-{
-	struct tah_regs *dev = ocp_get_drvdata(ocpdev);
-	struct emac_ethtool_regs_subhdr *hdr = buf;
-	struct tah_regs *regs = (struct tah_regs *)(hdr + 1);
-
-	hdr->version = 0;
-	hdr->index = ocpdev->def->index;
-	memcpy_fromio(regs, dev, sizeof(struct tah_regs));
-	return regs + 1;
-}
diff --git a/drivers/net/ibm_emac/ibm_emac_tah.h b/drivers/net/ibm_emac/ibm_emac_tah.h
deleted file mode 100644
index ccf6491..0000000
--- a/drivers/net/ibm_emac/ibm_emac_tah.h
+++ /dev/null
@@ -1,87 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_tah.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
- *
- * Copyright 2004 MontaVista Software, Inc.
- * Matt Porter <mporter@kernel.crashing.org>
- *
- * Copyright (c) 2005 Eugene Surovegin <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- */
-
-#ifndef _IBM_EMAC_TAH_H
-#define _IBM_EMAC_TAH_H
-
-#include <linux/init.h>
-#include <asm/ocp.h>
-
-/* TAH */
-struct tah_regs {
-	u32 revid;
-	u32 pad[3];
-	u32 mr;
-	u32 ssr0;
-	u32 ssr1;
-	u32 ssr2;
-	u32 ssr3;
-	u32 ssr4;
-	u32 ssr5;
-	u32 tsr;
-};
-
-/* TAH engine */
-#define TAH_MR_CVR		0x80000000
-#define TAH_MR_SR		0x40000000
-#define TAH_MR_ST_256		0x01000000
-#define TAH_MR_ST_512		0x02000000
-#define TAH_MR_ST_768		0x03000000
-#define TAH_MR_ST_1024		0x04000000
-#define TAH_MR_ST_1280		0x05000000
-#define TAH_MR_ST_1536		0x06000000
-#define TAH_MR_TFS_16KB		0x00000000
-#define TAH_MR_TFS_2KB		0x00200000
-#define TAH_MR_TFS_4KB		0x00400000
-#define TAH_MR_TFS_6KB		0x00600000
-#define TAH_MR_TFS_8KB		0x00800000
-#define TAH_MR_TFS_10KB		0x00a00000
-#define TAH_MR_DTFP		0x00100000
-#define TAH_MR_DIG		0x00080000
-
-#ifdef CONFIG_IBM_EMAC_TAH
-int tah_attach(void *emac) __init;
-
-void __tah_fini(struct ocp_device *ocpdev);
-static inline void tah_fini(struct ocp_device *ocpdev)
-{
-	if (ocpdev)
-		__tah_fini(ocpdev);
-}
-
-void __tah_reset(struct ocp_device *ocpdev);
-static inline void tah_reset(struct ocp_device *ocpdev)
-{
-	if (ocpdev)
-		__tah_reset(ocpdev);
-}
-
-int __tah_get_regs_len(struct ocp_device *ocpdev);
-static inline int tah_get_regs_len(struct ocp_device *ocpdev)
-{
-	return ocpdev ? __tah_get_regs_len(ocpdev) : 0;
-}
-
-void *tah_dump_regs(struct ocp_device *ocpdev, void *buf);
-#else
-# define tah_attach(x)		0
-# define tah_fini(x)		((void)0)
-# define tah_reset(x)		((void)0)
-# define tah_get_regs_len(x)	0
-# define tah_dump_regs(x,buf)	(buf)
-#endif				/* !CONFIG_IBM_EMAC_TAH */
-
-#endif				/* _IBM_EMAC_TAH_H */
diff --git a/drivers/net/ibm_emac/ibm_emac_zmii.c b/drivers/net/ibm_emac/ibm_emac_zmii.c
deleted file mode 100644
index 2c0fdb0..0000000
--- a/drivers/net/ibm_emac/ibm_emac_zmii.c
+++ /dev/null
@@ -1,253 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_zmii.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Armin Kuster <akuster@mvista.com>
- * 	Copyright 2001 MontaVista Softare Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/kernel.h>
-#include <linux/ethtool.h>
-#include <asm/io.h>
-
-#include "ibm_emac_core.h"
-#include "ibm_emac_debug.h"
-
-/* ZMIIx_FER */
-#define ZMII_FER_MDI(idx)	(0x80000000 >> ((idx) * 4))
-#define ZMII_FER_MDI_ALL	(ZMII_FER_MDI(0) | ZMII_FER_MDI(1) | \
-				 ZMII_FER_MDI(2) | ZMII_FER_MDI(3))
-
-#define ZMII_FER_SMII(idx)	(0x40000000 >> ((idx) * 4))
-#define ZMII_FER_RMII(idx)	(0x20000000 >> ((idx) * 4))
-#define ZMII_FER_MII(idx)	(0x10000000 >> ((idx) * 4))
-
-/* ZMIIx_SSR */
-#define ZMII_SSR_SCI(idx)	(0x40000000 >> ((idx) * 4))
-#define ZMII_SSR_FSS(idx)	(0x20000000 >> ((idx) * 4))
-#define ZMII_SSR_SP(idx)	(0x10000000 >> ((idx) * 4))
-
-/* ZMII only supports MII, RMII and SMII 
- * we also support autodetection for backward compatibility
- */
-static inline int zmii_valid_mode(int mode)
-{
-	return  mode == PHY_MODE_MII ||
-		mode == PHY_MODE_RMII ||
-		mode == PHY_MODE_SMII ||
-		mode == PHY_MODE_NA;
-}
-
-static inline const char *zmii_mode_name(int mode)
-{
-	switch (mode) {
-	case PHY_MODE_MII:
-		return "MII";
-	case PHY_MODE_RMII:
-		return "RMII";
-	case PHY_MODE_SMII:
-		return "SMII";
-	default:
-		BUG();
-	}
-}
-
-static inline u32 zmii_mode_mask(int mode, int input)
-{
-	switch (mode) {
-	case PHY_MODE_MII:
-		return ZMII_FER_MII(input);
-	case PHY_MODE_RMII:
-		return ZMII_FER_RMII(input);
-	case PHY_MODE_SMII:
-		return ZMII_FER_SMII(input);
-	default:
-		return 0;
-	}
-}
-
-static int __init zmii_init(struct ocp_device *ocpdev, int input, int *mode)
-{
-	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
-	struct zmii_regs __iomem *p;
-
-	ZMII_DBG("%d: init(%d, %d)" NL, ocpdev->def->index, input, *mode);
-
-	if (!dev) {
-		dev = kzalloc(sizeof(struct ibm_ocp_zmii), GFP_KERNEL);
-		if (!dev) {
-			printk(KERN_ERR
-			       "zmii%d: couldn't allocate device structure!\n",
-			       ocpdev->def->index);
-			return -ENOMEM;
-		}
-		dev->mode = PHY_MODE_NA;
-
-		p = ioremap(ocpdev->def->paddr, sizeof(struct zmii_regs));
-		if (!p) {
-			printk(KERN_ERR
-			       "zmii%d: could not ioremap device registers!\n",
-			       ocpdev->def->index);
-			kfree(dev);
-			return -ENOMEM;
-		}
-		dev->base = p;
-		ocp_set_drvdata(ocpdev, dev);
-		
-		/* We may need FER value for autodetection later */
-		dev->fer_save = in_be32(&p->fer);
-
-		/* Disable all inputs by default */
-		out_be32(&p->fer, 0);
-	} else
-		p = dev->base;
-
-	if (!zmii_valid_mode(*mode)) {
-		/* Probably an EMAC connected to RGMII, 
-		 * but it still may need ZMII for MDIO 
-		 */
-		goto out;
-	}
-
-	/* Autodetect ZMII mode if not specified.
-	 * This is only for backward compatibility with the old driver.
-	 * Please, always specify PHY mode in your board port to avoid
-	 * any surprises.
-	 */
-	if (dev->mode == PHY_MODE_NA) {
-		if (*mode == PHY_MODE_NA) {
-			u32 r = dev->fer_save;
-
-			ZMII_DBG("%d: autodetecting mode, FER = 0x%08x" NL,
-				 ocpdev->def->index, r);
-			
-			if (r & (ZMII_FER_MII(0) | ZMII_FER_MII(1)))
-				dev->mode = PHY_MODE_MII;
-			else if (r & (ZMII_FER_RMII(0) | ZMII_FER_RMII(1)))
-				dev->mode = PHY_MODE_RMII;
-			else
-				dev->mode = PHY_MODE_SMII;
-		} else
-			dev->mode = *mode;
-
-		printk(KERN_NOTICE "zmii%d: bridge in %s mode\n",
-		       ocpdev->def->index, zmii_mode_name(dev->mode));
-	} else {
-		/* All inputs must use the same mode */
-		if (*mode != PHY_MODE_NA && *mode != dev->mode) {
-			printk(KERN_ERR
-			       "zmii%d: invalid mode %d specified for input %d\n",
-			       ocpdev->def->index, *mode, input);
-			return -EINVAL;
-		}
-	}
-
-	/* Report back correct PHY mode, 
-	 * it may be used during PHY initialization.
-	 */
-	*mode = dev->mode;
-
-	/* Enable this input */
-	out_be32(&p->fer, in_be32(&p->fer) | zmii_mode_mask(dev->mode, input));
-      out:
-	++dev->users;
-	return 0;
-}
-
-int __init zmii_attach(void *emac)
-{
-	struct ocp_enet_private *dev = emac;
-	struct ocp_func_emac_data *emacdata = dev->def->additions;
-
-	if (emacdata->zmii_idx >= 0) {
-		dev->zmii_input = emacdata->zmii_mux;
-		dev->zmii_dev =
-		    ocp_find_device(OCP_VENDOR_IBM, OCP_FUNC_ZMII,
-				    emacdata->zmii_idx);
-		if (!dev->zmii_dev) {
-			printk(KERN_ERR "emac%d: unknown zmii%d!\n",
-			       dev->def->index, emacdata->zmii_idx);
-			return -ENODEV;
-		}
-		if (zmii_init
-		    (dev->zmii_dev, dev->zmii_input, &emacdata->phy_mode)) {
-			printk(KERN_ERR
-			       "emac%d: zmii%d initialization failed!\n",
-			       dev->def->index, emacdata->zmii_idx);
-			return -ENODEV;
-		}
-	}
-	return 0;
-}
-
-void __zmii_enable_mdio(struct ocp_device *ocpdev, int input)
-{
-	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
-	u32 fer = in_be32(&dev->base->fer) & ~ZMII_FER_MDI_ALL;
-
-	ZMII_DBG2("%d: mdio(%d)" NL, ocpdev->def->index, input);
-
-	out_be32(&dev->base->fer, fer | ZMII_FER_MDI(input));
-}
-
-void __zmii_set_speed(struct ocp_device *ocpdev, int input, int speed)
-{
-	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
-	u32 ssr = in_be32(&dev->base->ssr);
-
-	ZMII_DBG("%d: speed(%d, %d)" NL, ocpdev->def->index, input, speed);
-
-	if (speed == SPEED_100)
-		ssr |= ZMII_SSR_SP(input);
-	else
-		ssr &= ~ZMII_SSR_SP(input);
-
-	out_be32(&dev->base->ssr, ssr);
-}
-
-void __zmii_fini(struct ocp_device *ocpdev, int input)
-{
-	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
-	BUG_ON(!dev || dev->users == 0);
-
-	ZMII_DBG("%d: fini(%d)" NL, ocpdev->def->index, input);
-
-	/* Disable this input */
-	out_be32(&dev->base->fer,
-		 in_be32(&dev->base->fer) & ~zmii_mode_mask(dev->mode, input));
-
-	if (!--dev->users) {
-		/* Free everything if this is the last user */
-		ocp_set_drvdata(ocpdev, NULL);
-		iounmap(dev->base);
-		kfree(dev);
-	}
-}
-
-int __zmii_get_regs_len(struct ocp_device *ocpdev)
-{
-	return sizeof(struct emac_ethtool_regs_subhdr) +
-	    sizeof(struct zmii_regs);
-}
-
-void *zmii_dump_regs(struct ocp_device *ocpdev, void *buf)
-{
-	struct ibm_ocp_zmii *dev = ocp_get_drvdata(ocpdev);
-	struct emac_ethtool_regs_subhdr *hdr = buf;
-	struct zmii_regs *regs = (struct zmii_regs *)(hdr + 1);
-
-	hdr->version = 0;
-	hdr->index = ocpdev->def->index;
-	memcpy_fromio(regs, dev->base, sizeof(struct zmii_regs));
-	return regs + 1;
-}
diff --git a/drivers/net/ibm_emac/ibm_emac_zmii.h b/drivers/net/ibm_emac/ibm_emac_zmii.h
deleted file mode 100644
index fad6d8b..0000000
--- a/drivers/net/ibm_emac/ibm_emac_zmii.h
+++ /dev/null
@@ -1,82 +0,0 @@
-/*
- * drivers/net/ibm_emac/ibm_emac_zmii.h
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
- *
- * Copyright (c) 2004, 2005 Zultys Technologies.
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * Based on original work by
- *      Armin Kuster <akuster@mvista.com>
- * 	Copyright 2001 MontaVista Softare Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef _IBM_EMAC_ZMII_H_
-#define _IBM_EMAC_ZMII_H_
-
-#include <linux/init.h>
-#include <asm/ocp.h>
-
-/* ZMII bridge registers */
-struct zmii_regs {
-	u32 fer;		/* Function enable reg */
-	u32 ssr;		/* Speed select reg */
-	u32 smiirs;		/* SMII status reg */
-};
-
-/* ZMII device */
-struct ibm_ocp_zmii {
-	struct zmii_regs __iomem *base;
-	int mode;		/* subset of PHY_MODE_XXXX */
-	int users;		/* number of EMACs using this ZMII bridge */
-	u32 fer_save;		/* FER value left by firmware */
-};
-
-#ifdef CONFIG_IBM_EMAC_ZMII
-int zmii_attach(void *emac) __init;
-
-void __zmii_fini(struct ocp_device *ocpdev, int input);
-static inline void zmii_fini(struct ocp_device *ocpdev, int input)
-{
-	if (ocpdev)
-		__zmii_fini(ocpdev, input);
-}
-
-void __zmii_enable_mdio(struct ocp_device *ocpdev, int input);
-static inline void zmii_enable_mdio(struct ocp_device *ocpdev, int input)
-{
-	if (ocpdev)
-		__zmii_enable_mdio(ocpdev, input);
-}
-
-void __zmii_set_speed(struct ocp_device *ocpdev, int input, int speed);
-static inline void zmii_set_speed(struct ocp_device *ocpdev, int input,
-				  int speed)
-{
-	if (ocpdev)
-		__zmii_set_speed(ocpdev, input, speed);
-}
-
-int __zmii_get_regs_len(struct ocp_device *ocpdev);
-static inline int zmii_get_regs_len(struct ocp_device *ocpdev)
-{
-	return ocpdev ? __zmii_get_regs_len(ocpdev) : 0;
-}
-
-void *zmii_dump_regs(struct ocp_device *ocpdev, void *buf);
-
-#else
-# define zmii_attach(x)		0
-# define zmii_fini(x,y)		((void)0)
-# define zmii_enable_mdio(x,y)	((void)0)
-# define zmii_set_speed(x,y,z)	((void)0)
-# define zmii_get_regs_len(x)	0
-# define zmii_dump_regs(x,buf)	(buf)
-#endif				/* !CONFIG_IBM_EMAC_ZMII */
-
-#endif				/* _IBM_EMAC_ZMII_H_ */
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b7915cd..83a877f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -34,406 +34,145 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
+
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
-
-#include <linux/bitops.h>
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/platform_device.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/mii.h>
-
 #include <linux/mv643xx_eth.h>
-
 #include <asm/io.h>
 #include <asm/types.h>
-#include <asm/pgtable.h>
 #include <asm/system.h>
-#include <asm/delay.h>
-#include <asm/dma-mapping.h>
 
-#define MV643XX_CHECKSUM_OFFLOAD_TX
-#define MV643XX_NAPI
-#define MV643XX_TX_FAST_REFILL
-#undef	MV643XX_COAL
+static char mv643xx_eth_driver_name[] = "mv643xx_eth";
+static char mv643xx_eth_driver_version[] = "1.1";
 
-#define MV643XX_TX_COAL 100
-#ifdef MV643XX_COAL
-#define MV643XX_RX_COAL 100
-#endif
+#define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
+#define MV643XX_ETH_NAPI
+#define MV643XX_ETH_TX_FAST_REFILL
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
 #else
 #define MAX_DESCS_PER_SKB	1
 #endif
 
-#define ETH_VLAN_HLEN		4
-#define ETH_FCS_LEN		4
-#define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
-#define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
-					ETH_VLAN_HLEN + ETH_FCS_LEN)
-#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + \
-					dma_get_cache_alignment())
-
 /*
  * Registers shared between all ports.
  */
-#define PHY_ADDR_REG				0x0000
-#define SMI_REG					0x0004
-#define WINDOW_BASE(i)				(0x0200 + ((i) << 3))
-#define WINDOW_SIZE(i)				(0x0204 + ((i) << 3))
-#define WINDOW_REMAP_HIGH(i)			(0x0280 + ((i) << 2))
-#define WINDOW_BAR_ENABLE			0x0290
-#define WINDOW_PROTECT(i)			(0x0294 + ((i) << 4))
+#define PHY_ADDR			0x0000
+#define SMI_REG				0x0004
+#define WINDOW_BASE(w)			(0x0200 + ((w) << 3))
+#define WINDOW_SIZE(w)			(0x0204 + ((w) << 3))
+#define WINDOW_REMAP_HIGH(w)		(0x0280 + ((w) << 2))
+#define WINDOW_BAR_ENABLE		0x0290
+#define WINDOW_PROTECT(w)		(0x0294 + ((w) << 4))
 
 /*
  * Per-port registers.
  */
-#define PORT_CONFIG_REG(p)				(0x0400 + ((p) << 10))
-#define PORT_CONFIG_EXTEND_REG(p)			(0x0404 + ((p) << 10))
-#define MAC_ADDR_LOW(p)					(0x0414 + ((p) << 10))
-#define MAC_ADDR_HIGH(p)				(0x0418 + ((p) << 10))
-#define SDMA_CONFIG_REG(p)				(0x041c + ((p) << 10))
-#define PORT_SERIAL_CONTROL_REG(p)			(0x043c + ((p) << 10))
-#define PORT_STATUS_REG(p)				(0x0444 + ((p) << 10))
-#define TRANSMIT_QUEUE_COMMAND_REG(p)			(0x0448 + ((p) << 10))
-#define MAXIMUM_TRANSMIT_UNIT(p)			(0x0458 + ((p) << 10))
-#define INTERRUPT_CAUSE_REG(p)				(0x0460 + ((p) << 10))
-#define INTERRUPT_CAUSE_EXTEND_REG(p)			(0x0464 + ((p) << 10))
-#define INTERRUPT_MASK_REG(p)				(0x0468 + ((p) << 10))
-#define INTERRUPT_EXTEND_MASK_REG(p)			(0x046c + ((p) << 10))
-#define TX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0474 + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x060c + ((p) << 10))
-#define RECEIVE_QUEUE_COMMAND_REG(p)			(0x0680 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x06c0 + ((p) << 10))
-#define MIB_COUNTERS_BASE(p)				(0x1000 + ((p) << 7))
-#define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(p)	(0x1400 + ((p) << 10))
-#define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(p)		(0x1500 + ((p) << 10))
-#define DA_FILTER_UNICAST_TABLE_BASE(p)			(0x1600 + ((p) << 10))
-
-/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define UNICAST_NORMAL_MODE		(0 << 0)
-#define UNICAST_PROMISCUOUS_MODE	(1 << 0)
-#define DEFAULT_RX_QUEUE(queue)		((queue) << 1)
-#define DEFAULT_RX_ARP_QUEUE(queue)	((queue) << 4)
-#define RECEIVE_BC_IF_NOT_IP_OR_ARP	(0 << 7)
-#define REJECT_BC_IF_NOT_IP_OR_ARP	(1 << 7)
-#define RECEIVE_BC_IF_IP		(0 << 8)
-#define REJECT_BC_IF_IP			(1 << 8)
-#define RECEIVE_BC_IF_ARP		(0 << 9)
-#define REJECT_BC_IF_ARP		(1 << 9)
-#define TX_AM_NO_UPDATE_ERROR_SUMMARY	(1 << 12)
-#define CAPTURE_TCP_FRAMES_DIS		(0 << 14)
-#define CAPTURE_TCP_FRAMES_EN		(1 << 14)
-#define CAPTURE_UDP_FRAMES_DIS		(0 << 15)
-#define CAPTURE_UDP_FRAMES_EN		(1 << 15)
-#define DEFAULT_RX_TCP_QUEUE(queue)	((queue) << 16)
-#define DEFAULT_RX_UDP_QUEUE(queue)	((queue) << 19)
-#define DEFAULT_RX_BPDU_QUEUE(queue)	((queue) << 22)
-
-#define PORT_CONFIG_DEFAULT_VALUE			\
-		UNICAST_NORMAL_MODE		|	\
-		DEFAULT_RX_QUEUE(0)		|	\
-		DEFAULT_RX_ARP_QUEUE(0)		|	\
-		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		RECEIVE_BC_IF_IP		|	\
-		RECEIVE_BC_IF_ARP		|	\
-		CAPTURE_TCP_FRAMES_DIS		|	\
-		CAPTURE_UDP_FRAMES_DIS		|	\
-		DEFAULT_RX_TCP_QUEUE(0)		|	\
-		DEFAULT_RX_UDP_QUEUE(0)		|	\
-		DEFAULT_RX_BPDU_QUEUE(0)
-
-/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define CLASSIFY_EN				(1 << 0)
-#define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
-#define SPAN_BPDU_PACKETS_TO_RX_QUEUE_7		(1 << 1)
-#define PARTITION_DISABLE			(0 << 2)
-#define PARTITION_ENABLE			(1 << 2)
-
-#define PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		PARTITION_DISABLE
-
-/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define RIFB				(1 << 0)
-#define RX_BURST_SIZE_1_64BIT		(0 << 1)
-#define RX_BURST_SIZE_2_64BIT		(1 << 1)
+#define PORT_CONFIG(p)			(0x0400 + ((p) << 10))
+#define  UNICAST_PROMISCUOUS_MODE	0x00000001
+#define PORT_CONFIG_EXT(p)		(0x0404 + ((p) << 10))
+#define MAC_ADDR_LOW(p)			(0x0414 + ((p) << 10))
+#define MAC_ADDR_HIGH(p)		(0x0418 + ((p) << 10))
+#define SDMA_CONFIG(p)			(0x041c + ((p) << 10))
+#define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
+#define PORT_STATUS(p)			(0x0444 + ((p) << 10))
+#define  TX_FIFO_EMPTY			0x00000400
+#define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
+#define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
+#define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
+#define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
+#define TX_BW_BURST(p)			(0x045c + ((p) << 10))
+#define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define  INT_TX_END			0x07f80000
+#define  INT_RX				0x0007fbfc
+#define  INT_EXT			0x00000002
+#define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
+#define  INT_EXT_LINK			0x00100000
+#define  INT_EXT_PHY			0x00010000
+#define  INT_EXT_TX_ERROR_0		0x00000100
+#define  INT_EXT_TX_0			0x00000001
+#define  INT_EXT_TX			0x0000ffff
+#define INT_MASK(p)			(0x0468 + ((p) << 10))
+#define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
+#define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
+#define TXQ_FIX_PRIO_CONF_MOVED(p)	(0x04dc + ((p) << 10))
+#define TX_BW_RATE_MOVED(p)		(0x04e0 + ((p) << 10))
+#define TX_BW_MTU_MOVED(p)		(0x04e8 + ((p) << 10))
+#define TX_BW_BURST_MOVED(p)		(0x04ec + ((p) << 10))
+#define RXQ_CURRENT_DESC_PTR(p, q)	(0x060c + ((p) << 10) + ((q) << 4))
+#define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
+#define TXQ_CURRENT_DESC_PTR(p, q)	(0x06c0 + ((p) << 10) + ((q) << 2))
+#define TXQ_BW_TOKENS(p, q)		(0x0700 + ((p) << 10) + ((q) << 4))
+#define TXQ_BW_CONF(p, q)		(0x0704 + ((p) << 10) + ((q) << 4))
+#define TXQ_BW_WRR_CONF(p, q)		(0x0708 + ((p) << 10) + ((q) << 4))
+#define MIB_COUNTERS(p)			(0x1000 + ((p) << 7))
+#define SPECIAL_MCAST_TABLE(p)		(0x1400 + ((p) << 10))
+#define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
+#define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
+
+
+/*
+ * SDMA configuration register.
+ */
 #define RX_BURST_SIZE_4_64BIT		(2 << 1)
-#define RX_BURST_SIZE_8_64BIT		(3 << 1)
-#define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
-#define BLM_RX_BYTE_SWAP		(0 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
-#define BLM_TX_BYTE_SWAP		(0 << 5)
-#define DESCRIPTORS_BYTE_SWAP		(1 << 6)
-#define DESCRIPTORS_NO_SWAP		(0 << 6)
-#define IPG_INT_RX(value)		(((value) & 0x3fff) << 8)
-#define TX_BURST_SIZE_1_64BIT		(0 << 22)
-#define TX_BURST_SIZE_2_64BIT		(1 << 22)
 #define TX_BURST_SIZE_4_64BIT		(2 << 22)
-#define TX_BURST_SIZE_8_64BIT		(3 << 22)
-#define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
-		IPG_INT_RX(0)		|	\
 		TX_BURST_SIZE_4_64BIT
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
 		RX_BURST_SIZE_4_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
-		IPG_INT_RX(0)		|	\
 		TX_BURST_SIZE_4_64BIT
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
-/* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define SERIAL_PORT_DISABLE			(0 << 0)
-#define SERIAL_PORT_ENABLE			(1 << 0)
-#define DO_NOT_FORCE_LINK_PASS			(0 << 1)
-#define FORCE_LINK_PASS				(1 << 1)
-#define ENABLE_AUTO_NEG_FOR_DUPLX		(0 << 2)
-#define DISABLE_AUTO_NEG_FOR_DUPLX		(1 << 2)
-#define ENABLE_AUTO_NEG_FOR_FLOW_CTRL		(0 << 3)
-#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
-#define ADV_NO_FLOW_CTRL			(0 << 4)
-#define ADV_SYMMETRIC_FLOW_CTRL			(1 << 4)
-#define FORCE_FC_MODE_NO_PAUSE_DIS_TX		(0 << 5)
-#define FORCE_FC_MODE_TX_PAUSE_DIS		(1 << 5)
-#define FORCE_BP_MODE_NO_JAM			(0 << 7)
-#define FORCE_BP_MODE_JAM_TX			(1 << 7)
-#define FORCE_BP_MODE_JAM_TX_ON_RX_ERR		(2 << 7)
-#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
-#define FORCE_LINK_FAIL				(0 << 10)
-#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
-#define RETRANSMIT_16_ATTEMPTS			(0 << 11)
-#define RETRANSMIT_FOREVER			(1 << 11)
-#define ENABLE_AUTO_NEG_SPEED_GMII		(0 << 13)
-#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
-#define DTE_ADV_0				(0 << 14)
-#define DTE_ADV_1				(1 << 14)
-#define DISABLE_AUTO_NEG_BYPASS			(0 << 15)
-#define ENABLE_AUTO_NEG_BYPASS			(1 << 15)
-#define AUTO_NEG_NO_CHANGE			(0 << 16)
-#define RESTART_AUTO_NEG			(1 << 16)
-#define MAX_RX_PACKET_1518BYTE			(0 << 17)
+
+/*
+ * Port serial control register.
+ */
+#define SET_MII_SPEED_TO_100			(1 << 24)
+#define SET_GMII_SPEED_TO_1000			(1 << 23)
+#define SET_FULL_DUPLEX_MODE			(1 << 21)
 #define MAX_RX_PACKET_1522BYTE			(1 << 17)
-#define MAX_RX_PACKET_1552BYTE			(2 << 17)
-#define MAX_RX_PACKET_9022BYTE			(3 << 17)
-#define MAX_RX_PACKET_9192BYTE			(4 << 17)
 #define MAX_RX_PACKET_9700BYTE			(5 << 17)
 #define MAX_RX_PACKET_MASK			(7 << 17)
-#define CLR_EXT_LOOPBACK			(0 << 20)
-#define SET_EXT_LOOPBACK			(1 << 20)
-#define SET_HALF_DUPLEX_MODE			(0 << 21)
-#define SET_FULL_DUPLEX_MODE			(1 << 21)
-#define DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(0 << 22)
-#define ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX	(1 << 22)
-#define SET_GMII_SPEED_TO_10_100		(0 << 23)
-#define SET_GMII_SPEED_TO_1000			(1 << 23)
-#define SET_MII_SPEED_TO_10			(0 << 24)
-#define SET_MII_SPEED_TO_100			(1 << 24)
+#define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
+#define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
+#define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
+#define DISABLE_AUTO_NEG_FOR_FLOW_CTRL		(1 << 3)
+#define DISABLE_AUTO_NEG_FOR_DUPLEX		(1 << 2)
+#define FORCE_LINK_PASS				(1 << 1)
+#define SERIAL_PORT_ENABLE			(1 << 0)
 
-#define PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		DO_NOT_FORCE_LINK_PASS		|	\
-		ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		DISABLE_AUTO_NEG_FOR_FLOW_CTRL	|	\
-		ADV_SYMMETRIC_FLOW_CTRL		|	\
-		FORCE_FC_MODE_NO_PAUSE_DIS_TX	|	\
-		FORCE_BP_MODE_NO_JAM		|	\
-		(1 << 9) /* reserved */		|	\
-		DO_NOT_FORCE_LINK_FAIL		|	\
-		RETRANSMIT_16_ATTEMPTS		|	\
-		ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		DTE_ADV_0			|	\
-		DISABLE_AUTO_NEG_BYPASS		|	\
-		AUTO_NEG_NO_CHANGE		|	\
-		MAX_RX_PACKET_9700BYTE		|	\
-		CLR_EXT_LOOPBACK		|	\
-		SET_FULL_DUPLEX_MODE		|	\
-		ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-/* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define PORT_STATUS_MODE_10_BIT		(1 << 0)
-#define PORT_STATUS_LINK_UP		(1 << 1)
-#define PORT_STATUS_FULL_DUPLEX		(1 << 2)
-#define PORT_STATUS_FLOW_CONTROL	(1 << 3)
-#define PORT_STATUS_GMII_1000		(1 << 4)
-#define PORT_STATUS_MII_100		(1 << 5)
-/* PSR bit 6 is undocumented */
-#define PORT_STATUS_TX_IN_PROGRESS	(1 << 7)
-#define PORT_STATUS_AUTONEG_BYPASSED	(1 << 8)
-#define PORT_STATUS_PARTITION		(1 << 9)
-#define PORT_STATUS_TX_FIFO_EMPTY	(1 << 10)
-/* PSR bits 11-31 are reserved */
-
-#define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
-
-#define DESC_SIZE				64
-
-#define ETH_RX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for receive */
-#define ETH_TX_QUEUES_ENABLED	(1 << 0)	/* use only Q0 for transmit */
-
-#define ETH_INT_CAUSE_RX_DONE	(ETH_RX_QUEUES_ENABLED << 2)
-#define ETH_INT_CAUSE_RX_ERROR	(ETH_RX_QUEUES_ENABLED << 9)
-#define ETH_INT_CAUSE_RX	(ETH_INT_CAUSE_RX_DONE | ETH_INT_CAUSE_RX_ERROR)
-#define ETH_INT_CAUSE_EXT	0x00000002
-#define ETH_INT_UNMASK_ALL	(ETH_INT_CAUSE_RX | ETH_INT_CAUSE_EXT)
-
-#define ETH_INT_CAUSE_TX_DONE	(ETH_TX_QUEUES_ENABLED << 0)
-#define ETH_INT_CAUSE_TX_ERROR	(ETH_TX_QUEUES_ENABLED << 8)
-#define ETH_INT_CAUSE_TX	(ETH_INT_CAUSE_TX_DONE | ETH_INT_CAUSE_TX_ERROR)
-#define ETH_INT_CAUSE_PHY	0x00010000
-#define ETH_INT_CAUSE_STATE	0x00100000
-#define ETH_INT_UNMASK_ALL_EXT	(ETH_INT_CAUSE_TX | ETH_INT_CAUSE_PHY | \
-					ETH_INT_CAUSE_STATE)
-
-#define ETH_INT_MASK_ALL	0x00000000
-#define ETH_INT_MASK_ALL_EXT	0x00000000
-
-#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
-#define PHY_WAIT_MICRO_SECONDS	10
-
-/* Buffer offset from buffer pointer */
-#define RX_BUF_OFFSET				0x2
-
-/* Gigabit Ethernet Unit Global Registers */
-
-/* MIB Counters register definitions */
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_LOW	0x0
-#define ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH	0x4
-#define ETH_MIB_BAD_OCTETS_RECEIVED		0x8
-#define ETH_MIB_INTERNAL_MAC_TRANSMIT_ERR	0xc
-#define ETH_MIB_GOOD_FRAMES_RECEIVED		0x10
-#define ETH_MIB_BAD_FRAMES_RECEIVED		0x14
-#define ETH_MIB_BROADCAST_FRAMES_RECEIVED	0x18
-#define ETH_MIB_MULTICAST_FRAMES_RECEIVED	0x1c
-#define ETH_MIB_FRAMES_64_OCTETS		0x20
-#define ETH_MIB_FRAMES_65_TO_127_OCTETS		0x24
-#define ETH_MIB_FRAMES_128_TO_255_OCTETS	0x28
-#define ETH_MIB_FRAMES_256_TO_511_OCTETS	0x2c
-#define ETH_MIB_FRAMES_512_TO_1023_OCTETS	0x30
-#define ETH_MIB_FRAMES_1024_TO_MAX_OCTETS	0x34
-#define ETH_MIB_GOOD_OCTETS_SENT_LOW		0x38
-#define ETH_MIB_GOOD_OCTETS_SENT_HIGH		0x3c
-#define ETH_MIB_GOOD_FRAMES_SENT		0x40
-#define ETH_MIB_EXCESSIVE_COLLISION		0x44
-#define ETH_MIB_MULTICAST_FRAMES_SENT		0x48
-#define ETH_MIB_BROADCAST_FRAMES_SENT		0x4c
-#define ETH_MIB_UNREC_MAC_CONTROL_RECEIVED	0x50
-#define ETH_MIB_FC_SENT				0x54
-#define ETH_MIB_GOOD_FC_RECEIVED		0x58
-#define ETH_MIB_BAD_FC_RECEIVED			0x5c
-#define ETH_MIB_UNDERSIZE_RECEIVED		0x60
-#define ETH_MIB_FRAGMENTS_RECEIVED		0x64
-#define ETH_MIB_OVERSIZE_RECEIVED		0x68
-#define ETH_MIB_JABBER_RECEIVED			0x6c
-#define ETH_MIB_MAC_RECEIVE_ERROR		0x70
-#define ETH_MIB_BAD_CRC_EVENT			0x74
-#define ETH_MIB_COLLISION			0x78
-#define ETH_MIB_LATE_COLLISION			0x7c
-
-/* Port serial status reg (PSR) */
-#define ETH_INTERFACE_PCM			0x00000001
-#define ETH_LINK_IS_UP				0x00000002
-#define ETH_PORT_AT_FULL_DUPLEX			0x00000004
-#define ETH_RX_FLOW_CTRL_ENABLED		0x00000008
-#define ETH_GMII_SPEED_1000			0x00000010
-#define ETH_MII_SPEED_100			0x00000020
-#define ETH_TX_IN_PROGRESS			0x00000080
-#define ETH_BYPASS_ACTIVE			0x00000100
-#define ETH_PORT_AT_PARTITION_STATE		0x00000200
-#define ETH_PORT_TX_FIFO_EMPTY			0x00000400
-
-/* SMI reg */
-#define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
-#define ETH_SMI_OPCODE_READ	0x04000000	/* Operation is in progress */
-
-/* Interrupt Cause Register Bit Definitions */
-
-/* SDMA command status fields macros */
-
-/* Tx & Rx descriptors status */
-#define ETH_ERROR_SUMMARY			0x00000001
-
-/* Tx & Rx descriptors command */
-#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
-
-/* Tx descriptors status */
-#define ETH_LC_ERROR				0
-#define ETH_UR_ERROR				0x00000002
-#define ETH_RL_ERROR				0x00000004
-#define ETH_LLC_SNAP_FORMAT			0x00000200
-
-/* Rx descriptors status */
-#define ETH_OVERRUN_ERROR			0x00000002
-#define ETH_MAX_FRAME_LENGTH_ERROR		0x00000004
-#define ETH_RESOURCE_ERROR			0x00000006
-#define ETH_VLAN_TAGGED				0x00080000
-#define ETH_BPDU_FRAME				0x00100000
-#define ETH_UDP_FRAME_OVER_IP_V_4		0x00200000
-#define ETH_OTHER_FRAME_TYPE			0x00400000
-#define ETH_LAYER_2_IS_ETH_V_2			0x00800000
-#define ETH_FRAME_TYPE_IP_V_4			0x01000000
-#define ETH_FRAME_HEADER_OK			0x02000000
-#define ETH_RX_LAST_DESC			0x04000000
-#define ETH_RX_FIRST_DESC			0x08000000
-#define ETH_UNKNOWN_DESTINATION_ADDR		0x10000000
-#define ETH_RX_ENABLE_INTERRUPT			0x20000000
-#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
-
-/* Rx descriptors byte count */
-#define ETH_FRAME_FRAGMENTED			0x00000004
-
-/* Tx descriptors command */
-#define ETH_LAYER_4_CHECKSUM_FIRST_DESC		0x00000400
-#define ETH_FRAME_SET_TO_VLAN			0x00008000
-#define ETH_UDP_FRAME				0x00010000
-#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
-#define ETH_GEN_IP_V_4_CHECKSUM			0x00040000
-#define ETH_ZERO_PADDING			0x00080000
-#define ETH_TX_LAST_DESC			0x00100000
-#define ETH_TX_FIRST_DESC			0x00200000
-#define ETH_GEN_CRC				0x00400000
-#define ETH_TX_ENABLE_INTERRUPT			0x00800000
-#define ETH_AUTO_MODE				0x40000000
-
-#define ETH_TX_IHL_SHIFT			11
-
-/* typedefs */
-
-typedef enum _eth_func_ret_status {
-	ETH_OK,			/* Returned as expected.		*/
-	ETH_ERROR,		/* Fundamental error.			*/
-	ETH_RETRY,		/* Could not process request. Try later.*/
-	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
-	ETH_QUEUE_FULL,		/* Ring resource error.			*/
-	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
-} ETH_FUNC_RET_STATUS;
-
-/* These are for big-endian machines.  Little endian needs different
- * definitions.
+#define DEFAULT_RX_QUEUE_SIZE		400
+#define DEFAULT_TX_QUEUE_SIZE		800
+
+
+/*
+ * RX/TX descriptors.
  */
 #if defined(__BIG_ENDIAN)
-struct eth_rx_desc {
+struct rx_desc {
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
 	u16 buf_size;		/* Buffer size				*/
 	u32 cmd_sts;		/* Descriptor command status		*/
@@ -441,7 +180,7 @@ struct eth_rx_desc {
 	u32 buf_ptr;		/* Descriptor buffer pointer		*/
 };
 
-struct eth_tx_desc {
+struct tx_desc {
 	u16 byte_cnt;		/* buffer byte count			*/
 	u16 l4i_chk;		/* CPU provided TCP checksum		*/
 	u32 cmd_sts;		/* Command/status field			*/
@@ -449,7 +188,7 @@ struct eth_tx_desc {
 	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
 };
 #elif defined(__LITTLE_ENDIAN)
-struct eth_rx_desc {
+struct rx_desc {
 	u32 cmd_sts;		/* Descriptor command status		*/
 	u16 buf_size;		/* Buffer size				*/
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
@@ -457,7 +196,7 @@ struct eth_rx_desc {
 	u32 next_desc_ptr;	/* Next descriptor pointer		*/
 };
 
-struct eth_tx_desc {
+struct tx_desc {
 	u32 cmd_sts;		/* Command/status field			*/
 	u16 l4i_chk;		/* CPU provided TCP checksum		*/
 	u16 byte_cnt;		/* buffer byte count			*/
@@ -468,18 +207,59 @@ struct eth_tx_desc {
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
 
-/* Unified struct for Rx and Tx operations. The user is not required to	*/
-/* be familier with neither Tx nor Rx descriptors.			*/
-struct pkt_info {
-	unsigned short byte_cnt;	/* Descriptor buffer byte count	*/
-	unsigned short l4i_chk;		/* Tx CPU provided TCP Checksum	*/
-	unsigned int cmd_sts;		/* Descriptor command status	*/
-	dma_addr_t buf_ptr;		/* Descriptor buffer pointer	*/
-	struct sk_buff *return_info;	/* User resource return information */
+/* RX & TX descriptor command */
+#define BUFFER_OWNED_BY_DMA		0x80000000
+
+/* RX & TX descriptor status */
+#define ERROR_SUMMARY			0x00000001
+
+/* RX descriptor status */
+#define LAYER_4_CHECKSUM_OK		0x40000000
+#define RX_ENABLE_INTERRUPT		0x20000000
+#define RX_FIRST_DESC			0x08000000
+#define RX_LAST_DESC			0x04000000
+
+/* TX descriptor command */
+#define TX_ENABLE_INTERRUPT		0x00800000
+#define GEN_CRC				0x00400000
+#define TX_FIRST_DESC			0x00200000
+#define TX_LAST_DESC			0x00100000
+#define ZERO_PADDING			0x00080000
+#define GEN_IP_V4_CHECKSUM		0x00040000
+#define GEN_TCP_UDP_CHECKSUM		0x00020000
+#define UDP_FRAME			0x00010000
+
+#define TX_IHL_SHIFT			11
+
+
+/* global *******************************************************************/
+struct mv643xx_eth_shared_private {
+	/*
+	 * Ethernet controller base address.
+	 */
+	void __iomem *base;
+
+	/*
+	 * Protects access to SMI_REG, which is shared between ports.
+	 */
+	spinlock_t phy_lock;
+
+	/*
+	 * Per-port MBUS window access register value.
+	 */
+	u32 win_protect;
+
+	/*
+	 * Hardware-specific parameters.
+	 */
+	unsigned int t_clk;
+	int extended_rx_coal_limit;
+	int tx_bw_control_moved;
 };
 
-/* Ethernet port specific information */
-struct mv643xx_mib_counters {
+
+/* per-port *****************************************************************/
+struct mib_counters {
 	u64 good_octets_received;
 	u32 bad_octets_received;
 	u32 internal_mac_transmit_err;
@@ -512,461 +292,282 @@ struct mv643xx_mib_counters {
 	u32 late_collision;
 };
 
-struct mv643xx_shared_private {
-	void __iomem *eth_base;
-
-	/* used to protect SMI_REG, which is shared across ports */
-	spinlock_t phy_lock;
+struct rx_queue {
+	int index;
 
-	u32 win_protect;
-
-	unsigned int t_clk;
-};
-
-struct mv643xx_private {
-	struct mv643xx_shared_private *shared;
-	int port_num;			/* User Ethernet port number	*/
-
-	struct mv643xx_shared_private *shared_smi;
-
-	u32 rx_sram_addr;		/* Base address of rx sram area */
-	u32 rx_sram_size;		/* Size of rx sram area		*/
-	u32 tx_sram_addr;		/* Base address of tx sram area */
-	u32 tx_sram_size;		/* Size of tx sram area		*/
+	int rx_ring_size;
 
-	int rx_resource_err;		/* Rx ring resource error flag */
+	int rx_desc_count;
+	int rx_curr_desc;
+	int rx_used_desc;
 
-	/* Tx/Rx rings managment indexes fields. For driver use */
+	struct rx_desc *rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	int rx_desc_area_size;
+	struct sk_buff **rx_skb;
 
-	/* Next available and first returning Rx resource */
-	int rx_curr_desc_q, rx_used_desc_q;
+	struct timer_list rx_oom;
+};
 
-	/* Next available and first returning Tx resource */
-	int tx_curr_desc_q, tx_used_desc_q;
+struct tx_queue {
+	int index;
 
-#ifdef MV643XX_TX_FAST_REFILL
-	u32 tx_clean_threshold;
-#endif
+	int tx_ring_size;
 
-	struct eth_rx_desc *p_rx_desc_area;
-	dma_addr_t rx_desc_dma;
-	int rx_desc_area_size;
-	struct sk_buff **rx_skb;
+	int tx_desc_count;
+	int tx_curr_desc;
+	int tx_used_desc;
 
-	struct eth_tx_desc *p_tx_desc_area;
+	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 	struct sk_buff **tx_skb;
+};
 
-	struct work_struct tx_timeout_task;
+struct mv643xx_eth_private {
+	struct mv643xx_eth_shared_private *shared;
+	int port_num;
 
 	struct net_device *dev;
-	struct napi_struct napi;
-	struct net_device_stats stats;
-	struct mv643xx_mib_counters mib_counters;
+
+	struct mv643xx_eth_shared_private *shared_smi;
+	int phy_addr;
+
 	spinlock_t lock;
-	/* Size of Tx Ring per queue */
-	int tx_ring_size;
-	/* Number of tx descriptors in use */
-	int tx_desc_count;
-	/* Size of Rx Ring per queue */
-	int rx_ring_size;
-	/* Number of rx descriptors in use */
-	int rx_desc_count;
+
+	struct mib_counters mib_counters;
+	struct work_struct tx_timeout_task;
+	struct mii_if_info mii;
 
 	/*
-	 * Used in case RX Ring is empty, which can be caused when
-	 * system does not have resources (skb's)
+	 * RX state.
 	 */
-	struct timer_list timeout;
-
-	u32 rx_int_coal;
-	u32 tx_int_coal;
-	struct mii_if_info mii;
-};
+	int default_rx_ring_size;
+	unsigned long rx_desc_sram_addr;
+	int rx_desc_sram_size;
+	u8 rxq_mask;
+	int rxq_primary;
+	struct napi_struct napi;
+	struct rx_queue rxq[8];
 
-/* Static function declarations */
-static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(struct mv643xx_private *mp);
-static void eth_port_start(struct net_device *dev);
-
-static void ethernet_phy_reset(struct mv643xx_private *mp);
-
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
-				   unsigned int phy_reg, unsigned int value);
-
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
-				  unsigned int phy_reg, unsigned int *value);
-
-static void eth_clear_mib_counters(struct mv643xx_private *mp);
-
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-					    struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
-
-static void eth_port_uc_addr_get(struct mv643xx_private *mp,
-				 unsigned char *p_addr);
-static void eth_port_uc_addr_set(struct mv643xx_private *mp,
-				 unsigned char *p_addr);
-static void eth_port_set_multicast_list(struct net_device *);
-static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
-						unsigned int queues);
-static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
-						unsigned int queues);
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp);
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp);
-static int mv643xx_eth_open(struct net_device *);
-static int mv643xx_eth_stop(struct net_device *);
-static void eth_port_init_mac_tables(struct mv643xx_private *mp);
-#ifdef MV643XX_NAPI
-static int mv643xx_poll(struct napi_struct *napi, int budget);
+	/*
+	 * TX state.
+	 */
+	int default_tx_ring_size;
+	unsigned long tx_desc_sram_addr;
+	int tx_desc_sram_size;
+	u8 txq_mask;
+	int txq_primary;
+	struct tx_queue txq[8];
+#ifdef MV643XX_ETH_TX_FAST_REFILL
+	int tx_clean_threshold;
 #endif
-static int ethernet_phy_get(struct mv643xx_private *mp);
-static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr);
-static int ethernet_phy_detect(struct mv643xx_private *mp);
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static const struct ethtool_ops mv643xx_ethtool_ops;
+};
 
-static char mv643xx_driver_name[] = "mv643xx_eth";
-static char mv643xx_driver_version[] = "1.0";
 
-static inline u32 rdl(struct mv643xx_private *mp, int offset)
+/* port register accessors **************************************************/
+static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
 {
-	return readl(mp->shared->eth_base + offset);
+	return readl(mp->shared->base + offset);
 }
 
-static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
+static inline void wrl(struct mv643xx_eth_private *mp, int offset, u32 data)
 {
-	writel(data, mp->shared->eth_base + offset);
+	writel(data, mp->shared->base + offset);
 }
 
-/*
- * Changes MTU (maximum transfer unit) of the gigabit ethenret port
- *
- * Input :	pointer to ethernet interface network device structure
- *		new mtu size
- * Output :	0 upon success, -EINVAL upon failure
- */
-static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu > 9500) || (new_mtu < 64))
-		return -EINVAL;
 
-	dev->mtu = new_mtu;
-	if (!netif_running(dev))
-		return 0;
-
-	/*
-	 * Stop and then re-open the interface. This will allocate RX
-	 * skbs of the new MTU.
-	 * There is a possible danger that the open will not succeed,
-	 * due to memory being full, which might fail the open function.
-	 */
-	mv643xx_eth_stop(dev);
-	if (mv643xx_eth_open(dev)) {
-		printk(KERN_ERR "%s: Fatal error on opening device\n",
-			dev->name);
-	}
-
-	return 0;
-}
-
-/*
- * mv643xx_eth_rx_refill_descs
- *
- * Fills / refills RX queue on a certain gigabit ethernet port
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
-static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
+/* rxq/txq helper functions *************************************************/
+static struct mv643xx_eth_private *rxq_to_mp(struct rx_queue *rxq)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	struct pkt_info pkt_info;
-	struct sk_buff *skb;
-	int unaligned;
-
-	while (mp->rx_desc_count < mp->rx_ring_size) {
-		skb = dev_alloc_skb(ETH_RX_SKB_SIZE + dma_get_cache_alignment());
-		if (!skb)
-			break;
-		mp->rx_desc_count++;
-		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
-		if (unaligned)
-			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
-		pkt_info.cmd_sts = ETH_RX_ENABLE_INTERRUPT;
-		pkt_info.byte_cnt = ETH_RX_SKB_SIZE;
-		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
-					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
-		pkt_info.return_info = skb;
-		if (eth_rx_return_buff(mp, &pkt_info) != ETH_OK) {
-			printk(KERN_ERR
-				"%s: Error allocating RX Ring\n", dev->name);
-			break;
-		}
-		skb_reserve(skb, ETH_HW_IP_ALIGN);
-	}
-	/*
-	 * If RX ring is empty of SKB, set a timer to try allocating
-	 * again at a later time.
-	 */
-	if (mp->rx_desc_count == 0) {
-		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
-		mp->timeout.expires = jiffies + (HZ / 10);	/* 100 mSec */
-		add_timer(&mp->timeout);
-	}
+	return container_of(rxq, struct mv643xx_eth_private, rxq[rxq->index]);
 }
 
-/*
- * mv643xx_eth_rx_refill_descs_timer_wrapper
- *
- * Timer routine to wake up RX queue filling task. This function is
- * used only in case the RX queue is empty, and all alloc_skb has
- * failed (due to out of memory event).
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
-static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
+static struct mv643xx_eth_private *txq_to_mp(struct tx_queue *txq)
 {
-	mv643xx_eth_rx_refill_descs((struct net_device *)data);
+	return container_of(txq, struct mv643xx_eth_private, txq[txq->index]);
 }
 
-/*
- * mv643xx_eth_update_mac_address
- *
- * Update the MAC address of the port in the address table
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
-static void mv643xx_eth_update_mac_address(struct net_device *dev)
+static void rxq_enable(struct rx_queue *rxq)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	eth_port_init_mac_tables(mp);
-	eth_port_uc_addr_set(mp, dev->dev_addr);
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	wrl(mp, RXQ_COMMAND(mp->port_num), 1 << rxq->index);
 }
 
-/*
- * mv643xx_eth_set_rx_mode
- *
- * Change from promiscuos to regular rx mode
- *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
- */
-static void mv643xx_eth_set_rx_mode(struct net_device *dev)
+static void rxq_disable(struct rx_queue *rxq)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	u32 config_reg;
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	u8 mask = 1 << rxq->index;
 
-	config_reg = rdl(mp, PORT_CONFIG_REG(mp->port_num));
-	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
-	else
-		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
-	wrl(mp, PORT_CONFIG_REG(mp->port_num), config_reg);
-
-	eth_port_set_multicast_list(dev);
+	wrl(mp, RXQ_COMMAND(mp->port_num), mask << 8);
+	while (rdl(mp, RXQ_COMMAND(mp->port_num)) & mask)
+		udelay(10);
 }
 
-/*
- * mv643xx_eth_set_mac_address
- *
- * Change the interface's mac address.
- * No special hardware thing should be done because interface is always
- * put in promiscuous mode.
- *
- * Input :	pointer to ethernet interface network device structure and
- *		a pointer to the designated entry to be added to the cache.
- * Output :	zero upon success, negative upon failure
- */
-static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
+static void txq_enable(struct tx_queue *txq)
 {
-	int i;
-
-	for (i = 0; i < 6; i++)
-		/* +2 is for the offset of the HW addr type */
-		dev->dev_addr[i] = ((unsigned char *)addr)[i + 2];
-	mv643xx_eth_update_mac_address(dev);
-	return 0;
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	wrl(mp, TXQ_COMMAND(mp->port_num), 1 << txq->index);
 }
 
-/*
- * mv643xx_eth_tx_timeout
- *
- * Called upon a timeout on transmitting a packet
- *
- * Input :	pointer to ethernet interface network device structure.
- * Output :	N/A
- */
-static void mv643xx_eth_tx_timeout(struct net_device *dev)
+static void txq_disable(struct tx_queue *txq)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	printk(KERN_INFO "%s: TX timeout  ", dev->name);
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	u8 mask = 1 << txq->index;
 
-	/* Do the reset outside of interrupt context */
-	schedule_work(&mp->tx_timeout_task);
+	wrl(mp, TXQ_COMMAND(mp->port_num), mask << 8);
+	while (rdl(mp, TXQ_COMMAND(mp->port_num)) & mask)
+		udelay(10);
 }
 
-/*
- * mv643xx_eth_tx_timeout_task
- *
- * Actual routine to reset the adapter when a timeout on Tx has occurred
- */
-static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
+static void __txq_maybe_wake(struct tx_queue *txq)
 {
-	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
-						  tx_timeout_task);
-	struct net_device *dev = mp->dev;
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 
-	if (!netif_running(dev))
-		return;
+	/*
+	 * netif_{stop,wake}_queue() flow control only applies to
+	 * the primary queue.
+	 */
+	BUG_ON(txq->index != mp->txq_primary);
 
-	netif_stop_queue(dev);
+	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_DESCS_PER_SKB)
+		netif_wake_queue(mp->dev);
+}
 
-	eth_port_reset(mp);
-	eth_port_start(dev);
 
-	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(dev);
-}
+/* rx ***********************************************************************/
+static void txq_reclaim(struct tx_queue *txq, int force);
 
-/**
- * mv643xx_eth_free_tx_descs - Free the tx desc data for completed descriptors
- *
- * If force is non-zero, frees uncompleted descriptors as well
- */
-static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
+static void rxq_refill(struct rx_queue *rxq)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	struct eth_tx_desc *desc;
-	u32 cmd_sts;
-	struct sk_buff *skb;
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	unsigned long flags;
-	int tx_index;
-	dma_addr_t addr;
-	int count;
-	int released = 0;
 
-	while (mp->tx_desc_count > 0) {
-		spin_lock_irqsave(&mp->lock, flags);
-
-		/* tx_desc_count might have changed before acquiring the lock */
-		if (mp->tx_desc_count <= 0) {
-			spin_unlock_irqrestore(&mp->lock, flags);
-			return released;
-		}
-
-		tx_index = mp->tx_used_desc_q;
-		desc = &mp->p_tx_desc_area[tx_index];
-		cmd_sts = desc->cmd_sts;
+	spin_lock_irqsave(&mp->lock, flags);
 
-		if (!force && (cmd_sts & ETH_BUFFER_OWNED_BY_DMA)) {
-			spin_unlock_irqrestore(&mp->lock, flags);
-			return released;
-		}
+	while (rxq->rx_desc_count < rxq->rx_ring_size) {
+		int skb_size;
+		struct sk_buff *skb;
+		int unaligned;
+		int rx;
 
-		mp->tx_used_desc_q = (tx_index + 1) % mp->tx_ring_size;
-		mp->tx_desc_count--;
+		/*
+		 * Reserve 2+14 bytes for an ethernet header (the
+		 * hardware automatically prepends 2 bytes of dummy
+		 * data to each received packet), 4 bytes for a VLAN
+		 * header, and 4 bytes for the trailing FCS -- 24
+		 * bytes total.
+		 */
+		skb_size = mp->dev->mtu + 24;
 
-		addr = desc->buf_ptr;
-		count = desc->byte_cnt;
-		skb = mp->tx_skb[tx_index];
-		if (skb)
-			mp->tx_skb[tx_index] = NULL;
+		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
+		if (skb == NULL)
+			break;
 
-		if (cmd_sts & ETH_ERROR_SUMMARY) {
-			printk("%s: Error in TX\n", dev->name);
-			dev->stats.tx_errors++;
-		}
+		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
+		if (unaligned)
+			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
-		spin_unlock_irqrestore(&mp->lock, flags);
+		rxq->rx_desc_count++;
+		rx = rxq->rx_used_desc;
+		rxq->rx_used_desc = (rx + 1) % rxq->rx_ring_size;
 
-		if (cmd_sts & ETH_TX_FIRST_DESC)
-			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
+		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
+						skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = skb_size;
+		rxq->rx_skb[rx] = skb;
+		wmb();
+		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
+						RX_ENABLE_INTERRUPT;
+		wmb();
 
-		if (skb)
-			dev_kfree_skb_irq(skb);
+		/*
+		 * The hardware automatically prepends 2 bytes of
+		 * dummy data to each received packet, so that the
+		 * IP header ends up 16-byte aligned.
+		 */
+		skb_reserve(skb, 2);
+	}
 
-		released = 1;
+	if (rxq->rx_desc_count != rxq->rx_ring_size) {
+		rxq->rx_oom.expires = jiffies + (HZ / 10);
+		add_timer(&rxq->rx_oom);
 	}
 
-	return released;
+	spin_unlock_irqrestore(&mp->lock, flags);
 }
 
-static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev)
+static inline void rxq_refill_timer_wrapper(unsigned long data)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	if (mv643xx_eth_free_tx_descs(dev, 0) &&
-	    mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(dev);
+	rxq_refill((struct rx_queue *)data);
 }
 
-static void mv643xx_eth_free_all_tx_descs(struct net_device *dev)
+static int rxq_process(struct rx_queue *rxq, int budget)
 {
-	mv643xx_eth_free_tx_descs(dev, 1);
-}
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	struct net_device_stats *stats = &mp->dev->stats;
+	int rx;
 
-/*
- * mv643xx_eth_receive
- *
- * This function is forward packets that are received from the port's
- * queues toward kernel core or FastRoute them to another interface.
- *
- * Input :	dev - a pointer to the required interface
- *		max - maximum number to receive (0 means unlimted)
- *
- * Output :	number of served packets
- */
-static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned int received_packets = 0;
-	struct sk_buff *skb;
-	struct pkt_info pkt_info;
+	rx = 0;
+	while (rx < budget) {
+		struct rx_desc *rx_desc;
+		unsigned int cmd_sts;
+		struct sk_buff *skb;
+		unsigned long flags;
+
+		spin_lock_irqsave(&mp->lock, flags);
+
+		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
+
+		cmd_sts = rx_desc->cmd_sts;
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			spin_unlock_irqrestore(&mp->lock, flags);
+			break;
+		}
+		rmb();
+
+		skb = rxq->rx_skb[rxq->rx_curr_desc];
+		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
 
-	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
-		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
-							DMA_FROM_DEVICE);
-		mp->rx_desc_count--;
-		received_packets++;
+		rxq->rx_curr_desc = (rxq->rx_curr_desc + 1) % rxq->rx_ring_size;
+
+		spin_unlock_irqrestore(&mp->lock, flags);
+
+		dma_unmap_single(NULL, rx_desc->buf_ptr + 2,
+				 mp->dev->mtu + 24, DMA_FROM_DEVICE);
+		rxq->rx_desc_count--;
+		rx++;
 
 		/*
 		 * Update statistics.
-		 * Note byte count includes 4 byte CRC count
+		 *
+		 * Note that the descriptor byte count includes 2 dummy
+		 * bytes automatically inserted by the hardware at the
+		 * start of the packet (which we don't count), and a 4
+		 * byte CRC at the end of the packet (which we do count).
 		 */
 		stats->rx_packets++;
-		stats->rx_bytes += pkt_info.byte_cnt;
-		skb = pkt_info.return_info;
+		stats->rx_bytes += rx_desc->byte_cnt - 2;
+
 		/*
-		 * In case received a packet without first / last bits on OR
-		 * the error summary bit is on, the packets needs to be dropeed.
+		 * In case we received a packet without first / last bits
+		 * on, or the error summary bit is set, the packet needs
+		 * to be dropped.
 		 */
-		if (((pkt_info.cmd_sts
-				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
-					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
-				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
+		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+					(RX_FIRST_DESC | RX_LAST_DESC))
+				|| (cmd_sts & ERROR_SUMMARY)) {
 			stats->rx_dropped++;
-			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
-							ETH_RX_LAST_DESC)) !=
-				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
+
+			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+				(RX_FIRST_DESC | RX_LAST_DESC)) {
 				if (net_ratelimit())
-					printk(KERN_ERR
-						"%s: Received packet spread "
-						"on multiple descriptors\n",
-						dev->name);
+					dev_printk(KERN_ERR, &mp->dev->dev,
+						   "received packet spanning "
+						   "multiple descriptors\n");
 			}
-			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
+
+			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
 			dev_kfree_skb_irq(skb);
@@ -975,2391 +576,2003 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
 			 */
-			skb_put(skb, pkt_info.byte_cnt - 4);
+			skb_put(skb, rx_desc->byte_cnt - 2 - 4);
 
-			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
+			if (cmd_sts & LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				skb->csum = htons(
-					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
+					(cmd_sts & 0x0007fff8) >> 3);
 			}
-			skb->protocol = eth_type_trans(skb, dev);
-#ifdef MV643XX_NAPI
+			skb->protocol = eth_type_trans(skb, mp->dev);
+#ifdef MV643XX_ETH_NAPI
 			netif_receive_skb(skb);
 #else
 			netif_rx(skb);
 #endif
 		}
-		dev->last_rx = jiffies;
+
+		mp->dev->last_rx = jiffies;
 	}
-	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
-	return received_packets;
+	rxq_refill(rxq);
+
+	return rx;
 }
 
-/* Set the mv643xx port configuration register for the speed/duplex mode. */
-static void mv643xx_eth_update_pscr(struct net_device *dev,
-				    struct ethtool_cmd *ecmd)
+#ifdef MV643XX_ETH_NAPI
+static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int port_num = mp->port_num;
-	u32 o_pscr, n_pscr;
-	unsigned int queues;
+	struct mv643xx_eth_private *mp;
+	int rx;
+	int i;
 
-	o_pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
-	n_pscr = o_pscr;
+	mp = container_of(napi, struct mv643xx_eth_private, napi);
 
-	/* clear speed, duplex and rx buffer size fields */
-	n_pscr &= ~(SET_MII_SPEED_TO_100  |
-		   SET_GMII_SPEED_TO_1000 |
-		   SET_FULL_DUPLEX_MODE   |
-		   MAX_RX_PACKET_MASK);
-
-	if (ecmd->duplex == DUPLEX_FULL)
-		n_pscr |= SET_FULL_DUPLEX_MODE;
-
-	if (ecmd->speed == SPEED_1000)
-		n_pscr |= SET_GMII_SPEED_TO_1000 |
-			  MAX_RX_PACKET_9700BYTE;
-	else {
-		if (ecmd->speed == SPEED_100)
-			n_pscr |= SET_MII_SPEED_TO_100;
-		n_pscr |= MAX_RX_PACKET_1522BYTE;
+#ifdef MV643XX_ETH_TX_FAST_REFILL
+	if (++mp->tx_clean_threshold > 5) {
+		mp->tx_clean_threshold = 0;
+		for (i = 0; i < 8; i++)
+			if (mp->txq_mask & (1 << i))
+				txq_reclaim(mp->txq + i, 0);
 	}
+#endif
 
-	if (n_pscr != o_pscr) {
-		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
-		else {
-			queues = mv643xx_eth_port_disable_tx(mp);
-
-			o_pscr &= ~SERIAL_PORT_ENABLE;
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
-			if (queues)
-				mv643xx_eth_port_enable_tx(mp, queues);
-		}
+	rx = 0;
+	for (i = 7; rx < budget && i >= 0; i--)
+		if (mp->rxq_mask & (1 << i))
+			rx += rxq_process(mp->rxq + i, budget - rx);
+
+	if (rx < budget) {
+		netif_rx_complete(mp->dev, napi);
+		wrl(mp, INT_CAUSE(mp->port_num), 0);
+		wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
+		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 	}
+
+	return rx;
 }
+#endif
 
-/*
- * mv643xx_eth_int_handler
- *
- * Main interrupt handler for the gigbit ethernet ports
- *
- * Input :	irq	- irq number (not used)
- *		dev_id	- a pointer to the required interface's data structure
- *		regs	- not used
- * Output :	N/A
- */
 
-static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
+/* tx ***********************************************************************/
+static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 {
-	struct net_device *dev = (struct net_device *)dev_id;
-	struct mv643xx_private *mp = netdev_priv(dev);
-	u32 eth_int_cause, eth_int_cause_ext = 0;
-	unsigned int port_num = mp->port_num;
-
-	/* Read interrupt cause registers */
-	eth_int_cause = rdl(mp, INTERRUPT_CAUSE_REG(port_num)) &
-						ETH_INT_UNMASK_ALL;
-	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
-		eth_int_cause_ext = rdl(mp,
-			INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
-						ETH_INT_UNMASK_ALL_EXT;
-		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num),
-							~eth_int_cause_ext);
-	}
-
-	/* PHY status changed */
-	if (eth_int_cause_ext & (ETH_INT_CAUSE_PHY | ETH_INT_CAUSE_STATE)) {
-		struct ethtool_cmd cmd;
+	int frag;
 
-		if (mii_link_ok(&mp->mii)) {
-			mii_ethtool_gset(&mp->mii, &cmd);
-			mv643xx_eth_update_pscr(dev, &cmd);
-			mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
-			if (!netif_carrier_ok(dev)) {
-				netif_carrier_on(dev);
-				if (mp->tx_ring_size - mp->tx_desc_count >=
-							MAX_DESCS_PER_SKB)
-					netif_wake_queue(dev);
-			}
-		} else if (netif_carrier_ok(dev)) {
-			netif_stop_queue(dev);
-			netif_carrier_off(dev);
-		}
+	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
+		if (fragp->size <= 8 && fragp->page_offset & 7)
+			return 1;
 	}
 
-#ifdef MV643XX_NAPI
-	if (eth_int_cause & ETH_INT_CAUSE_RX) {
-		/* schedule the NAPI poll routine to maintain port */
-		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	return 0;
+}
 
-		/* wait for previous write to complete */
-		rdl(mp, INTERRUPT_MASK_REG(port_num));
+static int txq_alloc_desc_index(struct tx_queue *txq)
+{
+	int tx_desc_curr;
 
-		netif_rx_schedule(dev, &mp->napi);
-	}
-#else
-	if (eth_int_cause & ETH_INT_CAUSE_RX)
-		mv643xx_eth_receive_queue(dev, INT_MAX);
-#endif
-	if (eth_int_cause_ext & ETH_INT_CAUSE_TX)
-		mv643xx_eth_free_completed_tx_descs(dev);
+	BUG_ON(txq->tx_desc_count >= txq->tx_ring_size);
 
-	/*
-	 * If no real interrupt occured, exit.
-	 * This can happen when using gigE interrupt coalescing mechanism.
-	 */
-	if ((eth_int_cause == 0x0) && (eth_int_cause_ext == 0x0))
-		return IRQ_NONE;
+	tx_desc_curr = txq->tx_curr_desc;
+	txq->tx_curr_desc = (tx_desc_curr + 1) % txq->tx_ring_size;
 
-	return IRQ_HANDLED;
-}
+	BUG_ON(txq->tx_curr_desc == txq->tx_used_desc);
 
-#ifdef MV643XX_COAL
+	return tx_desc_curr;
+}
 
-/*
- * eth_port_set_rx_coal - Sets coalescing interrupt mechanism on RX path
- *
- * DESCRIPTION:
- *	This routine sets the RX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the tClk of the MV-643xx chip
- *	, and the required delay of the interrupt in usec.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int delay		Delay in usec
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
- */
-static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
-					unsigned int delay)
+static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
-	unsigned int port_num = mp->port_num;
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int frag;
 
-	/* Set RX Coalescing mechanism */
-	wrl(mp, SDMA_CONFIG_REG(port_num),
-		((coal & 0x3fff) << 8) |
-		(rdl(mp, SDMA_CONFIG_REG(port_num))
-			& 0xffc000ff));
+	for (frag = 0; frag < nr_frags; frag++) {
+		skb_frag_t *this_frag;
+		int tx_index;
+		struct tx_desc *desc;
 
-	return coal;
-}
-#endif
+		this_frag = &skb_shinfo(skb)->frags[frag];
+		tx_index = txq_alloc_desc_index(txq);
+		desc = &txq->tx_desc_area[tx_index];
 
-/*
- * eth_port_set_tx_coal - Sets coalescing interrupt mechanism on TX path
- *
- * DESCRIPTION:
- *	This routine sets the TX coalescing interrupt mechanism parameter.
- *	This parameter is a timeout counter, that counts in 64 t_clk
- *	chunks ; that when timeout event occurs a maskable interrupt
- *	occurs.
- *	The parameter is calculated using the t_cLK frequency of the
- *	MV-643xx chip and the required delay in the interrupt in uSec
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int delay		Delay in uSeconds
- *
- * OUTPUT:
- *	Interrupt coalescing mechanism value is set in MV-643xx chip.
- *
- * RETURN:
- *	The interrupt coalescing value set in the gigE port.
- *
- */
-static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
-					unsigned int delay)
-{
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
+		/*
+		 * The last fragment will generate an interrupt
+		 * which will free the skb on TX completion.
+		 */
+		if (frag == nr_frags - 1) {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA |
+					ZERO_PADDING | TX_LAST_DESC |
+					TX_ENABLE_INTERRUPT;
+			txq->tx_skb[tx_index] = skb;
+		} else {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA;
+			txq->tx_skb[tx_index] = NULL;
+		}
 
-	/* Set TX Coalescing mechanism */
-	wrl(mp, TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
+		desc->l4i_chk = 0;
+		desc->byte_cnt = this_frag->size;
+		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
+						this_frag->page_offset,
+						this_frag->size,
+						DMA_TO_DEVICE);
+	}
+}
 
-	return coal;
+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
 }
 
-/*
- * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
- *	This function prepares a Rx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Rx descriptors and buffers.
- *
- * RETURN:
- *	None.
- */
-static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
+static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
-	volatile struct eth_rx_desc *p_rx_desc;
-	int rx_desc_num = mp->rx_ring_size;
-	int i;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int tx_index;
+	struct tx_desc *desc;
+	u32 cmd_sts;
+	int length;
 
-	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct eth_rx_desc *)mp->p_rx_desc_area;
-	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
-			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
+	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
+
+	tx_index = txq_alloc_desc_index(txq);
+	desc = &txq->tx_desc_area[tx_index];
+
+	if (nr_frags) {
+		txq_submit_frag_skb(txq, skb);
+
+		length = skb_headlen(skb);
+		txq->tx_skb[tx_index] = NULL;
+	} else {
+		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
+		length = skb->len;
+		txq->tx_skb[tx_index] = skb;
 	}
 
-	/* Save Rx desc pointer to driver struct. */
-	mp->rx_curr_desc_q = 0;
-	mp->rx_used_desc_q = 0;
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
-	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
-}
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
-/*
- * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
- *	This function prepares a Tx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Tx descriptors and buffers.
- *
- * RETURN:
- *	None.
- */
-static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
-{
-	int tx_desc_num = mp->tx_ring_size;
-	struct eth_tx_desc *p_tx_desc;
-	int i;
+		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
+			   GEN_IP_V4_CHECKSUM   |
+			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
-	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct eth_tx_desc *)mp->p_tx_desc_area;
-	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
-			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			cmd_sts |= UDP_FRAME;
+			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
+			break;
+		case IPPROTO_TCP:
+			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
+			break;
+		default:
+			BUG();
+		}
+	} else {
+		/* Errata BTS #50, IHL must be 5 if no HW checksum */
+		cmd_sts |= 5 << TX_IHL_SHIFT;
+		desc->l4i_chk = 0;
 	}
 
-	mp->tx_curr_desc_q = 0;
-	mp->tx_used_desc_q = 0;
+	/* ensure all other descriptors are written before first cmd_sts */
+	wmb();
+	desc->cmd_sts = cmd_sts;
+
+	/* ensure all descriptors are written before poking hardware */
+	wmb();
+	txq_enable(txq);
 
-	mp->tx_desc_area_size = tx_desc_num * sizeof(struct eth_tx_desc);
+	txq->tx_desc_count += nr_frags + 1;
 }
 
-static int mv643xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int err;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct tx_queue *txq;
+	unsigned long flags;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
+		stats->tx_dropped++;
+		dev_printk(KERN_DEBUG, &dev->dev,
+			   "failed to linearize skb with tiny "
+			   "unaligned fragment\n");
+		return NETDEV_TX_BUSY;
+	}
 
-	return err;
-}
+	spin_lock_irqsave(&mp->lock, flags);
 
-static int mv643xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int err;
+	txq = mp->txq + mp->txq_primary;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB) {
+		spin_unlock_irqrestore(&mp->lock, flags);
+		if (txq->index == mp->txq_primary && net_ratelimit())
+			dev_printk(KERN_ERR, &dev->dev,
+				   "primary tx queue full?!\n");
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 
-	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
-	cmd->supported &= ~SUPPORTED_1000baseT_Half;
-	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+	txq_submit_skb(txq, skb);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	dev->trans_start = jiffies;
 
-	return err;
+	if (txq->index == mp->txq_primary) {
+		int entries_left;
+
+		entries_left = txq->tx_ring_size - txq->tx_desc_count;
+		if (entries_left < MAX_DESCS_PER_SKB)
+			netif_stop_queue(dev);
+	}
+
+	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return NETDEV_TX_OK;
 }
 
+
+/* tx rate control **********************************************************/
 /*
- * mv643xx_eth_open
- *
- * This function is called when openning the network device. The function
- * should initialize all the hardware, initialize cyclic Rx/Tx
- * descriptors chain and buffers and allocate an IRQ to the network
- * device.
- *
- * Input :	a pointer to the network device structure
- *
- * Output :	zero of success , nonzero if fails.
+ * Set total maximum TX rate (shared by all TX queues for this port)
+ * to 'rate' bits per second, with a maximum burst of 'burst' bytes.
  */
-
-static int mv643xx_eth_open(struct net_device *dev)
+static void tx_set_rate(struct mv643xx_eth_private *mp, int rate, int burst)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
-	unsigned int size;
-	int err;
+	int token_rate;
+	int mtu;
+	int bucket_size;
 
-	/* Clear any pending ethernet port interrupts */
-	wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
-	wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num));
+	token_rate = ((rate / 1000) * 64) / (mp->shared->t_clk / 1000);
+	if (token_rate > 1023)
+		token_rate = 1023;
 
-	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "%s: Can not assign IRQ\n", dev->name);
-		return -EAGAIN;
-	}
+	mtu = (mp->dev->mtu + 255) >> 8;
+	if (mtu > 63)
+		mtu = 63;
 
-	eth_port_init(mp);
+	bucket_size = (burst + 255) >> 8;
+	if (bucket_size > 65535)
+		bucket_size = 65535;
 
-	memset(&mp->timeout, 0, sizeof(struct timer_list));
-	mp->timeout.function = mv643xx_eth_rx_refill_descs_timer_wrapper;
-	mp->timeout.data = (unsigned long)dev;
-
-	/* Allocate RX and TX skb rings */
-	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
-								GFP_KERNEL);
-	if (!mp->rx_skb) {
-		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
-		err = -ENOMEM;
-		goto out_free_irq;
-	}
-	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
-								GFP_KERNEL);
-	if (!mp->tx_skb) {
-		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
-		err = -ENOMEM;
-		goto out_free_rx_skb;
+	if (mp->shared->tx_bw_control_moved) {
+		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
+		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
+		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
+	} else {
+		wrl(mp, TX_BW_RATE(mp->port_num), token_rate);
+		wrl(mp, TX_BW_MTU(mp->port_num), mtu);
+		wrl(mp, TX_BW_BURST(mp->port_num), bucket_size);
 	}
+}
 
-	/* Allocate TX ring */
-	mp->tx_desc_count = 0;
-	size = mp->tx_ring_size * sizeof(struct eth_tx_desc);
-	mp->tx_desc_area_size = size;
-
-	if (mp->tx_sram_size) {
-		mp->p_tx_desc_area = ioremap(mp->tx_sram_addr,
-							mp->tx_sram_size);
-		mp->tx_desc_dma = mp->tx_sram_addr;
-	} else
-		mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
-							&mp->tx_desc_dma,
-							GFP_KERNEL);
+static void txq_set_rate(struct tx_queue *txq, int rate, int burst)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int token_rate;
+	int bucket_size;
 
-	if (!mp->p_tx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-							dev->name, size);
-		err = -ENOMEM;
-		goto out_free_tx_skb;
-	}
-	BUG_ON((u32) mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
-	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
-
-	ether_init_tx_desc_ring(mp);
-
-	/* Allocate RX ring */
-	mp->rx_desc_count = 0;
-	size = mp->rx_ring_size * sizeof(struct eth_rx_desc);
-	mp->rx_desc_area_size = size;
-
-	if (mp->rx_sram_size) {
-		mp->p_rx_desc_area = ioremap(mp->rx_sram_addr,
-							mp->rx_sram_size);
-		mp->rx_desc_dma = mp->rx_sram_addr;
-	} else
-		mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
-							&mp->rx_desc_dma,
-							GFP_KERNEL);
+	token_rate = ((rate / 1000) * 64) / (mp->shared->t_clk / 1000);
+	if (token_rate > 1023)
+		token_rate = 1023;
 
-	if (!mp->p_rx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
-							dev->name, size);
-		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
-							dev->name);
-		if (mp->rx_sram_size)
-			iounmap(mp->p_tx_desc_area);
-		else
-			dma_free_coherent(NULL, mp->tx_desc_area_size,
-					mp->p_tx_desc_area, mp->tx_desc_dma);
-		err = -ENOMEM;
-		goto out_free_tx_skb;
-	}
-	memset((void *)mp->p_rx_desc_area, 0, size);
+	bucket_size = (burst + 255) >> 8;
+	if (bucket_size > 65535)
+		bucket_size = 65535;
 
-	ether_init_rx_desc_ring(mp);
-
-	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
+	wrl(mp, TXQ_BW_TOKENS(mp->port_num, txq->index), token_rate << 14);
+	wrl(mp, TXQ_BW_CONF(mp->port_num, txq->index),
+			(bucket_size << 10) | token_rate);
+}
 
-#ifdef MV643XX_NAPI
-	napi_enable(&mp->napi);
-#endif
+static void txq_set_fixed_prio_mode(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int off;
+	u32 val;
 
-	eth_port_start(dev);
+	/*
+	 * Turn on fixed priority mode.
+	 */
+	if (mp->shared->tx_bw_control_moved)
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+	else
+		off = TXQ_FIX_PRIO_CONF(mp->port_num);
 
-	/* Interrupt Coalescing */
+	val = rdl(mp, off);
+	val |= 1 << txq->index;
+	wrl(mp, off, val);
+}
 
-#ifdef MV643XX_COAL
-	mp->rx_int_coal =
-		eth_port_set_rx_coal(mp, MV643XX_RX_COAL);
-#endif
+static void txq_set_wrr(struct tx_queue *txq, int weight)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int off;
+	u32 val;
 
-	mp->tx_int_coal =
-		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
+	/*
+	 * Turn off fixed priority mode.
+	 */
+	if (mp->shared->tx_bw_control_moved)
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+	else
+		off = TXQ_FIX_PRIO_CONF(mp->port_num);
 
-	/* Unmask phy and link status changes interrupts */
-	wrl(mp, INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
+	val = rdl(mp, off);
+	val &= ~(1 << txq->index);
+	wrl(mp, off, val);
 
-	/* Unmask RX buffer and TX end interrupt */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	/*
+	 * Configure WRR weight for this queue.
+	 */
+	off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
 
-	return 0;
+	val = rdl(mp, off);
+	val = (val & ~0xff) | (weight & 0xff);
+	wrl(mp, off, val);
+}
 
-out_free_tx_skb:
-	kfree(mp->tx_skb);
-out_free_rx_skb:
-	kfree(mp->rx_skb);
-out_free_irq:
-	free_irq(dev->irq, dev);
 
-	return err;
-}
+/* mii management interface *************************************************/
+#define SMI_BUSY		0x10000000
+#define SMI_READ_VALID		0x08000000
+#define SMI_OPCODE_READ		0x04000000
+#define SMI_OPCODE_WRITE	0x00000000
 
-static void mv643xx_eth_free_tx_rings(struct net_device *dev)
+static void smi_reg_read(struct mv643xx_eth_private *mp, unsigned int addr,
+			 unsigned int reg, unsigned int *value)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
+	unsigned long flags;
+	int i;
 
-	/* Stop Tx Queues */
-	mv643xx_eth_port_disable_tx(mp);
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
-	/* Free outstanding skb's on TX ring */
-	mv643xx_eth_free_all_tx_descs(dev);
+	/* wait for the SMI register to become available */
+	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
+		if (i == 1000) {
+			printk("%s: PHY busy timeout\n", mp->dev->name);
+			goto out;
+		}
+		udelay(10);
+	}
 
-	BUG_ON(mp->tx_used_desc_q != mp->tx_curr_desc_q);
+	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
-	/* Free TX ring */
-	if (mp->tx_sram_size)
-		iounmap(mp->p_tx_desc_area);
-	else
-		dma_free_coherent(NULL, mp->tx_desc_area_size,
-				mp->p_tx_desc_area, mp->tx_desc_dma);
+	/* now wait for the data to be valid */
+	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
+		if (i == 1000) {
+			printk("%s: PHY read timeout\n", mp->dev->name);
+			goto out;
+		}
+		udelay(10);
+	}
+
+	*value = readl(smi_reg) & 0xffff;
+out:
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
-static void mv643xx_eth_free_rx_rings(struct net_device *dev)
+static void smi_reg_write(struct mv643xx_eth_private *mp,
+			  unsigned int addr,
+			  unsigned int reg, unsigned int value)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int curr;
+	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
+	unsigned long flags;
+	int i;
 
-	/* Stop RX Queues */
-	mv643xx_eth_port_disable_rx(mp);
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
-	/* Free preallocated skb's on RX rings */
-	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
-		if (mp->rx_skb[curr]) {
-			dev_kfree_skb(mp->rx_skb[curr]);
-			mp->rx_desc_count--;
+	/* wait for the SMI register to become available */
+	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
+		if (i == 1000) {
+			printk("%s: PHY busy timeout\n", mp->dev->name);
+			goto out;
 		}
+		udelay(10);
 	}
 
-	if (mp->rx_desc_count)
-		printk(KERN_ERR
-			"%s: Error in freeing Rx Ring. %d skb's still"
-			" stuck in RX Ring - ignoring them\n", dev->name,
-			mp->rx_desc_count);
-	/* Free RX ring */
-	if (mp->rx_sram_size)
-		iounmap(mp->p_rx_desc_area);
-	else
-		dma_free_coherent(NULL, mp->rx_desc_area_size,
-				mp->p_rx_desc_area, mp->rx_desc_dma);
+	writel(SMI_OPCODE_WRITE | (reg << 21) |
+		(addr << 16) | (value & 0xffff), smi_reg);
+out:
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
-/*
- * mv643xx_eth_stop
- *
- * This function is used when closing the network device.
- * It updates the hardware,
- * release all memory that holds buffers and descriptors and release the IRQ.
- * Input :	a pointer to the device structure
- * Output :	zero if success , nonzero if fails
- */
 
-static int mv643xx_eth_stop(struct net_device *dev)
+/* mib counters *************************************************************/
+static inline u32 mib_read(struct mv643xx_eth_private *mp, int offset)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
+}
 
-	/* Mask all interrupts on ethernet port */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
-	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+static void mib_counters_clear(struct mv643xx_eth_private *mp)
+{
+	int i;
 
-#ifdef MV643XX_NAPI
-	napi_disable(&mp->napi);
-#endif
-	netif_carrier_off(dev);
-	netif_stop_queue(dev);
+	for (i = 0; i < 0x80; i += 4)
+		mib_read(mp, i);
+}
+
+static void mib_counters_update(struct mv643xx_eth_private *mp)
+{
+	struct mib_counters *p = &mp->mib_counters;
+
+	p->good_octets_received += mib_read(mp, 0x00);
+	p->good_octets_received += (u64)mib_read(mp, 0x04) << 32;
+	p->bad_octets_received += mib_read(mp, 0x08);
+	p->internal_mac_transmit_err += mib_read(mp, 0x0c);
+	p->good_frames_received += mib_read(mp, 0x10);
+	p->bad_frames_received += mib_read(mp, 0x14);
+	p->broadcast_frames_received += mib_read(mp, 0x18);
+	p->multicast_frames_received += mib_read(mp, 0x1c);
+	p->frames_64_octets += mib_read(mp, 0x20);
+	p->frames_65_to_127_octets += mib_read(mp, 0x24);
+	p->frames_128_to_255_octets += mib_read(mp, 0x28);
+	p->frames_256_to_511_octets += mib_read(mp, 0x2c);
+	p->frames_512_to_1023_octets += mib_read(mp, 0x30);
+	p->frames_1024_to_max_octets += mib_read(mp, 0x34);
+	p->good_octets_sent += mib_read(mp, 0x38);
+	p->good_octets_sent += (u64)mib_read(mp, 0x3c) << 32;
+	p->good_frames_sent += mib_read(mp, 0x40);
+	p->excessive_collision += mib_read(mp, 0x44);
+	p->multicast_frames_sent += mib_read(mp, 0x48);
+	p->broadcast_frames_sent += mib_read(mp, 0x4c);
+	p->unrec_mac_control_received += mib_read(mp, 0x50);
+	p->fc_sent += mib_read(mp, 0x54);
+	p->good_fc_received += mib_read(mp, 0x58);
+	p->bad_fc_received += mib_read(mp, 0x5c);
+	p->undersize_received += mib_read(mp, 0x60);
+	p->fragments_received += mib_read(mp, 0x64);
+	p->oversize_received += mib_read(mp, 0x68);
+	p->jabber_received += mib_read(mp, 0x6c);
+	p->mac_receive_error += mib_read(mp, 0x70);
+	p->bad_crc_event += mib_read(mp, 0x74);
+	p->collision += mib_read(mp, 0x78);
+	p->late_collision += mib_read(mp, 0x7c);
+}
+
+
+/* ethtool ******************************************************************/
+struct mv643xx_eth_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int netdev_off;
+	int mp_off;
+};
+
+#define SSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct net_device_stats, m),		\
+	  offsetof(struct net_device, stats.m), -1 }
+
+#define MIBSTAT(m)						\
+	{ #m, FIELD_SIZEOF(struct mib_counters, m),		\
+	  -1, offsetof(struct mv643xx_eth_private, mib_counters.m) }
+
+static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
+	SSTAT(rx_packets),
+	SSTAT(tx_packets),
+	SSTAT(rx_bytes),
+	SSTAT(tx_bytes),
+	SSTAT(rx_errors),
+	SSTAT(tx_errors),
+	SSTAT(rx_dropped),
+	SSTAT(tx_dropped),
+	MIBSTAT(good_octets_received),
+	MIBSTAT(bad_octets_received),
+	MIBSTAT(internal_mac_transmit_err),
+	MIBSTAT(good_frames_received),
+	MIBSTAT(bad_frames_received),
+	MIBSTAT(broadcast_frames_received),
+	MIBSTAT(multicast_frames_received),
+	MIBSTAT(frames_64_octets),
+	MIBSTAT(frames_65_to_127_octets),
+	MIBSTAT(frames_128_to_255_octets),
+	MIBSTAT(frames_256_to_511_octets),
+	MIBSTAT(frames_512_to_1023_octets),
+	MIBSTAT(frames_1024_to_max_octets),
+	MIBSTAT(good_octets_sent),
+	MIBSTAT(good_frames_sent),
+	MIBSTAT(excessive_collision),
+	MIBSTAT(multicast_frames_sent),
+	MIBSTAT(broadcast_frames_sent),
+	MIBSTAT(unrec_mac_control_received),
+	MIBSTAT(fc_sent),
+	MIBSTAT(good_fc_received),
+	MIBSTAT(bad_fc_received),
+	MIBSTAT(undersize_received),
+	MIBSTAT(fragments_received),
+	MIBSTAT(oversize_received),
+	MIBSTAT(jabber_received),
+	MIBSTAT(mac_receive_error),
+	MIBSTAT(bad_crc_event),
+	MIBSTAT(collision),
+	MIBSTAT(late_collision),
+};
 
-	eth_port_reset(mp);
+static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int err;
 
-	mv643xx_eth_free_tx_rings(dev);
-	mv643xx_eth_free_rx_rings(dev);
+	spin_lock_irq(&mp->lock);
+	err = mii_ethtool_gset(&mp->mii, cmd);
+	spin_unlock_irq(&mp->lock);
 
-	free_irq(dev->irq, dev);
+	/*
+	 * The MAC does not support 1000baseT_Half.
+	 */
+	cmd->supported &= ~SUPPORTED_1000baseT_Half;
+	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+
+	return err;
+}
+
+static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->supported = SUPPORTED_MII;
+	cmd->advertising = ADVERTISED_MII;
+	cmd->speed = SPEED_1000;
+	cmd->duplex = DUPLEX_FULL;
+	cmd->port = PORT_MII;
+	cmd->phy_address = 0;
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->maxtxpkt = 1;
+	cmd->maxrxpkt = 1;
 
 	return 0;
 }
 
-#ifdef MV643XX_NAPI
-/*
- * mv643xx_poll
- *
- * This function is used in case of NAPI
- */
-static int mv643xx_poll(struct napi_struct *napi, int budget)
+static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct mv643xx_private *mp = container_of(napi, struct mv643xx_private, napi);
-	struct net_device *dev = mp->dev;
-	unsigned int port_num = mp->port_num;
-	int work_done;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int err;
 
-#ifdef MV643XX_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
-		mv643xx_eth_free_completed_tx_descs(dev);
-		mp->tx_clean_threshold = 0;
-	}
-#endif
+	/*
+	 * The MAC does not support 1000baseT_Half.
+	 */
+	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	work_done = 0;
-	if ((rdl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
-	    != (u32) mp->rx_used_desc_q)
-		work_done = mv643xx_eth_receive_queue(dev, budget);
+	spin_lock_irq(&mp->lock);
+	err = mii_ethtool_sset(&mp->mii, cmd);
+	spin_unlock_irq(&mp->lock);
 
-	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
-		wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
-		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
-	}
+	return err;
+}
 
-	return work_done;
+static int mv643xx_eth_set_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	return -EINVAL;
 }
-#endif
 
-/**
- * has_tiny_unaligned_frags - check if skb has any small, unaligned fragments
- *
- * Hardware can't handle unaligned fragments smaller than 9 bytes.
- * This helper function detects that case.
- */
+static void mv643xx_eth_get_drvinfo(struct net_device *dev,
+				    struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver,  mv643xx_eth_driver_name, 32);
+	strncpy(drvinfo->version, mv643xx_eth_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "platform", 32);
+	drvinfo->n_stats = ARRAY_SIZE(mv643xx_eth_stats);
+}
 
-static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
+static int mv643xx_eth_nway_reset(struct net_device *dev)
 {
-	unsigned int frag;
-	skb_frag_t *fragp;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		fragp = &skb_shinfo(skb)->frags[frag];
-		if (fragp->size <= 8 && fragp->page_offset & 0x7)
-			return 1;
-	}
-	return 0;
+	return mii_nway_restart(&mp->mii);
 }
 
-/**
- * eth_alloc_tx_desc_index - return the index of the next available tx desc
- */
-static int eth_alloc_tx_desc_index(struct mv643xx_private *mp)
+static int mv643xx_eth_nway_reset_phyless(struct net_device *dev)
 {
-	int tx_desc_curr;
-
-	BUG_ON(mp->tx_desc_count >= mp->tx_ring_size);
+	return -EINVAL;
+}
 
-	tx_desc_curr = mp->tx_curr_desc_q;
-	mp->tx_curr_desc_q = (tx_desc_curr + 1) % mp->tx_ring_size;
+static u32 mv643xx_eth_get_link(struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	BUG_ON(mp->tx_curr_desc_q == mp->tx_used_desc_q);
+	return mii_link_ok(&mp->mii);
+}
 
-	return tx_desc_curr;
+static u32 mv643xx_eth_get_link_phyless(struct net_device *dev)
+{
+	return 1;
 }
 
-/**
- * eth_tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
- *
- * Ensure the data for each fragment to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue.
- */
-static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
-				   struct sk_buff *skb)
+static void mv643xx_eth_get_strings(struct net_device *dev,
+				    uint32_t stringset, uint8_t *data)
 {
-	int frag;
-	int tx_index;
-	struct eth_tx_desc *desc;
+	int i;
 
-	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
-
-		tx_index = eth_alloc_tx_desc_index(mp);
-		desc = &mp->p_tx_desc_area[tx_index];
-
-		desc->cmd_sts = ETH_BUFFER_OWNED_BY_DMA;
-		/* Last Frag enables interrupt and frees the skb */
-		if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
-			desc->cmd_sts |= ETH_ZERO_PADDING |
-					 ETH_TX_LAST_DESC |
-					 ETH_TX_ENABLE_INTERRUPT;
-			mp->tx_skb[tx_index] = skb;
-		} else
-			mp->tx_skb[tx_index] = NULL;
-
-		desc = &mp->p_tx_desc_area[tx_index];
-		desc->l4i_chk = 0;
-		desc->byte_cnt = this_frag->size;
-		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
-						this_frag->page_offset,
-						this_frag->size,
-						DMA_TO_DEVICE);
+	if (stringset == ETH_SS_STATS) {
+		for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
+				mv643xx_eth_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+		}
 	}
 }
 
-static inline __be16 sum16_as_be(__sum16 sum)
+static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
+					  struct ethtool_stats *stats,
+					  uint64_t *data)
 {
-	return (__force __be16)sum;
-}
+	struct mv643xx_eth_private *mp = dev->priv;
+	int i;
 
-/**
- * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
- *
- * Ensure the data for an skb to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue and start the hardware.
- */
-static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
-					struct sk_buff *skb)
-{
-	int tx_index;
-	struct eth_tx_desc *desc;
-	u32 cmd_sts;
-	int length;
-	int nr_frags = skb_shinfo(skb)->nr_frags;
+	mib_counters_update(mp);
 
-	cmd_sts = ETH_TX_FIRST_DESC | ETH_GEN_CRC | ETH_BUFFER_OWNED_BY_DMA;
+	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
+		const struct mv643xx_eth_stats *stat;
+		void *p;
 
-	tx_index = eth_alloc_tx_desc_index(mp);
-	desc = &mp->p_tx_desc_area[tx_index];
+		stat = mv643xx_eth_stats + i;
 
-	if (nr_frags) {
-		eth_tx_fill_frag_descs(mp, skb);
+		if (stat->netdev_off >= 0)
+			p = ((void *)mp->dev) + stat->netdev_off;
+		else
+			p = ((void *)mp) + stat->mp_off;
 
-		length = skb_headlen(skb);
-		mp->tx_skb[tx_index] = NULL;
-	} else {
-		cmd_sts |= ETH_ZERO_PADDING |
-			   ETH_TX_LAST_DESC |
-			   ETH_TX_ENABLE_INTERRUPT;
-		length = skb->len;
-		mp->tx_skb[tx_index] = skb;
+		data[i] = (stat->sizeof_stat == 8) ?
+				*(uint64_t *)p : *(uint32_t *)p;
 	}
+}
 
-	desc->byte_cnt = length;
-	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+static int mv643xx_eth_get_sset_count(struct net_device *dev, int sset)
+{
+	if (sset == ETH_SS_STATS)
+		return ARRAY_SIZE(mv643xx_eth_stats);
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != htons(ETH_P_IP));
+	return -EOPNOTSUPP;
+}
 
-		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-			   ETH_GEN_IP_V_4_CHECKSUM  |
-			   ip_hdr(skb)->ihl << ETH_TX_IHL_SHIFT;
+static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
+	.get_settings		= mv643xx_eth_get_settings,
+	.set_settings		= mv643xx_eth_set_settings,
+	.get_drvinfo		= mv643xx_eth_get_drvinfo,
+	.nway_reset		= mv643xx_eth_nway_reset,
+	.get_link		= mv643xx_eth_get_link,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings		= mv643xx_eth_get_strings,
+	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
+	.get_sset_count		= mv643xx_eth_get_sset_count,
+};
 
-		switch (ip_hdr(skb)->protocol) {
-		case IPPROTO_UDP:
-			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
-			break;
-		case IPPROTO_TCP:
-			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
-			break;
-		default:
-			BUG();
-		}
-	} else {
-		/* Errata BTS #50, IHL must be 5 if no HW checksum */
-		cmd_sts |= 5 << ETH_TX_IHL_SHIFT;
-		desc->l4i_chk = 0;
-	}
+static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
+	.get_settings		= mv643xx_eth_get_settings_phyless,
+	.set_settings		= mv643xx_eth_set_settings_phyless,
+	.get_drvinfo		= mv643xx_eth_get_drvinfo,
+	.nway_reset		= mv643xx_eth_nway_reset_phyless,
+	.get_link		= mv643xx_eth_get_link_phyless,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings		= mv643xx_eth_get_strings,
+	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
+	.get_sset_count		= mv643xx_eth_get_sset_count,
+};
 
-	/* ensure all other descriptors are written before first cmd_sts */
-	wmb();
-	desc->cmd_sts = cmd_sts;
 
-	/* ensure all descriptors are written before poking hardware */
-	wmb();
-	mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
+/* address handling *********************************************************/
+static void uc_addr_get(struct mv643xx_eth_private *mp, unsigned char *addr)
+{
+	unsigned int mac_h;
+	unsigned int mac_l;
+
+	mac_h = rdl(mp, MAC_ADDR_HIGH(mp->port_num));
+	mac_l = rdl(mp, MAC_ADDR_LOW(mp->port_num));
 
-	mp->tx_desc_count += nr_frags + 1;
+	addr[0] = (mac_h >> 24) & 0xff;
+	addr[1] = (mac_h >> 16) & 0xff;
+	addr[2] = (mac_h >> 8) & 0xff;
+	addr[3] = mac_h & 0xff;
+	addr[4] = (mac_l >> 8) & 0xff;
+	addr[5] = mac_l & 0xff;
 }
 
-/**
- * mv643xx_eth_start_xmit - queue an skb to the hardware for transmission
- *
- */
-static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static void init_mac_tables(struct mv643xx_eth_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned long flags;
-
-	BUG_ON(netif_queue_stopped(dev));
+	int i;
 
-	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
-		stats->tx_dropped++;
-		printk(KERN_DEBUG "%s: failed to linearize tiny "
-				"unaligned fragment\n", dev->name);
-		return NETDEV_TX_BUSY;
+	for (i = 0; i < 0x100; i += 4) {
+		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, 0);
+		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, 0);
 	}
 
-	spin_lock_irqsave(&mp->lock, flags);
+	for (i = 0; i < 0x10; i += 4)
+		wrl(mp, UNICAST_TABLE(mp->port_num) + i, 0);
+}
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
-		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
-		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&mp->lock, flags);
-		return NETDEV_TX_BUSY;
-	}
+static void set_filter_table_entry(struct mv643xx_eth_private *mp,
+				   int table, unsigned char entry)
+{
+	unsigned int table_reg;
 
-	eth_tx_submit_descs_for_skb(mp, skb);
-	stats->tx_bytes += skb->len;
-	stats->tx_packets++;
-	dev->trans_start = jiffies;
+	/* Set "accepts frame bit" at specified table entry */
+	table_reg = rdl(mp, table + (entry & 0xfc));
+	table_reg |= 0x01 << (8 * (entry & 3));
+	wrl(mp, table + (entry & 0xfc), table_reg);
+}
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB)
-		netif_stop_queue(dev);
+static void uc_addr_set(struct mv643xx_eth_private *mp, unsigned char *addr)
+{
+	unsigned int mac_h;
+	unsigned int mac_l;
+	int table;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	mac_l = (addr[4] << 8) | addr[5];
+	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
 
-	return NETDEV_TX_OK;
+	wrl(mp, MAC_ADDR_LOW(mp->port_num), mac_l);
+	wrl(mp, MAC_ADDR_HIGH(mp->port_num), mac_h);
+
+	table = UNICAST_TABLE(mp->port_num);
+	set_filter_table_entry(mp, table, addr[5] & 0x0f);
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void mv643xx_netpoll(struct net_device *netdev)
+static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 {
-	struct mv643xx_private *mp = netdev_priv(netdev);
-	int port_num = mp->port_num;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
-	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	/* +2 is for the offset of the HW addr type */
+	memcpy(dev->dev_addr, addr + 2, 6);
 
-	mv643xx_eth_int_handler(netdev->irq, netdev);
+	init_mac_tables(mp);
+	uc_addr_set(mp, dev->dev_addr);
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	return 0;
 }
-#endif
 
-static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
-				     int speed, int duplex,
-				     struct ethtool_cmd *cmd)
+static int addr_crc(unsigned char *addr)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	int crc = 0;
+	int i;
 
-	memset(cmd, 0, sizeof(*cmd));
+	for (i = 0; i < 6; i++) {
+		int j;
 
-	cmd->port = PORT_MII;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->phy_address = phy_address;
-
-	if (speed == 0) {
-		cmd->autoneg = AUTONEG_ENABLE;
-		/* mii lib checks, but doesn't use speed on AUTONEG_ENABLE */
-		cmd->speed = SPEED_100;
-		cmd->advertising = ADVERTISED_10baseT_Half  |
-				   ADVERTISED_10baseT_Full  |
-				   ADVERTISED_100baseT_Half |
-				   ADVERTISED_100baseT_Full;
-		if (mp->mii.supports_gmii)
-			cmd->advertising |= ADVERTISED_1000baseT_Full;
-	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->speed = speed;
-		cmd->duplex = duplex;
+		crc = (crc ^ addr[i]) << 8;
+		for (j = 7; j >= 0; j--) {
+			if (crc & (0x100 << j))
+				crc ^= 0x107 << j;
+		}
 	}
+
+	return crc;
 }
 
-/*/
- * mv643xx_eth_probe
- *
- * First function called after registering the network device.
- * It's purpose is to initialize the device as an ethernet device,
- * fill the ethernet device structure with pointers * to functions,
- * and set the MAC address of the interface
- *
- * Input :	struct device *
- * Output :	-ENOMEM if failed , 0 if success
- */
-static int mv643xx_eth_probe(struct platform_device *pdev)
+static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	struct mv643xx_eth_platform_data *pd;
-	int port_num;
-	struct mv643xx_private *mp;
-	struct net_device *dev;
-	u8 *p;
-	struct resource *res;
-	int err;
-	struct ethtool_cmd cmd;
-	int duplex = DUPLEX_HALF;
-	int speed = 0;			/* default to auto-negotiation */
-	DECLARE_MAC_BUF(mac);
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	u32 port_config;
+	struct dev_addr_list *addr;
+	int i;
 
-	pd = pdev->dev.platform_data;
-	if (pd == NULL) {
-		printk(KERN_ERR "No mv643xx_eth_platform_data\n");
-		return -ENODEV;
+	port_config = rdl(mp, PORT_CONFIG(mp->port_num));
+	if (dev->flags & IFF_PROMISC)
+		port_config |= UNICAST_PROMISCUOUS_MODE;
+	else
+		port_config &= ~UNICAST_PROMISCUOUS_MODE;
+	wrl(mp, PORT_CONFIG(mp->port_num), port_config);
+
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		int port_num = mp->port_num;
+		u32 accept = 0x01010101;
+
+		for (i = 0; i < 0x100; i += 4) {
+			wrl(mp, SPECIAL_MCAST_TABLE(port_num) + i, accept);
+			wrl(mp, OTHER_MCAST_TABLE(port_num) + i, accept);
+		}
+		return;
 	}
 
-	if (pd->shared == NULL) {
-		printk(KERN_ERR "No mv643xx_eth_platform_data->shared\n");
-		return -ENODEV;
+	for (i = 0; i < 0x100; i += 4) {
+		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, 0);
+		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, 0);
 	}
 
-	dev = alloc_etherdev(sizeof(struct mv643xx_private));
-	if (!dev)
-		return -ENOMEM;
+	for (addr = dev->mc_list; addr != NULL; addr = addr->next) {
+		u8 *a = addr->da_addr;
+		int table;
 
-	platform_set_drvdata(pdev, dev);
+		if (addr->da_addrlen != 6)
+			continue;
 
-	mp = netdev_priv(dev);
-	mp->dev = dev;
-#ifdef MV643XX_NAPI
-	netif_napi_add(dev, &mp->napi, mv643xx_poll, 64);
-#endif
+		if (memcmp(a, "\x01\x00\x5e\x00\x00", 5) == 0) {
+			table = SPECIAL_MCAST_TABLE(mp->port_num);
+			set_filter_table_entry(mp, table, a[5]);
+		} else {
+			int crc = addr_crc(a);
 
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	BUG_ON(!res);
-	dev->irq = res->start;
+			table = OTHER_MCAST_TABLE(mp->port_num);
+			set_filter_table_entry(mp, table, crc);
+		}
+	}
+}
 
-	dev->open = mv643xx_eth_open;
-	dev->stop = mv643xx_eth_stop;
-	dev->hard_start_xmit = mv643xx_eth_start_xmit;
-	dev->set_mac_address = mv643xx_eth_set_mac_address;
-	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
 
-	/* No need to Tx Timeout */
-	dev->tx_timeout = mv643xx_eth_tx_timeout;
+/* rx/tx queue initialisation ***********************************************/
+static int rxq_init(struct mv643xx_eth_private *mp, int index)
+{
+	struct rx_queue *rxq = mp->rxq + index;
+	struct rx_desc *rx_desc;
+	int size;
+	int i;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = mv643xx_netpoll;
-#endif
+	rxq->index = index;
 
-	dev->watchdog_timeo = 2 * HZ;
-	dev->base_addr = 0;
-	dev->change_mtu = mv643xx_eth_change_mtu;
-	dev->do_ioctl = mv643xx_eth_do_ioctl;
-	SET_ETHTOOL_OPS(dev, &mv643xx_ethtool_ops);
+	rxq->rx_ring_size = mp->default_rx_ring_size;
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
-#ifdef MAX_SKB_FRAGS
-	/*
-	 * Zero copy can only work if we use Discovery II memory. Else, we will
-	 * have to map the buffers to ISA memory which is only 16 MB
-	 */
-	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
-#endif
-#endif
+	rxq->rx_desc_count = 0;
+	rxq->rx_curr_desc = 0;
+	rxq->rx_used_desc = 0;
 
-	/* Configure the timeout task */
-	INIT_WORK(&mp->tx_timeout_task, mv643xx_eth_tx_timeout_task);
+	size = rxq->rx_ring_size * sizeof(struct rx_desc);
 
-	spin_lock_init(&mp->lock);
+	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size) {
+		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_addr,
+						mp->rx_desc_sram_size);
+		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
+	} else {
+		rxq->rx_desc_area = dma_alloc_coherent(NULL, size,
+							&rxq->rx_desc_dma,
+							GFP_KERNEL);
+	}
 
-	mp->shared = platform_get_drvdata(pd->shared);
-	port_num = mp->port_num = pd->port_number;
+	if (rxq->rx_desc_area == NULL) {
+		dev_printk(KERN_ERR, &mp->dev->dev,
+			   "can't allocate rx ring (%d bytes)\n", size);
+		goto out;
+	}
+	memset(rxq->rx_desc_area, 0, size);
 
-	if (mp->shared->win_protect)
-		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
+	rxq->rx_desc_area_size = size;
+	rxq->rx_skb = kmalloc(rxq->rx_ring_size * sizeof(*rxq->rx_skb),
+								GFP_KERNEL);
+	if (rxq->rx_skb == NULL) {
+		dev_printk(KERN_ERR, &mp->dev->dev,
+			   "can't allocate rx skb ring\n");
+		goto out_free;
+	}
 
-	mp->shared_smi = mp->shared;
-	if (pd->shared_smi != NULL)
-		mp->shared_smi = platform_get_drvdata(pd->shared_smi);
+	rx_desc = (struct rx_desc *)rxq->rx_desc_area;
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		int nexti = (i + 1) % rxq->rx_ring_size;
+		rx_desc[i].next_desc_ptr = rxq->rx_desc_dma +
+					nexti * sizeof(struct rx_desc);
+	}
 
-	/* set default config values */
-	eth_port_uc_addr_get(mp, dev->dev_addr);
-	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
-	mp->tx_ring_size = PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+	init_timer(&rxq->rx_oom);
+	rxq->rx_oom.data = (unsigned long)rxq;
+	rxq->rx_oom.function = rxq_refill_timer_wrapper;
 
-	if (is_valid_ether_addr(pd->mac_addr))
-		memcpy(dev->dev_addr, pd->mac_addr, 6);
+	return 0;
 
-	if (pd->phy_addr || pd->force_phy_addr)
-		ethernet_phy_set(mp, pd->phy_addr);
 
-	if (pd->rx_queue_size)
-		mp->rx_ring_size = pd->rx_queue_size;
+out_free:
+	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
+	else
+		dma_free_coherent(NULL, size,
+				  rxq->rx_desc_area,
+				  rxq->rx_desc_dma);
 
-	if (pd->tx_queue_size)
-		mp->tx_ring_size = pd->tx_queue_size;
+out:
+	return -ENOMEM;
+}
 
-	if (pd->tx_sram_size) {
-		mp->tx_sram_size = pd->tx_sram_size;
-		mp->tx_sram_addr = pd->tx_sram_addr;
-	}
+static void rxq_deinit(struct rx_queue *rxq)
+{
+	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	int i;
 
-	if (pd->rx_sram_size) {
-		mp->rx_sram_size = pd->rx_sram_size;
-		mp->rx_sram_addr = pd->rx_sram_addr;
-	}
+	rxq_disable(rxq);
 
-	duplex = pd->duplex;
-	speed = pd->speed;
+	del_timer_sync(&rxq->rx_oom);
 
-	/* Hook up MII support for ethtool */
-	mp->mii.dev = dev;
-	mp->mii.mdio_read = mv643xx_mdio_read;
-	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(mp);
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		if (rxq->rx_skb[i]) {
+			dev_kfree_skb(rxq->rx_skb[i]);
+			rxq->rx_desc_count--;
+		}
+	}
 
-	err = ethernet_phy_detect(mp);
-	if (err) {
-		pr_debug("%s: No PHY detected at addr %d\n",
-				dev->name, ethernet_phy_get(mp));
-		goto out;
+	if (rxq->rx_desc_count) {
+		dev_printk(KERN_ERR, &mp->dev->dev,
+			   "error freeing rx ring -- %d skbs stuck\n",
+			   rxq->rx_desc_count);
 	}
 
-	ethernet_phy_reset(mp);
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
-	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
-	mv643xx_eth_update_pscr(dev, &cmd);
-	mv643xx_set_settings(dev, &cmd);
+	if (rxq->index == mp->rxq_primary &&
+	    rxq->rx_desc_area_size <= mp->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
+	else
+		dma_free_coherent(NULL, rxq->rx_desc_area_size,
+				  rxq->rx_desc_area, rxq->rx_desc_dma);
 
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	err = register_netdev(dev);
-	if (err)
-		goto out;
+	kfree(rxq->rx_skb);
+}
 
-	p = dev->dev_addr;
-	printk(KERN_NOTICE
-		"%s: port %d with MAC address %s\n",
-		dev->name, port_num, print_mac(mac, p));
+static int txq_init(struct mv643xx_eth_private *mp, int index)
+{
+	struct tx_queue *txq = mp->txq + index;
+	struct tx_desc *tx_desc;
+	int size;
+	int i;
 
-	if (dev->features & NETIF_F_SG)
-		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
+	txq->index = index;
 
-	if (dev->features & NETIF_F_IP_CSUM)
-		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
-								dev->name);
+	txq->tx_ring_size = mp->default_tx_ring_size;
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
-	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
-#endif
+	txq->tx_desc_count = 0;
+	txq->tx_curr_desc = 0;
+	txq->tx_used_desc = 0;
 
-#ifdef MV643XX_COAL
-	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
-								dev->name);
-#endif
+	size = txq->tx_ring_size * sizeof(struct tx_desc);
 
-#ifdef MV643XX_NAPI
-	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
-#endif
+	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size) {
+		txq->tx_desc_area = ioremap(mp->tx_desc_sram_addr,
+						mp->tx_desc_sram_size);
+		txq->tx_desc_dma = mp->tx_desc_sram_addr;
+	} else {
+		txq->tx_desc_area = dma_alloc_coherent(NULL, size,
+							&txq->tx_desc_dma,
+							GFP_KERNEL);
+	}
+
+	if (txq->tx_desc_area == NULL) {
+		dev_printk(KERN_ERR, &mp->dev->dev,
+			   "can't allocate tx ring (%d bytes)\n", size);
+		goto out;
+	}
+	memset(txq->tx_desc_area, 0, size);
 
-	if (mp->tx_sram_size > 0)
-		printk(KERN_NOTICE "%s: Using SRAM\n", dev->name);
+	txq->tx_desc_area_size = size;
+	txq->tx_skb = kmalloc(txq->tx_ring_size * sizeof(*txq->tx_skb),
+								GFP_KERNEL);
+	if (txq->tx_skb == NULL) {
+		dev_printk(KERN_ERR, &mp->dev->dev,
+			   "can't allocate tx skb ring\n");
+		goto out_free;
+	}
+
+	tx_desc = (struct tx_desc *)txq->tx_desc_area;
+	for (i = 0; i < txq->tx_ring_size; i++) {
+		int nexti = (i + 1) % txq->tx_ring_size;
+		tx_desc[i].next_desc_ptr = txq->tx_desc_dma +
+					nexti * sizeof(struct tx_desc);
+	}
 
 	return 0;
 
-out:
-	free_netdev(dev);
 
-	return err;
+out_free:
+	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(NULL, size,
+				  txq->tx_desc_area,
+				  txq->tx_desc_dma);
+
+out:
+	return -ENOMEM;
 }
 
-static int mv643xx_eth_remove(struct platform_device *pdev)
+static void txq_reclaim(struct tx_queue *txq, int force)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	unsigned long flags;
 
-	unregister_netdev(dev);
-	flush_scheduled_work();
+	spin_lock_irqsave(&mp->lock, flags);
+	while (txq->tx_desc_count > 0) {
+		int tx_index;
+		struct tx_desc *desc;
+		u32 cmd_sts;
+		struct sk_buff *skb;
+		dma_addr_t addr;
+		int count;
+
+		tx_index = txq->tx_used_desc;
+		desc = &txq->tx_desc_area[tx_index];
+		cmd_sts = desc->cmd_sts;
 
-	free_netdev(dev);
-	platform_set_drvdata(pdev, NULL);
-	return 0;
-}
+		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA))
+			break;
 
-static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
-					  struct mbus_dram_target_info *dram)
-{
-	void __iomem *base = msp->eth_base;
-	u32 win_enable;
-	u32 win_protect;
-	int i;
+		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
+		txq->tx_desc_count--;
 
-	for (i = 0; i < 6; i++) {
-		writel(0, base + WINDOW_BASE(i));
-		writel(0, base + WINDOW_SIZE(i));
-		if (i < 4)
-			writel(0, base + WINDOW_REMAP_HIGH(i));
-	}
+		addr = desc->buf_ptr;
+		count = desc->byte_cnt;
+		skb = txq->tx_skb[tx_index];
+		txq->tx_skb[tx_index] = NULL;
 
-	win_enable = 0x3f;
-	win_protect = 0;
+		if (cmd_sts & ERROR_SUMMARY) {
+			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
+			mp->dev->stats.tx_errors++;
+		}
 
-	for (i = 0; i < dram->num_cs; i++) {
-		struct mbus_dram_window *cs = dram->cs + i;
+		/*
+		 * Drop mp->lock while we free the skb.
+		 */
+		spin_unlock_irqrestore(&mp->lock, flags);
 
-		writel((cs->base & 0xffff0000) |
-			(cs->mbus_attr << 8) |
-			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
-		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
+		if (cmd_sts & TX_FIRST_DESC)
+			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
+		else
+			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
 
-		win_enable &= ~(1 << i);
-		win_protect |= 3 << (2 * i);
-	}
+		if (skb)
+			dev_kfree_skb_irq(skb);
 
-	writel(win_enable, base + WINDOW_BAR_ENABLE);
-	msp->win_protect = win_protect;
+		spin_lock_irqsave(&mp->lock, flags);
+	}
+	spin_unlock_irqrestore(&mp->lock, flags);
 }
 
-static int mv643xx_eth_shared_probe(struct platform_device *pdev)
+static void txq_deinit(struct tx_queue *txq)
 {
-	static int mv643xx_version_printed = 0;
-	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
-	struct mv643xx_shared_private *msp;
-	struct resource *res;
-	int ret;
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 
-	if (!mv643xx_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+	txq_disable(txq);
+	txq_reclaim(txq, 1);
 
-	ret = -EINVAL;
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL)
-		goto out;
+	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-	ret = -ENOMEM;
-	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
-	if (msp == NULL)
-		goto out;
-	memset(msp, 0, sizeof(*msp));
+	if (txq->index == mp->txq_primary &&
+	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(NULL, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
 
-	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
-	if (msp->eth_base == NULL)
-		goto out_free;
+	kfree(txq->tx_skb);
+}
 
-	spin_lock_init(&msp->phy_lock);
-	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
 
-	platform_set_drvdata(pdev, msp);
+/* netdev ops and related ***************************************************/
+static void update_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
+{
+	u32 pscr_o;
+	u32 pscr_n;
 
-	/*
-	 * (Re-)program MBUS remapping windows if we are asked to.
-	 */
-	if (pd != NULL && pd->dram != NULL)
-		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
+	pscr_o = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
 
-	return 0;
+	/* clear speed, duplex and rx buffer size fields */
+	pscr_n = pscr_o & ~(SET_MII_SPEED_TO_100   |
+			    SET_GMII_SPEED_TO_1000 |
+			    SET_FULL_DUPLEX_MODE   |
+			    MAX_RX_PACKET_MASK);
 
-out_free:
-	kfree(msp);
-out:
-	return ret;
-}
+	if (speed == SPEED_1000) {
+		pscr_n |= SET_GMII_SPEED_TO_1000 | MAX_RX_PACKET_9700BYTE;
+	} else {
+		if (speed == SPEED_100)
+			pscr_n |= SET_MII_SPEED_TO_100;
+		pscr_n |= MAX_RX_PACKET_1522BYTE;
+	}
 
-static int mv643xx_eth_shared_remove(struct platform_device *pdev)
-{
-	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
+	if (duplex == DUPLEX_FULL)
+		pscr_n |= SET_FULL_DUPLEX_MODE;
 
-	iounmap(msp->eth_base);
-	kfree(msp);
+	if (pscr_n != pscr_o) {
+		if ((pscr_o & SERIAL_PORT_ENABLE) == 0)
+			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
+		else {
+			int i;
 
-	return 0;
+			for (i = 0; i < 8; i++)
+				if (mp->txq_mask & (1 << i))
+					txq_disable(mp->txq + i);
+
+			pscr_o &= ~SERIAL_PORT_ENABLE;
+			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_o);
+			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
+			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
+
+			for (i = 0; i < 8; i++)
+				if (mp->txq_mask & (1 << i))
+					txq_enable(mp->txq + i);
+		}
+	}
 }
 
-static void mv643xx_eth_shutdown(struct platform_device *pdev)
+static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 {
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	u32 int_cause;
+	u32 int_cause_ext;
+	u32 txq_active;
+
+	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
+			(INT_TX_END | INT_RX | INT_EXT);
+	if (int_cause == 0)
+		return IRQ_NONE;
 
-	/* Mask all interrupts on ethernet port */
-	wrl(mp, INTERRUPT_MASK_REG(port_num), 0);
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	int_cause_ext = 0;
+	if (int_cause & INT_EXT) {
+		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num))
+				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
+	}
 
-	eth_port_reset(mp);
-}
+	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
+		if (mp->phy_addr == -1 || mii_link_ok(&mp->mii)) {
+			int i;
 
-static struct platform_driver mv643xx_eth_driver = {
-	.probe = mv643xx_eth_probe,
-	.remove = mv643xx_eth_remove,
-	.shutdown = mv643xx_eth_shutdown,
-	.driver = {
-		.name = MV643XX_ETH_NAME,
-		.owner	= THIS_MODULE,
-	},
-};
+			if (mp->phy_addr != -1) {
+				struct ethtool_cmd cmd;
 
-static struct platform_driver mv643xx_eth_shared_driver = {
-	.probe = mv643xx_eth_shared_probe,
-	.remove = mv643xx_eth_shared_remove,
-	.driver = {
-		.name = MV643XX_ETH_SHARED_NAME,
-		.owner	= THIS_MODULE,
-	},
-};
+				mii_ethtool_gset(&mp->mii, &cmd);
+				update_pscr(mp, cmd.speed, cmd.duplex);
+			}
 
-/*
- * mv643xx_init_module
- *
- * Registers the network drivers into the Linux kernel
- *
- * Input :	N/A
- *
- * Output :	N/A
- */
-static int __init mv643xx_init_module(void)
-{
-	int rc;
+			for (i = 0; i < 8; i++)
+				if (mp->txq_mask & (1 << i))
+					txq_enable(mp->txq + i);
 
-	rc = platform_driver_register(&mv643xx_eth_shared_driver);
-	if (!rc) {
-		rc = platform_driver_register(&mv643xx_eth_driver);
-		if (rc)
-			platform_driver_unregister(&mv643xx_eth_shared_driver);
+			if (!netif_carrier_ok(dev)) {
+				netif_carrier_on(dev);
+				__txq_maybe_wake(mp->txq + mp->txq_primary);
+			}
+		} else if (netif_carrier_ok(dev)) {
+			netif_stop_queue(dev);
+			netif_carrier_off(dev);
+		}
 	}
-	return rc;
-}
 
-/*
- * mv643xx_cleanup_module
- *
- * Registers the network drivers into the Linux kernel
- *
- * Input :	N/A
- *
- * Output :	N/A
- */
-static void __exit mv643xx_cleanup_module(void)
-{
-	platform_driver_unregister(&mv643xx_eth_driver);
-	platform_driver_unregister(&mv643xx_eth_shared_driver);
-}
+	/*
+	 * RxBuffer or RxError set for any of the 8 queues?
+	 */
+#ifdef MV643XX_ETH_NAPI
+	if (int_cause & INT_RX) {
+		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
+		rdl(mp, INT_MASK(mp->port_num));
 
-module_init(mv643xx_init_module);
-module_exit(mv643xx_cleanup_module);
+		netif_rx_schedule(dev, &mp->napi);
+	}
+#else
+	if (int_cause & INT_RX) {
+		int i;
 
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
-		" and Dale Farnsworth");
-MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
-MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
-MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
+		for (i = 7; i >= 0; i--)
+			if (mp->rxq_mask & (1 << i))
+				rxq_process(mp->rxq + i, INT_MAX);
+	}
+#endif
 
-/*
- * The second part is the low level driver of the gigE ethernet ports.
- */
+	txq_active = rdl(mp, TXQ_COMMAND(mp->port_num));
 
-/*
- * Marvell's Gigabit Ethernet controller low level driver
- *
- * DESCRIPTION:
- *	This file introduce low level API to Marvell's Gigabit Ethernet
- *		controller. This Gigabit Ethernet Controller driver API controls
- *		1) Operations (i.e. port init, start, reset etc').
- *		2) Data flow (i.e. port send, receive etc').
- *		Each Gigabit Ethernet port is controlled via
- *		struct mv643xx_private.
- *		This struct includes user configuration information as well as
- *		driver internal data needed for its operations.
- *
- *		Supported Features:
- *		- This low level driver is OS independent. Allocating memory for
- *		  the descriptor rings and buffers are not within the scope of
- *		  this driver.
- *		- The user is free from Rx/Tx queue managing.
- *		- This low level driver introduce functionality API that enable
- *		  the to operate Marvell's Gigabit Ethernet Controller in a
- *		  convenient way.
- *		- Simple Gigabit Ethernet port operation API.
- *		- Simple Gigabit Ethernet port data flow API.
- *		- Data flow and operation API support per queue functionality.
- *		- Support cached descriptors for better performance.
- *		- Enable access to all four DRAM banks and internal SRAM memory
- *		  spaces.
- *		- PHY access and control API.
- *		- Port control register configuration API.
- *		- Full control over Unicast and Multicast MAC configurations.
- *
- *		Operation flow:
- *
- *		Initialization phase
- *		This phase complete the initialization of the the
- *		mv643xx_private struct.
- *		User information regarding port configuration has to be set
- *		prior to calling the port initialization routine.
- *
- *		In this phase any port Tx/Rx activity is halted, MIB counters
- *		are cleared, PHY address is set according to user parameter and
- *		access to DRAM and internal SRAM memory spaces.
- *
- *		Driver ring initialization
- *		Allocating memory for the descriptor rings and buffers is not
- *		within the scope of this driver. Thus, the user is required to
- *		allocate memory for the descriptors ring and buffers. Those
- *		memory parameters are used by the Rx and Tx ring initialization
- *		routines in order to curve the descriptor linked list in a form
- *		of a ring.
- *		Note: Pay special attention to alignment issues when using
- *		cached descriptors/buffers. In this phase the driver store
- *		information in the mv643xx_private struct regarding each queue
- *		ring.
- *
- *		Driver start
- *		This phase prepares the Ethernet port for Rx and Tx activity.
- *		It uses the information stored in the mv643xx_private struct to
- *		initialize the various port registers.
- *
- *		Data flow:
- *		All packet references to/from the driver are done using
- *		struct pkt_info.
- *		This struct is a unified struct used with Rx and Tx operations.
- *		This way the user is not required to be familiar with neither
- *		Tx nor Rx descriptors structures.
- *		The driver's descriptors rings are management by indexes.
- *		Those indexes controls the ring resources and used to indicate
- *		a SW resource error:
- *		'current'
- *		This index points to the current available resource for use. For
- *		example in Rx process this index will point to the descriptor
- *		that will be passed to the user upon calling the receive
- *		routine.  In Tx process, this index will point to the descriptor
- *		that will be assigned with the user packet info and transmitted.
- *		'used'
- *		This index points to the descriptor that need to restore its
- *		resources. For example in Rx process, using the Rx buffer return
- *		API will attach the buffer returned in packet info to the
- *		descriptor pointed by 'used'. In Tx process, using the Tx
- *		descriptor return will merely return the user packet info with
- *		the command status of the transmitted buffer pointed by the
- *		'used' index. Nevertheless, it is essential to use this routine
- *		to update the 'used' index.
- *		'first'
- *		This index supports Tx Scatter-Gather. It points to the first
- *		descriptor of a packet assembled of multiple buffers. For
- *		example when in middle of Such packet we have a Tx resource
- *		error the 'curr' index get the value of 'first' to indicate
- *		that the ring returned to its state before trying to transmit
- *		this packet.
- *
- *		Receive operation:
- *		The eth_port_receive API set the packet information struct,
- *		passed by the caller, with received information from the
- *		'current' SDMA descriptor.
- *		It is the user responsibility to return this resource back
- *		to the Rx descriptor ring to enable the reuse of this source.
- *		Return Rx resource is done using the eth_rx_return_buff API.
- *
- *	Prior to calling the initialization routine eth_port_init() the user
- *	must set the following fields under mv643xx_private struct:
- *	port_num		User Ethernet port number.
- *	port_config		User port configuration value.
- *	port_config_extend	User port config extend value.
- *	port_sdma_config	User port SDMA config value.
- *	port_serial_control	User port serial control value.
- *
- *		This driver data flow is done using the struct pkt_info which
- *		is a unified struct for Rx and Tx operations:
- *
- *		byte_cnt	Tx/Rx descriptor buffer byte count.
- *		l4i_chk		CPU provided TCP Checksum. For Tx operation
- *				only.
- *		cmd_sts		Tx/Rx descriptor command status.
- *		buf_ptr		Tx/Rx descriptor buffer pointer.
- *		return_info	Tx/Rx user resource return information.
- */
+	/*
+	 * TxBuffer or TxError set for any of the 8 queues?
+	 */
+	if (int_cause_ext & INT_EXT_TX) {
+		int i;
 
-/* Ethernet Port routines */
-static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
-					    int table, unsigned char entry);
+		for (i = 0; i < 8; i++)
+			if (mp->txq_mask & (1 << i))
+				txq_reclaim(mp->txq + i, 0);
+	}
 
-/*
- * eth_port_init - Initialize the Ethernet port driver
- *
- * DESCRIPTION:
- *	This function prepares the ethernet port to start its activity:
- *	1) Completes the ethernet port driver struct initialization toward port
- *		start routine.
- *	2) Resets the device to a quiescent state in case of warm reboot.
- *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
- *	4) Clean MAC tables. The reset status of those tables is unknown.
- *	5) Set PHY address.
- *	Note: Call this routine prior to eth_port_start routine and after
- *	setting user values in the user fields of Ethernet port control
- *	struct.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet port control struct
- *
- * OUTPUT:
- *	See description.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_init(struct mv643xx_private *mp)
-{
-	mp->rx_resource_err = 0;
+	/*
+	 * Any TxEnd interrupts?
+	 */
+	if (int_cause & INT_TX_END) {
+		int i;
+
+		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
+		for (i = 0; i < 8; i++) {
+			struct tx_queue *txq = mp->txq + i;
+			if (txq->tx_desc_count && !((txq_active >> i) & 1))
+				txq_enable(txq);
+		}
+	}
 
-	eth_port_reset(mp);
+	/*
+	 * Enough space again in the primary TX queue for a full packet?
+	 */
+	if (int_cause_ext & INT_EXT_TX) {
+		struct tx_queue *txq = mp->txq + mp->txq_primary;
+		__txq_maybe_wake(txq);
+	}
 
-	eth_port_init_mac_tables(mp);
+	return IRQ_HANDLED;
 }
 
-/*
- * eth_port_start - Start the Ethernet port activity.
- *
- * DESCRIPTION:
- *	This routine prepares the Ethernet port for Rx and Tx activity:
- *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
- *	    has been initialized a descriptor's ring (using
- *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
- *	 2. Initialize and enable the Ethernet configuration port by writing to
- *	    the port's configuration and command registers.
- *	 3. Initialize and enable the SDMA by writing to the SDMA's
- *	    configuration and command registers.  After completing these steps,
- *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
- *
- *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *	to calling this function (use ether_init_tx_desc_ring for Tx queues
- *	and ether_init_rx_desc_ring for Rx queues).
- *
- * INPUT:
- *	dev - a pointer to the required interface
- *
- * OUTPUT:
- *	Ethernet port is ready to receive and transmit.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_start(struct net_device *dev)
+static void phy_reset(struct mv643xx_eth_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
-	int tx_curr_desc, rx_curr_desc;
-	u32 pscr;
-	struct ethtool_cmd ethtool_cmd;
-
-	/* Assignment of Tx CTRP of given queue */
-	tx_curr_desc = mp->tx_curr_desc_q;
-	wrl(mp, TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
-
-	/* Assignment of Rx CRDP of given queue */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	wrl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+	unsigned int data;
 
-	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(mp, dev->dev_addr);
+	smi_reg_read(mp, mp->phy_addr, 0, &data);
+	data |= 0x8000;
+	smi_reg_write(mp, mp->phy_addr, 0, data);
 
-	/* Assign port configuration and command. */
-	wrl(mp, PORT_CONFIG_REG(port_num),
-			  PORT_CONFIG_DEFAULT_VALUE);
-
-	wrl(mp, PORT_CONFIG_EXTEND_REG(port_num),
-			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+	do {
+		udelay(1);
+		smi_reg_read(mp, mp->phy_addr, 0, &data);
+	} while (data & 0x8000);
+}
 
-	pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+static void port_start(struct mv643xx_eth_private *mp)
+{
+	u32 pscr;
+	int i;
 
+	/*
+	 * Configure basic link parameters.
+	 */
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
 	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
-
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLX     |
-		DO_NOT_FORCE_LINK_FAIL	   |
+		DISABLE_AUTO_NEG_FOR_DUPLEX    |
+		DO_NOT_FORCE_LINK_FAIL	       |
 		SERIAL_PORT_CONTROL_RESERVED;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	pscr |= SERIAL_PORT_ENABLE;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
 
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
-	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	/*
+	 * Perform PHY reset, if there is a PHY.
+	 */
+	if (mp->phy_addr != -1) {
+		struct ethtool_cmd cmd;
 
-	/* Assign port SDMA configuration */
-	wrl(mp, SDMA_CONFIG_REG(port_num),
-			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
+		mv643xx_eth_get_settings(mp->dev, &cmd);
+		phy_reset(mp);
+		mv643xx_eth_set_settings(mp->dev, &cmd);
+	}
 
-	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
+	/*
+	 * Configure TX path and queues.
+	 */
+	tx_set_rate(mp, 1000000000, 16777216);
+	for (i = 0; i < 8; i++) {
+		struct tx_queue *txq = mp->txq + i;
+		int off = TXQ_CURRENT_DESC_PTR(mp->port_num, i);
+		u32 addr;
 
-	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+		if ((mp->txq_mask & (1 << i)) == 0)
+			continue;
 
-	/* save phy settings across reset */
-	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp);
-	mv643xx_set_settings(dev, &ethtool_cmd);
-}
+		addr = (u32)txq->tx_desc_dma;
+		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
+		wrl(mp, off, addr);
 
-/*
- * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
- */
-static void eth_port_uc_addr_set(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-	int table;
+		txq_set_rate(txq, 1000000000, 16777216);
+		txq_set_fixed_prio_mode(txq);
+	}
 
-	mac_l = (p_addr[4] << 8) | (p_addr[5]);
-	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
-							(p_addr[3] << 0);
+	/*
+	 * Add configured unicast address to address filter table.
+	 */
+	uc_addr_set(mp, mp->dev->dev_addr);
 
-	wrl(mp, MAC_ADDR_LOW(port_num), mac_l);
-	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
+	/*
+	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
+	 * frames to RX queue #0.
+	 */
+	wrl(mp, PORT_CONFIG(mp->port_num), 0x00000000);
 
-	/* Accept frames with this address */
-	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
-	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
-}
+	/*
+	 * Treat BPDUs as normal multicasts, and disable partition mode.
+	 */
+	wrl(mp, PORT_CONFIG_EXT(mp->port_num), 0x00000000);
 
-/*
- * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
- */
-static void eth_port_uc_addr_get(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
+	/*
+	 * Enable the receive queues.
+	 */
+	for (i = 0; i < 8; i++) {
+		struct rx_queue *rxq = mp->rxq + i;
+		int off = RXQ_CURRENT_DESC_PTR(mp->port_num, i);
+		u32 addr;
+
+		if ((mp->rxq_mask & (1 << i)) == 0)
+			continue;
 
-	mac_h = rdl(mp, MAC_ADDR_HIGH(port_num));
-	mac_l = rdl(mp, MAC_ADDR_LOW(port_num));
+		addr = (u32)rxq->rx_desc_dma;
+		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
+		wrl(mp, off, addr);
 
-	p_addr[0] = (mac_h >> 24) & 0xff;
-	p_addr[1] = (mac_h >> 16) & 0xff;
-	p_addr[2] = (mac_h >> 8) & 0xff;
-	p_addr[3] = mac_h & 0xff;
-	p_addr[4] = (mac_l >> 8) & 0xff;
-	p_addr[5] = mac_l & 0xff;
+		rxq_enable(rxq);
+	}
 }
 
-/*
- * The entries in each table are indexed by a hash of a packet's MAC
- * address.  One bit in each entry determines whether the packet is
- * accepted.  There are 4 entries (each 8 bits wide) in each register
- * of the table.  The bits in each entry are defined as follows:
- *	0	Accept=1, Drop=0
- *	3-1	Queue			(ETH_Q0=0)
- *	7-4	Reserved = 0;
- */
-static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
-					    int table, unsigned char entry)
+static void set_rx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
 {
-	unsigned int table_reg;
-	unsigned int tbl_offset;
-	unsigned int reg_offset;
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
+	u32 val;
+
+	val = rdl(mp, SDMA_CONFIG(mp->port_num));
+	if (mp->shared->extended_rx_coal_limit) {
+		if (coal > 0xffff)
+			coal = 0xffff;
+		val &= ~0x023fff80;
+		val |= (coal & 0x8000) << 10;
+		val |= (coal & 0x7fff) << 7;
+	} else {
+		if (coal > 0x3fff)
+			coal = 0x3fff;
+		val &= ~0x003fff00;
+		val |= (coal & 0x3fff) << 8;
+	}
+	wrl(mp, SDMA_CONFIG(mp->port_num), val);
+}
 
-	tbl_offset = (entry / 4) * 4;	/* Register offset of DA table entry */
-	reg_offset = entry % 4;		/* Entry offset within the register */
+static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
+{
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
-	/* Set "accepts frame bit" at specified table entry */
-	table_reg = rdl(mp, table + tbl_offset);
-	table_reg |= 0x01 << (8 * reg_offset);
-	wrl(mp, table + tbl_offset, table_reg);
+	if (coal > 0x3fff)
+		coal = 0x3fff;
+	wrl(mp, TX_FIFO_URGENT_THRESHOLD(mp->port_num), (coal & 0x3fff) << 4);
 }
 
-/*
- * eth_port_mc_addr - Multicast address settings.
- *
- * The MV device supports multicast using two tables:
- * 1) Special Multicast Table for MAC addresses of the form
- *    0x01-00-5E-00-00-XX (where XX is between 0x00 and 0x_FF).
- *    The MAC DA[7:0] bits are used as a pointer to the Special Multicast
- *    Table entries in the DA-Filter table.
- * 2) Other Multicast Table for multicast of another type. A CRC-8bit
- *    is used as an index to the Other Multicast Table entries in the
- *    DA-Filter table.  This function calculates the CRC-8bit value.
- * In either case, eth_port_set_filter_table_entry() is then called
- * to set to set the actual table entry.
- */
-static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
+static int mv643xx_eth_open(struct net_device *dev)
 {
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-	unsigned char crc_result = 0;
-	int table;
-	int mac_array[48];
-	int crc[8];
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int err;
 	int i;
 
-	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
-	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num);
-		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
-		return;
+	wrl(mp, INT_CAUSE(mp->port_num), 0);
+	wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
+	rdl(mp, INT_CAUSE_EXT(mp->port_num));
+
+	err = request_irq(dev->irq, mv643xx_eth_irq,
+			  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
+			  dev->name, dev);
+	if (err) {
+		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
+		return -EAGAIN;
 	}
 
-	/* Calculate CRC-8 out of the given address */
-	mac_h = (p_addr[0] << 8) | (p_addr[1]);
-	mac_l = (p_addr[2] << 24) | (p_addr[3] << 16) |
-			(p_addr[4] << 8) | (p_addr[5] << 0);
-
-	for (i = 0; i < 32; i++)
-		mac_array[i] = (mac_l >> i) & 0x1;
-	for (i = 32; i < 48; i++)
-		mac_array[i] = (mac_h >> (i - 32)) & 0x1;
-
-	crc[0] = mac_array[45] ^ mac_array[43] ^ mac_array[40] ^ mac_array[39] ^
-		 mac_array[35] ^ mac_array[34] ^ mac_array[31] ^ mac_array[30] ^
-		 mac_array[28] ^ mac_array[23] ^ mac_array[21] ^ mac_array[19] ^
-		 mac_array[18] ^ mac_array[16] ^ mac_array[14] ^ mac_array[12] ^
-		 mac_array[8]  ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[0];
-
-	crc[1] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[41] ^ mac_array[39] ^ mac_array[36] ^ mac_array[34] ^
-		 mac_array[32] ^ mac_array[30] ^ mac_array[29] ^ mac_array[28] ^
-		 mac_array[24] ^ mac_array[23] ^ mac_array[22] ^ mac_array[21] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[17] ^ mac_array[16] ^
-		 mac_array[15] ^ mac_array[14] ^ mac_array[13] ^ mac_array[12] ^
-		 mac_array[9]  ^ mac_array[6]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[2] = mac_array[47] ^ mac_array[46] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[42] ^ mac_array[39] ^ mac_array[37] ^ mac_array[34] ^
-		 mac_array[33] ^ mac_array[29] ^ mac_array[28] ^ mac_array[25] ^
-		 mac_array[24] ^ mac_array[22] ^ mac_array[17] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^
-		 mac_array[6]  ^ mac_array[2]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[3] = mac_array[47] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[40] ^ mac_array[38] ^ mac_array[35] ^ mac_array[34] ^
-		 mac_array[30] ^ mac_array[29] ^ mac_array[26] ^ mac_array[25] ^
-		 mac_array[23] ^ mac_array[18] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[7]  ^
-		 mac_array[3]  ^ mac_array[2]  ^ mac_array[1];
-
-	crc[4] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[41] ^
-		 mac_array[39] ^ mac_array[36] ^ mac_array[35] ^ mac_array[31] ^
-		 mac_array[30] ^ mac_array[27] ^ mac_array[26] ^ mac_array[24] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[15] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^ mac_array[4]  ^
-		 mac_array[3]  ^ mac_array[2];
-
-	crc[5] = mac_array[47] ^ mac_array[46] ^ mac_array[45] ^ mac_array[42] ^
-		 mac_array[40] ^ mac_array[37] ^ mac_array[36] ^ mac_array[32] ^
-		 mac_array[31] ^ mac_array[28] ^ mac_array[27] ^ mac_array[25] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[16] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[5]  ^
-		 mac_array[4]  ^ mac_array[3];
-
-	crc[6] = mac_array[47] ^ mac_array[46] ^ mac_array[43] ^ mac_array[41] ^
-		 mac_array[38] ^ mac_array[37] ^ mac_array[33] ^ mac_array[32] ^
-		 mac_array[29] ^ mac_array[28] ^ mac_array[26] ^ mac_array[21] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[6]  ^ mac_array[5]  ^
-		 mac_array[4];
-
-	crc[7] = mac_array[47] ^ mac_array[44] ^ mac_array[42] ^ mac_array[39] ^
-		 mac_array[38] ^ mac_array[34] ^ mac_array[33] ^ mac_array[30] ^
-		 mac_array[29] ^ mac_array[27] ^ mac_array[22] ^ mac_array[20] ^
-		 mac_array[18] ^ mac_array[17] ^ mac_array[15] ^ mac_array[13] ^
-		 mac_array[11] ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[5];
+	init_mac_tables(mp);
 
-	for (i = 0; i < 8; i++)
-		crc_result = crc_result | (crc[i] << i);
+	for (i = 0; i < 8; i++) {
+		if ((mp->rxq_mask & (1 << i)) == 0)
+			continue;
 
-	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num);
-	eth_port_set_filter_table_entry(mp, table, crc_result);
-}
+		err = rxq_init(mp, i);
+		if (err) {
+			while (--i >= 0)
+				if (mp->rxq_mask & (1 << i))
+					rxq_deinit(mp->rxq + i);
+			goto out;
+		}
 
-/*
- * Set the entire multicast list based on dev->mc_list.
- */
-static void eth_port_set_multicast_list(struct net_device *dev)
-{
+		rxq_refill(mp->rxq + i);
+	}
 
-	struct dev_mc_list	*mc_list;
-	int			i;
-	int			table_index;
-	struct mv643xx_private	*mp = netdev_priv(dev);
-	unsigned int		eth_port_num = mp->port_num;
+	for (i = 0; i < 8; i++) {
+		if ((mp->txq_mask & (1 << i)) == 0)
+			continue;
 
-	/* If the device is in promiscuous mode or in all multicast mode,
-	 * we will fully populate both multicast tables with accept.
-	 * This is guaranteed to yield a match on all multicast addresses...
-	 */
-	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
-		for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-			/* Set all entries in DA filter special multicast
-			 * table (Ex_dFSMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
-
-			/* Set all entries in DA filter other multicast
-			 * table (Ex_dFOMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+		err = txq_init(mp, i);
+		if (err) {
+			while (--i >= 0)
+				if (mp->txq_mask & (1 << i))
+					txq_deinit(mp->txq + i);
+			goto out_free;
 		}
-		return;
 	}
 
-	/* We will clear out multicast tables every time we get the list.
-	 * Then add the entire new list...
-	 */
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
-
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
-	}
+#ifdef MV643XX_ETH_NAPI
+	napi_enable(&mp->napi);
+#endif
+
+	port_start(mp);
 
-	/* Get pointer to net_device multicast list and add each one... */
-	for (i = 0, mc_list = dev->mc_list;
-			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
-			i++, mc_list = mc_list->next)
-		if (mc_list->dmi_addrlen == 6)
-			eth_port_mc_addr(mp, mc_list->dmi_addr);
+	set_rx_coal(mp, 0);
+	set_tx_coal(mp, 0);
+
+	wrl(mp, INT_MASK_EXT(mp->port_num),
+	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+
+	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+
+	return 0;
+
+
+out_free:
+	for (i = 0; i < 8; i++)
+		if (mp->rxq_mask & (1 << i))
+			rxq_deinit(mp->rxq + i);
+out:
+	free_irq(dev->irq, dev);
+
+	return err;
 }
 
-/*
- * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
- *
- * DESCRIPTION:
- *	Go through all the DA filter tables (Unicast, Special Multicast &
- *	Other Multicast) and set each entry to 0.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	Multicast and Unicast packets are rejected.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_init_mac_tables(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	int table_index;
-
-	/* Clear DA filter unicast table (Ex_dFUT) */
-	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		wrl(mp, DA_FILTER_UNICAST_TABLE_BASE(port_num) +
-					table_index, 0);
-
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
+static void port_reset(struct mv643xx_eth_private *mp)
+{
+	unsigned int data;
+	int i;
+
+	for (i = 0; i < 8; i++) {
+		if (mp->rxq_mask & (1 << i))
+			rxq_disable(mp->rxq + i);
+		if (mp->txq_mask & (1 << i))
+			txq_disable(mp->txq + i);
 	}
+	while (!(rdl(mp, PORT_STATUS(mp->port_num)) & TX_FIFO_EMPTY))
+		udelay(10);
+
+	/* Reset the Enable bit in the Configuration Register */
+	data = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	data &= ~(SERIAL_PORT_ENABLE		|
+		  DO_NOT_FORCE_LINK_FAIL	|
+		  FORCE_LINK_PASS);
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), data);
 }
 
-/*
- * eth_clear_mib_counters - Clear all MIB counters
- *
- * DESCRIPTION:
- *	This function clears all MIB counters of a specific ethernet port.
- *	A read from the MIB counter will reset the counter.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	After reading all MIB counters, the counters resets.
- *
- * RETURN:
- *	MIB counter value.
- *
- */
-static void eth_clear_mib_counters(struct mv643xx_private *mp)
+static int mv643xx_eth_stop(struct net_device *dev)
 {
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
-	/* Perform dummy reads from MIB counters */
-	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
-									i += 4)
-		rdl(mp, MIB_COUNTERS_BASE(port_num) + i);
+	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
+	rdl(mp, INT_MASK(mp->port_num));
+
+#ifdef MV643XX_ETH_NAPI
+	napi_disable(&mp->napi);
+#endif
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
+	free_irq(dev->irq, dev);
+
+	port_reset(mp);
+	mib_counters_update(mp);
+
+	for (i = 0; i < 8; i++) {
+		if (mp->rxq_mask & (1 << i))
+			rxq_deinit(mp->rxq + i);
+		if (mp->txq_mask & (1 << i))
+			txq_deinit(mp->txq + i);
+	}
+
+	return 0;
 }
 
-static inline u32 read_mib(struct mv643xx_private *mp, int offset)
+static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	return rdl(mp, MIB_COUNTERS_BASE(mp->port_num) + offset);
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	if (mp->phy_addr != -1)
+		return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+
+	return -EOPNOTSUPP;
 }
 
-static void eth_update_mib_counters(struct mv643xx_private *mp)
+static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct mv643xx_mib_counters *p = &mp->mib_counters;
-	int offset;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	p->good_octets_received +=
-		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
-	p->good_octets_received +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
+	if (new_mtu < 64 || new_mtu > 9500)
+		return -EINVAL;
 
-	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
-			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
+	dev->mtu = new_mtu;
+	tx_set_rate(mp, 1000000000, 16777216);
 
-	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
-	p->good_octets_sent +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+	if (!netif_running(dev))
+		return 0;
 
-	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
-			offset <= ETH_MIB_LATE_COLLISION;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
+	/*
+	 * Stop and then re-open the interface. This will allocate RX
+	 * skbs of the new MTU.
+	 * There is a possible danger that the open will not succeed,
+	 * due to memory being full.
+	 */
+	mv643xx_eth_stop(dev);
+	if (mv643xx_eth_open(dev)) {
+		dev_printk(KERN_ERR, &dev->dev,
+			   "fatal error on re-opening device after "
+			   "MTU change\n");
+	}
+
+	return 0;
 }
 
-/*
- * ethernet_phy_detect - Detect whether a phy is present
- *
- * DESCRIPTION:
- *	This function tests whether there is a PHY present on
- *	the specified port.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	None
- *
- * RETURN:
- *	0 on success
- *	-ENODEV on failure
- *
- */
-static int ethernet_phy_detect(struct mv643xx_private *mp)
+static void tx_timeout_task(struct work_struct *ugly)
 {
-	unsigned int phy_reg_data0;
-	int auto_neg;
+	struct mv643xx_eth_private *mp;
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
-	auto_neg = phy_reg_data0 & 0x1000;
-	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	mp = container_of(ugly, struct mv643xx_eth_private, tx_timeout_task);
+	if (netif_running(mp->dev)) {
+		netif_stop_queue(mp->dev);
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
-	if ((phy_reg_data0 & 0x1000) == auto_neg)
-		return -ENODEV;				/* change didn't take */
+		port_reset(mp);
+		port_start(mp);
 
-	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
-	return 0;
+		__txq_maybe_wake(mp->txq + mp->txq_primary);
+	}
 }
 
-/*
- * ethernet_phy_get - Get the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine returns the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	PHY address.
- *
- */
-static int ethernet_phy_get(struct mv643xx_private *mp)
+static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
-	unsigned int reg_data;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	reg_data = rdl(mp, PHY_ADDR_REG);
+	dev_printk(KERN_INFO, &dev->dev, "tx timeout\n");
 
-	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
+	schedule_work(&mp->tx_timeout_task);
 }
 
-/*
- * ethernet_phy_set - Set the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine sets the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	int		phy_addr	PHY address.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	None.
- *
- */
-static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void mv643xx_eth_netpoll(struct net_device *dev)
 {
-	u32 reg_data;
-	int addr_shift = 5 * mp->port_num;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+
+	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
+	rdl(mp, INT_MASK(mp->port_num));
+
+	mv643xx_eth_irq(dev->irq, dev);
 
-	reg_data = rdl(mp, PHY_ADDR_REG);
-	reg_data &= ~(0x1f << addr_shift);
-	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	wrl(mp, PHY_ADDR_REG, reg_data);
+	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_CAUSE_EXT);
 }
+#endif
 
-/*
- * ethernet_phy_reset - Reset Ethernet port PHY.
- *
- * DESCRIPTION:
- *	This routine utilizes the SMI interface to reset the ethernet port PHY.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	The PHY is reset.
- *
- * RETURN:
- *	None.
- *
- */
-static void ethernet_phy_reset(struct mv643xx_private *mp)
+static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
 {
-	unsigned int phy_reg_data;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	int val;
 
-	/* Reset the PHY */
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
-	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data);
+	smi_reg_read(mp, addr, reg, &val);
 
-	/* wait for PHY to come out of reset */
-	do {
-		udelay(1);
-		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
-	} while (phy_reg_data & 0x8000);
+	return val;
 }
 
-static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
-					unsigned int queues)
+static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
 {
-	wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	smi_reg_write(mp, addr, reg, val);
 }
 
-static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
-					unsigned int queues)
-{
-	wrl(mp, RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
-}
 
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
+/* platform glue ************************************************************/
+static void
+mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *msp,
+			      struct mbus_dram_target_info *dram)
 {
-	unsigned int port_num = mp->port_num;
-	u32 queues;
+	void __iomem *base = msp->base;
+	u32 win_enable;
+	u32 win_protect;
+	int i;
 
-	/* Stop Tx port activity. Check port Tx activity. */
-	queues = rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
+	for (i = 0; i < 6; i++) {
+		writel(0, base + WINDOW_BASE(i));
+		writel(0, base + WINDOW_SIZE(i));
+		if (i < 4)
+			writel(0, base + WINDOW_REMAP_HIGH(i));
+	}
 
-		/* Wait for all Tx activity to terminate. */
-		/* Check port cause register that all Tx queues are stopped */
-		while (rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
+	win_enable = 0x3f;
+	win_protect = 0;
 
-		/* Wait for Tx FIFO to empty */
-		while (rdl(mp, PORT_STATUS_REG(port_num)) &
-							ETH_PORT_TX_FIFO_EMPTY)
-			udelay(PHY_WAIT_MICRO_SECONDS);
+	for (i = 0; i < dram->num_cs; i++) {
+		struct mbus_dram_window *cs = dram->cs + i;
+
+		writel((cs->base & 0xffff0000) |
+			(cs->mbus_attr << 8) |
+			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
+		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
+
+		win_enable &= ~(1 << i);
+		win_protect |= 3 << (2 * i);
 	}
 
-	return queues;
+	writel(win_enable, base + WINDOW_BAR_ENABLE);
+	msp->win_protect = win_protect;
 }
 
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
+static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 {
-	unsigned int port_num = mp->port_num;
-	u32 queues;
-
-	/* Stop Rx port activity. Check port Rx activity. */
-	queues = rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
-
-		/* Wait for all Rx activity to terminate. */
-		/* Check port cause register that all Rx queues are stopped */
-		while (rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
-	}
+	/*
+	 * Check whether we have a 14-bit coal limit field in bits
+	 * [21:8], or a 16-bit coal limit in bits [25,21:7] of the
+	 * SDMA config register.
+	 */
+	writel(0x02000000, msp->base + SDMA_CONFIG(0));
+	if (readl(msp->base + SDMA_CONFIG(0)) & 0x02000000)
+		msp->extended_rx_coal_limit = 1;
+	else
+		msp->extended_rx_coal_limit = 0;
 
-	return queues;
+	/*
+	 * Check whether the TX rate control registers are in the
+	 * old or the new place.
+	 */
+	writel(1, msp->base + TX_BW_MTU_MOVED(0));
+	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1)
+		msp->tx_bw_control_moved = 1;
+	else
+		msp->tx_bw_control_moved = 0;
 }
 
-/*
- * eth_port_reset - Reset Ethernet port
- *
- * DESCRIPTION:
- * 	This routine resets the chip by aborting any SDMA engine activity and
- *	clearing the MIB counters. The Receiver and the Transmit unit are in
- *	idle state after this command is performed and the port is disabled.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	Channel activity is halted.
- *
- * RETURN:
- *	None.
- *
- */
-static void eth_port_reset(struct mv643xx_private *mp)
+static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
-	unsigned int port_num = mp->port_num;
-	unsigned int reg_data;
+	static int mv643xx_eth_version_printed = 0;
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
+	struct mv643xx_eth_shared_private *msp;
+	struct resource *res;
+	int ret;
 
-	mv643xx_eth_port_disable_tx(mp);
-	mv643xx_eth_port_disable_rx(mp);
+	if (!mv643xx_eth_version_printed++)
+		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
 
-	/* Clear all MIB counters */
-	eth_clear_mib_counters(mp);
+	ret = -EINVAL;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL)
+		goto out;
 
-	/* Reset the Enable bit in the Configuration Register */
-	reg_data = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
-	reg_data &= ~(SERIAL_PORT_ENABLE		|
-			DO_NOT_FORCE_LINK_FAIL	|
-			FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), reg_data);
-}
+	ret = -ENOMEM;
+	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
+	if (msp == NULL)
+		goto out;
+	memset(msp, 0, sizeof(*msp));
 
+	msp->base = ioremap(res->start, res->end - res->start + 1);
+	if (msp->base == NULL)
+		goto out_free;
 
-/*
- * eth_port_read_smi_reg - Read PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform PHY register read.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	*value		Register value buffer.
- *
- * OUTPUT:
- *	Write the value of a specified PHY register into given buffer.
- *
- * RETURN:
- *	false if the PHY is busy or read data is not in valid state.
- *	true otherwise.
- *
- */
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
-				unsigned int phy_reg, unsigned int *value)
-{
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
-	unsigned long flags;
-	int i;
+	spin_lock_init(&msp->phy_lock);
 
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	/*
+	 * (Re-)program MBUS remapping windows if we are asked to.
+	 */
+	if (pd != NULL && pd->dram != NULL)
+		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
+	/*
+	 * Detect hardware parameters.
+	 */
+	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+	infer_hw_params(msp);
 
-	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
-		smi_reg);
+	platform_set_drvdata(pdev, msp);
 
-	/* now wait for the data to be valid */
-	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY read timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
+	return 0;
 
-	*value = readl(smi_reg) & 0xffff;
+out_free:
+	kfree(msp);
 out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	return ret;
 }
 
-/*
- * eth_port_write_smi_reg - Write to PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform writes to PHY registers.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	value		Register value.
- *
- * OUTPUT:
- *	Write the given value to the specified PHY register.
- *
- * RETURN:
- *	false if the PHY is busy.
- *	true otherwise.
- *
- */
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
-				   unsigned int phy_reg, unsigned int value)
+static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
-	unsigned long flags;
-	int i;
-
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
+	iounmap(msp->base);
+	kfree(msp);
 
-	writel((phy_addr << 16) | (phy_reg << 21) |
-		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
-out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	return 0;
 }
 
-/*
- * Wrappers for MII support library.
- */
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
+static struct platform_driver mv643xx_eth_shared_driver = {
+	.probe		= mv643xx_eth_shared_probe,
+	.remove		= mv643xx_eth_shared_remove,
+	.driver = {
+		.name	= MV643XX_ETH_SHARED_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static void phy_addr_set(struct mv643xx_eth_private *mp, int phy_addr)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int val;
+	int addr_shift = 5 * mp->port_num;
+	u32 data;
 
-	eth_port_read_smi_reg(mp, location, &val);
-	return val;
+	data = rdl(mp, PHY_ADDR);
+	data &= ~(0x1f << addr_shift);
+	data |= (phy_addr & 0x1f) << addr_shift;
+	wrl(mp, PHY_ADDR, data);
 }
 
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+static int phy_addr_get(struct mv643xx_eth_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	eth_port_write_smi_reg(mp, location, val);
+	unsigned int data;
+
+	data = rdl(mp, PHY_ADDR);
+
+	return (data >> (5 * mp->port_num)) & 0x1f;
 }
 
-/*
- * eth_port_receive - Get received information from Rx ring.
- *
- * DESCRIPTION:
- * 	This routine returns the received data to the caller. There is no
- *	data copying during routine operation. All information is returned
- *	using pointer to packet information struct passed from the caller.
- *	If the routine exhausts Rx ring resources then the resource error flag
- *	is set.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	User packet buffer.
- *
- * OUTPUT:
- *	Rx ring current and used indexes are updated.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_QUEUE_FULL if Rx ring resources are exhausted.
- *	ETH_END_OF_JOB if there is no received data.
- *	ETH_OK otherwise.
- */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
+static void set_params(struct mv643xx_eth_private *mp,
+		       struct mv643xx_eth_platform_data *pd)
 {
-	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct eth_rx_desc *p_rx_desc;
-	unsigned int command_status;
-	unsigned long flags;
+	struct net_device *dev = mp->dev;
 
-	/* Do not process Rx ring in case of Rx ring resource error */
-	if (mp->rx_resource_err)
-		return ETH_QUEUE_FULL;
+	if (is_valid_ether_addr(pd->mac_addr))
+		memcpy(dev->dev_addr, pd->mac_addr, 6);
+	else
+		uc_addr_get(mp, dev->dev_addr);
 
-	spin_lock_irqsave(&mp->lock, flags);
+	if (pd->phy_addr == -1) {
+		mp->shared_smi = NULL;
+		mp->phy_addr = -1;
+	} else {
+		mp->shared_smi = mp->shared;
+		if (pd->shared_smi != NULL)
+			mp->shared_smi = platform_get_drvdata(pd->shared_smi);
 
-	/* Get the Rx Desc ring 'curr and 'used' indexes */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	rx_used_desc = mp->rx_used_desc_q;
+		if (pd->force_phy_addr || pd->phy_addr) {
+			mp->phy_addr = pd->phy_addr & 0x3f;
+			phy_addr_set(mp, mp->phy_addr);
+		} else {
+			mp->phy_addr = phy_addr_get(mp);
+		}
+	}
 
-	p_rx_desc = &mp->p_rx_desc_area[rx_curr_desc];
+	mp->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	if (pd->rx_queue_size)
+		mp->default_rx_ring_size = pd->rx_queue_size;
+	mp->rx_desc_sram_addr = pd->rx_sram_addr;
+	mp->rx_desc_sram_size = pd->rx_sram_size;
 
-	/* The following parameters are used to save readings from memory */
-	command_status = p_rx_desc->cmd_sts;
-	rmb();
+	if (pd->rx_queue_mask)
+		mp->rxq_mask = pd->rx_queue_mask;
+	else
+		mp->rxq_mask = 0x01;
+	mp->rxq_primary = fls(mp->rxq_mask) - 1;
 
-	/* Nothing to receive... */
-	if (command_status & (ETH_BUFFER_OWNED_BY_DMA)) {
-		spin_unlock_irqrestore(&mp->lock, flags);
-		return ETH_END_OF_JOB;
-	}
+	mp->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	if (pd->tx_queue_size)
+		mp->default_tx_ring_size = pd->tx_queue_size;
+	mp->tx_desc_sram_addr = pd->tx_sram_addr;
+	mp->tx_desc_sram_size = pd->tx_sram_size;
 
-	p_pkt_info->byte_cnt = (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
-	p_pkt_info->cmd_sts = command_status;
-	p_pkt_info->buf_ptr = (p_rx_desc->buf_ptr) + RX_BUF_OFFSET;
-	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
-	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
+	if (pd->tx_queue_mask)
+		mp->txq_mask = pd->tx_queue_mask;
+	else
+		mp->txq_mask = 0x01;
+	mp->txq_primary = fls(mp->txq_mask) - 1;
+}
 
-	/*
-	 * Clean the return info field to indicate that the
-	 * packet has been moved to the upper layers
-	 */
-	mp->rx_skb[rx_curr_desc] = NULL;
+static int phy_detect(struct mv643xx_eth_private *mp)
+{
+	unsigned int data;
+	unsigned int data2;
 
-	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
-	mp->rx_curr_desc_q = rx_next_curr_desc;
+	smi_reg_read(mp, mp->phy_addr, 0, &data);
+	smi_reg_write(mp, mp->phy_addr, 0, data ^ 0x1000);
 
-	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
-	if (rx_next_curr_desc == rx_used_desc)
-		mp->rx_resource_err = 1;
+	smi_reg_read(mp, mp->phy_addr, 0, &data2);
+	if (((data ^ data2) & 0x1000) == 0)
+		return -ENODEV;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	smi_reg_write(mp, mp->phy_addr, 0, data);
 
-	return ETH_OK;
+	return 0;
 }
 
-/*
- * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
- *
- * DESCRIPTION:
- *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
- *	next 'used' descriptor and attached the returned buffer to it.
- *	In case the Rx ring was in "resource error" condition, where there are
- *	no available Rx resources, the function resets the resource error flag.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	Information on returned buffer.
- *
- * OUTPUT:
- *	New available Rx resource in Rx descriptor ring.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_OK otherwise.
- */
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
+static int phy_init(struct mv643xx_eth_private *mp,
+		    struct mv643xx_eth_platform_data *pd)
 {
-	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct eth_rx_desc *p_used_rx_desc;
-	unsigned long flags;
+	struct ethtool_cmd cmd;
+	int err;
 
-	spin_lock_irqsave(&mp->lock, flags);
+	err = phy_detect(mp);
+	if (err) {
+		dev_printk(KERN_INFO, &mp->dev->dev,
+			   "no PHY detected at addr %d\n", mp->phy_addr);
+		return err;
+	}
+	phy_reset(mp);
 
-	/* Get 'used' Rx descriptor */
-	used_rx_desc = mp->rx_used_desc_q;
-	p_used_rx_desc = &mp->p_rx_desc_area[used_rx_desc];
+	mp->mii.phy_id = mp->phy_addr;
+	mp->mii.phy_id_mask = 0x3f;
+	mp->mii.reg_num_mask = 0x1f;
+	mp->mii.dev = mp->dev;
+	mp->mii.mdio_read = mv643xx_eth_mdio_read;
+	mp->mii.mdio_write = mv643xx_eth_mdio_write;
 
-	p_used_rx_desc->buf_ptr = p_pkt_info->buf_ptr;
-	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
-	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
+	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
 
-	/* Flush the write pipe */
+	memset(&cmd, 0, sizeof(cmd));
+
+	cmd.port = PORT_MII;
+	cmd.transceiver = XCVR_INTERNAL;
+	cmd.phy_address = mp->phy_addr;
+	if (pd->speed == 0) {
+		cmd.autoneg = AUTONEG_ENABLE;
+		cmd.speed = SPEED_100;
+		cmd.advertising = ADVERTISED_10baseT_Half  |
+				  ADVERTISED_10baseT_Full  |
+				  ADVERTISED_100baseT_Half |
+				  ADVERTISED_100baseT_Full;
+		if (mp->mii.supports_gmii)
+			cmd.advertising |= ADVERTISED_1000baseT_Full;
+	} else {
+		cmd.autoneg = AUTONEG_DISABLE;
+		cmd.speed = pd->speed;
+		cmd.duplex = pd->duplex;
+	}
 
-	/* Return the descriptor to DMA ownership */
-	wmb();
-	p_used_rx_desc->cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
-	wmb();
+	update_pscr(mp, cmd.speed, cmd.duplex);
+	mv643xx_eth_set_settings(mp->dev, &cmd);
 
-	/* Move the used descriptor pointer to the next descriptor */
-	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
+	return 0;
+}
 
-	/* Any Rx return cancels the Rx resource error status */
-	mp->rx_resource_err = 0;
+static int mv643xx_eth_probe(struct platform_device *pdev)
+{
+	struct mv643xx_eth_platform_data *pd;
+	struct mv643xx_eth_private *mp;
+	struct net_device *dev;
+	struct resource *res;
+	DECLARE_MAC_BUF(mac);
+	int err;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	pd = pdev->dev.platform_data;
+	if (pd == NULL) {
+		dev_printk(KERN_ERR, &pdev->dev,
+			   "no mv643xx_eth_platform_data\n");
+		return -ENODEV;
+	}
 
-	return ETH_OK;
-}
+	if (pd->shared == NULL) {
+		dev_printk(KERN_ERR, &pdev->dev,
+			   "no mv643xx_eth_platform_data->shared\n");
+		return -ENODEV;
+	}
 
-/************* Begin ethtool support *************************/
+	dev = alloc_etherdev(sizeof(struct mv643xx_eth_private));
+	if (!dev)
+		return -ENOMEM;
 
-struct mv643xx_stats {
-	char stat_string[ETH_GSTRING_LEN];
-	int sizeof_stat;
-	int stat_offset;
-};
+	mp = netdev_priv(dev);
+	platform_set_drvdata(pdev, mp);
 
-#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
-					offsetof(struct mv643xx_private, m)
-
-static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
-	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
-	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
-	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
-	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
-	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
-	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
-	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
-	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
-	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
-	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
-	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
-	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
-	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
-	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
-	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
-	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
-	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
-	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
-	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
-	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
-	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
-	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
-	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
-	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
-	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
-	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
-	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
-	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
-	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
-	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
-	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
-	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
-	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
-	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
-	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
-	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
-	{ "collision", MV643XX_STAT(mib_counters.collision) },
-	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
-};
+	mp->shared = platform_get_drvdata(pd->shared);
+	mp->port_num = pd->port_number;
 
-#define MV643XX_STATS_LEN	ARRAY_SIZE(mv643xx_gstrings_stats)
+	mp->dev = dev;
+#ifdef MV643XX_ETH_NAPI
+	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 64);
+#endif
 
-static void mv643xx_get_drvinfo(struct net_device *netdev,
-				struct ethtool_drvinfo *drvinfo)
-{
-	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
-	strncpy(drvinfo->version, mv643xx_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "mv643xx", 32);
-	drvinfo->n_stats = MV643XX_STATS_LEN;
-}
+	set_params(mp, pd);
 
-static int mv643xx_get_sset_count(struct net_device *netdev, int sset)
-{
-	switch (sset) {
-	case ETH_SS_STATS:
-		return MV643XX_STATS_LEN;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
+	spin_lock_init(&mp->lock);
 
-static void mv643xx_get_ethtool_stats(struct net_device *netdev,
-				struct ethtool_stats *stats, uint64_t *data)
-{
-	struct mv643xx_private *mp = netdev->priv;
-	int i;
+	mib_counters_clear(mp);
+	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
 
-	eth_update_mib_counters(mp);
+	if (mp->phy_addr != -1) {
+		err = phy_init(mp, pd);
+		if (err)
+			goto out;
 
-	for (i = 0; i < MV643XX_STATS_LEN; i++) {
-		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;
-		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
+	} else {
+		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
-}
 
-static void mv643xx_get_strings(struct net_device *netdev, uint32_t stringset,
-				uint8_t *data)
-{
-	int i;
 
-	switch(stringset) {
-	case ETH_SS_STATS:
-		for (i=0; i < MV643XX_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN,
-					mv643xx_gstrings_stats[i].stat_string,
-					ETH_GSTRING_LEN);
-		}
-		break;
-	}
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	BUG_ON(!res);
+	dev->irq = res->start;
+
+	dev->hard_start_xmit = mv643xx_eth_xmit;
+	dev->open = mv643xx_eth_open;
+	dev->stop = mv643xx_eth_stop;
+	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
+	dev->set_mac_address = mv643xx_eth_set_mac_address;
+	dev->do_ioctl = mv643xx_eth_ioctl;
+	dev->change_mtu = mv643xx_eth_change_mtu;
+	dev->tx_timeout = mv643xx_eth_tx_timeout;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = mv643xx_eth_netpoll;
+#endif
+	dev->watchdog_timeo = 2 * HZ;
+	dev->base_addr = 0;
+
+#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
+	/*
+	 * Zero copy can only work if we use Discovery II memory. Else, we will
+	 * have to map the buffers to ISA memory which is only 16 MB
+	 */
+	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+#endif
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	if (mp->shared->win_protect)
+		wrl(mp, WINDOW_PROTECT(mp->port_num), mp->shared->win_protect);
+
+	err = register_netdev(dev);
+	if (err)
+		goto out;
+
+	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %s\n",
+		   mp->port_num, print_mac(mac, dev->dev_addr));
+
+	if (dev->features & NETIF_F_SG)
+		dev_printk(KERN_NOTICE, &dev->dev, "scatter/gather enabled\n");
+
+	if (dev->features & NETIF_F_IP_CSUM)
+		dev_printk(KERN_NOTICE, &dev->dev, "tx checksum offload\n");
+
+#ifdef MV643XX_ETH_NAPI
+	dev_printk(KERN_NOTICE, &dev->dev, "napi enabled\n");
+#endif
+
+	if (mp->tx_desc_sram_size > 0)
+		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
+
+	return 0;
+
+out:
+	free_netdev(dev);
+
+	return err;
 }
 
-static u32 mv643xx_eth_get_link(struct net_device *dev)
+static int mv643xx_eth_remove(struct platform_device *pdev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
-	return mii_link_ok(&mp->mii);
+	unregister_netdev(mp->dev);
+	flush_scheduled_work();
+	free_netdev(mp->dev);
+
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
 }
 
-static int mv643xx_eth_nway_restart(struct net_device *dev)
+static void mv643xx_eth_shutdown(struct platform_device *pdev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
-	return mii_nway_restart(&mp->mii);
+	/* Mask all interrupts on ethernet port */
+	wrl(mp, INT_MASK(mp->port_num), 0);
+	rdl(mp, INT_MASK(mp->port_num));
+
+	if (netif_running(mp->dev))
+		port_reset(mp);
 }
 
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static struct platform_driver mv643xx_eth_driver = {
+	.probe		= mv643xx_eth_probe,
+	.remove		= mv643xx_eth_remove,
+	.shutdown	= mv643xx_eth_shutdown,
+	.driver = {
+		.name	= MV643XX_ETH_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init mv643xx_eth_init_module(void)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	int rc;
+
+	rc = platform_driver_register(&mv643xx_eth_shared_driver);
+	if (!rc) {
+		rc = platform_driver_register(&mv643xx_eth_driver);
+		if (rc)
+			platform_driver_unregister(&mv643xx_eth_shared_driver);
+	}
 
-	return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+	return rc;
 }
+module_init(mv643xx_eth_init_module);
 
-static const struct ethtool_ops mv643xx_ethtool_ops = {
-	.get_settings           = mv643xx_get_settings,
-	.set_settings           = mv643xx_set_settings,
-	.get_drvinfo            = mv643xx_get_drvinfo,
-	.get_link               = mv643xx_eth_get_link,
-	.set_sg			= ethtool_op_set_sg,
-	.get_sset_count		= mv643xx_get_sset_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
-	.get_strings            = mv643xx_get_strings,
-	.nway_reset		= mv643xx_eth_nway_restart,
-};
+static void __exit mv643xx_eth_cleanup_module(void)
+{
+	platform_driver_unregister(&mv643xx_eth_driver);
+	platform_driver_unregister(&mv643xx_eth_shared_driver);
+}
+module_exit(mv643xx_eth_cleanup_module);
 
-/************* End ethtool support *************************/
+MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, "
+	      "Manish Lachwani, Dale Farnsworth and Lennert Buytenhek");
+MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
+MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7f1cfc4..64b7eff 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.21"
+#define DRV_VERSION		"1.22"
 #define PFX			DRV_NAME " "
 
 /*
@@ -98,7 +98,7 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static const struct pci_device_id sky2_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b00) },	/* DGE-560T */
@@ -136,6 +136,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436C) }, /* 88E8072 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436D) }, /* 88E8055 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4370) }, /* 88E8075 */
+	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4380) }, /* 88E8057 */
 	{ 0 }
 };
 
@@ -146,17 +147,6 @@ static const unsigned txqaddr[] = { Q_XA1, Q_XA2 };
 static const unsigned rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
-/* This driver supports yukon2 chipset only */
-static const char *yukon2_name[] = {
-	"XL",		/* 0xb3 */
-	"EC Ultra", 	/* 0xb4 */
-	"Extreme",	/* 0xb5 */
-	"EC",		/* 0xb6 */
-	"FE",		/* 0xb7 */
-	"FE+",		/* 0xb8 */
-	"Supreme",	/* 0xb9 */
-};
-
 static void sky2_set_multicast(struct net_device *dev);
 
 /* Access to PHY via serial interconnect */
@@ -658,8 +648,7 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
 	}
 
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
-	    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U || hw->chip_id == CHIP_ID_YUKON_UL_2) {
 		/* apply fixes in PHY AFE */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 255);
 
@@ -667,9 +656,11 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		gm_phy_write(hw, port, 0x18, 0xaa99);
 		gm_phy_write(hw, port, 0x17, 0x2011);
 
-		/* fix for IEEE A/B Symmetry failure in 1000BASE-T */
-		gm_phy_write(hw, port, 0x18, 0xa204);
-		gm_phy_write(hw, port, 0x17, 0x2002);
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+			/* fix for IEEE A/B Symmetry failure in 1000BASE-T */
+			gm_phy_write(hw, port, 0x18, 0xa204);
+			gm_phy_write(hw, port, 0x17, 0x2002);
+		}
 
 		/* set page register to 0 */
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
@@ -678,7 +669,8 @@ static void sky2_phy_init(struct sky2_hw *hw, unsigned port)
 		/* apply workaround for integrated resistors calibration */
 		gm_phy_write(hw, port, PHY_MARV_PAGE_ADDR, 17);
 		gm_phy_write(hw, port, PHY_MARV_PAGE_DATA, 0x3f60);
-	} else if (hw->chip_id != CHIP_ID_YUKON_EX) {
+	} else if (hw->chip_id != CHIP_ID_YUKON_EX &&
+		   hw->chip_id < CHIP_ID_YUKON_SUPR) {
 		/* no effect on Yukon-XL */
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, ledctrl);
 
@@ -2818,6 +2810,7 @@ static u32 sky2_mhz(const struct sky2_hw *hw)
 	case CHIP_ID_YUKON_EC_U:
 	case CHIP_ID_YUKON_EX:
 	case CHIP_ID_YUKON_SUPR:
+	case CHIP_ID_YUKON_UL_2:
 		return 125;
 
 	case CHIP_ID_YUKON_FE:
@@ -2910,6 +2903,11 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 			| SKY2_HW_ADV_POWER_CTL;
 		break;
 
+	case CHIP_ID_YUKON_UL_2:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+
 	default:
 		dev_err(&hw->pdev->dev, "unsupported chip type 0x%x\n",
 			hw->chip_id);
@@ -4265,12 +4263,34 @@ static int __devinit pci_wake_enabled(struct pci_dev *dev)
 	return value & PCI_PM_CTRL_PME_ENABLE;
 }
 
+/* This driver supports yukon2 chipset only */
+static const char *sky2_name(u8 chipid, char *buf, int sz)
+{
+	const char *name[] = {
+		"XL",		/* 0xb3 */
+		"EC Ultra", 	/* 0xb4 */
+		"Extreme",	/* 0xb5 */
+		"EC",		/* 0xb6 */
+		"FE",		/* 0xb7 */
+		"FE+",		/* 0xb8 */
+		"Supreme",	/* 0xb9 */
+		"UL 2",		/* 0xba */
+	};
+
+	if (chipid >= CHIP_ID_YUKON_XL && chipid < CHIP_ID_YUKON_UL_2)
+		strncpy(buf, name[chipid - CHIP_ID_YUKON_XL], sz);
+	else
+		snprintf(buf, sz, "(chip %#x)", chipid);
+	return buf;
+}
+
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
+	char buf1[16];
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4341,10 +4361,10 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_out_iounmap;
 
-	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-%s (0x%x) rev %d\n",
-	       DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
-	       pdev->irq, yukon2_name[hw->chip_id - CHIP_ID_YUKON_XL],
-	       hw->chip_id, hw->chip_rev);
+	dev_info(&pdev->dev, "v%s addr 0x%llx irq %d Yukon-2 %s rev %d\n",
+		 DRV_VERSION, (unsigned long long)pci_resource_start(pdev, 0),
+		 pdev->irq, sky2_name(hw->chip_id, buf1, sizeof(buf1)),
+		 hw->chip_rev);
 
 	sky2_reset(hw);
 
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 1fa82bf..4d9c4a1 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -441,6 +441,7 @@ enum {
  	CHIP_ID_YUKON_FE   = 0xb7, /* YUKON-2 FE */
  	CHIP_ID_YUKON_FE_P = 0xb8, /* YUKON-2 FE+ */
 	CHIP_ID_YUKON_SUPR = 0xb9, /* YUKON-2 Supreme */
+	CHIP_ID_YUKON_UL_2 = 0xba, /* YUKON-2 Ultra 2 */
 };
 enum yukon_ec_rev {
 	CHIP_REV_YU_EC_A1    = 0,  /* Chip Rev. for Yukon-EC A1/A0 */
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index a15cdd4..1207857 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -17,30 +17,59 @@
 
 struct mv643xx_eth_shared_platform_data {
 	struct mbus_dram_target_info	*dram;
-	unsigned int	t_clk;
+	unsigned int		t_clk;
 };
 
 struct mv643xx_eth_platform_data {
+	/*
+	 * Pointer back to our parent instance, and our port number.
+	 */
 	struct platform_device	*shared;
-	int		port_number;
+	int			port_number;
 
+	/*
+	 * Whether a PHY is present, and if yes, at which address.
+	 */
 	struct platform_device	*shared_smi;
+	int			force_phy_addr;
+	int			phy_addr;
 
-	u16		force_phy_addr;	/* force override if phy_addr == 0 */
-	u16		phy_addr;
-
-	/* If speed is 0, then speed and duplex are autonegotiated. */
-	int		speed;		/* 0, SPEED_10, SPEED_100, SPEED_1000 */
-	int		duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
-
-	/* non-zero values of the following fields override defaults */
-	u32		tx_queue_size;
-	u32		rx_queue_size;
-	u32		tx_sram_addr;
-	u32		tx_sram_size;
-	u32		rx_sram_addr;
-	u32		rx_sram_size;
-	u8		mac_addr[6];	/* mac address if non-zero*/
+	/*
+	 * Use this MAC address if it is valid, overriding the
+	 * address that is already in the hardware.
+	 */
+	u8			mac_addr[6];
+
+	/*
+	 * If speed is 0, autonegotiation is enabled.
+	 *   Valid values for speed: 0, SPEED_10, SPEED_100, SPEED_1000.
+	 *   Valid values for duplex: DUPLEX_HALF, DUPLEX_FULL.
+	 */
+	int			speed;
+	int			duplex;
+
+	/*
+	 * Which RX/TX queues to use.
+	 */
+	int			rx_queue_mask;
+	int			tx_queue_mask;
+
+	/*
+	 * Override default RX/TX queue sizes if nonzero.
+	 */
+	int			rx_queue_size;
+	int			tx_queue_size;
+
+	/*
+	 * Use on-chip SRAM for RX/TX descriptors if size is nonzero
+	 * and sufficient to contain all descriptors for the requested
+	 * ring sizes.
+	 */
+	unsigned long		rx_sram_addr;
+	int			rx_sram_size;
+	unsigned long		tx_sram_addr;
+	int			tx_sram_size;
 };
 
-#endif /* __LINUX_MV643XX_ETH_H */
+
+#endif
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..9ccbfac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1479,6 +1479,7 @@ extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
+extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
@@ -1505,6 +1506,9 @@ extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 extern void dev_seq_stop(struct seq_file *seq, void *v);
 #endif
 
+extern int netdev_class_create_file(struct class_attribute *class_attr);
+extern void netdev_class_remove_file(struct class_attribute *class_attr);
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 0ff6224..bd3d72d 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -197,6 +197,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_GOING_DOWN	0x0009
 #define NETDEV_CHANGENAME	0x000A
 #define NETDEV_FEAT_CHANGE	0x000B
+#define NETDEV_BONDING_FAILOVER 0x000C
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/net/core/dev.c b/net/core/dev.c
index 68d8df0..0e45742 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -961,6 +961,12 @@ void netdev_state_change(struct net_device *dev)
 	}
 }
 
+void netdev_bonding_change(struct net_device *dev)
+{
+	call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, dev);
+}
+EXPORT_SYMBOL(netdev_bonding_change);
+
 /**
  *	dev_load 	- load a network module
  *	@net: the applicable net namespace
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index dccd737..3f79413 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -468,6 +468,19 @@ int netdev_register_kobject(struct net_device *net)
 	return device_add(dev);
 }
 
+int netdev_class_create_file(struct class_attribute *class_attr)
+{
+	return class_create_file(&net_class, class_attr);
+}
+
+void netdev_class_remove_file(struct class_attribute *class_attr)
+{
+	class_remove_file(&net_class, class_attr);
+}
+
+EXPORT_SYMBOL(netdev_class_create_file);
+EXPORT_SYMBOL(netdev_class_remove_file);
+
 void netdev_initialize_kobject(struct net_device *net)
 {
 	struct device *device = &(net->dev);
