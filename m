From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][next] xfrm: optimise xfrm_policy_lookup_bytype
Date: Mon, 11 May 2015 14:06:17 +0200
Message-ID: <20150511120616.GS8928@secunet.com>
References: <1431170257-18242-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33344 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094AbbEKMGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 08:06:23 -0400
Content-Disposition: inline
In-Reply-To: <1431170257-18242-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 09, 2015 at 07:17:37PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> It is unnecessary to continue to loop the policy if the priority
> of current looped police is larger than priority which is from
> the policy_bydst list.

Please explain why it is unnecessary to continue with the
loop here. In general a commit message should explain why
this code is changed.

> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/xfrm/xfrm_policy.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 66450c3..4adee12 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1116,6 +1116,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
>  	}
>  	chain = &net->xfrm.policy_inexact[dir];
>  	hlist_for_each_entry(pol, chain, bydst) {
> +		if (pol->priority >= priority)
> +			break;

priority is initialized with ~0U at the beginning of this function.
What if someone has an inexact policy with priority ~0U configured?
With your change, this policy will never match because we don't even
try to search for it.
