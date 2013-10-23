From: Dhahira Thesneem <dhahira.thesneem-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 1/1] mac80211:Resetting connection monitor timers in transmit path
Date: Wed, 23 Oct 2013 15:42:25 +0530
Message-ID: <1382523145-2302-1-git-send-email-dhahira.thesneem@mistralsolutions.com>
Cc: Dhahira Thesneem <dhahira.thesneem-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reset connection monitor timers when we are able to successfully transmit data to an AP.

Signed-off-by: Dhahira Thesneem <dhahira.thesneem-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
---
 net/mac80211/tx.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3456c04..e7725cf 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1700,7 +1700,8 @@ netdev_tx_t ieee80211_monitor_start_xmit(struct sk_buff *skb,
 
 	ieee80211_xmit(sdata, skb, chan->band);
 	rcu_read_unlock();
-
+	/*To reset connection monitor timers, after successful transmission*/
+	ieee80211_sta_reset_conn_monitor(sdata);
 	return NETDEV_TX_OK;
 
 fail_rcu:
@@ -2139,7 +2140,8 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 	ieee80211_xmit(sdata, skb, band);
 	rcu_read_unlock();
