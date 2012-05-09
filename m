From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/13] mac80211: Convert compare_ether_addr to ether_addr_equal by hand
Date: Tue,  8 May 2012 21:56:53 -0700
Message-ID: <95ab271a19bf0fc4c4fa007e95b76edc8d6b5611.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

spatch/coccinelle isn't perfect.  It doesn't understand
__aligned(x) and doesn't convert functions it can't parse.

Convert the remaining compare_ether_addr uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/mac80211/rx.c       |    4 ++--
 net/mac80211/sta_info.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 26bfd6f..d722c40 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1714,8 +1714,8 @@ static bool ieee80211_frame_allowed(struct ieee80211_rx_data *rx, __le16 fc)
 	 * of whether the frame was encrypted or not.
 	 */
 	if (ehdr->h_proto == rx->sdata->control_port_protocol &&
-	    (compare_ether_addr(ehdr->h_dest, rx->sdata->vif.addr) == 0 ||
-	     compare_ether_addr(ehdr->h_dest, pae_group_addr) == 0))
+	    (ether_addr_equal(ehdr->h_dest, rx->sdata->vif.addr) ||
+	     ether_addr_equal(ehdr->h_dest, pae_group_addr)))
 		return true;
 
 	if (ieee80211_802_1x_port_control(rx) ||
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index f75f5d9..e920b22 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -501,7 +501,7 @@ void for_each_sta_info_type_check(struct ieee80211_local *local,
 		nxt = _sta ? rcu_dereference(_sta->hnext) : NULL	\
 	     )								\
 	/* compare address and run code only if it matches */		\
-	if (compare_ether_addr(_sta->sta.addr, (_addr)) == 0)
+	if (ether_addr_equal(_sta->sta.addr, (_addr)))
 
 /*
  * Get STA info by index, BROKEN!
-- 
1.7.8.111.gad25c.dirty
