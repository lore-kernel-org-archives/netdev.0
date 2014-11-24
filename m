From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] sh_eth: Fix asynchronous external abort
Date: Mon, 24 Nov 2014 02:19:57 +0000
Message-ID: <1416795597.7215.76.camel@decadent.org.uk>
References: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
	 <1415862135-27972-3-git-send-email-ykaneko0929@gmail.com>
	 <20141124011759.GA5089@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iLgGtmfsmCOT63+uXC6h"
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20141124011759.GA5089@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iLgGtmfsmCOT63+uXC6h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-24 at 10:18 +0900, Simon Horman wrote:
> Hi Kaneko-san, Hi All,
>=20
> On Thu, Nov 13, 2014 at 04:02:15PM +0900, Yoshihiro Kaneko wrote:
> > From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> >=20
> > When clock is disabled, Ethernet register access raise Bus error.
>=20
> I have spoken with Kimura-san and the problem may be reproduced by
> calling ethtool with -s of -G while the network interface is down.
>=20
> e.g.:
> ifconfig eth0 down
> ethtool -G eth0 rx 512
>=20
> I have confirmed that the problem above appears in net-next
> and appears to be resolved with this patch and the previous on
> in this series (which seems to be a dependency) applied.
[...]

The change to sh_eth_set_ringparam() is fine.  But I don't think it is
correct for sh_eth_set_settings() to fail when the interface is down.
It should behave like sh_eth_set_ringparam() - validate and remember the
requested settings, so they can be applied when the interface is brought
up.

When drivers have their own rules about when certain configuration
operations can and can't be used, we end up with messes like WEXT.

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-iLgGtmfsmCOT63+uXC6h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIUAwUAVHKV0ue/yOyVhhEJAQpcYw/4zt192+cfaaMCoYcT29KwmzYAUPaR69zF
iSlqFIn2eRF16zm+eJFkgg18c4tF6b3rg8oA2vkBaSCBqqxgHk98jgPG+6TQCQie
VCc9aLsH6KOC5Xsb5SOy+QTA3N8j4N6VGqxGgtIikZN2CQVR60r0kx5k27p2gz+O
HQgZjZ0a3YQF+Yt38A5vmDkhlsyi0Yc0rpMvmJDaJ34E+UCmgKbPnUlQrChUs5TK
p3FqSIZpqktxqp2EbtfJbMDrwKxv4BIrYmb3a3eaBJp5OAuIJ3suOm7duDB3DAFK
O1RnNlCNsY05OfxHypvhxx6BiirgjxY7FqsoFZNuBlOyfx6R7HpuNALWzo3q8gIT
IA7lfqEyTFwiAW0FG02kGzmOhOku7XCFbDIt/gU3Eutf1mOTpgmzSfgps/y7MyOA
LrFv6lbF0gUivm4tFvGr+rpooLLuM98V9qrZaZVcYYWli3M0hdo8HQYUjs3DdXoU
hyxtIWzkqcoaEIkezmPTSvqy+GhKwZ8Cy/hWvZ8wiEe0H5HheD5d6nHNRWGyZrUt
cXXdXF1miIXyxacVNh7bY3CeQ2zKuczloquV5oFCS0mV0anmlcYokSB757Cr+mvq
hhAktE+NV0r53azvUeKHdIhRXeEe1vDTMskxkideFkk3UaX6IaUJ4oyM252gFPBY
grSIZxTA7g==
=ZBjM
-----END PGP SIGNATURE-----

--=-iLgGtmfsmCOT63+uXC6h--
