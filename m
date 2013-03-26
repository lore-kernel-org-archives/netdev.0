From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 09/12] mac802154: add
	mac802154_dev_get_dsn()
Date: Mon, 25 Mar 2013 23:59:29 -0400
Message-ID: <1364270372-19430-10-git-send-email-tony.cheneau@amnesiak.org>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Bring-over mac802154_dev_get_dsn() function that was present in the
Linux ZigBee kernel. This function is called by the 6LoWPAN code in
order to properly set the DSN (Data Sequence Number) value in the IEEE
802.15.4 frame.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/mac802154/mac802154.h | 1 +
 net/mac802154/mac_cmd.c   | 1 +
 net/mac802154/mib.c       | 9 +++++++++
 3 files changed, 11 insertions(+)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index a4dcaf1..21fa386 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -114,5 +114,6 @@ void mac802154_dev_set_ieee_addr(struct net_device *dev);
 u16 mac802154_dev_get_pan_id(const struct net_device *dev);
 void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
 void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan);
+u8 mac802154_dev_get_dsn(const struct net_device *dev);
 
 #endif /* MAC802154_H */
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index d8d2770..a99910d 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -73,4 +73,5 @@ struct ieee802154_mlme_ops mac802154_mlme_wpan = {
 	.start_req = mac802154_mlme_start_req,
 	.get_pan_id = mac802154_dev_get_pan_id,
 	.get_short_addr = mac802154_dev_get_short_addr,
+	.get_dsn = mac802154_dev_get_dsn,
 };
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index f47781a..f03e55f 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -159,6 +159,15 @@ void mac802154_dev_set_pan_id(struct net_device *dev, u16 val)
 	}
 }
 
+u8 mac802154_dev_get_dsn(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return priv->dsn++;
+}
+
 static void phy_chan_notify(struct work_struct *work)
 {
 	struct phy_chan_notify_work *nw = container_of(work,
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
