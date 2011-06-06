From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Mon, 06 Jun 2011 14:12:37 +0200
Message-ID: <1307362358.3098.6.camel@edumazet-laptop>
References: <4DE93422.3070000@ahsoftware.de>
	 <20110606111507.GA1000@hmsreliant.think-freely.org>
	 <4DECBEA3.6070408@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DECBEA3.6070408@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 06 juin 2011 =C3=A0 13:48 +0200, Alexander Holler a =C3=A9crit=
 :
> Am 06.06.2011 13:15, schrieb Neil Horman:
> > On Fri, Jun 03, 2011 at 09:21:06PM +0200, Alexander Holler wrote:
> >> Hello,
> >>
> >> I'm getting a oops in the bridge code in br_change_mtu() with
> >> 2.6.39.1. The patch below seems to fix that.
> >>
> >> I'm not sure about the usage of dst_cow_metrics_generic() in
> >> fake_dst_ops, but after having a quick look at it seems to be ok t=
o
> >> use that here.
> >>
> >> Regards,
> >>
> >> Alexander
> >>
> > How did the flags of the dst entry on which we're callnig dst_entry=
_write_ptr
> > wind up getting the  READ_ONLY flag set on it?  I don't see how we'=
er falling
> > into that clause in which we call cow_metrics when we call dst_metr=
ic_set.  It
> > seems like that flag is set erroneously.  perhaps we should just up=
date
> > fake_rtable.dst to have the correct flags?
> > Neil
>=20
> It is set by that change:
>=20
> --------
> @@ -124,7 +128,7 @@ void br_netfilter_rtable_init(struct net_bridge *=
br)
>   	atomic_set(&rt->dst.__refcnt, 1);
>   	rt->dst.dev =3D br->dev;
>   	rt->dst.path =3D &rt->dst;
> -	dst_metric_set(&rt->dst, RTAX_MTU, 1500);
> +	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
>   	rt->dst.flags	=3D DST_NOXFRM;
>   	rt->dst.ops =3D &fake_dst_ops;
>   }
> --------
>=20
> The true in dst_init_metrics() is responsible for that flag.
>=20

You are aware this change fixed an oops ?

read_only in this context means : In case this must be written, we make
a COW first
(allocate a piece of memory, copy the source in it before applying any
change)

It would be nice you send us the stack trace, so that we can have a clu=
e
of whats going on.

Thanks
