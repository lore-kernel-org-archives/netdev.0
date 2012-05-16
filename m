From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v5 05/13] mac802154: declare reduced mlme operations
Date: Wed, 16 May 2012 10:50:23 +0400
Message-ID: <1337151031-5178-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61280 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759359Ab2EPGvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 02:51:39 -0400
Received: by mail-wi0-f178.google.com with SMTP id hn6so372487wib.1
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 23:51:39 -0700 (PDT)
In-Reply-To: <1337151031-5178-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According IEEE 802.15.4 standard each node can be either full functionality
device (FFD) or reduce functionality device (RFD). So 2 sets of operations
are needed. This patch declare RFD operations structure.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/ieee802154_netdev.h |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 12a7ee4..d104c88 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -1,7 +1,7 @@
 /*
  * An interface between IEEE802.15.4 device and rest of the kernel.
  *
- * Copyright (C) 2007, 2008, 2009 Siemens AG
+ * Copyright (C) 2007-2012 Siemens AG
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2
@@ -21,6 +21,7 @@
  * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
  * Maxim Osipov <maxim.osipov@siemens.com>
  * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
  */
 
 #ifndef IEEE802154_NETDEVICE_H
@@ -112,12 +113,26 @@ struct ieee802154_mlme_ops {
 	u8 (*get_bsn)(const struct net_device *dev);
 };
 
-static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
-		const struct net_device *dev)
+/* The IEEE 802.15.4 standard defines 2 type of the devices:
+ * - FFD - full functionality device
+ * - RFD - reduce functionality device
+ *
+ * So 2 sets of mlme operations are needed
+ */
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
