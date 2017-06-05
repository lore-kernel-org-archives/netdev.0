From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 5/6] net: phy: add XAUI and 10GBASE-KR PHY connection types
Date: Mon, 05 Jun 2017 12:23:10 +0100
Message-ID: <E1dHq6I-0005XE-VR@rmk-PC.armlinux.org.uk>
References: <20170605112203.GA10680@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33022 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdFELX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 07:23:29 -0400
In-Reply-To: <20170605112203.GA10680@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XAUI allows XGMII to reach an extended distance by using a XGXS layer at
each end of the MAC to PHY link, operating over four Serdes lanes.

10GBASE-KR is a single lane Serdes backplane ethernet connection method
with autonegotiation on the link.  Some PHYs use this to connect to the
ethernet interface at 10G speeds, switching to other connection types
when utilising slower speeds.

10GBASE-KR is also used for XFI and SFI to connect to XFP and SFP fiber
modules.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 Documentation/ABI/testing/sysfs-class-net-phydev   | 2 +-
 Documentation/devicetree/bindings/net/ethernet.txt | 2 ++
 include/linux/phy.h                                | 7 +++++++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-phydev b/Documentation/ABI/testing/sysfs-class-net-phydev
index c768d5fd8496..6ebabfb27912 100644
--- a/Documentation/ABI/testing/sysfs-class-net-phydev
+++ b/Documentation/ABI/testing/sysfs-class-net-phydev
@@ -32,5 +32,5 @@ Contact:	netdev@vger.kernel.org
 		<empty> (not available), mii, gmii, sgmii, tbi, rev-mii,
 		rmii, rgmii, rgmii-id, rgmii-rxid, rgmii-txid, rtbi, smii
 		xgmii, moca, qsgmii, trgmii, 1000base-x, 2500base-x, rxaui,
-		unknown
+		xaui, 10gbase-kr, unknown
 
diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 3a6916909d90..d4abe9a98109 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -32,6 +32,8 @@
   * "2000base-x",
   * "2500base-x",
   * "rxaui"
+  * "xaui"
+  * "10gbase-kr" (10GBASE-KR, XFI, SFI)
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e6fcee188c8d..37feb502e1ae 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -83,6 +83,9 @@ typedef enum {
 	PHY_INTERFACE_MODE_1000BASEX,
 	PHY_INTERFACE_MODE_2500BASEX,
 	PHY_INTERFACE_MODE_RXAUI,
+	PHY_INTERFACE_MODE_XAUI,
+	/* 10GBASE-KR, XFI, SFI - single lane 10G Serdes */
+	PHY_INTERFACE_MODE_10GKR,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -149,6 +152,10 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "2500base-x";
 	case PHY_INTERFACE_MODE_RXAUI:
 		return "rxaui";
+	case PHY_INTERFACE_MODE_XAUI:
+		return "xaui";
+	case PHY_INTERFACE_MODE_10GKR:
+		return "10gbase-kr";
 	default:
 		return "unknown";
 	}
-- 
2.7.4
