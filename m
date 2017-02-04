From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 1/2] net: phy: Add 2000base-x, 2500base-x and rxaui modes
Date: Sat,  4 Feb 2017 20:02:49 +0100
Message-ID: <1486234970-11300-2-git-send-email-andrew@lunn.ch>
References: <1486234970-11300-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55728 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751098AbdBDTEm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 14:04:42 -0500
In-Reply-To: <1486234970-11300-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 ports 9 and 10 supports some additional PHY modes. Add
these modes to the PHY core so they can be used in the binding.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
v2:
As requested by Florian, the following patch includes a device tree
specification change using these new values.
---
 Documentation/devicetree/bindings/net/ethernet.txt | 3 +++
 include/linux/phy.h                                | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 05150957ecfd..3a6916909d90 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -29,6 +29,9 @@ The following properties are common to the Ethernet controllers:
   * "smii"
   * "xgmii"
   * "trgmii"
+  * "2000base-x",
+  * "2500base-x",
+  * "rxaui"
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 43474f39ef65..28ae9eafec19 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -81,6 +81,9 @@ typedef enum {
 	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_QSGMII,
 	PHY_INTERFACE_MODE_TRGMII,
+	PHY_INTERFACE_MODE_1000BASEX,
+	PHY_INTERFACE_MODE_2500BASEX,
+	PHY_INTERFACE_MODE_RXAUI,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -141,6 +144,12 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "qsgmii";
 	case PHY_INTERFACE_MODE_TRGMII:
 		return "trgmii";
+	case PHY_INTERFACE_MODE_1000BASEX:
+		return "1000base-x";
+	case PHY_INTERFACE_MODE_2500BASEX:
+		return "2500base-x";
+	case PHY_INTERFACE_MODE_RXAUI:
+		return "rxaui";
 	default:
 		return "unknown";
 	}
-- 
2.11.0
