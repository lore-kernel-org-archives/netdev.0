From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] get rid of __OPTIMIZE__ requirement in net drivers
Date: Tue, 22 Jun 2004 11:30:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622113052.1ef2cb7b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several network drivers have checks that they are only built with -O.
This breaks checking with sparse and other tools, and seems like a holdover from
when drivers were built out of tree and the kernel build system was less stable.
This patch gets rid of these.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/3c59x.c	2004-06-22 11:28:15 -07:00
@@ -238,12 +238,6 @@
 static int vortex_debug = 1;
 #endif
 
-#ifndef __OPTIMIZE__
-#error You must compile this file with the correct options!
-#error See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/eepro100.c	2004-06-22 11:28:15 -07:00
@@ -87,12 +87,6 @@
 /* Size of an pre-allocated Rx buffer: <Ethernet MTU> + slack.*/
 #define PKT_BUF_SZ		1536
 
-#if !defined(__OPTIMIZE__)  ||  !defined(__KERNEL__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/config.h>
 #include <linux/version.h>
 #include <linux/module.h>
diff -Nru a/drivers/net/epic100.c b/drivers/net/epic100.c
--- a/drivers/net/epic100.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/epic100.c	2004-06-22 11:28:15 -07:00
@@ -116,12 +116,6 @@
 #define TX_FIFO_THRESH 256
 #define RX_FIFO_THRESH 1		/* 0-3, 0==32, 64,96, or 3==128 bytes  */
 
-#if !defined(__OPTIMIZE__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/natsemi.c	2004-06-22 11:28:15 -07:00
@@ -139,12 +139,6 @@
 	* NAPI
 */
 
-#if !defined(__OPTIMIZE__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
--- a/drivers/net/sb1250-mac.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/sb1250-mac.c	2004-06-22 11:28:15 -07:00
@@ -55,12 +55,6 @@
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (2*HZ)
 
-#if !defined(__OPTIMIZE__)  ||  !defined(__KERNEL__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error  You must compile this driver with "-O".
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-06-22 11:28:15 -07:00
@@ -58,12 +58,6 @@
 
 #define SK_ADDR_EQUAL(a1,a2)		(!memcmp(a1,a2,6))
 
-#if !defined(__OPTIMIZE__)  ||  !defined(__KERNEL__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/version.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/sundance.c	2004-06-22 11:28:15 -07:00
@@ -148,15 +148,6 @@
 #define TX_TIMEOUT  (4*HZ)
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
 
-#ifndef __KERNEL__
-#define __KERNEL__
-#endif
-#if !defined(__OPTIMIZE__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 /* Include files, designed to support most kernel versions 2.0.0 and later. */
 #include <linux/module.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/tulip/winbond-840.c	2004-06-22 11:28:15 -07:00
@@ -111,15 +111,6 @@
 
 #define PKT_BUF_SZ		1536			/* Size of each temporary Rx buffer.*/
 
-#ifndef __KERNEL__
-#define __KERNEL__
-#endif
-#if !defined(__OPTIMIZE__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 /* Include files, designed to support most kernel versions 2.0.0 and later. */
 #include <linux/module.h>
 #include <linux/kernel.h>
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/typhoon.c	2004-06-22 11:28:15 -07:00
@@ -90,12 +90,6 @@
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
-#if !defined(__OPTIMIZE__)  ||  !defined(__KERNEL__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error  You must compile this driver with "-O".
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/via-rhine.c	2004-06-22 11:28:15 -07:00
@@ -183,12 +183,6 @@
 
 #define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer.*/
 
-#if !defined(__OPTIMIZE__)  ||  !defined(__KERNEL__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error  You must compile this driver with "-O".
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	2004-06-22 11:28:15 -07:00
+++ b/drivers/net/yellowfin.c	2004-06-22 11:28:15 -07:00
@@ -108,12 +108,6 @@
 
 #define yellowfin_debug debug
 
-#if !defined(__OPTIMIZE__)
-#warning  You must compile this file with the correct options!
-#warning  See the last lines of the source file.
-#error You must compile this driver with "-O".
-#endif
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
