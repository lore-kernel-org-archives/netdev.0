From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH 1/1] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Tue, 07 Jan 2014 13:14:34 +0100
Message-ID: <1389096874.2248.7.camel@weing>
References: <20140106160139.GB10204@order.stressinduktion.org>
	 <1389029375-17698-1-git-send-email-thaller@redhat.com>
	 <20140107120111.GB24730@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-WUEsv9Fs0Sa1QXNqf2dK"
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851AbaAGMO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 07:14:56 -0500
In-Reply-To: <20140107120111.GB24730@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WUEsv9Fs0Sa1QXNqf2dK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-07 at 13:01 +0100, Hannes Frederic Sowa wrote:
> On Mon, Jan 06, 2014 at 06:29:35PM +0100, Thomas Haller wrote:
> > @@ -3662,8 +3666,10 @@ static int inet6_addr_modify(struct inet6_ifaddr=
 *ifp, u32 ifa_flags,
> >  	if (!(ifp->flags&IFA_F_TENTATIVE))
> >  		ipv6_ifa_notify(0, ifp);
> > =20
> > -	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
> > -			      expires, flags);
> > +	if (ifa_flags & IFA_F_NOPREFIXROUTE =3D=3D 0) {
> > +		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
> > +				      expires, flags);
> > +	}
>=20
> Actually, if we switch from IFA_F_NOPREFIXROUTE to !IFA_F_NOPREFIXROUTE w=
e
> have to remove the prefix route, no?
>=20
> Greetings,
>=20
>   Hannes
>=20

hi Hannes,


I am about to resent the patch, so that IFA_F_NOPREFIXROUTE is saved in
the flags of the address. Later, when deleting such address, this is
used to indicate ~not~ to delete any prefix route... just as you suggest
in your earlier email (if I understood you right).

About this suggestion now, I tend to "no". Yes, it could be sensible, on
the other hand, if user space already controls the routes (as indicated
by it's use of IFA_F_NOPREFIXROUTES), I would just leave it to the user
to clean up the wrong prefix route.

What do you think?


Thomas

--=-WUEsv9Fs0Sa1QXNqf2dK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJSy++qAAoJECnCNm5N/FcozYcQAJzIpsOSkRM7KiMrScPlH/k2
ipzunrAz6AlZXoq9Gd1SKjCwXZz2bJrXRmN4AYmGQloxLJOYTLpOx/rXMIs9SeTN
itxayiZKDmo4FzEPnLGG1rFELM0fhPZ2WsqAL6s9CcGNXyawp8+db/7tD8IIi6ES
tSdmwmJIH2paAMpZZbRtFvEwKC1mkPXiFtdtslqRg/jc2qS8fN2TXG5ka8zGGET2
yP2CeRvTWz3hNP5wu2JH63hQJKtA/f8MWrpjC++PJnox4WEMA4JShY32qayoLZ29
6/62NXnrtyNd3qvR/Ocd8hzc4CNUlI7/60lCuswDDvDdT6hnkMmtTAUQJAnoivVI
7aI8lWX4zoGEAR1cvjlr+tJdd3Uob1NguOIzHM6FRb4gHUdrrSo+Vi2RVJMcZmDy
oWlY8OXh0AxU5nWAScLNwXO3x0WpBw/jEPHzAkhOtZyQ+P28CCgMyLPfyk1NPQWU
ArgUOBdV4stpEYQqgvJJt/iBrhtCaLqKhiPMM1IwxYmq9orccUxiR4umPTp70KAZ
vXb7/3loEKvPVUB8OYG15x8OpX+kHHyQv2xdMt0dlFhl74m02VN+B5YZ8iWFTgBp
TWhm7gbvfiLII2n1xHKPaO9YZV8k7QwYf/hf3kZNYSazuDV8zM3FG26GHCgbYBNc
WwzDzo8Dz3HyNI6bXlpA
=iTLN
-----END PGP SIGNATURE-----

--=-WUEsv9Fs0Sa1QXNqf2dK--
