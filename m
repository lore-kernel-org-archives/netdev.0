From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 1/1 2.6] RESEND ixgb: fix endianness issue for tx cleanup
Date: Wed, 22 Sep 2004 12:30:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409221227470.7544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes tx cleanup so that it works correctly on big endian 
machines.
This time I remembered to update the version string.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-09-21 13:54:34.000000000 -0700
+++ /home/jbrandeb/netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-09-22 12:01:42.000000000 -0700
@@ -30,7 +30,7 @@
 
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
-char ixgb_driver_version[] = "1.0.66";
+char ixgb_driver_version[] = "1.0.66-k2";
 char ixgb_copyright[] = "Copyright (c) 2001-2004 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -1676,7 +1676,7 @@ static boolean_t ixgb_clean_tx_irq(struc
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->status & cpu_to_le32(IXGB_TX_DESC_STATUS_DD)) {
+	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
 		for (cleaned = FALSE; !cleaned;) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
