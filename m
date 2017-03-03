From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Fri,  3 Mar 2017 13:45:35 +0100
Message-ID: <20170303124535.30125-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?q?Ond=C5=99ej=20Lyson=C4=9Bk?= <ondrej.lysonek@seznam.cz>,
        Jiri Slaby <jslaby@suse.cz>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60056 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751518AbdCCMps (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 07:45:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondřej Lysoněk <ondrej.lysonek@seznam.cz>

Use setup_timer() and setup_deferrable_timer() to set the data and
function timer fields. It makes the code cleaner and will allow for
easier change of the timer struct internals.

Signed-off-by: Ondřej Lysoněk <ondrej.lysonek@seznam.cz>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <linux-wireless@vger.kernel.org>
Cc: <netdev@vger.kernel.org>
---
 net/mac80211/agg-rx.c | 12 ++++++------
 net/mac80211/agg-tx.c | 12 ++++++------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 4456559cb056..1b7a4daf283c 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -357,14 +357,14 @@ void __ieee80211_start_rx_ba_session(struct sta_info *sta,
 	spin_lock_init(&tid_agg_rx->reorder_lock);
 
 	/* rx timer */
-	tid_agg_rx->session_timer.function = sta_rx_agg_session_timer_expired;
-	tid_agg_rx->session_timer.data = (unsigned long)&sta->timer_to_tid[tid];
-	init_timer_deferrable(&tid_agg_rx->session_timer);
+	setup_deferrable_timer(&tid_agg_rx->session_timer,
+			       sta_rx_agg_session_timer_expired,
+			       (unsigned long)&sta->timer_to_tid[tid]);
 
 	/* rx reorder timer */
-	tid_agg_rx->reorder_timer.function = sta_rx_agg_reorder_timer_expired;
-	tid_agg_rx->reorder_timer.data = (unsigned long)&sta->timer_to_tid[tid];
-	init_timer(&tid_agg_rx->reorder_timer);
+	setup_timer(&tid_agg_rx->reorder_timer,
+		    sta_rx_agg_reorder_timer_expired,
+		    (unsigned long)&sta->timer_to_tid[tid]);
 
 	/* prepare reordering buffer */
 	tid_agg_rx->reorder_buf =
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 45319cc01121..60e2a62f7bef 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -670,14 +670,14 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid,
 	tid_tx->timeout = timeout;
 
 	/* response timer */
-	tid_tx->addba_resp_timer.function = sta_addba_resp_timer_expired;
-	tid_tx->addba_resp_timer.data = (unsigned long)&sta->timer_to_tid[tid];
-	init_timer(&tid_tx->addba_resp_timer);
+	setup_timer(&tid_tx->addba_resp_timer,
+		    sta_addba_resp_timer_expired,
+		    (unsigned long)&sta->timer_to_tid[tid]);
 
 	/* tx timer */
-	tid_tx->session_timer.function = sta_tx_agg_session_timer_expired;
-	tid_tx->session_timer.data = (unsigned long)&sta->timer_to_tid[tid];
-	init_timer_deferrable(&tid_tx->session_timer);
+	setup_deferrable_timer(&tid_tx->session_timer,
+			       sta_tx_agg_session_timer_expired,
+			       (unsigned long)&sta->timer_to_tid[tid]);
 
 	/* assign a dialog token */
 	sta->ampdu_mlme.dialog_token_allocator++;
-- 
2.12.0
