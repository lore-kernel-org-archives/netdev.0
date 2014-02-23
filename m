From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: net/mlx4: Mellanox driver update 01-01-2014
Date: Sun, 23 Feb 2014 17:06:20 +0000
Message-ID: <1393175180.6823.56.camel@deadeye.wl.decadent.org.uk>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
	 <20140219.165049.1684072721398326970.davem@davemloft.net>
	 <1393032798.15717.85.camel@deadeye.wl.decadent.org.uk>
	 <20140223090142.GA24010@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BKC+48LC97n19jPBC/rL"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, yuvala@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60375 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbaBWRGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 12:06:38 -0500
In-Reply-To: <20140223090142.GA24010@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BKC+48LC97n19jPBC/rL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-02-23 at 11:01 +0200, Amir Vadai wrote:
> On 22/02/14 01:33 +0000, Ben Hutchings wrote:
[...]
> > So this sort of policy not only shouldn't be implemented in specific
> > drivers, but also ought to be configurable.
> >=20
> > Ben.
>=20
> Hi,
>=20
> The idea here is to prefer a local node than a remote one - and not to
> *always* use local nodes - kind of best effort approach.
> The patch is relevant when number of rings is smaller (or bigger) than
> number of CPU's - in this case the idea is to try to put the majority
> of rx queues on the local node, and not to spread it evenly on the
> numa nodes.
> So, for Intel architecture you will get better performance in average,
> and on other architectures, things will stay the same.
>=20
> Therefore, I don't think it is needed to have a tunable for that.
>=20
> If a user wants to use a more aggressive mode: to handle all incoming
> traffic only by local nodes, he'll be able to do it by changing number
> of rx channels to number of local cores - so we actually have the
> tunable you had in mind.

Right, that does sound pretty good as a default.  And I accept that it
would be reasonable to implement that initially without a tunable beyond
total number of IRQs.

I would like to have a central mechanism for this that would allow the
administrator to set a policy of spreading IRQs across all threads,
cores, packages, local cores, etc.  (The out-of-tree version of sfc has
such options.)  If you add the mechanism and default that you've
proposed, then someone (maybe me) can get round to the configurable
policy later.

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-BKC+48LC97n19jPBC/rL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwoqjOe/yOyVhhEJAQoX5BAAhEc3mPk7UC8hzmyYMyBZW0srQXDbhlB6
nDCLFNJ5G2Xl/Dwk0ZOqZGT+s7n0E1YQlvgoYonryk8VwNLPb2o1YFws6/ZCzEPE
cUNd4vvjmmqIXtu0MD154Ckb/z8+wmGZCO/pGstEFPY22sUo3ydkGrH3ZtxNEWdP
1uSiYA4hh+nvjBYZUUifjm0JUrDF3qMow+wi4dTNB696j0pENu07/mTuubRdB8he
CSy0rhRtch37UMgCkzUldQNKbgoggDjEg0d9fLFrBssXKRHoNN3IB7NmT0/1ruRC
Nc+bBv8c1WS4H+6JdE2805qsp+8OexjABjgIuQZzEIOYm0npUjn134ySzb16gfBU
zwFfvTeOTfb1kvuxDcYnOsXjUN28xCnvg10fOgYdjrORqtxlhPYEpmpI4lcv17oy
rXsWTcAprt5CLKU4JNMYP590G8kPUM3hS7lNooe2HlI3Qz7mbd4akac14edvj86U
DX2mOx7Y6r40vgFDB3QCZPa3rA5PfrRdmEMDEyXEfunlM6HKGMP6HefvLQh68vLe
HriGRT80exAFSTkTo8QUOOibJg812h7x7Y933jS5sPgCb/fqghGuHnj/5/SaHVWH
t3aplG2t1aic8hnN2x4ko+KfFAjFAuTPd6UtiNqa8K2tr2N/fztdk5//bfqlG6qH
RhQEuHzF0oI=
=eZB/
-----END PGP SIGNATURE-----

--=-BKC+48LC97n19jPBC/rL--
