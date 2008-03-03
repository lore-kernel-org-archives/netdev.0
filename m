From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Mon, 3 Mar 2008 14:14:42 +1100
Message-ID: <200803031414.43076.nickpiggin@yahoo.com.au>
References: <47BDBC23.10605@cosmosbay.com> <200802232023.52352.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271140470.1790@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760183AbYCCDPn@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0802271140470.1790@schroedinger.engr.sgi.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 February 2008 06:44, Christoph Lameter wrote:
> On Sat, 23 Feb 2008, Nick Piggin wrote:
> > What I don't understand is why the slab allocators have something like
> > this in it:
> >
> >         if ((flags & SLAB_HWCACHE_ALIGN) &&
> >                         size > cache_line_size() / 2)
> >                 return max_t(unsigned long, align, cache_line_size());
> >
> > If you ask for HWCACHE_ALIGN, then you should get it. I don't
> > understand, why do they think they knows better than the caller?
>
> Tradition.... Its irks me as well.
>
> > Things like this are just going to lead to very difficult to track
> > performance problems. Possibly correctness problems in rare cases.
> >
> > There could be another flag for "maybe align".
>
> SLAB_HWCACHE_ALIGN *is* effectively a maybe align flag given the above
> code.
>
> If we all agree then we could change this to have must have semantics? It
> has the potential of enlarging objects for small caches.
>
> SLAB_HWCACHE_ALIGN has an effect that varies according to the alignment
> requirements of the architecture that the kernel is build on. We may be in
> for some surprises if we change this.

I think so. If we ask for HWCACHE_ALIGN, it must be for a good reason.
If some structures get too bloated for no good reason, then the problem
is not with the slab allocator but with the caller asking for
HWCACHE_ALIGN.
