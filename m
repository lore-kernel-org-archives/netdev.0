From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] r8169: add NAPI suffix
Date: Wed, 9 Mar 2005 11:36:47 -0800
Message-ID: <20050309113647.174b1b5c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To tell if driver is configured for NAPI or not, put -NAPI on driver
version rather than putting message on console.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2005-03-09 11:24:24 -08:00
+++ b/drivers/net/r8169.c	2005-03-09 11:24:24 -08:00
@@ -69,7 +69,13 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 
-#define RTL8169_VERSION "2.2LK"
+#ifdef CONFIG_R8169_NAPI
+#define NAPI_SUFFIX	"-NAPI"
+#else
+#define NAPI_SUFFIX	""
+#endif
+
+#define RTL8169_VERSION "2.2LK" NAPI_SUFFIX
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -1364,7 +1370,6 @@
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
 	dev->weight = R8169_NAPI_WEIGHT;
-	printk(KERN_INFO PFX "NAPI enabled\n");
 #endif
 
 #ifdef CONFIG_R8169_VLAN
