From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: [PATCH 3/4] IrDA: smsc-ircc: Minimal hotplug support.
Date: Tue, 9 May 2006 00:23:59 +0300
Message-ID: <20060508212359.GD20933@irie>
Reply-To: Samuel Ortiz <samuel.ortiz@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>,
	IrDA users <irda-users@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext13.nokia.com ([131.228.20.172]:23530 "EHLO
	mgw-ext13.nokia.com") by vger.kernel.org with ESMTP
	id S1751110AbWEHVg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 17:36:57 -0400
To: "ext David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minimal PNP hotplug support for the smsc-ircc2 driver.  A modular driver
will be modprobed via hotplug, but still bypasses driver model probing.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>


---

 drivers/net/irda/smsc-ircc2.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

863409d3d18ed6194ef84d813bb316248a9ea0a3
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 58f76ce..a467404 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -54,6 +54,7 @@ #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
 #include <linux/dma-mapping.h>
+#include <linux/pnp.h>
 #include <linux/platform_device.h>
 
 #include <asm/io.h>
@@ -358,6 +359,16 @@ static inline void register_bank(int iob
                iobase + IRCC_MASTER);
 }
 
+#ifdef	CONFIG_PNP
+/* PNP hotplug support */
+static const struct pnp_device_id smsc_ircc_pnp_table[] = {
+	{ .id = "SMCf010", .driver_data = 0 },
+	/* and presumably others */
+	{ }
+};
+MODULE_DEVICE_TABLE(pnp, smsc_ircc_pnp_table);
+#endif
+
 
 /*******************************************************************************
  *
@@ -2072,7 +2083,8 @@ static void smsc_ircc_sir_wait_hw_transm
 
 /* PROBING
  *
- *
+ * REVISIT we can be told about the device by PNP, and should use that info
+ * instead of probing hardware and creating a platform_device ...
  */
 
 static int __init smsc_ircc_look_for_chips(void)
-- 
1.3.1

