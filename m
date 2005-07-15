From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] Use time_before in hamradio drivers
Date: Fri, 15 Jul 2005 11:16:42 +0100
Message-ID: <20050715101642.GA11823@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Marcelo Feitoza Parisi <marcelo@feitoza.com.br>,
	domen@coderock.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Feitoza Parisi <marcelo@feitoza.com.br>


Use of time_before() macro, defined at linux/jiffies.h, which deal with
wrapping correctly and are nicer to read.

Signed-off-by: Marcelo Feitoza Parisi <marcelo@feitoza.com.br>
Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 baycom_epp.c     |    3 ++-
 baycom_par.c     |    3 ++-
 baycom_ser_fdx.c |    3 ++-
 baycom_ser_hdx.c |    3 ++-
 mkiss.c          |    3 ++-
 5 files changed, 10 insertions(+), 5 deletions(-)

Index: linux-cvs/drivers/net/hamradio/mkiss.c
===================================================================
--- linux-cvs.orig/drivers/net/hamradio/mkiss.c	2005-07-15 11:11:26.000000000 +0100
+++ linux-cvs/drivers/net/hamradio/mkiss.c	2005-07-15 11:12:40.000000000 +0100
@@ -46,6 +46,7 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
+#include <linux/jiffies.h>
 
 #include <net/ax25.h>
 
@@ -429,7 +430,7 @@
 		 * May be we must check transmitter timeout here ?
 		 *      14 Oct 1994 Dmitry Gorodchanin.
 		 */
-		if (jiffies - dev->trans_start  < 20 * HZ) {
+		if (time_before(jiffies, dev->trans_start + 20 * HZ)) {
 			/* 20 sec timeout not reached */
 			return 1;
 		}
Index: linux-cvs/drivers/net/hamradio/baycom_ser_fdx.c
===================================================================
--- linux-cvs.orig/drivers/net/hamradio/baycom_ser_fdx.c	2005-07-15 11:11:26.000000000 +0100
+++ linux-cvs/drivers/net/hamradio/baycom_ser_fdx.c	2005-07-15 11:12:40.000000000 +0100
@@ -79,6 +79,7 @@
 #include <asm/io.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
+#include <linux/jiffies.h>
 
 /* --------------------------------------------------------------------- */
 
@@ -159,7 +160,7 @@
 	 * measure the interrupt frequency
 	 */
 	bc->debug_vals.cur_intcnt++;
-	if ((cur_jiffies - bc->debug_vals.last_jiffies) >= HZ) {
+	if (time_after_eq(cur_jiffies, bc->debug_vals.last_jiffies + HZ)) {
 		bc->debug_vals.last_jiffies = cur_jiffies;
 		bc->debug_vals.last_intcnt = bc->debug_vals.cur_intcnt;
 		bc->debug_vals.cur_intcnt = 0;
Index: linux-cvs/drivers/net/hamradio/baycom_ser_hdx.c
===================================================================
--- linux-cvs.orig/drivers/net/hamradio/baycom_ser_hdx.c	2005-07-15 11:11:26.000000000 +0100
+++ linux-cvs/drivers/net/hamradio/baycom_ser_hdx.c	2005-07-15 11:12:40.000000000 +0100
@@ -69,6 +69,7 @@
 #include <asm/io.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
+#include <linux/jiffies.h>
 
 /* --------------------------------------------------------------------- */
 
@@ -150,7 +151,7 @@
 	 * measure the interrupt frequency
 	 */
 	bc->debug_vals.cur_intcnt++;
-	if ((cur_jiffies - bc->debug_vals.last_jiffies) >= HZ) {
+	if (time_after_eq(cur_jiffies, bc->debug_vals.last_jiffies + HZ)) {
 		bc->debug_vals.last_jiffies = cur_jiffies;
 		bc->debug_vals.last_intcnt = bc->debug_vals.cur_intcnt;
 		bc->debug_vals.cur_intcnt = 0;
Index: linux-cvs/drivers/net/hamradio/baycom_epp.c
===================================================================
--- linux-cvs.orig/drivers/net/hamradio/baycom_epp.c	2005-07-15 11:11:26.000000000 +0100
+++ linux-cvs/drivers/net/hamradio/baycom_epp.c	2005-07-15 11:12:40.000000000 +0100
@@ -54,6 +54,7 @@
 #include <linux/kmod.h>
 #include <linux/hdlcdrv.h>
 #include <linux/baycom.h>
+#include <linux/jiffies.h>
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 /* prototypes for ax25_encapsulate and ax25_rebuild_header */
 #include <net/ax25.h> 
@@ -287,7 +288,7 @@
 	 * measure the interrupt frequency
 	 */
 	bc->debug_vals.cur_intcnt++;
-	if ((cur_jiffies - bc->debug_vals.last_jiffies) >= HZ) {
+	if (time_after_eq(cur_jiffies, bc->debug_vals.last_jiffies + HZ)) {
 		bc->debug_vals.last_jiffies = cur_jiffies;
 		bc->debug_vals.last_intcnt = bc->debug_vals.cur_intcnt;
 		bc->debug_vals.cur_intcnt = 0;
Index: linux-cvs/drivers/net/hamradio/baycom_par.c
===================================================================
--- linux-cvs.orig/drivers/net/hamradio/baycom_par.c	2005-07-15 11:11:26.000000000 +0100
+++ linux-cvs/drivers/net/hamradio/baycom_par.c	2005-07-15 11:12:40.000000000 +0100
@@ -84,6 +84,7 @@
 #include <linux/baycom.h>
 #include <linux/parport.h>
 #include <linux/bitops.h>
+#include <linux/jiffies.h>
 
 #include <asm/bug.h>
 #include <asm/system.h>
@@ -165,7 +166,7 @@
 	 * measure the interrupt frequency
 	 */
 	bc->debug_vals.cur_intcnt++;
-	if ((cur_jiffies - bc->debug_vals.last_jiffies) >= HZ) {
+	if (time_after_eq(cur_jiffies, bc->debug_vals.last_jiffies + HZ)) {
 		bc->debug_vals.last_jiffies = cur_jiffies;
 		bc->debug_vals.last_intcnt = bc->debug_vals.cur_intcnt;
 		bc->debug_vals.cur_intcnt = 0;
