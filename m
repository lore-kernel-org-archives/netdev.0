From: Chunho Lee <handera@gmail.com>
Subject: [PATCH] mac80211: Fix null pointer dereference with iTXQ support
Date: Fri,  7 Jul 2017 17:03:14 -0700
Message-ID: <1499472194-9654-1-git-send-email-ch.lee@newracom.com>
Cc: ch.lee@newracom.com, thomas.kang@newracom.com,
        Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org (open list:MAC80211),
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change adds null pointer check before dereferencing pointer dev on
netif_tx_start_all_queues() when an interface is added.
With iTXQ support, netif_tx_start_all_queues() is always called while
an interface is added. however, the netdev queues are not associated
and dev is null when the interface is either NL80211_IFTYPE_P2P_DEVICE
or NL80211_IFTYPE_NAN.

Signed-off-by: Chunho Lee <ch.lee@newracom.com>
---
 net/mac80211/iface.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index f5f5015..e2edd10 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -731,7 +731,8 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 	    sdata->vif.type == NL80211_IFTYPE_AP_VLAN ||
 	    local->ops->wake_tx_queue) {
 		/* XXX: for AP_VLAN, actually track AP queues */
-		netif_tx_start_all_queues(dev);
+		if (dev)
+			netif_tx_start_all_queues(dev);
 	} else if (dev) {
 		unsigned long flags;
 		int n_acs = IEEE80211_NUM_ACS;
-- 
2.7.4
