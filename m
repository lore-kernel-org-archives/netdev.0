From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] stmmac ethernet: remove cut & paste code
Date: Thu, 24 Nov 2016 22:44:01 +0100
Message-ID: <20161124214401.GA25662@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124102901.GA27793@amd>
 <20161124103630.GB27793@amd>
 <20161124104619.GA30723@amd>
 <20161124110548.GB30723@amd>
 <1480017925.19726.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:37938 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966267AbcKXVx2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:53:28 -0500
Content-Disposition: inline
In-Reply-To: <1480017925.19726.13.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2016-11-24 12:05:25, Joe Perches wrote:
> On Thu, 2016-11-24 at 12:05 +0100, Pavel Machek wrote:
> > Remove duplicate code from _tx routines.
>=20
> trivia:
>=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> []
> > @@ -1960,6 +1960,38 @@ static void stmmac_tso_allocator(struct stmmac_p=
riv *priv, unsigned int des,
> >  	}
> >  }
> > =20
> > +static void stmmac_xmit_common(struct sk_buff *skb, struct net_device =
*dev, int nfrags, struct dma_desc *desc)
> > +{
> > +	struct stmmac_priv *priv =3D netdev_priv(dev);
> > +
> > +	if (unlikely(stmmac_tx_avail(priv) <=3D (MAX_SKB_FRAGS + 1))) {
> > +		if (netif_msg_hw(priv))
> > +			pr_debug("%s: stop transmitted packets\n", __func__);
>=20
> 		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
> 			  __func__);

Not now. Modifying the code while de-duplicating would be bad idea.

(And it looks like the driver has rather more serious problems than
printk style...)

Thanks,								=09
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg3XyEACgkQMOfwapXb+vJvfQCgxE04a0aDv7q03va8bYJ/3TEH
KJEAn0Y4aMU115Ri+IXjOTgXl1v7a7Y8
=OOyI
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
