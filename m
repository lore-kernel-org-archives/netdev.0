From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 20:54:54 +1100
Message-ID: <20150127095454.GA2695@gondor.apana.org.au>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35881 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861AbbA0Jzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 04:55:32 -0500
Content-Disposition: inline
In-Reply-To: <20150127094541.GC22262@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 09:45:41AM +0000, Thomas Graf wrote:
>
> OK. I'll wait for your netfilter approach before posting NLM_F_INTR
> patches.

Why would we still need the INTR stuff given that Dave has asked
for this to be done outside of rhashtable?

What I'm planning on doing right now is to divide rhashtable users
into two camps, lockless insert/removal vs. locked insert/removal.
netfilter will obviously fall into the latter camp.

For those with locked insert/removal I will make resizing/rehashing
synchronous since there is zero benefit from doing it in a separate
thread.

Once that is done you can then easily walk the table by just holding
the lock, which is what netfilter does today.

I'll probably make netlink locked too since it's much simpler that
way.  Only really high performance users like TCP/UDP sockets need
lockless insert/removal and the complexity that comes with it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
