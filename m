From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] minor cleanup to net_namespace.c.
Date: Fri, 15 Apr 2011 14:37:52 +0200
Message-ID: <20110415123751.GC2697@psychotron>
References: <4DA83971.7010903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Rob Landley <rlandley@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DA83971.7010903@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Apr 15, 2011 at 02:26:25PM CEST, rlandley@parallels.com wrote:
>From: Rob Landley <rlandley@parallels.com>
>
>Inline a small static function that's only ever called from one place.
>
>Signed-off-by: Rob Landley <rlandley@parallels.com>
>---
>
> net/core/net_namespace.c |   12 ++++--------
> 1 file changed, 4 insertions(+), 8 deletions(-)
>
>diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>index 3f86026..1abb508 100644
>--- a/net/core/net_namespace.c
>+++ b/net/core/net_namespace.c
>@@ -216,11 +216,14 @@ static void net_free(struct net *net)
> 	kmem_cache_free(net_cachep, net);
> }
>
>-static struct net *net_create(void)
>+struct net *copy_net_ns(unsigned long flags, struct net *old_net)
> {
> 	struct net *net;
> 	int rv;
>
>+	if (!(flags & CLONE_NEWNET))
>+		return get_net(old_net);
>+
> 	net = net_alloc();
> 	if (!net)
> 		return ERR_PTR(-ENOMEM);
>@@ -239,13 +242,6 @@ static struct net *net_create(void)
> 	return net;
> }
>
>-struct net *copy_net_ns(unsigned long flags, struct net *old_net)
>-{
>-	if (!(flags & CLONE_NEWNET))
>-		return get_net(old_net);
>-	return net_create();
>-}
>-
> static DEFINE_SPINLOCK(cleanup_list_lock);
> static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
>

Reviewed-by: Jiri Pirko <jpirko@redhat.com>
