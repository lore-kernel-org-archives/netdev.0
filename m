From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] cfg80211: Add stub for cfg80211_get_station()
Date: Fri, 19 Aug 2016 22:02:48 +0200
Message-ID: <20160819200248.8202-1-linus.luessing@c0d3.blue>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Antonio Quartulli <a@unstable.cc>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This allows modules using this function (currently: batman-adv) to
compile even if cfg80211 is not built at all, thus relaxing
dependencies.

Signed-off-by: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
---
 include/net/cfg80211.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 9c23f4d3..beb7610 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1102,6 +1102,7 @@ struct station_info {
 	struct cfg80211_tid_stats pertid[IEEE80211_NUM_TIDS + 1];
 };
 
+#if IS_ENABLED(CONFIG_CFG80211)
 /**
  * cfg80211_get_station - retrieve information about a given station
  * @dev: the device where the station is supposed to be connected to
@@ -1114,6 +1115,14 @@ struct station_info {
  */
 int cfg80211_get_station(struct net_device *dev, const u8 *mac_addr,
 			 struct station_info *sinfo);
+#else
+static inline int cfg80211_get_station(struct net_device *dev,
+				       const u8 *mac_addr,
+				       struct station_info *sinfo)
+{
+	return -ENOENT;
+}
+#endif
 
 /**
  * enum monitor_flags - monitor flags
-- 
2.1.4
