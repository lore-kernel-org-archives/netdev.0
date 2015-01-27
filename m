From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 21:24:20 +1100
Message-ID: <20150127102420.GA3777@gondor.apana.org.au>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150127101512.GE22262@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 27, 2015 at 10:15:12AM +0000, Thomas Graf wrote:
>
> Because libraries like libnl already handle this transparently for
> various user space apps. Those apps are not even aware of the problem
> and always get a consistent dump if the kernel implements INTR.

Did you see Dave's message? He said those that dump need to create
their own data structure so there is no point in proceeding with
any of this work within rhashtable.
 
> Because making it synchronous does not help the Netlink dump problem
> at all, see below.
> 
> Also, a sync resize causes a random inserts/removal to take a lot
> longer. This leads to less predictable insert/removal times. I have
> no objection to offering both sync and async resizing as long as the
> choice of balance is configurable.

So what?  They can switch over to lockless mode if they care.

The point is that for netfilter as it stands it makes no sense
to go lockless because its modus operandi is to hold a single
lock over everything, including walking/dumping.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
