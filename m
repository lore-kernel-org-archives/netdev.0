From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 23/24] mdio: mdio-nop: Dummy driver to testing
Date: Mon,  4 Jan 2016 18:37:01 +0100
Message-ID: <1451929022-5580-24-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35033 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbcADRkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:40:18 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a dummy driver which does nothing, but is useful for testing
the mdio device framework.
---
 drivers/net/phy/Kconfig    |  8 ++++++++
 drivers/net/phy/Makefile   |  1 +
 drivers/net/phy/mdio-nop.c | 37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+)
 create mode 100644 drivers/net/phy/mdio-nop.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 60994a83a0d6..107613354b14 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -256,6 +256,14 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+comment "MDIO devices"
+
+config MDIO_NOP
+       tristate "linux MDIO NOP driver"
+       help
+         MDIO driver which does nothing, other than test the MDIO framework.
+	 Say No, unless you are testing the framework.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 680e88f9915a..258542178c98 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -42,3 +42,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_MDIO_NOP)		+= mdio-nop.o
diff --git a/drivers/net/phy/mdio-nop.c b/drivers/net/phy/mdio-nop.c
new file mode 100644
index 000000000000..c2ff06c58a5c
--- /dev/null
+++ b/drivers/net/phy/mdio-nop.c
@@ -0,0 +1,37 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/mdio.h>
+
+static int mdio_nop_probe(struct mdio_device *mdiodev)
+{
+	dev_info(&mdiodev->dev, "mdio_nop_probe for address %d\n",
+		 mdiodev->addr);
+
+	return 0;
+}
+
+static void mdio_nop_remove(struct mdio_device *mdiodev)
+{
+	dev_info(&mdiodev->dev, "mdio_nop_remove for address %d\n",
+		 mdiodev->addr);
+}
+
+static const struct of_device_id mdio_nop_ids[] = {
+	{ .compatible = "linux,mdio-nop" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, mdio_nop_ids);
+
+struct mdio_driver mdio_nop_drv = {
+	.probe = mdio_nop_probe,
+	.remove = mdio_nop_remove,
+	.mdiodrv = {
+		.driver	= {
+			.name = "mdio-nop",
+			.of_match_table = mdio_nop_ids,
+		},
+	},
+};
+
+mdio_module_driver(mdio_nop_drv);
-- 
2.6.4
