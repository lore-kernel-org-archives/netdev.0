From: James Morris <jmorris@namei.org>
Subject: Re: PATCH[1/1]: kernel panic when large security contexts in ACQUIRE
Date: Fri, 13 Apr 2007 13:51:24 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0704131351080.20794@d.namei>
References: <200704131504.l3DF4lYF031824@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:58952 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbXDMRv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 13:51:28 -0400
In-Reply-To: <200704131504.l3DF4lYF031824@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Apr 2007, Joy Latten wrote:

> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Acked-by: James Morris <jmorris@namei.org>


> 
> 
> diff -urpN linux-2.6.20/net/xfrm/xfrm_user.c linux-2.6.20.patch/net/xfrm/xfrm_user.c
> --- linux-2.6.20/net/xfrm/xfrm_user.c	2007-04-12 15:12:27.000000000 -0500
> +++ linux-2.6.20.patch/net/xfrm/xfrm_user.c	2007-04-13 09:32:35.000000000 -0500
> @@ -272,9 +272,8 @@ static int attach_encap_tmpl(struct xfrm
>  }
>  
>  
> -static inline int xfrm_user_sec_ctx_size(struct xfrm_policy *xp)
> +static inline int xfrm_user_sec_ctx_size(struct xfrm_sec_ctx *xfrm_ctx)
>  {
> -	struct xfrm_sec_ctx *xfrm_ctx = xp->security;
>  	int len = 0;
>  
>  	if (xfrm_ctx) {
> @@ -2170,7 +2169,7 @@ static int xfrm_send_acquire(struct xfrm
>  
>  	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
>  	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
> -	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
> +	len += RTA_SPACE(xfrm_user_sec_ctx_size(x->security));
>  #ifdef CONFIG_XFRM_SUB_POLICY
>  	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
>  #endif
> @@ -2280,7 +2279,7 @@ static int xfrm_exp_policy_notify(struct
>  
>  	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
>  	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
> -	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp));
> +	len += RTA_SPACE(xfrm_user_sec_ctx_size(xp->security));
>  #ifdef CONFIG_XFRM_SUB_POLICY
>  	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
>  #endif
> 

-- 
James Morris
<jmorris@namei.org>
