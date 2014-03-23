From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in chan.c
Date: Mon, 24 Mar 2014 00:44:47 +0530
Message-ID: <1395602087-13123-1-git-send-email-monamagarwal123@gmail.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:64359 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaCWTPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 15:15:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/mac80211/chan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index bd1fd8e..b297bd3 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -392,7 +392,7 @@ static void ieee80211_unassign_vif_chanctx(struct ieee80211_sub_if_data *sdata,
 	lockdep_assert_held(&local->chanctx_mtx);
 
 	ctx->refcount--;
-	rcu_assign_pointer(sdata->vif.chanctx_conf, NULL);
+	RCU_INIT_POINTER(sdata->vif.chanctx_conf, NULL);
 
 	sdata->vif.bss_conf.idle = true;
 
-- 
1.7.9.5
