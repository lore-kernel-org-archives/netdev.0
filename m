From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 07/12] use a dynamic pool of sk_buffs to keep up with
 fast targets
Date: Tue, 3 Jul 2007 12:18:06 -0700
Message-ID: <20070703121806.5327d232@freepuppy.localdomain.hemminger.net>
References: <1d8423c28c48a6d26516cdc707dbcdf015a4e347.1182883861.git.ecashin@coraid.com>
	<bca4cec8ad679e8f8549cb78e012e54bfad1027e.1182883861.git.ecashin@coraid.com>
	<20070702213636.9ca1d842.akpm@linux-foundation.org>
	<20070702.214036.42772583.davem@davemloft.net>
	<20070703184533.GR11166@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760473AbXGCTSd@vger.kernel.org>
In-Reply-To: <20070703184533.GR11166@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Jul 2007 13:45:33 -0500
Matt Mackall <mpm@selenic.com> wrote:

> On Mon, Jul 02, 2007 at 09:40:36PM -0700, David Miller wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Mon, 2 Jul 2007 21:36:36 -0700
> > 
> > > My initial thought is that if there is a legitimate need for this
> > > new capability then it should be made available to other parts of
> > > the kernel rather than being private to the AEO driver.
> > 
> > Absolutely.
> > 
> > We even used to have something like this on a per-cpu basis but using
> > generic SLAB is so much better for caching and NUMA that we got rid of
> > that.
> > 
> > Every sk_buff private "quicklist" pool implementation you
> > see should essentially be NAK'd from the get go, it's
> > meaningless and if it's really needed one should investigate
> > why SKB allocations become such a problem instead of papering
> > over the issue. :-)
> 
> This is in the VM write-back path. SLAB is insufficient to avoid
> deadlock.
> 
Then where is the code to drain your pool back to the normal pool.
The problem with private pools is that they work great for benchmarks
and if that is the only code in the system. But they suck if other
code needs to run. How do you keep your private stash from running
the network device out of memory to receive packets?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
