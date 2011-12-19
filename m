From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 05/14] mac802154: define reduced mlme
	operations
Date: Mon, 19 Dec 2011 19:33:45 +0300
Message-ID: <1324312434-13151-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111219163117.GA13123-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
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
 include/net/ieee802154_netdev.h |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 12a7ee4..f74c5db 100644
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
 
+struct ieee802154_reduced_mlme_ops {
+	struct wpan_phy *(*get_phy)(const struct net_device *dev);
+};
+
 static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
 		const struct net_device *dev)
 {
 	return dev->ml_priv;
 }
 
-#endif
-
+static inline struct ieee802154_reduced_mlme_ops *ieee802154_reduced_mlme_ops(
+		const struct net_device *dev)
+{
+	return dev->ml_priv;
+}
 
+#endif
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
