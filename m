From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Date: Mon, 29 Oct 2012 15:17:16 -0400
Message-ID: <CA+1xoqdi2pQENa=--FkPbOGOHgK+M26_jNCxGTkFiynqnR+7og@mail.gmail.com>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
 <20121029113515.GB9115@Krystal> <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
 <20121029183157.GC3097@jtriplet-mobl1> <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com>
 <20121029185319.GA21546@Krystal> <CA+1xoqcSx04JEXy2aPu4Qt7Zb4iSqXBSjARgMae_FusgzpgnaQ@mail.gmail.com>
 <20121029191256.GE4066@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>,
	Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121029191256.GE4066-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2012 at 3:12 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Mon, Oct 29, 2012 at 03:09:36PM -0400, Sasha Levin wrote:
>> The other thing is whether hash_init() should be called for hashtables
>> that were created with DEFINE_HASHTABLE(). That point was raised by
>> Neil Brown last time this series went around, and it seems that no one
>> objected to the point that it should be consistent across the code.
>
> Hmmm?  If something is DEFINE_XXX()'d, you definitely shouldn't be
> calling XXX_init() on it.  That's how it is with most other abstract
> data types and you need *VERY* strong rationale to deviate from that.

Neil Brown raised that point last time that this series went around,
and suggested that this should be consistent and hash_init() would
appear everywhere, even if DEFINE_HASHTABLE() was used. Since no one
objected to that I thought we're going with that.

I'll chalk it up to me getting confused :)


Thanks,
Sasha
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
