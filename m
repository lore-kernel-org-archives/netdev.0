From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 1/4] mac80211: Removed unused 'i' variable
Date: Wed, 23 Nov 2016 20:45:36 -0800
Message-ID: <c7cb0fc989545ddc3c3dd1fe29774ee3bf483623.1479962513.git.kirtika@chromium.org>
References: <cover.1479962513.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Marek Kwaczynski <marek.kwaczynski@tieto.com>,
        David Spinadel <david.spinadel@intel.com>,
        Alexander Bondar <alexander.bondar@intel.com>,
        Michal Kazior <michal.kazior@tieto.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35243 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754622AbcKXEpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 23:45:42 -0500
Content-Disposition: inline
In-Reply-To: <cover.1479962513.git.kirtika@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5bcae31d9 (mac80211: implement multi-vif in-place reservations)
introduced ieee80211_vif_use_reserved_switch() with a counter variable
'i' that is set but not used. Compiling with W=1 gives the following
warning, fix it.
net/mac80211/chan.c: In function ‘ieee80211_vif_use_reserved_switch’:
net/mac80211/chan.c:1273:6: warning: variable ‘i’ set but not used [-Wunused-but-set-variable]

This is a harmless warning, and is only being fixed to reduce the
noise obtained with W=1 in the kernel.

Fixes: 5bcae31d9 ("mac80211: implement multi-vif in-place reservations")
Cc: Michal Kazior <michal.kazior@tieto.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Signed-off-by: Kirtika Ruchandani <kirtika@chromium.org>
---
 net/mac80211/chan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index e75cbf6..7550fd2 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -1270,7 +1270,7 @@ static int ieee80211_vif_use_reserved_switch(struct ieee80211_local *local)
 	struct ieee80211_sub_if_data *sdata, *sdata_tmp;
 	struct ieee80211_chanctx *ctx, *ctx_tmp, *old_ctx;
 	struct ieee80211_chanctx *new_ctx = NULL;
-	int i, err, n_assigned, n_reserved, n_ready;
+	int err, n_assigned, n_reserved, n_ready;
 	int n_ctx = 0, n_vifs_switch = 0, n_vifs_assign = 0, n_vifs_ctxless = 0;
 
 	lockdep_assert_held(&local->mtx);
@@ -1391,8 +1391,6 @@ static int ieee80211_vif_use_reserved_switch(struct ieee80211_local *local)
 	 * Update all structures, values and pointers to point to new channel
 	 * context(s).
 	 */
-
-	i = 0;
 	list_for_each_entry(ctx, &local->chanctx_list, list) {
 		if (ctx->replace_state != IEEE80211_CHANCTX_REPLACES_OTHER)
 			continue;
-- 
2.8.0.rc3.226.g39d4020
