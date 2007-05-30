From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 1/4] mac80211: fail back to use associate from reassociate
Date: Wed, 30 May 2007 14:28:07 -0400
Message-ID: <20070530182807.GD3610@tuxdriver.com>
References: <20070530182538.GB3610@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070530182538.GB3610-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 3e07e9d..dbac858 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1155,6 +1155,8 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	if (status_code != WLAN_STATUS_SUCCESS) {
 		printk(KERN_DEBUG "%s: AP denied association (code=%d)\n",
 		       dev->name, status_code);
+		if (status_code == WLAN_STATUS_REASSOC_NO_ASSOC)
+			ifsta->prev_bssid_set = 0;
 		return;
 	}
 
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
