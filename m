From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to traverse
 the bridge without hitting netfilter
Date: Fri, 6 Mar 2015 17:37:00 +0100
Message-ID: <20150306163700.GC20382@breakpoint.cc>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>
 <20150223160619.GF24297@breakpoint.cc>
 <54EEF32D.2010202@amazon.de>
 <20150226.113431.238255529591339000.davem@davemloft.net>
 <54F982B5.90108@gmail.com>
 <20150306142932.GA15926@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Imre Palik <imrep.amz@gmail.com>,
	David Miller <davem@davemloft.net>, imrep@amazon.de,
	fw@strlen.de, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, aliguori@amazon.com, nbd@openwrt.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150306142932.GA15926@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Mar 06, 2015 at 11:34:29AM +0100, Imre Palik wrote:
> > On 02/26/15 17:34, David Miller wrote:
> > > From: Imre Palik <imrep@amazon.de>
> > > Date: Thu, 26 Feb 2015 11:19:25 +0100
> > > 
> > >> If you are looking for peculiarities in my setup then here they are:
> > >> I am on 4k pages, and perf is not working :-(
> > >> (I am trying to fix those too, but that is far from being a low hanging fruit.)
> > >> So my guess would be that the packet pipeline doesn't fit in the cache/tlb
> > > 
> > > Pure specualtion until you can actually use perf to measure these
> > > things.
> > > 
> > > And I don't want to apply patches which were designed based upon
> > > pure speculation.
> > > 
> > 
> > I did performance measurements in the following way:
> > 
> > Removed those pieces of the packet pipeline that I don't necessarily
> > need one-by-one.  Then measured their effect on small packet
> > performance.
> > 
> > This was the only part that produced considerable effect.
> > 
> > The pure speculation was about why the effect is more than 15%
> > increase in packet throughput, although the code path avoided
> > contains way less code than 15% of the packet pipeline.  It seems,
> > Felix Fietkau profiled similar changes, and found my guess well
> > founded.
> > 
> > Now could anybody explain me what else is wrong with my patch?
> 
> We have to come up with a more generic solution for this.

Jiri Benc suggested to allowing to attach netfilter hooks e.g. via tc
action, maybe that would be an option worth investigating.

Then you could for instance add filtering rules only to the bridge port
that needs it.

> These sysfs tweaks you're proposing look to me like an obscure way to
> tune this.

I agree, adding more tunables isn't all that helpful, in the past this
only helped to prolong the problem.
