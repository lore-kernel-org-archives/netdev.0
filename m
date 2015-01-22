From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Thu, 22 Jan 2015 09:05:18 +0000
Message-ID: <20150122090518.GA30859@casper.infradead.org>
References: <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
 <20150121095837.GA25750@gondor.apana.org.au>
 <20150121102346.GQ20315@casper.infradead.org>
 <20150122063501.GA3746@gondor.apana.org.au>
 <20150122072030.GA4039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150122072030.GA4039@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/22/15 at 06:20pm, Herbert Xu wrote:
> On Thu, Jan 22, 2015 at 05:35:01PM +1100, Herbert Xu wrote:
> > On Wed, Jan 21, 2015 at 10:23:46AM +0000, Thomas Graf wrote:
> > >
> > > The usage will be identical to how __inet_lookup_listener() uses it.
> > > If at the end of the lookup, we ended up in a different table than
> > > we started, the lookup is restarted as an entry has moved to another
> > > table while we were moving over it.
> > 
> > Who uses this stuff apart from ip_dynaddr?
> 
> OK it's there for fast socket recycling.  Given that and the fact
> that everyone seems to be happy with restarting the dump after a
> resize, I think we should just go with that.
> 
> Anybody who wants a better walk can always implement their own
> data structure outside of rhashtable.

What did you think of the idea to let the user store the walker
bit for rhashtable?
