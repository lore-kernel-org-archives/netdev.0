From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.5] e1000: fix napi crash on ifdown during traffic
Date: Thu, 3 Jun 2004 18:29:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406031821580.4386-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0406031804340.4336-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <Pine.LNX.4.44.0406031804340.4336-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed off by: Jesse Brandeburg

diff -Naurp linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.mod/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-06-03 17:57:55.000000000 -0700
+++ linux-2.5/drivers/net/e1000.mod/e1000_main.c	2004-06-03 17:59:04.000000000 -0700
@@ -52,7 +52,7 @@
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.52-k2";
+char e1000_driver_version[] = "5.2.52-k4";
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -2143,6 +2143,7 @@ e1000_clean(struct net_device *netdev, i
 	if(work_done < work_to_do || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
+		return 0;
 	}
 
 	return (work_done >= work_to_do);
