From: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: Remove unused 'struct ieee80211_rx_status' ptr
Date: Mon, 21 Nov 2016 21:44:24 -0800
Message-ID: <20161122054424.GA31927@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit 554891e63a29 introduced 'struct ieee80211_rx_status' in
ieee80211_rx_h_defragment but did not use it. Compiling with W=1
gives the following warning, fix it.

net/mac80211/rx.c: In function ‘ieee80211_rx_h_defragment’:
net/mac80211/rx.c:1911:30: warning: variable ‘status’ set but not used [-Wunused-but-set-variable]

Fixes: 554891e63a29 ("mac80211: move packet flags into packet")
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Signed-off-by: Kirtika Ruchandani <kirtika-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 net/mac80211/rx.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index eeab725..d2a00f2 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1908,7 +1908,6 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *rx)
 	unsigned int frag, seq;
 	struct ieee80211_fragment_entry *entry;
 	struct sk_buff *skb;
-	struct ieee80211_rx_status *status;

 	hdr = (struct ieee80211_hdr *)rx->skb->data;
 	fc = hdr->frame_control;
@@ -2034,9 +2033,6 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *rx)
 		dev_kfree_skb(skb);
 	}

-	/* Complete frame has been reassembled - process it now */
-	status = IEEE80211_SKB_RXCB(rx->skb);
