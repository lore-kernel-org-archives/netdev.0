From: Solomon Peachy <pizza@shaftnet.org>
Subject: Re: [PATCH] cw1200: fix bogus maybe-uninitialized warning
Date: Tue, 25 Oct 2016 14:13:52 -0400
Message-ID: <20161025181352.GB28536@shaftnet.org>
References: <20161024154215.2863586-1-arnd@arndb.de>
 <063D6719AE5E284EB5DD2968C1650D6DB0209E9A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="b5gNqxB1S1yM7hjW"
Cc: "'Arnd Bergmann'" <arnd@arndb.de>,
        Kalle Valo <kvalo@codeaurora.org>,
        Johannes Berg <johannes.berg@intel.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 162-17-110-37-static.hfc.comcastbusiness.net ([162.17.110.37]:46726
        "EHLO stuffed.shaftnet.org" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753827AbcJYSer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 14:34:47 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0209E9A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--b5gNqxB1S1yM7hjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 25, 2016 at 01:24:55PM +0000, David Laight wrote:
> > -	if (count > 1) {
> > -		/* We already released one buffer, now for the rest */
> > -		ret =3D wsm_release_tx_buffer(priv, count - 1);
> > -		if (ret < 0)
> > -			return ret;
> > -		else if (ret > 0)
> > -			cw1200_bh_wakeup(priv);
> > -	}
> > +	/* We already released one buffer, now for the rest */
> > +	ret =3D wsm_release_tx_buffer(priv, count - 1);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	if (ret > 0)
> > +		cw1200_bh_wakeup(priv);
>=20
> That doesn't look equivalent to me (when count =3D=3D 1).

I concur, this patch should not be applied in its current form.

 - Solomon
--=20
Solomon Peachy        		       pizza at shaftnet dot org
Delray Beach, FL                          ^^ (email/xmpp) ^^
Quidquid latine dictum sit, altum viditur.

--b5gNqxB1S1yM7hjW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEABECAAYFAlgPoN8ACgkQPuLgii2759AS3gCfUKNTMDFd/WctTiPJIi6IyXuY
C30AnR9RZTG8b8EJBU+CbZHPfwFyz4WZ
=5eri
-----END PGP SIGNATURE-----

--b5gNqxB1S1yM7hjW--
