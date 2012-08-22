From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 13/17] lockd: use new hashtable implementation
Date: Wed, 22 Aug 2012 09:22:43 -0400
Message-ID: <20120822132243.GA2844@Krystal>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-14-git-send-email-levinsasha928@gmail.com> <20120822114752.GC20158@fieldses.org> <5034CD02.2010103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5034CD02.2010103-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> On 08/22/2012 01:47 PM, J. Bruce Fields wrote:
> > On Wed, Aug 22, 2012 at 04:27:08AM +0200, Sasha Levin wrote:
> >> +static int __init nlm_init(void)
> >> +{
> >> +	hash_init(nlm_files);
> >> +	return 0;
> >> +}
> >> +
> >> +module_init(nlm_init);
> > 
> > That's giving me:
> > 
> > fs/lockd/svcsubs.o: In function `nlm_init':
> > /home/bfields/linux-2.6/fs/lockd/svcsubs.c:454: multiple definition of `init_module'
> > fs/lockd/svc.o:/home/bfields/linux-2.6/fs/lockd/svc.c:606: first defined here
> > make[2]: *** [fs/lockd/lockd.o] Error 1
> > make[1]: *** [fs/lockd] Error 2
> > make[1]: *** Waiting for unfinished jobs....
> 
> I tested this entire patch set both with linux-next and Linus' latest master,
> and it worked fine in both places.
> 
> Is it possible that lockd has a -next tree which isn't pulled into linux-next?
> (there's nothing listed in MAINTAINERS that I could see).

fs/lockd/Makefile:

obj-$(CONFIG_LOCKD) += lockd.o

lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
                svcshare.o svcproc.o svcsubs.o mon.o xdr.o grace.o

your patch adds a module_init to svcsubs.c.
However, there is already one in svc.c, pulled into the same module.

in your test build, is CONFIG_LOCKD defined as "m" or "y" ? You should
always test both.

One solution here is to create a "local" init function in svcsubs.c and
expose it to svc.c, so the latter can call it from its module init
function.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
