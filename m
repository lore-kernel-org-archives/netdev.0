From: Paul Burton <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4 3/7] dt-bindings: net: Document Intel pch_gbe binding
Date: Mon, 5 Jun 2017 10:31:32 -0700
Message-ID: <20170605173136.10795-4-paul.burton@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170605173136.10795-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>,
        Paul Burton <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170605173136.10795-1-paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Introduce documentation for a device tree binding for the Intel Platform
Controller Hub (PCH) GigaBit Ethernet (GBE) device. Although this is a
PCIe device & thus largely auto-detectable, this binding will be used to
provide the driver with the PHY reset GPIO.

Signed-off-by: Paul Burton <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

---

Changes in v4: None

Changes in v3:
- New patch.

Changes in v2: None

 Documentation/devicetree/bindings/net/pch_gbe.txt | 25 +++++++++++++++++++++++
 1 file changed, 25 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/pch_gbe.txt

diff --git a/Documentation/devicetree/bindings/net/pch_gbe.txt b/Documentation/devicetree/bindings/net/pch_gbe.txt
new file mode 100644
index 000000000000..5de479c26b04
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/pch_gbe.txt
@@ -0,0 +1,25 @@
+Intel Platform Controller Hub (PCH) GigaBit Ethernet (GBE)
+
+Required properties:
+- compatible:		Should be the PCI vendor & device ID, eg. "pci8086,8802".
+- reg:			Should be a PCI device number as specified by the PCI bus
+			binding to IEEE Std 1275-1994.
+- phy-reset-gpios:	Should be a GPIO list containing a single GPIO that
+			resets the attached PHY when active.
+
+Example:
+
+	eg20t_mac@2,0,1 {
+		compatible = "pci8086,8802";
+		reg = <0x00020100 0 0 0 0>;
+		phy-reset-gpios = <&eg20t_gpio 6
+				   GPIO_ACTIVE_LOW>;
+	};
+
+	eg20t_gpio: eg20t_gpio@2,0,2 {
+		compatible = "pci8086,8803";
+		reg = <0x00020200 0 0 0 0>;
+
+		gpio-controller;
+		#gpio-cells = <2>;
+	};
-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
