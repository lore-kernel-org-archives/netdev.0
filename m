From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: Delete hold_timer when destroy policy
Date: Thu, 1 Aug 2013 14:01:47 +0200
Message-ID: <20130801120146.GD25511@secunet.com>
References: <1375351716-3265-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42929 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752542Ab3HAMBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 08:01:49 -0400
Content-Disposition: inline
In-Reply-To: <1375351716-3265-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 06:08:36PM +0800, Fan Du wrote:
> Both policy timer and hold_timer need to be deleted when destroy policy
> Bad mood today, maybe I'm wrong about this...
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_policy.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index d8da6b8..f7078eb 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -308,7 +308,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
>  {
>  	BUG_ON(!policy->walk.dead);
>  
> -	if (del_timer(&policy->timer))
> +	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_timer))
>  		BUG();
>  

The timers should be already deleted when xfrm_policy_destroy() is
called. This is just to check if that really happened and to
catch this bug if not. So it's not a bug fix, it just helps to
catch a potential bug. I'll consider to take this into ipsec-next
after some testing.
