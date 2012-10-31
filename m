From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Tue, 30 Oct 2012 21:15:29 -0400
Message-ID: <CA+1xoqd9CMP4_CET38LTm6vVXwbButn3hJNbcFs6Darkh1EJSg@mail.gmail.com>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <20121031005128.GA30251@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Jim Rees <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121031005128.GA30251-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2012 at 8:51 PM, Jim Rees <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org> wrote:
> Sasha Levin wrote:
>
>   On Tue, Oct 30, 2012 at 5:42 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>   > Hello,
>   >
>   > Just some nitpicks.
>   >
>   > On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
>   >> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
>   >> +#define hash_min(val, bits)                                                  \
>   >> +({                                                                           \
>   >> +     sizeof(val) <= 4 ?                                                      \
>   >> +     hash_32(val, bits) :                                                    \
>   >> +     hash_long(val, bits);                                                   \
>   >> +})
>   >
>   > Doesn't the above fit in 80 column.  Why is it broken into multiple
>   > lines?  Also, you probably want () around at least @val.  In general,
>   > it's a good idea to add () around any macro argument to avoid nasty
>   > surprises.
>
>   It was broken to multiple lines because it looks nicer that way (IMO).
>
>   If we wrap it with () it's going to go over 80, so it's going to stay
>   broken down either way :)
>
> I would prefer the body be all on one line too. But shouldn't this be a
> static inline function?

We want sizeof(val), which wouldn't work in a static inline. We can
either wrap a static inline __hash_min() with a macro and pass that
size to it, but that's quite an overkill here, or we can add a size
parameter to hash_min(), but it would look awkward considering how
hash_32()/hash_64()/hash_long() look like.


Thanks,
Sasha
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
