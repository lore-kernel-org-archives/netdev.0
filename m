From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCHv2 net-next 3/4] flowcache: Fixup flow cache part in xfrm
 policy
Date: Tue, 14 Jan 2014 19:59:07 +0100
Message-ID: <20140114185907.GB1971@kria>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
 <1389663588-29678-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:39778 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbaANS7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 13:59:24 -0500
Content-Disposition: inline
In-Reply-To: <1389663588-29678-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-01-14, 09:39:46 +0800, Fan Du wrote:
> Bump flow cache genid, and flush flow cache should also be made
> in per net style.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_policy.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index e205c4b..d39c90f 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -661,7 +661,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
>  		hlist_add_head(&policy->bydst, chain);
>  	xfrm_pol_hold(policy);
>  	net->xfrm.policy_count[dir]++;
> -	atomic_inc(&flow_cache_genid);
> +	atomic_inc(&net->xfrm.flow_cache_genid);
>  
>  	/* After previous checking, family can either be AF_INET or AF_INET6 */
>  	if (policy->family == AF_INET)
> @@ -2567,14 +2567,14 @@ static void __xfrm_garbage_collect(struct net *net)
>  
>  void xfrm_garbage_collect(struct net *net)
>  {
> -	flow_cache_flush();
> +	flow_cache_flush(net);
>  	__xfrm_garbage_collect(net);
>  }
>  EXPORT_SYMBOL(xfrm_garbage_collect);
>  
>  static void xfrm_garbage_collect_deferred(struct net *net)
>  {
> -	flow_cache_flush_deferred();
> +	flow_cache_flush_deferred(net);
>  	__xfrm_garbage_collect(net);
>  }
>  
> @@ -2947,6 +2947,7 @@ static int __net_init xfrm_net_init(struct net *net)
>  	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
>  	mutex_init(&net->xfrm.xfrm_cfg_mutex);
>  
> +	flow_cache_init(net);
>  	return 0;
>  
>  out_sysctl:


You didn't address Cong Wang's comments for v1:

2014-01-13, 11:42:47 -0800, Cong Wang wrote:
> On Sun, Jan 12, 2014 at 11:49 PM, Fan Du <fan.du@windriver.com> wrote:
> >  void xfrm_garbage_collect(struct net *net)
> >  {
> > -       flow_cache_flush();
> > +       flow_cache_flush(net);
> >         __xfrm_garbage_collect(net);
> >  }
> >  EXPORT_SYMBOL(xfrm_garbage_collect);
> >
> >  static void xfrm_garbage_collect_deferred(struct net *net)
> >  {
> > -       flow_cache_flush_deferred();
> > +       flow_cache_flush_deferred(net);
> >         __xfrm_garbage_collect(net);
> >  }
> >
> 
> You changed the prototypes of flow_cache_flush*() in the previous
> patch, so, here you break bisect. They have to be in one commit.


-- 
Sabrina
