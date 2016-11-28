From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] stmmac ethernet: remove cut & paste code
Date: Mon, 28 Nov 2016 15:35:39 +0100
Message-ID: <20161128143539.GB31224@amd>
References: <20161124085506.GA25007@amd>
 <20161124102901.GA27793@amd>
 <20161124103630.GB27793@amd>
 <20161124104619.GA30723@amd>
 <20161124110548.GB30723@amd>
 <1480017925.19726.13.camel@perches.com>
 <20161124214401.GA25662@amd>
 <1480026433.19726.17.camel@perches.com>
 <20161128115023.GA15034@amd>
 <1480343068.14294.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="kORqDWCi7qDJ0mEj"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:32966 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932666AbcK1Ofn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 09:35:43 -0500
Content-Disposition: inline
In-Reply-To: <1480343068.14294.5.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2016-11-28 06:24:28, Joe Perches wrote:
> On Mon, 2016-11-28 at 12:50 +0100, Pavel Machek wrote:
> > On Thu 2016-11-24 14:27:13, Joe Perches wrote:
> > > On Thu, 2016-11-24 at 22:44 +0100, Pavel Machek wrote:
> > > > On Thu 2016-11-24 12:05:25, Joe Perches wrote:
> > > > > On Thu, 2016-11-24 at 12:05 +0100, Pavel Machek wrote:
> > > > > > Remove duplicate code from _tx routines.
> > > > >=20
> > > > > trivia:
> > > > >=20
> > > > > > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c =
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > > > >=20
> > > > > []
> > > > > > @@ -1960,6 +1960,38 @@ static void stmmac_tso_allocator(struct =
stmmac_priv *priv, unsigned int des,
> > > > > >  	}
> > > > > >  }
> > > > > > =20
> > > > > > +static void stmmac_xmit_common(struct sk_buff *skb, struct net=
_device *dev, int nfrags, struct dma_desc *desc)
> > > > > > +{
> > > > > > +	struct stmmac_priv *priv =3D netdev_priv(dev);
> > > > > > +
> > > > > > +	if (unlikely(stmmac_tx_avail(priv) <=3D (MAX_SKB_FRAGS + 1)))=
 {
> > > > > > +		if (netif_msg_hw(priv))
> > > > > > +			pr_debug("%s: stop transmitted packets\n", __func__);
> > > > >=20
> > > > > 		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
> > > > > 			  __func__);
> > > >=20
> > > > Not now. Modifying the code while de-duplicating would be bad idea.
> > >=20
> > > Too many people think overly granular patches are the
> > > best and only way to make changes.
> > > Deduplication and consolidation can happen simultaneously.
> >=20
> > Can, but should not at this point. Please take a look at the driver in
> > question before commenting on trivial printk style.
>=20
> I had.
>=20
> It's perfectly acceptable and already uses netif_<level> properly.
>=20
> This consolidation now introduces the _only_ instance where it is
> now improperly using a netif_msg_<type> then single pr_<level>
> function sequence that should be consolidated into netif_dbg.

> Every other use of netif_msg_<level> then either emits multiple
> lines or is used in an if/else.

Are you looking at right driver? I don't see single use of
netif_msg_<level>, but see this at stmmac_main.c:756. Code is actually
pretty consistent using pr_*.

                                if (netif_msg_link(priv))
                                        pr_warn("%s: Speed (%d) not 10/100\=
n",
                                                dev->name, phydev->speed);

Anyway, I'm moving code around, if you want to do trivial cleanups, do
them yourself.
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--kORqDWCi7qDJ0mEj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg8QLsACgkQMOfwapXb+vKbGACgqJmAG6e7JUvXEnrJZ9EsjxYX
rGQAn2yurDzGKBJ/PO12lTJ5pbGejDiI
=7Mvu
-----END PGP SIGNATURE-----

--kORqDWCi7qDJ0mEj--
