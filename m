From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 9/9] rhashtable: Add immediate rehash during insertion
Date: Tue, 24 Mar 2015 08:44:23 +1100
Message-ID: <20150323214422.GA19938@gondor.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <E1Ya2kO-0004JD-Om@gondolin.me.apana.org.au>
 <20150323165033.GD20752@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57256 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCWVov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:44:51 -0400
Content-Disposition: inline
In-Reply-To: <20150323165033.GD20752@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 04:50:33PM +0000, Thomas Graf wrote:
>
> 2nd: Seems like you rely on an underflow to allow to "disable"
> the elasticity limit. Fair enough, but it would be great to
> have the limit configurable as well.
> 
> How about making elasticity a signed int, default to 16 if user
> specifies 0 and require it to be set to -1 (through a define)
> to actually disable the behaviour. That would avoid requiring
> two variables to implement this and makes the limit configurable
> at the same time.

I specifically made it this way because I don't think the users
should be touching the actual limit.  This is something that you
always want to enable unless you're in the situation of netfilter
where you don't care.

If you did care then 16 is sort of intrinsic to the 32-bit hash
that we're using.  Going below doesn't make much sense because
you may run into false warnings due to double rehashes (that's
how I discovered 4 was uesless, very quickly :) Remember the
rehash is only there to detect pathological cases where people
are actively attacking us.  Otherwise the 100% utilisation check
will kick in.

Going above 16 means that you're hashing multiple objects with
the same key.  Then you'd want to disable this altogether.

The rhashtable already has too many knobs and I don't want to
add anything unnecessary to rhashtable_params.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
