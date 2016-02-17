From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 1/4] inetpeer: Add net namespace assosication in inet_peer_base
Date: Wed, 17 Feb 2016 12:09:55 +0200
Message-ID: <1455703798-15258-2-git-send-email-kernel@kyup.com>
References: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34092 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933830AbcBQKKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:10:03 -0500
Received: by mail-wm0-f48.google.com with SMTP id b205so148324006wmb.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:10:02 -0800 (PST)
In-Reply-To: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required so that the inet_peer_* sysctls can be
namespacified

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/inetpeer.h | 1 +
 net/ipv4/route.c       | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 235c7811a86a..287bb54cda58 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -67,6 +67,7 @@ struct inet_peer_base {
 	struct inet_peer __rcu	*root;
 	seqlock_t		lock;
 	int			total;
+	struct net		*net;
 };
 
 void inet_peer_base_init(struct inet_peer_base *);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e429c6..4bb45e52411c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2775,6 +2775,7 @@ static int __net_init ipv4_inetpeer_init(struct net *net)
 		return -ENOMEM;
 	inet_peer_base_init(bp);
 	net->ipv4.peers = bp;
+	bp->net = net;
 	return 0;
 }
 
-- 
2.5.0
