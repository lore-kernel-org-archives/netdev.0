From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 9/10] rhashtable: Allow GFP_ATOMIC bucket table
 allocation
Date: Sun, 22 Mar 2015 19:02:10 +1100
Message-ID: <20150322080209.GB2856@gondor.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
 <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48913 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbbCVIC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:02:29 -0400
Content-Disposition: inline
In-Reply-To: <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 06:53:52PM +1100, Herbert Xu wrote:
.
>  	size = sizeof(*tbl) + nbuckets * sizeof(tbl->buckets[0]);
> -	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> -		tbl = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> +	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER) ||
> +	    gfp != GFP_KERNEL)
> +		tbl = kzalloc(size, gfp | __GFP_NOWARN | __GFP_NORETRY);
>  	if (tbl == NULL)
>  		tbl = vzalloc(size);

Oops, this will still attempt vzalloc.  I will send a v2.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
