From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Mon, 20 Oct 2014 04:09:41 +0100
Message-ID: <1413774581.31953.12.camel@decadent.org.uk>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
	 <20141013.135127.1915115817707962111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oRvwtw+tIgHpEGWzeZzh"
Cc: mleitner@redhat.com, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20141013.135127.1915115817707962111.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oRvwtw+tIgHpEGWzeZzh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-10-13 at 13:51 -0400, David Miller wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Mon, 13 Oct 2014 14:03:30 -0300
>=20
> > Further tests revealed that after moving the garbage collector to a wor=
k
> > queue and protecting it with a spinlock may leave the system prone to
> > soft lockups if bottom half gets very busy.
> >=20
> > It was reproced with a set of firewall rules that REJECTed packets. If
> > the NIC bottom half handler ends up running on the same CPU that is
> > running the garbage collector on a very large cache, the garbage
> > collector will not be able to do its job due to the amount of work
> > needed for handling the REJECTs and also won't reschedule.
> >=20
> > The fix is to disable bottom half during the garbage collecting, as it
> > already was in the first place (most calls to it came from softirqs).
> >=20
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Acked-by: David S. Miller <davem@davemloft.net>
> > Cc: stable@vger.kernel.org
>=20
> -stable folks, please integrate this directly, thanks!

I've appplied this and the previous two patches mentioned ('ipv4: move
route garbage collector to work queue' and 'ipv4: avoid parallel route
cache gc executions').  But I didn't get the other two from you.  The
last batch of networking fixes I received and applied was dated
2014-08-07, and the next one I've seen is dated 2014-10-11 and has
nothing for 3.2 or 3.4.  Did I miss one between these?

Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-oRvwtw+tIgHpEGWzeZzh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVER8+ue/yOyVhhEJAQp6CA/+OQMYoHpKwWSaVqLrw8dCKDuUf9RMdBwb
Fa/M88xIfx5BZooGSU5YX+ZTj0qNTVQClJttdFy9pQGTG1r3FHvC6NmVL88DBAN7
8ZQdKGCBAknKAaCT7nIWoSxwBRpCijyIjgplrUuqpFJfAqA6LkNLHeUHKg+VSImi
ueYQqF/czQRZFZtizYYhK9kp/duk1DJk5Lhy0k1ryW6Sl+ZUV+/2/lN6/oEbYvXh
bI+RLDrajsoFukgwN7+6mWLm1fKxaghlW9hpJJLREuNLbgu6EW9ccIQ2CeN02zGZ
MBI9+q4tMjtiVZRMaLWbXPfaFXfab1fV39kJJfocZeYkU7KL9AOvSLTEqjulknKA
6GNxD9vtcEj2JoG89tPalNSVn+SYuAPJPCioz02lFbPKTZRmLiojrdhoFKKV7cuq
H0FL1G21yTSbNKct4/tc10/HIgwvEZV5x7gFWdWB7l1EB2V2u73v6mrPid4xOvCy
T3/xyd89EHxqbase5S20qywc1g3+jYRe+CyBfP/j0EuxE0f3X7us95jGAJbkzlTa
j6Hf+NxqcB+EgxwLLkJQqpcah6rxDEKkQ6WAsvscTDNsCJbkODnNXE2OF4yhGeQQ
NavSn+T1Am9DR0OwzuYfboFZJJFSCPTmNRvADlIDC+utDRMMyG4hv2nW9c9S2uri
Ja2A2TwVeFQ=
=vc6p
-----END PGP SIGNATURE-----

--=-oRvwtw+tIgHpEGWzeZzh--
