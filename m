From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 6/6] handle register_netdev failure
Date: Sat, 21 Feb 2004 23:39:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212334510.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* driver not handling failures of register_netdev 
  [Stephen Hemminger (shemminger@osdl.org)]

------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-20 14:09:07.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-20 14:09:55.000000000 -0800
@@ -68,7 +68,7 @@
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.30.1-k1";
+char e1000_driver_version[] = "5.2.30.1-k2";
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -529,7 +529,8 @@ e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->tx_timeout_task,
 		(void (*)(void *))e1000_tx_timeout_task, netdev);
 
-	register_netdev(netdev);
+	if((err = register_netdev(netdev)))
+		goto err_register;
 
 	/* we're going to reset, so assume we have no link for now */
 
@@ -574,6 +575,7 @@ e1000_probe(struct pci_dev *pdev,
 	cards_found++;
 	return 0;
 
+err_register:
 err_sw_init:
 err_eeprom:
 	iounmap(adapter->hw.hw_addr);
