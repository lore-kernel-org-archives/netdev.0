From: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH RESEND v3 4/8] wdt: Device tree support for pnx4008-wdt
Date: Sat, 14 Apr 2012 00:36:35 +0200
Message-ID: <1334356600-20950-4-git-send-email-stigge@antcom.de>
References: <1334356600-20950-1-git-send-email-stigge@antcom.de>
Cc: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
To: arm-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, srinivas.bakki-3arQi8VN3Tc@public.gmane.org, kevin.wells-3arQi8VN3Tc@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org, jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334356600-20950-1-git-send-email-stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds watchdog support to pnx4008-wdt.c

Signed-off-by: Roland Stigge <stigge-uj/7R2tJ6VmzQB+pC5nmwQ@public.gmane.org>
Reviewed-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

---

 Applies to v3.4-rc2

 Documentation/devicetree/bindings/watchdog/pnx4008-wdt.txt |   13 +++++++++++++
 drivers/watchdog/pnx4008_wdt.c                             |   10 ++++++++++
 2 files changed, 23 insertions(+)

--- /dev/null
+++ linux-2.6/Documentation/devicetree/bindings/watchdog/pnx4008-wdt.txt
@@ -0,0 +1,13 @@
+* NXP PNX watchdog timer
+
+Required properties:
+- compatible: must be "nxp,pnx4008-wdt"
+- reg: physical base address of the controller and length of memory mapped
+  region.
+
+Example:
+
+	watchdog@4003C000 {
+		compatible = "nxp,pnx4008-wdt";
+		reg = <0x4003C000 0x1000>;
+	};
--- linux-2.6.orig/drivers/watchdog/pnx4008_wdt.c
+++ linux-2.6/drivers/watchdog/pnx4008_wdt.c
@@ -32,6 +32,7 @@
 #include <linux/io.h>
 #include <linux/slab.h>
 #include <linux/err.h>
+#include <linux/of.h>
 #include <mach/hardware.h>
 
 /* WatchDog Timer - Chapter 23 Page 207 */
@@ -201,10 +202,19 @@ static int __devexit pnx4008_wdt_remove(
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id pnx4008_wdt_match[] = {
+	{ .compatible = "nxp,pnx4008-wdt" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, pnx4008_wdt_match);
+#endif
+
 static struct platform_driver platform_wdt_driver = {
 	.driver = {
 		.name = "pnx4008-watchdog",
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(pnx4008_wdt_match),
 	},
 	.probe = pnx4008_wdt_probe,
 	.remove = __devexit_p(pnx4008_wdt_remove),
