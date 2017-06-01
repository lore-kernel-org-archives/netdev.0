From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 4/5] net: phy: add XAUI and 10GBASE-KR PHY connection types
Date: Thu, 01 Jun 2017 11:26:47 +0100
Message-ID: <E1dGNJX-00043v-3M@rmk-PC.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:53064 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbdFAK0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:26:55 -0400
In-Reply-To: <20170601102327.GF27796@n2100.armlinux.org.uk>
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
 Documentation/devicetree/bindings/net/ethernet.txt | 2 ++
 include/linux/phy.h                                | 7 +++++++
 2 files changed, 9 insertions(+)

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
index 45dfe1b2b003..45728d0a0d0e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -84,6 +84,9 @@ typedef enum {
 	PHY_INTERFACE_MODE_1000BASEX,
 	PHY_INTERFACE_MODE_2500BASEX,
 	PHY_INTERFACE_MODE_RXAUI,
+	PHY_INTERFACE_MODE_XAUI,
+	/* 10GBASE-KR, XFI, SFI - single lane 10G Serdes */
+	PHY_INTERFACE_MODE_10GKR,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -150,6 +153,10 @@ static inline const char *phy_modes(phy_interface_t interface)
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
