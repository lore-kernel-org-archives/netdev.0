From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] mac80211: Check correct skb for shared states
 before freeing original
Date: Wed, 10 Sep 2014 16:06:23 -0400
Message-ID: <20140910200442.15961.84466.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The code for cloning the skb for an acknowledgement was checking to see if
the cloned skb was shared and if it was it was then freeing the original
skb.  Since a clone should never really be shared I suspect that the
intention was to avoid freeing the clone if the original was shared.  As
such I am updating the code so that if the original is shared we free the
original and use the clone.  This avoids unnecessary work in the next
section where we would be cloning the skb if the original is shared.

Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/tx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 925c39f..e527cd3 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2087,7 +2087,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 			if (id >= 0) {
 				info_id = id;
 				info_flags |= IEEE80211_TX_CTL_REQ_TX_STATUS;
-			} else if (skb_shared(skb)) {
+			} else if (skb_shared(orig_skb)) {
 				kfree_skb(orig_skb);
 			} else {
 				kfree_skb(skb);

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
