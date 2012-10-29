From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable
	implementation
Date: Mon, 29 Oct 2012 11:41:04 -0400
Message-ID: <20121029154104.GA18542@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
	<1351450948-15618-9-git-send-email-levinsasha928@gmail.com>
	<20121029124229.GC11733@Krystal>
	<CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com>
	<20121029151343.GA17722@Krystal>
	<20121029151653.GC9502@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121029151653.GC9502-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

* J. Bruce Fields (bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org) wrote:
> On Mon, Oct 29, 2012 at 11:13:43AM -0400, Mathieu Desnoyers wrote:
> > * Linus Torvalds (torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org) wrote:
> > > On Mon, Oct 29, 2012 at 5:42 AM, Mathieu Desnoyers
> > > <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> > > >
> > > > So defining e.g.:
> > > >
> > > > #include <linux/log2.h>
> > > >
> > > > #define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))
> > > >
> > > > would keep the intended behavior in all cases: use one page for the hash
> > > > array.
> > > 
> > > Well, since that wasn't true before either because of the long-time
> > > bug you point out, clearly the page size isn't all that important. I
> > > think it's more important to have small and simple code, and "9" is
> > > certainly that, compared to playing ilog2 games with not-so-obvious
> > > things.
> > > 
> > > Because there's no reason to believe that '9' is in any way a worse
> > > random number than something page-shift-related, is there? And getting
> > > away from *previous* overly-complicated size calculations that had
> > > been broken because they were too complicated and random, sounds like
> > > a good idea.
> > 
> > Good point. I agree that unless we really care about the precise number
> > of TLB entries and cache lines used by this hash table, we might want to
> > stay away from page-size and pointer-size based calculation.
> >
> > It might not hurt to explain this in the patch changelog though.
> 
> I'd also be happy to take that as a separate patch now.

FYIW: I've made a nice boo-boo above. It should have been:

#define DFR_HASH_BITS   (PAGE_SHIFT - ilog2(sizeof(struct hlist_head)))

Because we happen to have a memory indexed in bytes, not in bits. I
guess this goes a long way proving Linus' point about virtues of trivial
code. ;-)

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
