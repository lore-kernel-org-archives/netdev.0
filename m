From: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Wed, 13 Jul 2016 12:20:04 +0200
Message-ID: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On some boards (android tablets) different batches use different sdio
wifi modules. This is not a problem since sdio is a discoverable bus,
so we only need to describe and activate the mmc controller in dt and
then the kernel will automatically load the right driver.

But sometimes it is useful to specify certain ethernet properties for
these "unknown" sdio devices, specifically we want the boot-loader
to be able to set "local-mac-address" as some of these sdio wifi
modules come without an eeprom / without a factory programmed mac
address.

Since the exact device is unknown (differs per batch) we cannot use
a wifi-chip specific compatible. This commit adds a new
"generic,ethernet" binding for use in dt-nodes describing such an
unknown ethernet device.

Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 Documentation/devicetree/bindings/net/generic.txt | 30 +++++++++++++++++++++++
 1 file changed, 30 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/generic.txt

diff --git a/Documentation/devicetree/bindings/net/generic.txt b/Documentation/devicetree/bindings/net/generic.txt
new file mode 100644
index 0000000..2325709
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/generic.txt
@@ -0,0 +1,30 @@
+* Generic ethernet controller
+
+This binding is for ethernet devices which need a dt node so that certain
+standard properties, e.g. a mac-address can be specified via dt, but
+otherwise can be detected automatically as they are on a discoverable bus.
+
+Required properties:
+- compatible: should be "generic,ethernet"
+
+Optional properties:
+- See bindings/ethernet.txt
+
+Example:
+
+/ {
+	aliases {
+		/* Make u-boot set mac-address for the sdio-wifi (no eeprom) */
+		ethernet0 = &sdio_wifi;
+	};
+};
+
+&mmc1 {
+	non-removable;
+	status = "okay";
+
+	sdio_wifi: sdio_wifi@1 {
+		compatible = "generic,ethernet"
+		reg = <1>;
+	};
+};
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
