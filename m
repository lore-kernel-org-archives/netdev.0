From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] get rid of warnings about #if DEBUG
Date: Tue, 22 Jun 2004 13:52:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622135253.43a9acde@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several drivers use '#if DEBUG' which is a warning under the sparse checker.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-06-22 13:47:25 -07:00
+++ b/drivers/net/acenic.c	2004-06-22 13:47:25 -07:00
@@ -1634,7 +1634,7 @@
 	cur_size = atomic_read(&ap->cur_rx_bufs);
 	if ((cur_size < RX_LOW_STD_THRES) &&
 	    !test_and_set_bit(0, &ap->std_refill_busy)) {
-#if DEBUG
+#ifdef DEBUG
 		printk("refilling buffers (current %i)\n", cur_size);
 #endif
 		ace_load_std_rx_ring(ap, RX_RING_SIZE - cur_size);
@@ -1644,7 +1644,7 @@
 		cur_size = atomic_read(&ap->cur_mini_bufs);
 		if ((cur_size < RX_LOW_MINI_THRES) &&
 		    !test_and_set_bit(0, &ap->mini_refill_busy)) {
-#if DEBUG
+#ifdef DEBUG
 			printk("refilling mini buffers (current %i)\n",
 			       cur_size);
 #endif
@@ -1655,7 +1655,7 @@
 	cur_size = atomic_read(&ap->cur_jumbo_bufs);
 	if (ap->jumbo && (cur_size < RX_LOW_JUMBO_THRES) &&
 	    !test_and_set_bit(0, &ap->jumbo_refill_busy)) {
-#if DEBUG
+#ifdef DEBUG
 		printk("refilling jumbo buffers (current %i)\n", cur_size);
 #endif
 		ace_load_jumbo_rx_ring(ap, RX_JUMBO_SIZE - cur_size);
@@ -2255,7 +2255,7 @@
 		if (cur_size < RX_LOW_STD_THRES) {
 			if ((cur_size < RX_PANIC_STD_THRES) &&
 			    !test_and_set_bit(0, &ap->std_refill_busy)) {
-#if DEBUG
+#ifdef DEBUG
 				printk("low on std buffers %i\n", cur_size);
 #endif
 				ace_load_std_rx_ring(ap,
@@ -2270,7 +2270,7 @@
 				if ((cur_size < RX_PANIC_MINI_THRES) &&
 				    !test_and_set_bit(0,
 						      &ap->mini_refill_busy)) {
-#if DEBUG
+#ifdef DEBUG
 					printk("low on mini buffers %i\n",
 					       cur_size);
 #endif
@@ -2286,7 +2286,7 @@
 				if ((cur_size < RX_PANIC_JUMBO_THRES) &&
 				    !test_and_set_bit(0,
 						      &ap->jumbo_refill_busy)){
-#if DEBUG
+#ifdef DEBUG
 					printk("low on jumbo buffers %i\n",
 					       cur_size);
 #endif
diff -Nru a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
--- a/drivers/net/ixgb/ixgb.h	2004-06-22 13:47:25 -07:00
+++ b/drivers/net/ixgb/ixgb.h	2004-06-22 13:47:25 -07:00
@@ -77,7 +77,7 @@
 #include "ixgb_ee.h"
 #include "ixgb_ids.h"
 
-#if _DEBUG_DRIVER_
+#ifdef _DEBUG_DRIVER_
 #define IXGB_DBG(args...) printk(KERN_DEBUG "ixgb: " args)
 #else
 #define IXGB_DBG(args...)
diff -Nru a/drivers/net/wan/sbni.h b/drivers/net/wan/sbni.h
--- a/drivers/net/wan/sbni.h	2004-06-22 13:47:25 -07:00
+++ b/drivers/net/wan/sbni.h	2004-06-22 13:47:25 -07:00
@@ -6,7 +6,7 @@
 #ifndef SBNI_H
 #define SBNI_H
 
-#if SBNI_DEBUG
+#ifdef SBNI_DEBUG
 #define DP( A ) A
 #else
 #define DP( A )
diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	2004-06-22 13:47:25 -07:00
+++ b/drivers/net/yellowfin.c	2004-06-22 13:47:25 -07:00
@@ -65,7 +65,7 @@
 static int bogus_rx;
 static int dma_ctrl = 0x004A0263; 			/* Constrained by errata */
 static int fifo_cfg = 0x0020;				/* Bypass external Tx FIFO. */
-#elif YF_NEW					/* A future perfect board :->.  */
+#elif defined(YF_NEW)					/* A future perfect board :->.  */
 static int dma_ctrl = 0x00CAC277;			/* Override when loading module! */
 static int fifo_cfg = 0x0028;
 #else
