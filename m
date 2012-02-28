From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 05/13] mac802154: define reduced mlme
	operations
Date: Tue, 28 Feb 2012 18:00:24 +0300
Message-ID: <1330441232-17650-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1330441232-17650-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1330441232-17650-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

According IEEE 802.15.4 standard each node can be either full functionality
device (FFD) or reduce functionality device (RFD). So 2 sets of operations
are needed. This patch define RFD operations structure.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
