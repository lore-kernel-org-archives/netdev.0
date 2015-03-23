From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 20:39:52 +1100
Message-ID: <20150323093952.GA12635@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
 <20150323083319.GB16023@casper.infradead.org>
 <20150323092806.GA12506@gondor.apana.org.au>
 <20150323093632.GD16023@casper.infradead.org>
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
Received: from ringil.hengli.com.au ([178.18.16.133]:56447 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbCWJkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:40:10 -0400
Content-Disposition: inline
In-Reply-To: <20150323093632.GD16023@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 09:36:32AM +0000, Thomas Graf wrote:
>
> > You never want automatic shrinking unless all your users are
> > trusted.  I doubt there would be many rhashtable users where
> > this would apply.  Even nft_hash is quite tenuous.
> 
> Why?

Because with multiple rehashing it's quite easy to convert your
hash table into a linked list by repeatedly growing and shrinking.

Multiple rehashing simply cannot work unless you get rid of automatic
shrinking for the untrusted case.

> Same can be said for growing. Why do we differ between the two?
> Would you expect users requiring shrinking() to call
> rhashtable_shrink() after every remove? Should they encode their
> own logic based on rhashtable internals?

No we must be able to grow or insertions will fail.  The same cannot
be said for shrinking.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
