From: igorm@etf.rs
Subject: [PATCH] Fix skb_update_prio
Date: Fri, 25 Nov 2011 18:44:54 +0100
Message-ID: <1322243094-10420-2-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1322243094-10420-1-git-send-email-igorm@etf.rs>
Cc: Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:58525 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947Ab1KYRpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 12:45:11 -0500
In-Reply-To: <1322243094-10420-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Change function rcu_dereference to rcu_dereference_bh to avoid warning

[ INFO: suspicious RCU usage. ]
-------------------------------
net/core/dev.c:2459 suspicious rcu_dereference_check() usage!

because we are locking with

rcu_read_lock_bh();

in function dev_queue_xmit(struct sk_buff *skb)

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8afb244..d1f1071 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2452,7 +2452,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 static void skb_update_prio(struct sk_buff *skb)
 {
-	struct netprio_map *map = rcu_dereference(skb->dev->priomap);
+	struct netprio_map *map = rcu_dereference_bh(skb->dev->priomap);
 
 	if ((!skb->priority) && (skb->sk) && map)
 		skb->priority = map->priomap[skb->sk->sk_cgrp_prioidx];
-- 
1.7.5.4
