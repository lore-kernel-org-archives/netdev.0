From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v4 05/13] mac802154: define reduced mlme operations
Date: Sat, 12 May 2012 17:59:17 +0400
Message-ID: <1336831165-23944-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56158 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754647Ab2ELOAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 10:00:17 -0400
Received: by wgbdr13 with SMTP id dr13so3305381wgb.1
        for <netdev@vger.kernel.org>; Sat, 12 May 2012 07:00:16 -0700 (PDT)
In-Reply-To: <1336831165-23944-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According IEEE 802.15.4 standard each node can be either full functionality
device (FFD) or reduce functionality device (RFD). So 2 sets of operations
are needed. This patch define RFD operations structure.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/ieee802154_netdev.h |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 12a7ee4..b27730e 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -83,6 +83,14 @@ struct wpan_phy;
  * get_phy should increment the reference counting on returned phy.
  * Use wpan_wpy_put to put that reference.
  */
+
+/*
+ * The IEEE 802.15.4 standard defines 2 type of devices:
+ * - FFD - full functionality device
+ * - RFD - reduce functionality device
+ *
+ * So 2 sets of mlme operations are needed
+ */
 struct ieee802154_mlme_ops {
 	int (*assoc_req)(struct net_device *dev,
 			struct ieee802154_addr *addr,
@@ -112,12 +120,20 @@ struct ieee802154_mlme_ops {
 	u8 (*get_bsn)(const struct net_device *dev);
 };
 
-static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
-		const struct net_device *dev)
+struct ieee802154_reduced_mlme_ops {
+	struct wpan_phy *(*get_phy)(const struct net_device *dev);
+};
+
+static inline struct ieee802154_mlme_ops *
+ieee802154_mlme_ops(const struct net_device *dev)
 {
 	return dev->ml_priv;
 }
 
-#endif
-
+static inline struct ieee802154_reduced_mlme_ops *
+ieee802154_reduced_mlme_ops(const struct net_device *dev)
+{
+	return dev->ml_priv;
+}
 
+#endif
-- 
1.7.2.3
