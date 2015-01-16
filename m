From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 16:32:03 +0000
Message-ID: <20150116163202.GJ30132@acer.localdomain>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116161530.GC15052@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.01, Thomas Graf wrote:
> On 01/16/15 at 04:03pm, Patrick McHardy wrote:
> > On 16.01, Thomas Graf wrote:
> > > A walker may not see insertions that occur after the walker was started
> > > if resizing is enabled. Is that a problem for nftables?
> > 
> > No, that would be Ok. The case I'm wondering about is:
> > 
> > - insertion
> > - resize starts
> > - another insertion
> > - walker, resize not finished yet
> 
> Correct, walker may not see "another insertion". The window for this
> behavior to occur is not the full resize operation, just the linking
> period, but it may occur. The length of the window is typically
> equal to a grace period.
> 
> We can provide a synchronization function to block the dumper or the
> insertion/removal until the linking is complete. The latter would
> give the old runtime behaviour back (variable runtime of insert),
> the blocked dumper might be preferred. What do you think?

If we have to block, the dumper if of course preferred. Taking the
mutex should do fine I guess?

I suppose walking both tables without any races would be rather
complicated.
