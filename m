From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 07 Feb 2004 19:28:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.192804.29120956.yoshfuji@linux-ipv6.org>
References: <4023D6FB.9010909@kolumbus.fi>
	<20040207.131455.27570445.yoshfuji@linux-ipv6.org>
	<4024A488.60203@kolumbus.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kazunori@miyazawa.org, davem@redhat.com, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.penttila@kolumbus.fi
In-Reply-To: <4024A488.60203@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4024A488.60203@kolumbus.fi> (at Sat, 07 Feb 2004 10:40:40 +02=
00), Mika Penttil=E4 <mika.penttila@kolumbus.fi> says:

> >The ip6_output2() resolves and inserts link-layer address appropriatel=
y.
> >If it did, we would have noticed (by conformance test or even by
> >usual operation). ;-)
> > =20
> >
> ip6_output2() doesn't resolve link-layer addresses. We don't even have =
a=20
> neighbour, in
> ndisc_dst_alloc(dev, NULL, ip6_output2); case.

ip6_output2() calls ip6_output_flinish().
ip6_output_finish() calls dst->hh->hh_output() if hh is already built.
Otherwise, dst->neighbour->output() is called and it resolves=20
link-layer address of neighbor.

I think you missed our ndsic_dst_alloc() change.
ndisc_dst_alloc() takes 4 argument:
   struct dst_entry *ndisc_dst_alloc(struct net_device *dev,=20
                                     struct neighbour *neigh,
                                     struct in6_addr *addr,
                                     int (*output)(struct sk_buff *));
If neigh is NULL, we do ndisc_get_neigh(dev, addr) to get one.


> You just described how the normal link layer address resolving goes. It=
=20
> doesn't apply here. Again, there is no dst->neighbour.

There IS with our patch.

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
