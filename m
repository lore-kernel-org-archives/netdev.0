From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/2] net: phy: Add phy_interface_is_rgmii helper
Date: Tue, 26 May 2015 12:19:58 -0700
Message-ID: <1432667999-11563-2-git-send-email-f.fainelli@gmail.com>
References: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, dmurphy@ti.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36005 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307AbbEZTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 15:20:35 -0400
Received: by paza2 with SMTP id a2so90525106paz.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 12:20:34 -0700 (PDT)
In-Reply-To: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RGMII interfaces come in 4 different flavors that the PHY library needs
to care about: regular RGMII (no delays), RGMII with either RX or TX
delay, and both. In order to avoid errors of checking only for one type
of RGMII interface and miss the 3 others, introduce a convenience
function which tests for all values.

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 701c7a3946e0..a26c3f84b8dd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -678,6 +678,17 @@ static inline bool phy_is_internal(struct phy_device *phydev)
 }
 
 /**
+ * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
+ * is RGMII (all variants)
+ * @phydev: the phy_device struct
+ */
+static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
+{
+	return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
+		phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
+}
+
+/**
  * phy_write_mmd - Convenience function for writing a register
  * on an MMD on a given PHY.
  * @phydev: The phy_device struct
-- 
2.1.0
