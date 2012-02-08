From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Wed, 8 Feb 2012 23:08:26 +0200
Message-ID: <CAJZOPZL_zEbNwUfVOmQeODny7HDf24gOc1HStfBxim_UtD-kvA@mail.gmail.com>
References: <20120206.113145.1284864994961472499.davem@davemloft.net>
	<1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328727110.2631.8.camel@edumazet-laptop>
	<20120208.155027.599792363539233740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120208.155027.599792363539233740.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2012 at 10:50 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Shlomo Pongratz reported GRO L2 header check was suited for Ethernet
> > only, and failed on IB/ipoib traffic.
> > He provided a patch faking a zeroed header to let GRO aggregates frames.
> >
> > Roland Dreier, Herbert Xu, and others suggested we change GRO L2 header
> > check to be more generic, ie not assuming L2 header is 14 bytes, but
> > taking into account hard_header_len.
> >
> > __napi_gro_receive() has special handling for the common case (Ethernet)
> > to avoid a memcmp() call and use an inline optimized function instead.

> Applied.

Hi Dave, for correct operation / future bisection, you should 1st
apply Roland's patch which reduces the hard header len advertized by
ipoib to be only the size of the ipoib header without that 20 bytes
headroom, else the gro memcmp will be issued on the ipoib header and
then 20 bytes of the ip header, kind of back to square one...

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
