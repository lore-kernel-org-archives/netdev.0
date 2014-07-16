From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 1/2] net: davinci_mdio: reuse for keystone2 arch
Date: Wed, 16 Jul 2014 15:13:02 +0300
Message-ID: <1405512783-20307-2-git-send-email-grygorii.strashko@ti.com>
References: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<santosh.shilimkar-l0cyMroinI0@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405512783-20307-1-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The similar MDIO HW blocks is used by keystone 2 SoCs as
in Davinci SoCs:
- one in Gigabit Ethernet (GbE) Switch Subsystem
  See http://www.ti.com/lit/ug/sprugv9d/sprugv9d.pdf
- one in 10 Gigabit Ethernet Subsystem
  See http://www.ti.com/lit/ug/spruhj5/spruhj5.pdf

Hence, reuse Davinci MDIO driver for Keystone 2 and
enable TI networking for Keystone 2 devices

Reviewed-by: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
Acked-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
---
 .../devicetree/bindings/net/davinci-mdio.txt       |    8 ++++----
 drivers/net/ethernet/ti/Kconfig                    |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
index 72efaaf..0369e25 100644
--- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
+++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
@@ -1,8 +1,8 @@
-TI SoC Davinci MDIO Controller Device Tree Bindings
+TI SoC Davinci/Keystone2 MDIO Controller Device Tree Bindings
 ---------------------------------------------------
 
 Required properties:
-- compatible		: Should be "ti,davinci_mdio"
+- compatible		: Should be "ti,davinci_mdio" or "ti,keystone_mdio"
 - reg			: physical base address and size of the davinci mdio
 			  registers map
 - bus_freq		: Mdio Bus frequency
@@ -19,7 +19,7 @@ file.
 Examples:
 
 	mdio: davinci_mdio@4A101000 {
-		compatible = "ti,cpsw";
+		compatible = "ti,davinci_mdio";
 		reg = <0x4A101000 0x1000>;
 		bus_freq = <1000000>;
 	};
@@ -27,7 +27,7 @@ Examples:
 (or)
 
 	mdio: davinci_mdio@4A101000 {
-		compatible = "ti,cpsw";
+		compatible = "ti,davinci_mdio";
 		ti,hwmods = "davinci_mdio";
 		bus_freq = <1000000>;
 	};
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 53150c2..1769700 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_TI
 	bool "Texas Instruments (TI) devices"
 	default y
-	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX))
+	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE))
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -32,7 +32,7 @@ config TI_DAVINCI_EMAC
 
 config TI_DAVINCI_MDIO
 	tristate "TI DaVinci MDIO Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE )
 	select PHYLIB
 	---help---
 	  This driver supports TI's DaVinci MDIO module.
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
