From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac tx timeout
Date: Tue, 13 Jun 2017 10:38:52 +0200
Message-ID: <20170613083852.GA17031@amd>
References: <fc8e5141-5815-9a6d-51ed-ddd7e5c2bbc8@axis.com>
 <20170523133946.GA7713@amd>
 <9f7d2198-073f-435c-fd9a-f25889968b9d@axis.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Lars Persson <larper@axis.com>, netdev <netdev@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:50007 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752186AbdFMIjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 04:39:14 -0400
Content-Disposition: inline
In-Reply-To: <9f7d2198-073f-435c-fd9a-f25889968b9d@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > @@ -2043,7 +2063,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff
> > *skb, stru\
> > ct net_device *dev)
> >         } else
> > 	                priv->tx_count_frames =3D 0;
> >=20
> > +       dma_rmb();
> > +       dma_wmb();
> >         /* To avoid raise condition */
> > +       BUG_ON(first->des01.etx.own); /* This BUG_ON seems to be enough.
> > +                                          Replacing it with barriers i=
s _not_enough. */
> >         priv->hw->desc->set_tx_owner(first);
> >  	wmb();
> >=20
> > No, the BUG_ON() does not trigger. Yes, it still fixes the driver for
> > me. You may want to verify it has same effect for you.
>=20
> Hello Pavel,
>=20
> I am sincerely grateful for you help.
>=20
> I forward ported your patch to 4.9,
> however, I could still get tx timeouts.
>=20
> Thankfully I finally found the root cause of
> my tx timeouts, see the patch I've submitted
> here:
>=20
> http://marc.info/?l=3Dlinux-kernel&m=3D149673393525236

Thanks a lot for the information. And unfortunately yes, there's
probably more work to do in the stmmac driver; for example it would be
good if _tx_timeout were actually able to recover the card. I probably
have patch for that somewhere, too...

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlk/pJwACgkQMOfwapXb+vLDmACcCAQTgX9K1+u5K1HXn/A0v6wN
gPEAn05sCN1MgRhV4UXrg195RbwusiQn
=BoCk
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--
