From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and
	naive	hashtable
Date: Mon, 29 Oct 2012 12:29:04 -0400
Message-ID: <20121029162904.GA19509@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
	<20121029112907.GA9115@Krystal>
	<CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com>
	<20121029161412.GB18944@Krystal>
	<CA+1xoqfBXM4sjvcZtUncnWAaUxA9_YBod3Hjx3ZO=K1oJO_j7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqfBXM4sjvcZtUncnWAaUxA9_YBod3Hjx3ZO=K1oJO_j7g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> On Mon, Oct 29, 2012 at 12:14 PM, Mathieu Desnoyers
> <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> > * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >> On Mon, Oct 29, 2012 at 7:29 AM, Mathieu Desnoyers
> >> <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> >> > * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >> >> +
> >> >> +     for (i = 0; i < sz; i++)
> >> >> +             INIT_HLIST_HEAD(&ht[sz]);
> >> >
> >> > ouch. How did this work ? Has it been tested at all ?
> >> >
> >> > sz -> i
> >>
> >> Funny enough, it works perfectly. Generally as a test I boot the
> >> kernel in a VM and let it fuzz with trinity for a bit, doing that with
> >> the code above worked flawlessly.
> >>
> >> While it works, it's obviously wrong. Why does it work though? Usually
> >> there's a list op happening pretty soon after that which brings the
> >> list into proper state.
> >>
> >> I've been playing with a patch that adds a magic value into list_head
> >> if CONFIG_DEBUG_LIST is set, and checks that magic in the list debug
> >> code in lib/list_debug.c.
> >>
> >> Does it sound like something useful? If so I'll send that patch out.
> >
> > Most of the calls to this initialization function apply it on zeroed
> > memory (static/kzalloc'd...), which makes it useless. I'd actually be in
> > favor of removing those redundant calls (as I pointed out in another
> > email), and document that zeroed memory don't need to be explicitly
> > initialized.
> 
> Why would that make it useless? The idea is that the init functions
> will set the magic field to something random, like:
> 
> .magic = 0xBADBEEF0;
> 
> And have list_add() and friends WARN(.magic != 0xBADBEEF0, "Using an
> uninitialized list\n");
> 
> This way we'll catch all places that don't go through list initialization code.

As I replied to Tejun Heo already, I agree that keeping the
initialization in place makes sense for future-proofness. This intent
should probably be documented in a comment about the initialization
function though, just to make sure nobody will try to skip it.

Thanks,

Mathieu

> 
> 
> Thanks,
> Sasha

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
