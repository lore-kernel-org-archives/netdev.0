From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 2.6] ixgb - fix bug in transmit cleanup for ppc64
Date: Mon, 2 Aug 2004 18:51:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408021847070.9894-100000@westville2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes an endianness error when on PPC64 arch.
Signed off by: Jesse Brandeburg <jesse.brandeburg@intel.com>

diff -Nurp --exclude=CVS linux-2.6.7/drivers/net/ixgb/ixgb_main.c linux-2.6.7_mod/drivers/net/ixgb/ixgb_main.c
--- linux-2.6.7/drivers/net/ixgb/ixgb_main.c	2004-06-16 05:19:01.000000000 +0000
+++ linux-2.6.7_mod/drivers/net/ixgb/ixgb_main.c	2004-08-03 01:34:52.000000000 +0000
@@ -1677,7 +1677,7 @@ static boolean_t ixgb_clean_tx_irq(struc
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->status & cpu_to_le32(IXGB_TX_DESC_STATUS_DD)) {
+	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
 		for (cleaned = FALSE; !cleaned;) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
