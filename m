From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] dt-binding: net/phy: fix interrupts description
Date: Wed, 23 Aug 2017 09:11:00 +0300
Message-ID: <b3756346473feadfeba70ecb71960cad48e66621.1503468660.git.baruch@tkos.co.il>
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
        Baruch Siach <baruch@tkos.co.il>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:46613 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752291AbdHWGLP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 02:11:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b053dc5a722ea (powerpc: Refactor device tree binding) split the
Ethernet PHY binding documentation out of the big booting-without-of.txt
file, leaving a dangling reference to "section 2" in the 'interrupts'
property description. Drop that reference, and make the description look
more like the rest.

While at it, make the example interrupt-parent phandle look more like a
real world phandle, and use an IRQ_TYPE_ macro for the 'interrupts'
type.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 Documentation/devicetree/bindings/net/phy.txt | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index b55857696fc3..86ba72af6163 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -2,11 +2,7 @@ PHY nodes
 
 Required properties:
 
- - interrupts : <a b> where a is the interrupt number and b is a
-   field that represents an encoding of the sense and level
-   information for the interrupt.  This should be encoded based on
-   the information in section 2) depending on the type of interrupt
-   controller you have.
+ - interrupts : interrupt specifier for the sole interrupt.
  - interrupt-parent : the phandle for the interrupt controller that
    services interrupts for this device.
  - reg : The ID number for the phy, usually a small integer
@@ -56,7 +52,7 @@ Example:
 
 ethernet-phy@0 {
 	compatible = "ethernet-phy-id0141.0e90", "ethernet-phy-ieee802.3-c22";
-	interrupt-parent = <40000>;
-	interrupts = <35 1>;
+	interrupt-parent = <&PIC>;
+	interrupts = <35 IRQ_TYPE_EDGE_RISING>;
 	reg = <0>;
 };
-- 
2.14.1
