From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 3/16 2.5] ixgb: Fix endianess issue for Tx cleanup
Date: Fri, 15 Oct 2004 06:54:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150622460.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -1677,7 +1677,7 @@ static boolean_t ixgb_clean_tx_irq(struc
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->status & cpu_to_le32(IXGB_TX_DESC_STATUS_DD)) {
+	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
 		for (cleaned = FALSE; !cleaned;) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
