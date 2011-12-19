From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/14] ieee802154: interface type to be
	added
Date: Mon, 19 Dec 2011 19:33:50 +0300
Message-ID: <1324312434-13151-10-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Alexander Smirnov \(none\)" <alexander@Lenovo.>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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

From: Alexander Smirnov <alexander@Lenovo.(none)>

This stack supports several types of slaves interfaces. Another
parameter to 'add_iface_ function added.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/nl802154.h |    5 +++++
 include/net/wpan-phy.h   |    2 +-
 net/ieee802154/nl-phy.c  |   10 +++++++++-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index d2b5ae2..8fa29ff 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -68,6 +68,7 @@ enum {
 	IEEE802154_ATTR_CHANNEL_PAGE_LIST,
 
 	IEEE802154_ATTR_PHY_NAME,
+	IEEE802154_ATTR_DEV_TYPE,
 
 	__IEEE802154_ATTR_MAX,
 };
@@ -124,4 +125,8 @@ enum {
 
 #define IEEE802154_CMD_MAX (__IEEE802154_CMD_MAX - 1)
 
+enum {
+	__IEEE802154_DEV_MAX,
+};
+
 #endif
diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index d86fffd..0c2c931 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -42,7 +42,7 @@ struct wpan_phy {
 	int idx;
 
 	struct net_device *(*add_iface)(struct wpan_phy *phy,
-			const char *name);
+			const char *name, int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index c64a38d..cf3cd71 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -179,6 +179,7 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 	const char *devname;
 	int rc = -ENOBUFS;
 	struct net_device *dev;
+        int type = -EINVAL;
 
 	pr_debug("%s\n", __func__);
 
@@ -221,7 +222,14 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 		goto nla_put_failure;
 	}
 
-	dev = phy->add_iface(phy, devname);
+	if (info->attrs[IEEE802154_ATTR_DEV_TYPE]) {
+		type = nla_get_u8(info->attrs[IEEE802154_ATTR_DEV_TYPE]);
+		if (type > __IEEE802154_DEV_MAX) {
+			return -EINVAL;
+		}
+	}
+
+	dev = phy->add_iface(phy, devname, type);
 	if (IS_ERR(dev)) {
 		rc = PTR_ERR(dev);
 		goto nla_put_failure;
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
