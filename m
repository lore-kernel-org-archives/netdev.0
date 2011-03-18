From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 35/36] net/mac80211,rcu: convert call_rcu(work_free_rcu) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:14:15 +0800
Message-ID: <4D82DC17.2090106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65167 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752712Ab1CREM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback work_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(work_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/mac80211/work.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index 36305e0..dcc433e 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -66,17 +66,9 @@ static void run_again(struct ieee80211_local *local,
 		mod_timer(&local->work_timer, timeout);
 }
 
-static void work_free_rcu(struct rcu_head *head)
-{
-	struct ieee80211_work *wk =
-		container_of(head, struct ieee80211_work, rcu_head);
-
-	kfree(wk);
-}
-
 void free_work(struct ieee80211_work *wk)
 {
-	call_rcu(&wk->rcu_head, work_free_rcu);
+	kfree_rcu(wk, rcu_head);
 }
 
 static int ieee80211_compatible_rates(const u8 *supp_rates, int supp_rates_len,
-- 
1.7.4
