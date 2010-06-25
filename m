From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + fix-netpoll-allow-netpoll_setup-cleanup-recursion.patch
	added to -mm tree
Date: Fri, 25 Jun 2010 13:00:43 +1000
Message-ID: <20100625030043.GA26269@gondor.apana.org.au>
References: <201006250121.o5P1La69008693@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mm-commits@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54412 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab0FYDAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 23:00:50 -0400
Content-Disposition: inline
In-Reply-To: <201006250121.o5P1La69008693@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 05:52:47PM -0700, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      fix "netpoll: Allow netpoll_setup/cleanup recursion"
> has been added to the -mm tree.  Its filename is
>      fix-netpoll-allow-netpoll_setup-cleanup-recursion.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: fix "netpoll: Allow netpoll_setup/cleanup recursion"
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Remove rtnl_unlock() which had no corresponding rtnl_lock().
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Thanks for catching this Andrew!

> ---
> 
>  net/core/netpoll.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff -puN net/core/netpoll.c~fix-netpoll-allow-netpoll_setup-cleanup-recursion net/core/netpoll.c
> --- a/net/core/netpoll.c~fix-netpoll-allow-netpoll_setup-cleanup-recursion
> +++ a/net/core/netpoll.c
> @@ -748,7 +748,6 @@ int __netpoll_setup(struct netpoll *np)
>  
>  	/* last thing to do is link it to the net device structure */
>  	rcu_assign_pointer(ndev->npinfo, npinfo);
> -	rtnl_unlock();
>  
>  	return 0;
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
