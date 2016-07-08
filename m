From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH 1/3] net: smsc911x: augment device tree bindings
Date: Fri,  8 Jul 2016 11:07:30 +0200
Message-ID: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	devicetree@vger.kernel.org
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:32996 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbcGHJHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 05:07:41 -0400
Received: by mail-lf0-f45.google.com with SMTP id f6so26063779lfg.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 02:07:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds device tree bindings for:

- An optional GPIO line for releasing the RESET signal to the
  SMSC911x devices

- An optional PME (power management event) interrupt line that
  can be utilized to wake up the system on network activity.
  This signal exist on all the SMSC911x devices, it is just not
  very often routed.

Both these lines are routed to the SoC on the Qualcomm APQ8060
Dragonboard and thus needs to be bound in the device tree.

Cc: devicetree@vger.kernel.org
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 Documentation/devicetree/bindings/net/smsc911x.txt | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
index 3fed3c124411..7b01c37272c1 100644
--- a/Documentation/devicetree/bindings/net/smsc911x.txt
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -3,9 +3,12 @@
 Required properties:
 - compatible : Should be "smsc,lan<model>", "smsc,lan9115"
 - reg : Address and length of the io space for SMSC LAN
-- interrupts : Should contain SMSC LAN interrupt line
-- interrupt-parent : Should be the phandle for the interrupt controller
-  that services interrupts for this device
+- interrupts/extended-interrupts : Should contain the SMSC LAN
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
