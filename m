From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make net/ipv4/inet_timewait_sock.c:__inet_twsk_kill()
	static
Date: Fri, 13 Jul 2007 01:55:56 +0200
Message-ID: <20070712235556.GU3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59657 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759146AbXGLXzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 19:55:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global __inet_twsk_kill() static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/inet_timewait_sock.h |    3 ---
 net/ipv4/inet_timewait_sock.c    |    5 ++---
 2 files changed, 2 insertions(+), 6 deletions(-)

--- linux-2.6.22-rc6-mm1/include/net/inet_timewait_sock.h.old	2007-07-11 21:46:33.000000000 +0200
+++ linux-2.6.22-rc6-mm1/include/net/inet_timewait_sock.h	2007-07-11 21:46:49.000000000 +0200
@@ -209,9 +209,6 @@
 extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
 						  const int state);
 
-extern void __inet_twsk_kill(struct inet_timewait_sock *tw,
-			     struct inet_hashinfo *hashinfo);
-
 extern void __inet_twsk_hashdance(struct inet_timewait_sock *tw,
 				  struct sock *sk,
 				  struct inet_hashinfo *hashinfo);
--- linux-2.6.22-rc6-mm1/net/ipv4/inet_timewait_sock.c.old	2007-07-11 21:45:57.000000000 +0200
+++ linux-2.6.22-rc6-mm1/net/ipv4/inet_timewait_sock.c	2007-07-11 21:46:20.000000000 +0200
@@ -14,7 +14,8 @@
 #include <net/ip.h>
 
 /* Must be called with locally disabled BHs. */
-void __inet_twsk_kill(struct inet_timewait_sock *tw, struct inet_hashinfo *hashinfo)
+static void __inet_twsk_kill(struct inet_timewait_sock *tw,
+			     struct inet_hashinfo *hashinfo)
 {
 	struct inet_bind_hashbucket *bhead;
 	struct inet_bind_bucket *tb;
@@ -47,8 +48,6 @@
 	inet_twsk_put(tw);
 }
 
-EXPORT_SYMBOL_GPL(__inet_twsk_kill);
-
 /*
  * Enter the time wait state. This is called with locally disabled BH.
  * Essentially we whip up a timewait bucket, copy the relevant info into it

