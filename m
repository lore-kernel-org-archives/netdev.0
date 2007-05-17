From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] mac80211: fail back to use associate from reassociate failure
Date: Thu, 17 May 2007 13:16:59 -0400
Message-ID: <20070517171659.GB7720@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Some APs have strict checking between associate and reassociate. In
a case when an AP is restarted during a connection, it denies the
mac80211 reassoc request since this is a new association for the AP.
To fix this problem, we need to check the status code against
WLAN_STATUS_REASSOC_NO_ASSOC and clear ifsta->prev_bssid_set in
handling the association failure response.

Signed-off-by: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---

 net/mac80211/ieee80211_sta.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index b003912..dacd2d3 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1182,6 +1182,8 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	if (status_code != WLAN_STATUS_SUCCESS) {
 		printk(KERN_DEBUG "%s: AP denied association (code=%d)\n",
 		       dev->name, status_code);
+		if (status_code == WLAN_STATUS_REASSOC_NO_ASSOC)
+			ifsta->prev_bssid_set = 0;
 		return;
 	}
 
