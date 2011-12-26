From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 05/14 v2] mac802154: define reduced mlme operations
Date: Mon, 26 Dec 2011 20:06:24 +0300
Message-ID: <1324919184-14959-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51390 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab1LZQH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 11:07:27 -0500
Received: by eekc4 with SMTP id c4so11131988eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 08:07:26 -0800 (PST)
In-Reply-To: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
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
