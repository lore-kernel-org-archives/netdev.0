From: Joe Perches <joe@perches.com>
Subject: [PATCH -next] mac80211: Use #define IEEE80211_CCMP_PN_LEN and bool
Date: Mon, 30 Mar 2015 09:37:54 -0700
Message-ID: <1427733474.14276.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a #define constant instead of a hardcoded value
and use bool for an int used as a bool to reduce
structure size.

Miscellanea:

Neaten comments in structure definition.
Add #include of ieee80211.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/ieee80211_i.h | 7 ++++---
 net/mac80211/rx.c          | 4 ++--
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8d53d65..08f994d 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -26,6 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/leds.h>
 #include <linux/idr.h>
+#include <linux/ieee80211.h>
 #include <net/ieee80211_radiotap.h>
 #include <net/cfg80211.h>
 #include <net/mac80211.h>
@@ -89,11 +90,11 @@ struct ieee80211_fragment_entry {
 	unsigned int last_frag;
 	unsigned int extra_len;
 	struct sk_buff_head skb_list;
-	int ccmp; /* Whether fragments were encrypted with CCMP */
-	u8 last_pn[6]; /* PN of the last fragment if CCMP was used */
+	/* for CCMP fragments */
+	bool ccmp;				/* encrypted with CCMP */
+	u8 last_pn[IEEE80211_CCMP_PN_LEN];	/* PN of the last fragment */
 };
 
-
 struct ieee80211_bss {
 	u32 device_ts_beacon, device_ts_presp;
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 944bdc0..367ed9c 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1711,7 +1711,7 @@ ieee80211_reassemble_add(struct ieee80211_sub_if_data *sdata,
 	entry->seq = seq;
 	entry->rx_queue = rx_queue;
 	entry->last_frag = frag;
-	entry->ccmp = 0;
+	entry->ccmp = false;
 	entry->extra_len = 0;
 
 	return entry;
@@ -1812,7 +1812,7 @@ ieee80211_rx_h_defragment(struct ieee80211_rx_data *rx)
 			int queue = rx->security_idx;
 			/* Store CCMP PN so that we can verify that the next
 			 * fragment has a sequential PN value. */
-			entry->ccmp = 1;
+			entry->ccmp = true;
 			memcpy(entry->last_pn,
 			       rx->key->u.ccmp.rx_pn[queue],
 			       IEEE80211_CCMP_PN_LEN);
