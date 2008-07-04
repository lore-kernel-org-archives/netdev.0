From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 6/9] netns: add struct net parameter to rt_cache_invalidate
Date: Fri,  4 Jul 2008 17:17:09 +0400
Message-ID: <1215177432-25934-6-git-send-email-den@openvz.org>
References: <1215177360.27873.50.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20218 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754256AbYGDNQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 09:16:51 -0400
In-Reply-To: <1215177360.27873.50.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f99d9db..9725223 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -778,7 +778,7 @@ static void rt_worker_func(struct work_struct *work)
  * many times (2^24) without giving recent rt_genid.
  * Jenkins hash is strong enough that litle changes of rt_genid are OK.
  */
-static void rt_cache_invalidate(void)
+static void rt_cache_invalidate(struct net *net)
 {
 	unsigned char shuffle;
 
@@ -792,7 +792,7 @@ static void rt_cache_invalidate(void)
  */
 void rt_cache_flush(struct net *net, int delay)
 {
-	rt_cache_invalidate();
+	rt_cache_invalidate(net);
 	if (delay >= 0)
 		rt_do_flush(!in_softirq());
 }
@@ -803,7 +803,7 @@ void rt_cache_flush(struct net *net, int delay)
 static void rt_secret_rebuild(unsigned long __net)
 {
 	struct net *net = (struct net *)__net;
-	rt_cache_invalidate();
+	rt_cache_invalidate(net);
 	mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
 }
 
-- 
1.5.3.rc5

