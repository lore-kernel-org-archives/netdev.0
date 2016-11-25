From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH 1/2] Documentation: devicetree: clarify usage of the RGMII phy-modes
Date: Fri, 25 Nov 2016 14:12:00 +0100
Message-ID: <20161125131201.19994-2-martin.blumenstingl@googlemail.com>
References: <20161125131201.19994-1-martin.blumenstingl@googlemail.com>
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125131201.19994-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RGMII requires special RX and/or TX delays depending on the actual
hardware circuit/wiring. These delays can be added by the MAC, the PHY
or the designer of the circuit (the latter means that no delay has to
be added by PHY or MAC).
There are 4 RGMII phy-modes used describe where a delay should be
applied:
- rgmii: the RX and TX delays are either added by the MAC (where the
  exact delay is typically configurable, and can be turned off when no
  extra delay is needed) or not needed at all (because the hardware
  wiring adds the delay already). The PHY should neither add the RX nor
  TX delay in this case.
- rgmii-rxid: configures the PHY to enable the RX delay. The MAC should
  not add the RX delay in this case.
- rgmii-txid: configures the PHY to enable the TX delay. The MAC should
  not add the TX delay in this case.
- rgmii-id: combines rgmii-rxid and rgmii-txid and thus configures the
  PHY to enable the RX and TX delays. The MAC should neither add the RX
  nor TX delay in this case.

Document these cases in the ethernet.txt documentation to make it clear
when to use each mode.
If applied incorrectly one might end up with MAC and PHY both enabling
for example the TX delay, which breaks ethernet TX traffic on 1000Mbit/s
links.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 24 ++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index e1d7681..0515095 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -9,10 +9,26 @@ The following properties are common to the Ethernet controllers:
 - max-speed: number, specifies maximum speed in Mbit/s supported by the device;
 - max-frame-size: number, maximum transfer unit (IEEE defined MTU), rather than
   the maximum frame size (there's contradiction in ePAPR).
-- phy-mode: string, operation mode of the PHY interface; supported values are
-  "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
-  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "trgmii"; this is now a
-  de-facto standard property;
+- phy-mode: string, operation mode of the PHY interface. This is now a de-facto
+  standard property; supported values are:
+  * "mii"
+  * "gmii"
+  * "sgmii"
+  * "qsgmii"
+  * "tbi"
+  * "rev-mii"
+  * "rmii"
+  * "rgmii" (RX and TX delays are added by the MAC when required)
+  * "rgmii-id" (RGMII with internal RX and TX delays provided by the PHY, the
+     MAC should not add the RX or TX delays in this case)
+  * "rgmii-rxid" (RGMII with internal RX delay provided by the PHY, the MAC
+     should not add an RX delay in this case)
+  * "rgmii-txid" (RGMII with internal TX delay provided by the PHY, the MAC
+     should not add an TX delay in this case)
+  * "rtbi"
+  * "smii"
+  * "xgmii"
+  * "trgmii"
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
-- 
2.10.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
