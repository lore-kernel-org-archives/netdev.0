From: akpm@osdl.org
Subject: [patch 01/10] xircom_tulip_cb.c build fix
Date: Tue, 04 Jan 2005 21:59:26 -0800
Message-ID: <200501050559.j055xZ614657@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org, bero@arklinux.org,
        bunk@stusta.de
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Bernhard Rosenkraenzer <bero@arklinux.org>,
      Adrian Bunk <bunk@stusta.de>

- Define `debug' before using it.

- remove now-unneeded module_parm_array hack.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tulip/xircom_tulip_cb.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff -puN drivers/net/tulip/xircom_tulip_cb.c~xircom_tulip_cb-build-fix drivers/net/tulip/xircom_tulip_cb.c
--- 25/drivers/net/tulip/xircom_tulip_cb.c~xircom_tulip_cb-build-fix	2005-01-04 21:54:38.251683304 -0800
+++ 25-akpm/drivers/net/tulip/xircom_tulip_cb.c	2005-01-04 21:54:41.815141576 -0800
@@ -33,6 +33,13 @@
 
 /* A few user-configurable values. */
 
+#define xircom_debug debug
+#ifdef XIRCOM_DEBUG
+static int xircom_debug = XIRCOM_DEBUG;
+#else
+static int xircom_debug = 1;
+#endif
+
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 25;
 
@@ -124,19 +131,11 @@ module_param(max_interrupt_work, int, 0)
 module_param(rx_copybreak, int, 0);
 module_param(csr0, int, 0);
 
-static int num_units;
-module_param_array(options, num_units, int, 0);
-module_param_array(full_duplex, num_units, int, 0);
+module_param_array(options, int, NULL, 0);
+module_param_array(full_duplex, int, NULL, 0);
 
 #define RUN_AT(x) (jiffies + (x))
 
-#define xircom_debug debug
-#ifdef XIRCOM_DEBUG
-static int xircom_debug = XIRCOM_DEBUG;
-#else
-static int xircom_debug = 1;
-#endif
-
 /*
 				Theory of Operation
 
_
