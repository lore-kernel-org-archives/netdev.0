From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] XFRM: remove redundant parameter "int dir" in struct
 xfrm_mgr.acquire
Date: Mon, 13 Aug 2012 09:08:41 +0200
Message-ID: <20120813070841.GP1869@secunet.com>
References: <1344839157-25797-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55475 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364Ab2HMHIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 03:08:44 -0400
Content-Disposition: inline
In-Reply-To: <1344839157-25797-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 13, 2012 at 02:25:57PM +0800, Fan Du wrote:
>  
>  static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
> -			     struct xfrm_policy *xp, int dir)
> +			     struct xfrm_policy *xp)
>  {
>  	struct net *net = xs_net(x);
>  	struct sk_buff *skb;
> @@ -2614,7 +2614,7 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
>  	if (skb == NULL)
>  		return -ENOMEM;
>  
> -	if (build_acquire(skb, x, xt, xp, dir) < 0)
> +	if (build_acquire(skb, x, xt, xp, XFRM_POLICY_OUT) < 0)
>  		BUG();

xfrm_send_acquire() is the only caller of build_acquire().
So if you remove the dir parameter from xfrm_send_acquire(),
you can remove it from build_acquire() too. 
