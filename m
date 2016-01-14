From: <shh.xie@gmail.com>
Subject: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Thu, 14 Jan 2016 16:23:59 +0800
Message-ID: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <f.fainelli@gmail.com>,
	<davem@davemloft.net>, Shaohui Xie <Shaohui.Xie@freescale.com>
To: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0096.outbound.protection.outlook.com ([65.55.169.96]:29985
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750816AbcANIse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 03:48:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

This commit adds necessary definitions for the PHY layer to recognize
backplane Ethernet 1000BASE-KX and 10GBASE-KR as valid PHY interfaces,
"1000base-kx" for 1000BASE-KX, "10gbase-kr" for 10GBASE-KR.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
changes in v2:
new patch.

 Documentation/devicetree/bindings/net/ethernet.txt | 4 ++--
 include/linux/phy.h                                | 6 ++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 5d88f37..1166a5c 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -11,8 +11,8 @@ The following properties are common to the Ethernet controllers:
   the maximum frame size (there's contradiction in ePAPR).
 - phy-mode: string, operation mode of the PHY interface; supported values are
   "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii", "rgmii", "rgmii-id",
-  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a de-facto
-  standard property;
+  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "1000base-kx", "10gbase-kr";
+  this is now a de-facto standard property;
 - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
 - phy-handle: phandle, specifies a reference to a node representing a PHY
   device; this property is described in ePAPR and so preferred;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d6f3641..7acecf7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -80,6 +80,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_XGMII,
 	PHY_INTERFACE_MODE_MOCA,
 	PHY_INTERFACE_MODE_QSGMII,
+	PHY_INTERFACE_MODE_1000BASE_KX,
+	PHY_INTERFACE_MODE_10GBASE_KR,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -123,6 +125,10 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "moca";
 	case PHY_INTERFACE_MODE_QSGMII:
 		return "qsgmii";
+	case PHY_INTERFACE_MODE_1000BASE_KX:
+		return "1000base-kx";
+	case PHY_INTERFACE_MODE_10GBASE_KR:
+		return "10gbase-kr";
 	default:
 		return "unknown";
 	}
-- 
2.1.0.27.g96db324
