From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: fixed freeing skbs in interrupt context
Date: Tue,  1 May 2007 03:44:47 +0100 (BST)
Message-ID: <20070501024447.580AC7B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

Some of the kfree_skb() calls could happen in irq context.
Changed all calls to dev_kfree_skb() in non-irq context and to
dev_kfree_skb_any() where an irq context might happen.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index cd5d17f..91b908a 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -160,7 +160,7 @@ static int zd_mac_stop(struct ieee80211_hw *dev)
 		struct ieee80211_tx_control *control =
 			*(struct ieee80211_tx_control **)skb->cb;
 		kfree(control);
-		kfree_skb(skb);
+		dev_kfree_skb(skb);
 	}
 
 	return 0;
@@ -319,7 +319,7 @@ static int zd_mac_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 		return r;
 
 	if (control->flags & IEEE80211_TXCTL_NO_ACK) {
-		kfree_skb(skb);
+		dev_kfree_skb(skb);
 		return 0;
 	}
 
@@ -350,7 +350,7 @@ void zd_mac_tx_failed(struct ieee80211_hw *dev)
 		ieee80211_tx_status_irqsafe(dev, skb, &status);
 		kfree(control);
 	} else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return;
 }
@@ -457,7 +457,7 @@ static int filter_ack(struct ieee80211_hw *dev, struct ieee80211_hdr *rx_hdr,
 		ieee80211_tx_status_irqsafe(dev, skb, &status);
 		kfree(control);
 	} else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return 1;
 }
-- 
1.5.1.2
