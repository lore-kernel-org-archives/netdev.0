From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Wed, 20 Jul 2016 14:15:20 +0200
Message-ID: <20160720121520.GD3775@gauss.secunet.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58719 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbcGTMP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 08:15:26 -0400
Content-Disposition: inline
In-Reply-To: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 10:32:35AM +0200, Vegard Nossum wrote:
> AFAICT this message is just printed whenever input validation fails.
> This is a normal failure and we shouldn't be dumping the stack over it.
> 
> Looks like it was originally a printk that was maybe incorrectly
> upgraded to a WARN:
> 
> commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Wed May 12 06:37:06 2010 +0000
> 
>     xfrm: add severity to printk
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>  net/xfrm/xfrm_user.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 4fb04ce..0b81bfc 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -2150,7 +2150,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
>  	return 0;
>  
>  bad_policy:
> -	WARN(1, "BAD policy passed\n");
> +	printk(KERN_WARNING "xfrm_user: bad policy passed\n");

Why should we print here anything at all? If it is a normal
configuration error, we should remove the printing.
