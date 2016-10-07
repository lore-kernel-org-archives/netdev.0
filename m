From: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/10] mfd: sam: Add documentation for the SAM FPGA
Date: Fri,  7 Oct 2016 18:18:30 +0300
Message-ID: <1475853518-22264-3-git-send-email-pantelis.antoniou@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
        David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>,
        Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>,
        Debjit Ghosh <dghosh-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, li
To: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475853518-22264-1-git-send-email-pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>

Add DT bindings document for the SAM MFD device.

Signed-off-by: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
[Ported from Juniper kernel]
Signed-off-by: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
---
 Documentation/devicetree/bindings/mfd/jnx-sam.txt | 94 +++++++++++++++++++++++
 1 file changed, 94 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/mfd/jnx-sam.txt

diff --git a/Documentation/devicetree/bindings/mfd/jnx-sam.txt b/Documentation/devicetree/bindings/mfd/jnx-sam.txt
new file mode 100644
index 0000000..b4af7ea
--- /dev/null
+++ b/Documentation/devicetree/bindings/mfd/jnx-sam.txt
@@ -0,0 +1,94 @@
+Device-Tree bindings for Juniper Networks SAM MFD
+
+Required properties:
+
+- compatible - Must be: "jnx,sam"
+
+Optional properties:
+
+- pma-coefficients: A set of tupples containing the configuration of the PMA.
+
+Device                   Description
+------                   -----------
+jnx,i2c-sam		: I2C mux driver
+jnx,gpio-sam		: GPIO block
+jnx,flash-sam		: MTD Flash
+jnx,mdio-sam		: MDIO interfaces
+
+All these optional nodes are described in their respective binding
+documents.
+
+Example node:
+
+pci-0000-10-00.0 {
+	compatible = "jnx,sam";
+	#address-cells = <1>;
+	#size-cells = <0>;
+	pma-coefficients = <4 0x0>;
+
+	i2c-sam@10 {
+		compatible = "jnx,i2c-sam";
+		mux-channels = <2>;
+		master-offset = <0x10000>;
+	};
+
+	gpiogpqam0: gpio-sam@10 {
+		compatible = "jnx,gpio-sam";
+		gpio-controller;
+		#gpio-cells = <2>;
+		gpio-count = <297>;
+		interrupt-controller;
+		/*
+		* 1st cell: gpio interrupt status bit
+		* 2nd cell: 1st pin
+		* 3rd cell: # of pins
+		*/
+		gpio-interrupts =
+			<0 0 12>,   /* phy_int_monitor_en [16] */
+			<1 235 24>, /* qsfpp_fpga_int_monitor [17] */
+			<2 259 24>, /* qsfpp_fpga_modprs_monitor [18] */
+			<3 295 1>,  /* si5345_fpga_monitor [19] */
+			<4 294 1>;  /* fpc_pic_int_monitor [20] */
+	};
+
+	flash-sam@10 {
+		compatible = "jnx,flash-sam";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		partition@0 {
+		reg = <0x0 0x400000>;
+			label = "pic0-golden";
+			read-only;
+		};
+		partition@400000 {
+			reg = <0x400000 0x400000>;
+			label = "pic0-user";
+		};
+	};
+
+	mdio-sam@10 {
+		compatible = "jnx,mdio-sam";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0x40000>;
+
+		/* mii_bus types */
+		mdio0: mdio-sam@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x0>;
+		};
+
+		mdio1: mdio-sam@4000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x4000>;
+		};
+
+		mdio2: mdio-sam@8000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x8000>;
+		};
+	};
+};
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
