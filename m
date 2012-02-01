From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 6/6] cls_cgroup: remove redundant rcu_read_lock/unlock
Date: Wed, 1 Feb 2012 18:23:07 +1100
Message-ID: <20120201072307.GA6358@gondor.apana.org.au>
References: <4F28E1D1.900@cn.fujitsu.com> <4F28E22A.703@cn.fujitsu.com> <1328080039.22641.2.camel@edumazet-laptop> <4F28E7A0.6000309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F28E7A0.6000309-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 03:20:00PM +0800, Li Zefan wrote:
> Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> 
> >> diff --git a/net/core/sock.c b/net/core/sock.c
> >> index 213c856..c0bab23 100644
> >> --- a/net/core/sock.c
> >> +++ b/net/core/sock.c
> >> @@ -1160,9 +1160,7 @@ void sock_update_classid(struct sock *sk)
> >>  {
> >>  	u32 classid;
> >>  
> >> -	rcu_read_lock();  /* doing current task, which cannot vanish. */
> >>  	classid = task_cls_classid(current);
> >> -	rcu_read_unlock();
> >>  	if (classid && classid != sk->sk_classid)
> >>  		sk->sk_classid = classid;
> > 
> > Yes, this seems fine.
> > 
> > Then, I wonder why we do the "if (classid && classid != sk->sk_classid)"
> > 
> > before the :
> > 
> > 	sk->sk_classid = classid;
> > 
> > This seems unnecessary checks.
> > 
> 
> I was wondering about this too. He who added this may provide us with an
> answer.

Well writing a cache-line unnecessarily is bad.

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
