From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/8 net-2.6.26] [NETNS]: Add netns refcnt debug for inet bind buckets.
Date: Tue, 15 Apr 2008 16:37:52 +0400
Message-ID: <1208263075-28016-5-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39617 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760240AbYDOMjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:39:19 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/inet_hashtables.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 32ca2f8..1612184 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -35,7 +35,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
-		tb->ib_net       = net;
+		tb->ib_net       = hold_net(net);
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		INIT_HLIST_HEAD(&tb->owners);
@@ -51,6 +51,7 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
 {
 	if (hlist_empty(&tb->owners)) {
 		__hlist_del(&tb->node);
+		release_net(tb->ib_net);
 		kmem_cache_free(cachep, tb);
 	}
 }
-- 
1.5.3.rc5

