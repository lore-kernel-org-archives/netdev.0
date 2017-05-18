From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 1/2] include: linux: Add helper function to check phy interface mode
Date: Thu, 18 May 2017 15:13:43 -0700
Message-ID: <1495145624-29463-2-git-send-email-isubramanian@apm.com>
References: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Cc: f.fainelli@gmail.com, andrew@lunn.ch,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33108 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932420AbdERWKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 18:10:51 -0400
Received: by mail-pf0-f173.google.com with SMTP id e193so30142812pfh.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 15:10:51 -0700 (PDT)
In-Reply-To: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added helper function that checks phy_mode is RGMII (all variants)
'bool phy_interface_mode_is_rgmii(phy_interface_t mode)'

Changed the following function, to use the above.
'bool phy_interface_is_rgmii(struct phy_device *phydev)'

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Suggested-by: Andrew Lunn <andrew@lunn.ch>
---
 include/linux/phy.h | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54ef458..5a808a2 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -716,14 +716,24 @@ static inline bool phy_is_internal(struct phy_device *phydev)
 }
 
 /**
+ * phy_interface_mode_is_rgmii - Convenience function for testing if a
+ * PHY interface mode is RGMII (all variants)
+ * @mode: the phy_interface_t enum
+ */
+static inline bool phy_interface_mode_is_rgmii(phy_interface_t mode)
+{
+	return mode >= PHY_INTERFACE_MODE_RGMII &&
+		mode <= PHY_INTERFACE_MODE_RGMII_TXID;
+};
+
+/**
  * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
  * is RGMII (all variants)
  * @phydev: the phy_device struct
  */
 static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
 {
-	return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
-		phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
+	return phy_interface_mode_is_rgmii(phydev->interface);
 };
 
 /*
-- 
1.9.1
