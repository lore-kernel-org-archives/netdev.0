From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] xfrm: spin_lock() should be spin_unlock() in
	xfrm_state.c
Date: Fri, 27 Mar 2009 09:16:54 +0800
Message-ID: <20090327011654.GA24848@gondor.apana.org.au>
References: <20090326185845.2c5719b4@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33579 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934436AbZC0BRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 21:17:01 -0400
Content-Disposition: inline
In-Reply-To: <20090326185845.2c5719b4@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2009 at 06:58:45PM -0400, Chuck Ebbert wrote:
> xfrm: spin_lock() should be spin_unlock() in xfrm_state.c
> 
> spin_lock() should be spin_unlock() in xfrm_state_walk_done().
> 
> caused by:
> commit 12a169e7d8f4b1c95252d8b04ed0f1033ed7cfe2
> "ipsec: Put dumpers on the dump list"
> 
> Reported-by: Marc Milgram <mmilgram@redhat.com>
> Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
> ---
> 
> --- linux-2.6.29.noarch.orig/net/xfrm/xfrm_state.c
> +++ linux-2.6.29.noarch/net/xfrm/xfrm_state.c
> @@ -1615,7 +1615,7 @@ void xfrm_state_walk_done(struct xfrm_st
>  
>  	spin_lock_bh(&xfrm_state_lock);
>  	list_del(&walk->all);
> -	spin_lock_bh(&xfrm_state_lock);
> +	spin_unlock_bh(&xfrm_state_lock);
>  }
>  EXPORT_SYMBOL(xfrm_state_walk_done);

Good catch!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
