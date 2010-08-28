From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 7/7] net/wireless: Remove double test
Date: Sat, 28 Aug 2010 17:41:06 +0200
Message-ID: <1283010066-20935-8-git-send-email-julia@diku.dk>
References: <1283010066-20935-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283010066-20935-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The same expression is tested twice and the result is the same each time.

The sematic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@expression@
expression E;
@@

(
* E
  || ... || E
|
* E
  && ... && E
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/wireless/wext-core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 0ef17bc..4038593 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -611,7 +611,7 @@ struct iw_statistics *get_wireless_stats(struct net_device *dev)
 #endif
 
 #ifdef CONFIG_CFG80211_WEXT
-	if (dev->ieee80211_ptr && dev->ieee80211_ptr &&
+	if (dev->ieee80211_ptr &&
 	    dev->ieee80211_ptr->wiphy &&
 	    dev->ieee80211_ptr->wiphy->wext &&
 	    dev->ieee80211_ptr->wiphy->wext->get_wireless_stats)
