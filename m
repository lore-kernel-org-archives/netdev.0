From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 12:09:41 +0000
Message-ID: <20150121120941.GX3012@acer.localdomain>
References: <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
 <20150121095837.GA25750@gondor.apana.org.au>
 <20150121103421.GR20315@casper.infradead.org>
 <20150121103959.GR3012@acer.localdomain>
 <20150121113751.GT20315@casper.infradead.org>
 <20150121115924.GW3012@acer.localdomain>
 <20150121120727.GC12570@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150121120727.GC12570@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.01, Thomas Graf wrote:
> On 01/21/15 at 11:59am, Patrick McHardy wrote:
> > On 21.01, Thomas Graf wrote:
> > > On 01/21/15 at 10:40am, Patrick McHardy wrote:
> > > > An automatic restart handles this well. Userspace always had to
> > > > expect duplicates.
> > > 
> > > Maybe I don't understand the restart yet. How do you restart if the
> > > dump was already started and the user has read part of the dump?
> > 
> > You use the mutex to prevent concurrent resizes and dumps, for dumps
> > that have left the kernel you simply reset the iterator state after
> > a resize operation.
> 
> I see, so we possibly see a lot of duplicates but we will never miss
> any entries.
> 
> So in summary we do:
> 
> 2) We allow rhashtable users to opt in to Herbert's consistent walker
>    relying on the use of an additional bit.
> 
> 2) If user supports NLM_F_DUMP_INTR we block out resizes during
>    message construction and set NLM_F_DUMP_INTR if a resize/rehash
>    interrupted us while the user read.
> 
> 3) If (1) and (2) are not available we do (2) but restart the dump
>    on interruption thus causing duplicates but never missing any
>    entries.
> 
> I think this offers good flexibility for new users and compatibility
> for existing users.

Yep, sounds good to me.
