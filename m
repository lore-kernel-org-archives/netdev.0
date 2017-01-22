From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH] Documentation: net: phy: improve explanation when to specify the PHY ID
Date: Sun, 22 Jan 2017 17:41:32 +0100
Message-ID: <20170122164132.13967-1-martin.blumenstingl@googlemail.com>
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: andrew-g2DYL2Zd6BY@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The old description basically read like "ethernet-phy-idAAAA.BBBB" can
be specified when you know the actual PHY ID. However, specifying this
has a side-effect: it forces Linux to bind to a certain PHY driver (the
one that matches the ID given in the compatible string), ignoring the ID
which is reported by the actual PHY.
Whenever a device is shipped with (multiple) different PHYs during it's
production lifetime then explicitly specifying
"ethernet-phy-idAAAA.BBBB" could break certain revisions of that device.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
---
Thanks to Andrew Lunn for pointing the documentation issue out to me in:
http://lists.infradead.org/pipermail/linux-amlogic/2017-January/002141.html


 Documentation/devicetree/bindings/net/phy.txt | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index ff1bc4b1bb3b..fb5056b22685 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -19,8 +19,9 @@ Optional Properties:
   specifications. If neither of these are specified, the default is to
   assume clause 22.
 
-  If the phy's identifier is known then the list may contain an entry
-  of the form: "ethernet-phy-idAAAA.BBBB" where
+  If the PHY reports an incorrect ID (or none at all) then the
+  "compatible" list may contain an entry with the correct PHY ID in the
+  form: "ethernet-phy-idAAAA.BBBB" where
      AAAA - The value of the 16 bit Phy Identifier 1 register as
             4 hex digits. This is the chip vendor OUI bits 3:18
      BBBB - The value of the 16 bit Phy Identifier 2 register as
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
