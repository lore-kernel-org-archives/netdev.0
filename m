From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3.6 10/19] mac8011: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:53:49 +0800
Message-ID: <52CCBDBD.6050906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Wang Weidong <wangweidong1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 net/mac80211/iface.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 7aa9f9d..a4f9812 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1497,8 +1497,8 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 			bool used = false;
 
 			list_for_each_entry(sdata, &local->interfaces, list) {
-				if (memcmp(local->hw.wiphy->addresses[i].addr,
-					   sdata->vif.addr, ETH_ALEN) == 0) {
+				if (ether_addr_equal(local->hw.wiphy->addresses[i].addr,
+						     sdata->vif.addr)) {
 					used = true;
 					break;
 				}
@@ -1558,8 +1558,7 @@ static void ieee80211_assign_perm_addr(struct ieee80211_local *local,
 			val += inc;
 
 			list_for_each_entry(sdata, &local->interfaces, list) {
-				if (memcmp(tmp_addr, sdata->vif.addr,
-							ETH_ALEN) == 0) {
+				if (ether_addr_equal(tmp_addr, sdata->vif.addr)) {
 					used = true;
 					break;
 				}
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
