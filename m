From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH 3/3] net: stmmac: Use AVB mode by default
Date: Tue, 21 Mar 2017 17:42:49 +0100
Message-ID: <20170321164249.GB31875@ulmo.ba.sec>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
 <20170321151211.31841-3-thierry.reding@gmail.com>
 <bac4dbe3-dd38-8b2b-71f1-dbb04d8298bd@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="z6Eq5LdranGa6ru8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36187 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933414AbdCUQm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:42:58 -0400
Content-Disposition: inline
In-Reply-To: <bac4dbe3-dd38-8b2b-71f1-dbb04d8298bd@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z6Eq5LdranGa6ru8
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 03:23:00PM +0000, Joao Pinto wrote:
> =C3=80s 3:12 PM de 3/21/2017, Thierry Reding escreveu:
> > From: Thierry Reding <treding@nvidia.com>
> >=20
> > Prior to the recent multi-queue changes the driver would configure the
> > queues to use the AVB mode, but the mode then got switched to DCB. The
> > hardware still works fine in DCB mode, but my testing capabilities are
> > limited, so it's safer to revert to the prior setting anyway.
> >=20
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
> > ---
> >  include/linux/stmmac.h | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> > index be47b859e954..8349a5c1537b 100644
> > --- a/include/linux/stmmac.h
> > +++ b/include/linux/stmmac.h
> > @@ -56,8 +56,8 @@
> >  #define MTL_RX_ALGORITHM_WSP	0x5
> > =20
> >  /* RX/TX Queue Mode */
> > -#define MTL_QUEUE_DCB		0x0
> > -#define MTL_QUEUE_AVB		0x1
> > +#define MTL_QUEUE_AVB		0x0
> > +#define MTL_QUEUE_DCB		0x1
> > =20
> >  /* The MDC clock could be set higher than the IEEE 802.3
> >   * specified frequency limit 0f 2.5 MHz, by programming a clock divider
> >=20
>=20
> Thierry, I don't understand this patch. It will have 0 impact.
>=20
> In stmmac_platform configuration, 0 impact:
>=20
> 		if (of_property_read_bool(q_node, "snps,dcb-algorithm"))
> 			plat->rx_queues_cfg[queue].mode_to_use =3D MTL_QUEUE_DCB;
> 		else if (of_property_read_bool(q_node, "snps,avb-algorithm"))
> 			plat->rx_queues_cfg[queue].mode_to_use =3D MTL_QUEUE_AVB;
> 		else
> **			plat->rx_queues_cfg[queue].mode_to_use =3D MTL_QUEUE_DCB;
>=20
> In dwmac4_core, 0 impact:
>=20
> 	value &=3D GMAC_RX_QUEUE_CLEAR(queue);
> 	if (mode =3D=3D MTL_QUEUE_AVB)
> 		value |=3D GMAC_RX_AV_QUEUE_ENABLE(queue);
> 	else if (mode =3D=3D MTL_QUEUE_DCB)
> 		value |=3D GMAC_RX_DCB_QUEUE_ENABLE(queue);
>=20
> I think you should set the default mode in (**).

That was my initial attempt, but then I realized that for old DTBs,
stmmac_mtl_setup() will already exit prematurely because of the missing
snps,mtl-{rx,tx}-config properties. It's pretty much for the same reason
as the separate assignment of the default {rx,tx}_queues_to_use. In this
case it's somewhat more obfuscated, though. Changing AVB to be mode 0
means that plat->rx_queues_cfg[].mode_to_use will contain AVB as default
because plat is devm_kzalloc()'ed.

Effectively this change makes all queues use AVB by default unless they
are configured using the new device tree bindings.

Thierry

--z6Eq5LdranGa6ru8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRWAkACgkQ3SOs138+
s6EADw//QdMGAOakdXn+zObw6FfKZJg+vqa/mSSa3n+M5Y8hW/uAF7V4gWCVPwFT
6P6msTPqoSDOta+cMGw9VwWwOlzaDjMrh5oB37i+1AUTj/i68M3HiezTGOa76rjN
Y5IiqYYiejxrm/wJzZy8clx7oMfOxS7XbdV7fk4g+jVRYErv+6EEr2czb2c93O5Y
yvu3jBBGzz/3CAKQ0LzCzF1Bcbowsxtj9HRFsxKjbjlMCmzkYbPG8DiOGNE2hyeA
kzAqkmbyykoJ9bFggpOd+1/yOYwvLAVZaP0osG9x5Sa0y5jHWNg64U20UhO9hlTC
l7CO0JJY3QS2VchLQgKYoTVhrWLxi0LjtB/Xj7mhke9Yg4SOLY34zAG1NdQMBLl0
Vv3mhp1jptJWRGVn59AnCcKQtzKc353NOdXVzPvz8bXs9yz6Szur1JyoBAoUnxMw
dN3V+0jZESOY7eE31LlUG/RK5lC2NeT9cg2Waz9jL9yQyGip78qSGE8jWYo1P55B
gUA7oP11YJ1VVNLgY4mj1Y8opEk09zdFQuzqbhSuwLqvhHFJ+JjPaR4sCJmoFpZZ
Mv6WRX0ya5t7n2y6DpFuYqeJyF6I/axF1PK24n0jBT0Z6uKZY7BB+3cLM8Fx10lJ
XMETrLqQidaNM8qKG0+NK4uQZsXac4Wi5eIkuhmJR0Ut12ph31o=
=nepe
-----END PGP SIGNATURE-----

--z6Eq5LdranGa6ru8--
