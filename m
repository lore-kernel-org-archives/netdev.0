From: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Subject: [PATCH net v4 2/3] dt-binding: net: sfp binding documentation
Date: Thu,  7 Sep 2017 12:25:49 +0300
Message-ID: <5b46343b543ad1d2ebbc5be9871def7f92c4dbd8.1504776350.git.baruch@tkos.co.il>
References: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch@tkos.co.il>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add device-tree binding documentation SFP transceivers. Support for SFP
transceivers has been recently introduced (drivers/net/phy/sfp.c).

Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
---
v4:
  Remove redundant 'single' from the gpio specifier
  Rename 'moddef0-gpios' property to 'mod-def0-gpios'
  Remove 'phy-mode' property from the example; SFP determines the mode

v3:
  Mention gpios phandle and specifier
  Mention the polarity of each gpio
  Fix example property names

v2:
  Rename -gpio properties to -gpios
  Rename the rate-select-gpio property to rate-select0-gpios
  Add the rate-select1-gpios property
  Add examples
---
 Documentation/devicetree/bindings/net/sff,sfp.txt | 76 +++++++++++++++++++++++
 1 file changed, 76 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt

diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
new file mode 100644
index 000000000000..60e970ce10ee
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
@@ -0,0 +1,76 @@
+Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
+Transceiver
+
+Required properties:
+
+- compatible : must be "sff,sfp"
+
+Optional Properties:
+
+- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
+  interface
+
+- mod-def0-gpios : GPIO phandle and a specifier of the MOD-DEF0 (AKA Mod_ABS)
+  module presence input gpio signal, active (module absent) high
+
+- los-gpios : GPIO phandle and a specifier of the Receiver Loss of Signal
+  Indication input gpio signal, active (signal lost) high
+
+- tx-fault-gpios : GPIO phandle and a specifier of the Module Transmitter
+  Fault input gpio signal, active (fault condition) high
+
+- tx-disable-gpios : GPIO phandle and a specifier of the Transmitter Disable
+  output gpio signal, active (Tx disable) high
+
+- rate-select0-gpios : GPIO phandle and a specifier of the Rx Signaling Rate
+  Select (AKA RS0) output gpio signal, low: low Rx rate, high: high Rx rate
+
+- rate-select1-gpios : GPIO phandle and a specifier of the Tx Signaling Rate
+  Select (AKA RS1) output gpio signal (SFP+ only), low: low Tx rate, high:
+  high Tx rate
+
+Example #1: Direct serdes to SFP connection
+
+sfp_eth3: sfp-eth3 {
+	compatible = "sff,sfp";
+	i2c-bus = <&sfp_1g_i2c>;
+	los-gpios = <&cpm_gpio2 22 GPIO_ACTIVE_HIGH>;
+	mod-def0-gpios = <&cpm_gpio2 21 GPIO_ACTIVE_LOW>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&cpm_sfp_1g_pins &cps_sfp_1g_pins>;
+	tx-disable-gpios = <&cps_gpio1 24 GPIO_ACTIVE_HIGH>;
+	tx-fault-gpios = <&cpm_gpio2 19 GPIO_ACTIVE_HIGH>;
+};
+
+&cps_emac3 {
+	phy-names = "comphy";
+	phys = <&cps_comphy5 0>;
+	sfp = <&sfp_eth3>;
+};
+
+Example #2: Serdes to PHY to SFP connection
+
+sfp_eth0: sfp-eth0 {
+	compatible = "sff,sfp";
+	i2c-bus = <&sfpp0_i2c>;
+	los-gpios = <&cps_gpio1 28 GPIO_ACTIVE_HIGH>;
+	mod-def0-gpios = <&cps_gpio1 27 GPIO_ACTIVE_LOW>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&cps_sfpp0_pins>;
+	tx-disable-gpios = <&cps_gpio1 29 GPIO_ACTIVE_HIGH>;
+	tx-fault-gpios  = <&cps_gpio1 26 GPIO_ACTIVE_HIGH>;
+};
+
+p0_phy: ethernet-phy@0 {
+	compatible = "ethernet-phy-ieee802.3-c45";
+	pinctrl-names = "default";
+	pinctrl-0 = <&cpm_phy0_pins &cps_phy0_pins>;
+	reg = <0>;
+	interrupt = <&cpm_gpio2 18 IRQ_TYPE_EDGE_FALLING>;
+	sfp = <&sfp_eth0>;
+};
+
+&cpm_eth0 {
+	phy = <&p0_phy>;
+	phy-mode = "10gbase-kr";
+};
-- 
2.14.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
