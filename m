From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
 naive hashtable
Date: Thu, 06 Sep 2012 11:11:33 -0400
Message-ID: <1346944293.1680.26.camel@gandalf.local.home>
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	<503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	<20120828230050.GA3337@Krystal>
	<1346772948.27919.9.camel@gandalf.local.home>
	<50462C99.5000007@redhat.com>
	<50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal>
	<5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Tejun-/PVsmBQoxgPKo9QCiBeYKEEOCMrvLtNR@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120906145545.GA17332@leaf>
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

On Thu, 2012-09-06 at 07:55 -0700, Josh Triplett wrote:

> > My solution to making 'break' work in the iterator is:
> > 
> > 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node == NULL; bkt++)
> > 		hlist_for_each_entry(obj, node, &name[bkt], member)
> > 
> 
> Looks reasonable.  However, it would break (or rather, not break) on
> code like this:
> 
> 	hash_for_each_entry(...) {
> 		if (...) {
> 			foo(node);
> 			node = NULL;
> 			break;
> 		}
> 	}
> 
> Hiding the double loop still seems error-prone.

We've already had this conversation ;-)  A guess a big comment is in
order:

/*
 * NOTE!  Although this is a double loop, 'break' still works because of
 *        the 'node == NULL' condition in the outer loop. On break of
 *        the inner loop, node will be !NULL, and the outer loop will
 *        exit as well.
 */

-- Steve
