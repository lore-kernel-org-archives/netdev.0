From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Tue, 24 Mar 2015 08:48:20 +1100
Message-ID: <20150323214819.GB19938@gondor.apana.org.au>
References: <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
 <20150323083319.GB16023@casper.infradead.org>
 <20150323.124434.1526209682898584518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57149 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCWVse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:48:34 -0400
Content-Disposition: inline
In-Reply-To: <20150323.124434.1526209682898584518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 12:44:34PM -0400, David Miller wrote:
>
> The user can't do this with TCP?  Why is netlink only susceptible?
> 
> The only plausible argument for shrinking I've ever heard of is the
> nft_hash case, and there that code can _explicitly_ ask for a shrink
> after it has made a major table modification.
> 
> That puts all of the smarts for when to shrink where the knowledge
> resides, and in this case that's the user.

One thing I got to say is that automatic shrinking is a really
good stress test as reenabling it allowed me to quickly identify
two bugs in the final patch :)

Other than that I totally agree that it should be disabled by
default as otherwise it increases the amortised cost of the hash
table for a paltry saving in memory.

We can do it afterwards once we're sure this whole thing is stable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
