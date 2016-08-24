From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/3 v2] net: smsc911x: augment device tree bindings
Date: Wed, 24 Aug 2016 14:59:40 +0200
Message-ID: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
Cc: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Jeremy Linton <jeremy.linton-5wv7dgnIgG8@public.gmane.org>,
        Kamlakant Patel <kamlakant.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pavel Fedin <p.fedin-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds device tree bindings for:

- An optional GPIO line for releasing the RESET signal to the
  SMSC911x devices

- An optional PME (power management event) interrupt line that
  can be utilized to wake up the system on network activity.
  This signal exist on all the SMSC911x devices, it is just not
  very often routed.

Both these lines are routed to the SoC on the Qualcomm APQ8060
Dragonboard and thus needs to be bound in the device tree.

Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
ChangeLog v1->v2:
- Document for "interrupts", skip mentioning "interrupts-extended"
  as both are always supported.
---
 Documentation/devicetree/bindings/net/smsc911x.txt | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
index 3fed3c124411..11c4a46ba682 100644
--- a/Documentation/devicetree/bindings/net/smsc911x.txt
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -3,9 +3,12 @@
 Required properties:
 - compatible : Should be "smsc,lan<model>", "smsc,lan9115"
 - reg : Address and length of the io space for SMSC LAN
-- interrupts : Should contain SMSC LAN interrupt line
-- interrupt-parent : Should be the phandle for the interrupt controller
-  that services interrupts for this device
+- interrupts : Should contain the SMSC LAN
+  interrupt line as cell 0, cell 1 is an OPTIONAL PME (power
+  management event) interrupt that is able to wake up the host
+  system with a 50ms pulse on network activity
+  For generic bindings for interrupt controller parents, refer to
+  interrupt-controller/interrupts.txt
 - phy-mode : See ethernet.txt file in the same directory
 
 Optional properties:
@@ -21,6 +24,10 @@ Optional properties:
   external PHY
 - smsc,save-mac-address : Indicates that mac address needs to be saved
   before resetting the controller
+- reset-gpios : a GPIO line connected to the RESET (active low) signal
+  of the device. On many systems this is wired high so the device goes
+  out of reset at power-on, but if it is under program control, this
+  optional GPIO can wake up in response to it.
 
 Examples:
 
@@ -29,7 +36,8 @@ lan9220@f4000000 {
 	reg = <0xf4000000 0x2000000>;
 	phy-mode = "mii";
 	interrupt-parent = <&gpio1>;
-	interrupts = <31>;
+	interrupts = <31>, <32>;
+	reset-gpios = <&gpio1 30 GPIO_ACTIVE_LOW>;
 	reg-io-width = <4>;
 	smsc,irq-push-pull;
 };
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
