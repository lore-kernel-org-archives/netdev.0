From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Sat, 28 Apr 2007 15:52:46 +1000
Message-ID: <20070428055246.GA6172@gondor.apana.org.au>
References: <20070411075602.GA17635@gondor.apana.org.au> <1176293751.14322.14.camel@localhost.localdomain> <20070411122317.GA21159@gondor.apana.org.au> <1177739161.30071.165.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, buytenh@gnu.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1948 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161139AbXD1FxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 01:53:02 -0400
Content-Disposition: inline
In-Reply-To: <1177739161.30071.165.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 03:46:01PM +1000, Rusty Russell wrote:
> 
> OK, I did a quick check, and the only one I could find was br_if.c which
> calls register_netdevice() and doesn't set get_stats.  I don't think
> that zeroes in this case matters.

Thanks for following up on this Rusty!

Actually I just had a look at br_if.c and it seems that it does set
get_stats through br_dev_setup to br_dev_get_stats.

> ==
> Remove NETIF_F_INTERNAL_STATS: default to internal stats.
> 
> Herbert Xu conviced me that a new flag was overkill; every driver
> currently overrides get_stats, so we might as well make the internal
> one the default.  If someone did fail to set get_stats, they would now
> get all 0 stats instead of "No statistics available".
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Looks good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
