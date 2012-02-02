From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Thu, 02 Feb 2012 15:38:15 +0100
Message-ID: <1328193495.2279.51.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	  <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	  <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
	  <4F264A6C.3070706@mellanox.com> <1327910672.2891.12.camel@edumazet-laptop>
	  <20120130081849.GA7848@gondor.apana.org.au>
	  <1327913583.2288.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <20120130085742.GA8262@gondor.apana.org.au>
	  <CAJZOPZJb1HvcS0XXKLvoDuoi1EfYTY-awwY2g0aHWoS=4qmdyQ@mail.gmail.com>
	  <20120201083837.GA7081@gondor.apana.org.au>
	  <CAJZOPZJVAQoy0B30zqkROOBp_-bF6=EdU2L9V025fJgTexVuFQ@mail.gmail.com>
	 <1328105262.2595.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2A974B.209@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F2A974B.209-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 16:01 +0200, Or Gerlitz a =C3=A9cr=
it :
> On 2/1/2012 4:07 PM, Eric Dumazet wrote:
> >>> If we just turn it into a memcmp with a variable length would
> >>> that work for you?
> >>
> >> I think yes, FWIW we will compare the IPoIB header, Roland is that=
 okay for you?
> >
> > A memcmp(xxx, yyy, variable_len) will be out of line and slow, its =
a bit sad ... Are skb_mac_header(p) / skb_gro_mac_header(skb) going to =
point to IPoIB header ?
>=20
> yes, both skb_mac_header(p) / skb_gro_mac_header(skb) point to IPoIB=20
> header, however (see next)
>=20
>=20
> > Maybe we can keep a fastpath for ethernet case... (the "if (hlen =3D=
=3D ETH_HLEN) being always predicted)
> > Maybe need to introduce gro_hard_header_len as well)
>=20
> today, IPoIB advertizes hard_header_len which is bigger than the IPoI=
B=20
> header len, this is done such that skbs sent by the network stack hav=
e=20
> enough headroom for a "pseudoheader" which for few flows (e.g unicast=
=20
> arp replies and multicast) is placed there by the ipoib hard_header=20
> function and later used by the xmit function.
>=20
> So we can either try and change that, such that hard_header_len will =
be=20
> equal to the ipoib header len or add gro_hard_header_len as you=20
> suggested, any preferences?

I guess changing hard_header_len might be difficult (for you).

Adding gro_mac_header_len sounds the easy way.

[ You'll need to set it in your device setup() ]




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
