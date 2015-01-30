From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Fri, 30 Jan 2015 08:10:56 +0000
Message-ID: <20150130081055.GA6164@acer.localdomain>
References: <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
 <20150127101512.GE22262@casper.infradead.org>
 <20150127102420.GA3777@gondor.apana.org.au>
 <20150127111604.GF22262@casper.infradead.org>
 <20150127112304.GA4548@gondor.apana.org.au>
 <20150127130950.GA3950@acer.localdomain>
 <20150127203657.GA9061@gondor.apana.org.au>
 <20150128190715.GA4764@acer.localdomain>
 <20150130055859.GA17149@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	David.Laight@ACULAB.COM, ying.xue@windriver.com,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150130055859.GA17149@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.01, Herbert Xu wrote:
> On Wed, Jan 28, 2015 at 07:07:16PM +0000, Patrick McHardy wrote:
> > On 28.01, Herbert Xu wrote:
> > > On Tue, Jan 27, 2015 at 01:09:50PM +0000, Patrick McHardy wrote:
> > > >
> > > > Actually I have a patchset queued that adds runtime additions and
> > > > removals, both active and timeout based. So netfilter won't have
> > > > pure synchronous behaviour anymore.
> > > 
> > > Can you show us the patchset?
> > 
> > Sure, will send it over tomorrow.
> 
> So how are you handling the locking in these cases?

Insertion is handled using the rhashtable internal locks. GC happens
in work context and takes the rhashtable mutex, then walks the table
similar to nft_hash_walk and removes stale entries.

Still need to work out something to reduce RCU grace periods
(currently ignored) and make sure we don't race between ->get/->remove
in the netlink API and GC.
