From: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] sunrpc: make the function arg as const
Date: Tue, 17 Oct 2017 18:14:23 +0200
Message-ID: <1508256866-12798-2-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: julia.lawall-L2FTfq7BK8M@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
        jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make the struct cache_detail *tmpl argument of the function
cache_create_net as const as it is only getting passed to kmemup having
the argument as const void *.
Add const to the prototype too.

Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/sunrpc/cache.h | 2 +-
 net/sunrpc/cache.c           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 270bad0..40d2822 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -213,7 +213,7 @@ extern int cache_check(struct cache_detail *detail,
 extern int cache_register_net(struct cache_detail *cd, struct net *net);
 extern void cache_unregister_net(struct cache_detail *cd, struct net *net);
 
-extern struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net);
+extern struct cache_detail *cache_create_net(const struct cache_detail *tmpl, struct net *net);
 extern void cache_destroy_net(struct cache_detail *cd, struct net *net);
 
 extern void sunrpc_init_cache_detail(struct cache_detail *cd);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 79d55d9..e689438 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1674,7 +1674,7 @@ void cache_unregister_net(struct cache_detail *cd, struct net *net)
 }
 EXPORT_SYMBOL_GPL(cache_unregister_net);
 
-struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net)
+struct cache_detail *cache_create_net(const struct cache_detail *tmpl, struct net *net)
 {
 	struct cache_detail *cd;
 	int i;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
