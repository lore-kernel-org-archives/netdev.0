From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [patch] mac80211: remove unneed variable from
	ieee80211_tx_pending()
Date: Wed, 24 Mar 2010 14:56:41 +0300
Message-ID: <20100324115641.GE21571@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We don't need "sdata" any more after:
	d84f323477260e773d5317ad7cbe50f76115cb47
	mac80211: remove dev_hold/put calls

Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index cbe53ed..08e1f17 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2010,14 +2010,12 @@ void ieee80211_tx_pending(unsigned long data)
 		while (!skb_queue_empty(&local->pending[i])) {
 			struct sk_buff *skb = __skb_dequeue(&local->pending[i]);
 			struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-			struct ieee80211_sub_if_data *sdata;
 
 			if (WARN_ON(!info->control.vif)) {
 				kfree_skb(skb);
 				continue;
 			}
 
-			sdata = vif_to_sdata(info->control.vif);
 			spin_unlock_irqrestore(&local->queue_stop_reason_lock,
 						flags);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
