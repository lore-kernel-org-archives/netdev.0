From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] net: ethernet: cpsw: ignore VLAN ID 1
Date: Tue, 6 Jan 2015 14:31:19 -0600
Message-ID: <20150106203119.GC32308@saruman>
References: <1420566212-30081-1-git-send-email-balbi@ti.com>
 <20150106.141323.2091288413667564444.davem@davemloft.net>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1SQmhf2mF2YjsYvc"
Cc: <balbi@ti.com>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <stable@vger.kernel.org>,
	<mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150106.141323.2091288413667564444.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--1SQmhf2mF2YjsYvc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jan 06, 2015 at 02:13:23PM -0500, David Miller wrote:
> From: Felipe Balbi <balbi@ti.com>
> Date: Tue, 6 Jan 2015 11:43:32 -0600
>=20
> > CPSW completely hangs if we add, and later remove,
> > VLAN ID #1. What happens is that after removing
> > VLAN ID #1, no packets will be received by CPSW
> > rendering network unusable.
> >=20
> > In order to "fix" the issue, we're returning -EINVAL
> > if anybody tries to add VLAN ID #1. While at that,
> > also filter out any ID > 4095 because we only have
> > 12 bits for VLAN IDs.
> >=20
> > Fixes: 3b72c2f (drivers: net:ethernet: cpsw: add support for VLAN)
> > Cc: <stable@vger.kernel.org> # v3.9+
> > Cc: Mugunthan V N <mugunthanvnm@ti.com>
> > Tested-by: Schuyler Patton <spatton@ti.com>
> > Signed-off-by: Felipe Balbi <balbi@ti.com>
>=20
> You can't just unilaterally make one VLAN ID unusable.
>=20
> A better way to handle this situation must be found,
> and if that means turning off hw VLAN support completely,
> that's a much better alternative to this.
>=20
> I'm not applying this patch, sorry.

All other IDs work alright, it's just ID 1 which seems to be quirky. In
fact when trying to add VLAN ID 1, vconfig itself dumps out a warning
that VLAN ID 1 doesn't work on most switches.

What you're saying here is that you prefer to drop a feature that works
for all other 1023 IDs because 1 ID is quirky. Sounds like overkill
to me.

--=20
balbi

--1SQmhf2mF2YjsYvc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrEYXAAoJEIaOsuA1yqRERJwQALM/ArzpuY1h0bnqDUnRdlFj
ejsi2LkbLet8fC6oFERshF89pwuRGP8Vti0Tv5ppHrti5gDKr63A5u6p2I1MQpB9
aKsuwNCRedwKo/poG9KCxM/YA8w6v7DuMjfIwFPUP/dzVyG9OSTaGZJ+1junbOTq
4NOZkIWVUv+5B1n+d2lhM3RWA6HXGTWNpTX325l/ejXCXmE08wVYuocpk8GUtS50
3iM6gmLh/B8KVi15qywJnuvescShtyZ8DVlSsWEG+ElGrJzV8BcPpAooFgqtumQp
EYBM8Fieo9e/naS5JXx0bHAf4jBUciQOQUVI1ooIrnaUW7CjMikvTcVVIv7hyiN1
QY8dk6sOq9Q5r9mRCkDX2Dc3KXUJq7/j6GAL5EBdZbWHSnX8MmMJVVCgHdNMugjZ
N+HyDmHND2TEr8QOpH6f2OzI2JIptmHvkoxjvZjfAsP4Pq5U1T7j6yzcd5uJP9k+
KxdDcJSnq7DTP0aoEu0ac+Ej+pHlfU8L3xN+5qF/OOGqoQgMLOIsa1M0hcoTdTZh
rIUNqlMqhVhZ6iAjFDSBVIBh7MzuN6WDScKeu+n657E8A8b1jikYgnEvkZIzmRj8
+4i4uitdPiPxw+wBqimRFXX1NqKwOGDxL+13KUfjLOvQzMjNxfTy3PKxPeocg//w
sOHVhecbttunvt8PCMau
=3Adf
-----END PGP SIGNATURE-----

--1SQmhf2mF2YjsYvc--
