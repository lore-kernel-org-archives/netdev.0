From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] econet: kill unnecessary spin_lock_init()
Date: Sat, 28 Aug 2010 11:41:56 +0900
Message-ID: <1282963316-29938-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Julia Lawall <julia@diku.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:38823 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab0H1Css (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 22:48:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock aun_queue_lock is initialized statically. It is unnecessary
to initialize by spin_lock_init() at module load time.

This is detected by the semantic patch.

// <smpl>
@def@
declarer name DEFINE_SPINLOCK;
identifier spinlock;
@@

DEFINE_SPINLOCK(spinlock);

@@
identifier def.spinlock;
@@

- spin_lock_init(&spinlock);
// </smpl>

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Julia Lawall <julia@diku.dk>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/econet/af_econet.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index dc54bd0..baa98fb 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1009,7 +1009,6 @@ static int __init aun_udp_initialise(void)
 	struct sockaddr_in sin;
 
 	skb_queue_head_init(&aun_queue);
-	spin_lock_init(&aun_queue_lock);
 	setup_timer(&ab_cleanup_timer, ab_cleanup, 0);
 	ab_cleanup_timer.expires = jiffies + (HZ*2);
 	add_timer(&ab_cleanup_timer);
@@ -1167,7 +1166,6 @@ static int __init econet_proto_init(void)
 		goto out;
 	sock_register(&econet_family_ops);
 #ifdef CONFIG_ECONET_AUNUDP
-	spin_lock_init(&aun_queue_lock);
 	aun_udp_initialise();
 #endif
 #ifdef CONFIG_ECONET_NATIVE
-- 
1.6.0.6

