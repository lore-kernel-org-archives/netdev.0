From: raghavendra.koushik@s2io.com
Subject: [PATCH 2.6.9-rc2 12/12] S2io: styling
Date: Mon,  8 Nov 2004 08:18:05 -0800 (PST)
Message-ID: <20041108161805.5DB33328FC@linux.site>
Cc: ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached is the patch to implement comments about styling
and few other changes.
Following is list of changes.
1. Incorporated Randy's comment about C99 format for s2io_driver
   structure initialization.
2. Driver version displayed at load time.
3. If initialization failed in s2io_init_nic(), appropriate error
   codes are returned.
4. #ifdef SET_ETHTOOL_OPS removed in couple of places.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-26 16:45:59.090250752 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-26 16:45:47.840960904 -0700
@@ -250,10 +250,10 @@
 MODULE_DEVICE_TABLE(pci, s2io_tbl);
 
 static struct pci_driver s2io_driver = {
-      name:"S2IO",
-      id_table:s2io_tbl,
-      probe:s2io_init_nic,
-      remove:__devexit_p(s2io_rem_nic),
+      .name = "S2IO",
+      .id_table = s2io_tbl,
+      .probe = s2io_init_nic,
+      .remove = __devexit_p(s2io_rem_nic),
 };
 
 /* A simplifier macro used both by init and free shared_mem Fns(). */
@@ -4603,6 +4603,9 @@
 	struct config_param *config;
 
 
+	DBG_PRINT(ERR_DBG, "Loading S2IO driver with %s\n",
+		s2io_driver_version);
+
 	if ((ret = pci_enable_device(pdev))) {
 		DBG_PRINT(ERR_DBG,
 			  "s2io_init_nic: pci_enable_device failed\n");
@@ -4720,6 +4723,7 @@
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
 			  dev->name);
+		ret = -ENOMEM;
 		goto mem_alloc_failed;
 	}
 
@@ -4728,6 +4732,7 @@
 	if (!sp->bar0) {
 		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem1\n",
 			  dev->name);
+		ret = -ENOMEM;
 		goto bar0_remap_failed;
 	}
 
@@ -4736,6 +4741,7 @@
 	if (!sp->bar1) {
 		DBG_PRINT(ERR_DBG, "%s: S2IO: cannot remap io mem2\n",
 			  dev->name);
+		ret = -ENOMEM;
 		goto bar1_remap_failed;
 	}
 
@@ -4756,9 +4762,7 @@
 	dev->set_multicast_list = &s2io_set_multicast;
 	dev->do_ioctl = &s2io_ioctl;
 	dev->change_mtu = &s2io_change_mtu;
-#ifdef SET_ETHTOOL_OPS
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-#endif
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
 	 * mac address will be set every time dev->open() is called
@@ -4788,6 +4792,7 @@
 	if (s2io_set_swapper(sp)) {
 		DBG_PRINT(ERR_DBG, "%s:swapper settings are wrong\n",
 			  dev->name);
+		ret = -EAGAIN;
 		goto set_swap_failed;
 	}
 
@@ -4802,6 +4807,7 @@
 		DBG_PRINT(ERR_DBG,
 			  "%s: S2IO: swapper settings are wrong\n",
 			  dev->name);
+		ret = -EAGAIN;
 		goto set_swap_failed;
 	}
 
@@ -4874,6 +4880,7 @@
 
 	if (register_netdev(dev)) {
 		DBG_PRINT(ERR_DBG, "Device registration failed\n");
+		ret = -ENODEV;
 		goto register_failed;
 	}
 
@@ -4900,7 +4907,7 @@
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
-	return -ENODEV;
+	return ret;
 }
 
 /**
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-26 16:45:59.329214424 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-26 16:45:48.079924576 -0700
@@ -50,10 +50,6 @@
 #define ALIGN_SIZE  			127
 #define	PCIX_COMMAND_REGISTER	0x62
 
-#ifndef SET_ETHTOOL_OPS
-#define SUPPORTED_10000baseT_Full (1 << 12)
-#endif
-
 /*
  * Debug related variables.
  */
@@ -873,9 +869,7 @@
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs);
 static int verify_xena_quiescence(u64 val64, int flag);
-#ifdef SET_ETHTOOL_OPS
 static struct ethtool_ops netdev_ethtool_ops;
-#endif
 static void s2io_set_link(unsigned long data);
 static void s2io_card_down(nic_t * nic);
 static int s2io_card_up(nic_t * nic);
