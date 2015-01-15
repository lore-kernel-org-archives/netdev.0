From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 06:59:13 -0800
Message-ID: <1421333953.2632.22.camel@jtkirshe-mobl>
References: <1719052.SGOfRAJhfQ@storm>
	 <1421256052.11734.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5229621.KczjbIR22Q@storm>
	 <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iZzgtlz9kXkN3p5tQDFv"
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27059 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658AbbAOO7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 09:59:14 -0500
In-Reply-To: <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iZzgtlz9kXkN3p5tQDFv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-01-15 at 06:43 -0800, Eric Dumazet wrote:
> On Thu, 2015-01-15 at 11:11 +0100, Thomas Jarosch wrote:
> > On Wednesday, 14. January 2015 09:20:52 Eric Dumazet wrote:
> > > I would try to use lower data per txd. I am not sure 24KB is really
> > > supported.
> > >=20
> > > ( check commit d821a4c4d11ad160925dab2bb009b8444beff484 for details)
> > >=20
> > > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> > > b/drivers/net/ethernet/intel/e1000e/netdev.c index
> > > e14fd85f64eb..8d973f7edfbd 100644
> > > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > > @@ -3897,7 +3897,7 @@ void e1000e_reset(struct e1000_adapter *adapter=
)
> > >  	 * limit of 24KB due to receive synchronization limitations.
> > >  	 */
> > >  	adapter->tx_fifo_limit =3D min_t(u32, ((er32(PBA) >> 16) << 10) - 9=
6,
> > > -				       24 << 10);
> > > +				       8 << 10);
> > >=20
> > >  	/* Disable Adaptive Interrupt Moderation if 2 full packets cannot
> > >  	 * fit in receive buffer.
> >=20
> > Thanks for checking!
> >=20
> > I just tried that change on top of git f800c25 (git HEAD), same problem=
.=20
> > Let's see what the Intel wizards come up with.
> >=20
> > What "works" is to decrease the page size in git HEAD, too:
> >=20
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 85ab7d7..9f0ef97 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -2108,7 +2108,7 @@ static inline void __skb_queue_purge(struct=20
> > sk_buff_head *list)
> >                 kfree_skb(skb);
> >  }
> > =20
> > -#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
> > +#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(4096)
> >  #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_=
ORDER)
> >  #define NETDEV_PAGECNT_MAX_BIAS           NETDEV_FRAG_PAGE_MAX_SIZE
> >=20
> >=20
> >=20
> > When I try a page size of 8192, it starts failing again. I'll now run
> > a stress test with 4096 to see if the problem is really gone
> > or just happens more rarely.
>=20
> Sure, you basically reverted my patch.
>=20
> You are not the first to report a problem caused by this patch.
>=20
> This patch is known to have uncovered some driver bugs.
>=20
> We are not going to revert it. We are going to fix the real bugs.
>=20
> Thanks
>=20
>=20

Agreed, we are looking into issue Thomas.

--=-iZzgtlz9kXkN3p5tQDFv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUt9XBAAoJEOVv75VaS+3OW+IP/iq3QewB4DEaDTeCvDNnAf1i
+vY0XCwSmyXS92f7l9nmKBX4hvhe4gJUT6kwNZoKs3fX8pnzNkIvzP2M5M5OW9Ew
GP3X6S3gOKmY8cG8f1AC5aYqTRdpJ5lL+OpEyj1Pl++DalJtb9XxXElcZVT6nKZ6
1UF3dLaj6VOZy/DzcsYa0HfWvXBGnzZphw03ZuimjaXsVQ2/CXl2OmnVYjtV0pnP
5yMqVuvM/InCCtQgWh2S2m8UubzzFq+zv35t0yX9uxj8aUq3rlYYjDqddEry427e
uxLe47nLrvMEbiK0Xds/1+9SKPIFXb/GBT6m7vFA00wVIa6Um26JPAd8lWj1Vs71
DbNjFpOl+7mWycvsk6S6Vup8zyF9F9fDpUCpjTD4w59VANHubITggIaThhRL+KrW
+W5XfWbX3qgCnDCWfklVtefjeqI4xs3/5i4A1xw9n5NvPloHxEJupdKWsMxf8z/U
/RMNPvq/2lNVy4p09zPJgUSnRRopg65Q+68yGF3RA2wfw+FJVq6/0yhk7PRrTNrg
fl8a4oYKrYqpDakkAwNTayf/fAcdUztxQ1OLSLu66M3UXStJrLv6rJOQwXmoxhsq
qd/9gpeeewjPZ1FjXInzUt9JkBhFcBNc725MfxwMo+gFXPUTvF7KhEmMs1wMD/EE
v/xP+Wb6KN/bWAWVPp6a
=cLtU
-----END PGP SIGNATURE-----

--=-iZzgtlz9kXkN3p5tQDFv--
