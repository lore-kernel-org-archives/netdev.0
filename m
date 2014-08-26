From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 03/13] net: phy: provide stub for fixed_phy_set_link_update
Date: Mon, 25 Aug 2014 21:49:31 -0700
Message-ID: <1409028581-17399-4-git-send-email-f.fainelli@gmail.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:50883 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbaHZEua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 00:50:30 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so22290465pad.36
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 21:50:30 -0700 (PDT)
In-Reply-To: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for updating the DSA code and avoid using ifdefs there,
provide an empty stub for fixed_phy_set_link_update when
CONFIG_FIXED_PHY is not selected.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
New patch in v4 that resulted in more build testing

 include/linux/phy_fixed.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index ae612acebb53..941138664c1d 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -18,6 +18,9 @@ extern int fixed_phy_register(unsigned int irq,
 			      struct fixed_phy_status *status,
 			      struct device_node *np);
 extern void fixed_phy_del(int phy_addr);
+extern int fixed_phy_set_link_update(struct phy_device *phydev,
+			int (*link_update)(struct net_device *,
+					   struct fixed_phy_status *));
 #else
 static inline int fixed_phy_add(unsigned int irq, int phy_id,
 				struct fixed_phy_status *status)
@@ -34,14 +37,12 @@ static inline int fixed_phy_del(int phy_addr)
 {
 	return -ENODEV;
 }
-#endif /* CONFIG_FIXED_PHY */
-
-/*
- * This function issued only by fixed_phy-aware drivers, no need
- * protect it with #ifdef
- */
-extern int fixed_phy_set_link_update(struct phy_device *phydev,
+static inline int fixed_phy_set_link_update(struct phy_device *phydev,
 			int (*link_update)(struct net_device *,
-					   struct fixed_phy_status *));
+					   struct fixed_phy_status *))
+{
+	return -ENODEV;
+}
+#endif /* CONFIG_FIXED_PHY */
 
 #endif /* __PHY_FIXED_H */
-- 
1.9.1
