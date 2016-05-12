From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 12:00:33 +0200
Message-ID: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, "Andrew F . Davis" <afd-l0cyMroinI0@public.gmane.org>,
	Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The framework only asserts (for now) that the reset gpio is not active.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 Documentation/devicetree/bindings/net/phy.txt | 3 +++
 drivers/net/phy/phy_device.c                  | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentat=
ion/devicetree/bindings/net/phy.txt
index bc1c3c8bf8fa..c00a9a894547 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -35,6 +35,8 @@ Optional Properties:
 - broken-turn-around: If set, indicates the PHY device does not correc=
tly
   release the turn around line low at the end of a MDIO transaction.
=20
+- reset-gpios: Reference to a GPIO used to reset the phy.
+
 Example:
=20
 ethernet-phy@0 {
@@ -42,4 +44,5 @@ ethernet-phy@0 {
 	interrupt-parent =3D <40000>;
 	interrupts =3D <35 1>;
 	reg =3D <0>;
+	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
 };
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.=
c
index e551f3a89cfd..7d666ab47271 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -34,6 +34,7 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/of.h>
+#include <linux/gpio/consumer.h>
=20
 #include <asm/irq.h>
=20
@@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
 	struct device_driver *drv =3D phydev->mdio.dev.driver;
 	struct phy_driver *phydrv =3D to_phy_driver(drv);
 	int err =3D 0;
+	struct gpio_descs *reset_gpios;
=20
 	phydev->drv =3D phydrv;
=20
+	/* take phy out of reset */
+	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
+						    GPIOD_OUT_LOW);
+	if (IS_ERR(reset_gpios))
+		return PTR_ERR(reset_gpios);
+
 	/* Disable the interrupt if the PHY doesn't support it
 	 * but the interrupt is still a valid one
 	 */
--=20
2.8.0.rc3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
