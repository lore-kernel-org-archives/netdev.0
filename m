From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 20:29:21 +1100
Message-ID: <20150323092921.GB12506@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150322130630.GA16023@casper.infradead.org>
 <20150323000707.GA9507@gondor.apana.org.au>
 <20150323083712.GC16023@casper.infradead.org>
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
Received: from ringil.hengli.com.au ([178.18.16.133]:54253 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbCWJ3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:29:38 -0400
Content-Disposition: inline
In-Reply-To: <20150323083712.GC16023@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 08:37:12AM +0000, Thomas Graf wrote:
>
> I think rhashtable_shrink() should fetch ht->tbl in an RCU section to
> cheaply get the current table size and only do the allocation and take
> the lock if the table size warrants for shrinking.

Well you should never invoke rhashtable_shrink unless you actually
wanted to shrink.  So this is something that you should have checked
before rhashtable_shrink is called.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
