From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/1 net-2.6.26] [XFRM]: Compilation warnings in xfrm_user.c.
Date: Mon, 14 Apr 2008 10:35:46 -0400
Message-ID: <200804141035.46671.paul.moore@hp.com>
References: <1208178219-18754-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:6639 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbYDNOf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 10:35:59 -0400
In-Reply-To: <1208178219-18754-1-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 April 2008 9:03:39 am Denis V. Lunev wrote:
> When CONFIG_SECURITY_NETWORK_XFRM is undefined the following warnings
> appears: net/xfrm/xfrm_user.c: In function 'xfrm_add_pol_expire':
> net/xfrm/xfrm_user.c:1576: warning: 'ctx' may be used uninitialized
> in this function net/xfrm/xfrm_user.c: In function 'xfrm_get_policy':
> net/xfrm/xfrm_user.c:1340: warning: 'ctx' may be used uninitialized
> in this function (security_xfrm_policy_alloc is noop for the case).
>
> It seems that they are result of the commit
> 03e1ad7b5d871d4189b1da3125c2f12d1b5f7d0b
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  net/xfrm/xfrm_user.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index b822b56..1810f56 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -1343,14 +1343,14 @@ static int xfrm_get_policy(struct sk_buff
> *skb, struct nlmsghdr *nlh, if (err)
>  			return err;
>
> +		ctx = NULL;
>  		if (rt) {
>  			struct xfrm_user_sec_ctx *uctx = nla_data(rt);
>
>  			err = security_xfrm_policy_alloc(&ctx, uctx);
>  			if (err)
>  				return err;
> -		} else
> -			ctx = NULL;
> +		}
>  		xp = xfrm_policy_bysel_ctx(type, p->dir, &p->sel, ctx,
>  					   delete, &err);
>  		security_xfrm_policy_free(ctx);

Thanks for catching this, I was focusing more on the runtime issues with 
the else statement and forgot about compile time issues.  I wonder if 
it would be better to fix this in the dummy function for 
security_xfrm_policy_alloc()?  It seems cleaner to me.

-- 
paul moore
linux @ hp
