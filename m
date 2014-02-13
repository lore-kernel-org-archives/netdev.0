From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 01/10] net: phy: add "internal" PHY mode
Date: Wed, 12 Feb 2014 21:29:46 -0800
Message-ID: <1392269395-23513-2-git-send-email-f.fainelli@gmail.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392269395-23513-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On some systems, the PHY can be internal, in the same package as the
Ethernet MAC, and still be responding to a specific address on the MDIO
bus, in that case, the Ethernet MAC might need to know about it to
properly configure a port multiplexer to switch to an internal or
external PHY. Add a new PHY interface mode for this and update the
Device Tree of_get_phy_mode() function to look for it.

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Changes since v1:
- rebased against lastest net-next master branch

 include/linux/phy.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 42f1bc7..743c90e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -74,6 +74,7 @@ typedef enum {
 	PHY_INTERFACE_MODE_RTBI,
 	PHY_INTERFACE_MODE_SMII,
 	PHY_INTERFACE_MODE_XGMII,
+	PHY_INTERFACE_MODE_INTERNAL,
 	PHY_INTERFACE_MODE_MAX,
 } phy_interface_t;
 
@@ -113,6 +114,8 @@ static inline const char *phy_modes(phy_interface_t interface)
 		return "smii";
 	case PHY_INTERFACE_MODE_XGMII:
 		return "xgmii";
+	case PHY_INTERFACE_MODE_INTERNAL:
+		return "internal";
 	default:
 		return "unknown";
 	}
@@ -599,7 +602,8 @@ static inline bool phy_interrupt_is_valid(struct phy_device *phydev)
  */
 static inline bool phy_is_internal(struct phy_device *phydev)
 {
-	return phydev->is_internal;
+	return phydev->is_internal ||
+		phydev->interface == PHY_INTERFACE_MODE_INTERNAL;
 }
 
 /**
-- 
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
