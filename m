From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] via-velocity: convert to module_param
Date: Mon, 29 Nov 2004 09:40:32 -0800
Message-ID: <20041129094032.3b9cb540@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert via-velocity driver to module_param.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
--- a/drivers/net/via-velocity.c	2004-11-29 09:39:10 -08:00
+++ b/drivers/net/via-velocity.c	2004-11-29 09:39:10 -08:00
@@ -100,8 +100,8 @@
 MODULE_DESCRIPTION("VIA Networking Velocity Family Gigabit Ethernet Adapter Driver");
 
 #define VELOCITY_PARAM(N,D) \
-        static const int N[MAX_UNITS]=OPTION_DEFAULT;\
-        MODULE_PARM(N, "1-" __MODULE_STRING(MAX_UNITS) "i");\
+        static int N[MAX_UNITS]=OPTION_DEFAULT;\
+	module_param_array(N, int, NULL, 0); \
         MODULE_PARM_DESC(N, D);
 
 #define RX_DESC_MIN     64
@@ -229,7 +229,7 @@
 VELOCITY_PARAM(int_works, "Number of packets per interrupt services");
 
 static int rx_copybreak = 200;
-MODULE_PARM(rx_copybreak, "i");
+module_param(rx_copybreak, int, 0644);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
 static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr, struct velocity_info_tbl *info);
