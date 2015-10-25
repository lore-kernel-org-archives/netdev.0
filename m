From: "Bendik =?ISO-8859-1?Q?R=F8nning?= Opstad" <bro.devel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 1/2] tcp: Add DPIFL thin stream detection mechanism
Date: Sun, 25 Oct 2015 06:56:29 +0100
Message-ID: <1799007.TiMX4hfQRk@desktop>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com> <1445633413-3532-2-git-send-email-bro.devel+kernel@gmail.com> <1445636654.22974.193.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Yuchung Cheng <ycheng-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Erik Kline <ek-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Daniel Lee <Longinus00-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcelo Ricardo Leitner <mleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>,
	linux-doc-u79uwXL29TasMV2rI37PzA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445636654.22974.193.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, October 23, 2015 02:44:14 PM Eric Dumazet wrote:
> On Fri, 2015-10-23 at 22:50 +0200, Bendik R=F8nning Opstad wrote:
>=20
> > =20
> > +/**
> > + * tcp_stream_is_thin_dpifl() - Tests if the stream is thin based =
on dynamic PIF
> > + *                              limit
> > + * @tp: the tcp_sock struct
> > + *
> > + * Return: true if current packets in flight (PIF) count is lower =
than
> > + *         the dynamic PIF limit, else false
> > + */
> > +static inline bool tcp_stream_is_thin_dpifl(const struct tcp_sock =
*tp)
> > +{
> > +	u64 dpif_lim =3D tp->srtt_us >> 3;
> > +	/* Div by is_thin_min_itt_lim, the minimum allowed ITT
> > +	 * (Inter-transmission time) in usecs.
> > +	 */
> > +	do_div(dpif_lim, tp->thin_dpifl_itt_lower_bound);
> > +	return tcp_packets_in_flight(tp) < dpif_lim;
> > +}
> > +
> This is very strange :
>=20
> You are using a do_div() while both operands are 32bits.  A regular
> divide would be ok :
>=20
> u32 dpif_lim =3D (tp->srtt_us >> 3) / tp->thin_dpifl_itt_lower_bound;
>=20
> But then, you can avoid the divide by using a multiply, less expensiv=
e :
>=20
> return	(u64)tcp_packets_in_flight(tp) * tp->thin_dpifl_itt_lower_boun=
d <
> 	(tp->srtt_us >> 3);
>=20

You are of course correct. Will fix this and use multiply. Thanks.
