From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 14 Aug 2007 20:32:34 -0400
Message-ID: <20070815003234.GI7198@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These are a few more items intended for 2.6.23.

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

Thanks!

John

---

The following changes since commit 39d3520c92cf7a28c07229ca00cc35a1e8026c77:
  Linus Torvalds (1):
        Linux 2.6.23-rc3

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Johannes Berg (1):
      mac80211: fix tx status frame code

John W. Linville (1):
      mac80211: probe for hidden SSIDs in pre-auth scan

 net/mac80211/ieee80211.c     |    1 -
 net/mac80211/ieee80211_sta.c |    6 +++++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 8ec5ed1..7286c38 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -4678,7 +4678,6 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 			memset(skb->cb, 0, sizeof(skb->cb));
 			netif_rx(skb);
 			skb = skb2;
-			break;
 		}
 	}
  out:
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 7ba352e..0d99b68 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2154,7 +2154,11 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 		return 0;
 	} else {
 		if (ifsta->state != IEEE80211_AUTHENTICATE) {
-			ieee80211_sta_start_scan(dev, NULL, 0);
+			if (ifsta->auto_ssid_sel)
+				ieee80211_sta_start_scan(dev, NULL, 0);
+			else
+				ieee80211_sta_start_scan(dev, ifsta->ssid,
+							 ifsta->ssid_len);
 			ifsta->state = IEEE80211_AUTHENTICATE;
 			set_bit(IEEE80211_STA_REQ_AUTH, &ifsta->request);
 		} else
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
