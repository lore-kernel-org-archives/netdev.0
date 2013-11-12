From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH 1/2] random32: add __init prefix to prandom_start_seed_timer
Date: Tue, 12 Nov 2013 23:45:41 +0100
Message-ID: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756787Ab3KLWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 17:45:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only call that in functions annotated with __init, so add __init
prefix in prandom_start_seed_timer() as well, so that the kernel can
make use of this hint and we can possibly free up resources after it's
usage. And since it's an internal function rename it to
__prandom_start_seed_timer().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/random32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/random32.c b/lib/random32.c
index 82da4f4..4f9d5df 100644
--- a/lib/random32.c
+++ b/lib/random32.c
@@ -222,7 +222,7 @@ static void __prandom_timer(unsigned long dontcare)
 	add_timer(&seed_timer);
 }
 
-static void prandom_start_seed_timer(void)
+static void __init __prandom_start_seed_timer(void)
 {
 	set_timer_slack(&seed_timer, HZ);
 	seed_timer.expires = jiffies + 40 * HZ;
@@ -270,7 +270,7 @@ void prandom_reseed_late(void)
 static int __init prandom_reseed(void)
 {
 	__prandom_reseed(false);
-	prandom_start_seed_timer();
+	__prandom_start_seed_timer();
 	return 0;
 }
 late_initcall(prandom_reseed);
-- 
1.8.3.1
