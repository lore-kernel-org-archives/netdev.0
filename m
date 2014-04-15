From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/3] net: phy: add minimal support for QSGMII PHY
Date: Tue, 15 Apr 2014 15:50:19 +0200
Message-ID: <1397569821-5530-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	George Joseph <george.joseph@fairview5.com>, arno@natisbad.org,
	Willy Tarreau <w@1wt.eu>,
	Alexander Reuter <Alexander.Reuter@gmx.net>,
	devicetree@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40744 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752992AbaDONu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 09:50:26 -0400
In-Reply-To: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the necessary definitions for the PHY layer to
recognize "qsgmii" as a valid PHY interface. A QSMII interface, as
defined at
http://en.wikipedia.org/wiki/Media_Independent_Interface#Quad_Serial_Gigabit_Media_Independent_Interface,
is "is a method of combining four SGMII lines into a 5Gbit/s
interface. QSGMII, like SGMII, uses LVDS signalling for the TX and RX
data and a single LVDS clock signal. QSGMII uses significantly fewer
signal lines than four SGMII busses."

This type of MAC <-> PHY connection might require special handling on
the MAC driver side, so it should be possible to express this type of
MAC <-> PHY connection, for example in the Device Tree.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: devicetree@vger.kernel.org
---
 Documentation/devicetree/bindings/net/ethernet.txt | 2 +-
 include/linux/phy.h                                | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 9ecd43d..3fc3605 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -10,7 +10,7 @@ The following properties are common to the Ethernet controllers:
 - max-frame-size: number, maximum transfer unit (IEEE defined MTU), rather than
   the maximum frame size (there's contradiction in ePAPR).
 - phy-mode: string, operation mode of the PHY interface; supported values are
-  "mii", "gmii", "sgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
+  "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
   "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a de-facto
   standard property;
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 24126c4..4d0221f 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -75,6 +75,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
 	PHY_INTERFACE_MODE_MOCA,
+	PHY_INTERFACE_MODE_QSGMII,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -116,6 +117,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "xgmii";
 	case PHY_INTERFACE_MODE_MOCA:
 		return "moca";
+	case PHY_INTERFACE_MODE_QSGMII:
+		return "qsgmii";
 	default:
 		return "unknown";
 	}
-- 
1.8.3.2
