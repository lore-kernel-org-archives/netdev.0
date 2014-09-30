From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Tue, 30 Sep 2014 15:52:26 +0200
Message-ID: <20140930135226.GO1325@katana>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
 <1410273070-22485-3-git-send-email-rogerq@ti.com>
 <20140930132650.GN1325@katana>
 <542AB137.30507@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UFMLoheMaWcIEZAi"
Cc: wg@grandegger.com, mkl@pengutronix.de, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:39884 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbaI3Nvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 09:51:55 -0400
Content-Disposition: inline
In-Reply-To: <542AB137.30507@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UFMLoheMaWcIEZAi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> >> +- ti,raminit-syscon	: Handle to system control region that contains t=
he
> >> +			  RAMINIT register. If specified, the second memory resource
> >> +			  in the reg property must index into the RAMINIT
> >> +			  register within the syscon region
> >=20
> > There seems to be a simple "syscon" property these days.
>=20
> I had used plain "syscon" in the earlier revisions but was asked to make =
it a TI specific
> property since only TI uses this mechanism.

I see, when was that? Currently, it looks messy :( Grepping through the
dts files in 3.17-rc7, I see that bcm7445 uses "syscon" and variants
with prefixes, STE uses it, too. Samsung uses "samsung,syscon-phandle",
st uses "st,syscon"...

The MACID readout patches for AM335x (just applied right now) also use
"syscon": https://patchwork.ozlabs.org/patch/394289/

I'd vote for a generic "syscon" to be OK, yet I guess the DT maintainers
will have the final word.

> >> +- ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT re=
gister
> >> +- ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT regis=
ter
> >=20
> > This should not be encoded in DT! This is not describing hardware setup.
> > The driver should know where the bits are for the syscon phandle,
> > depending on which SoC it runs...
> >=20
> OK. I'll think of matching the compatible ID with SOC specific data in th=
e driver.

Great, thanks!


--UFMLoheMaWcIEZAi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUKrWZAAoJEBQN5MwUoCm23UEQAJkGdBdrmSsfgKsrD4Kici+i
gGk8ihjs1RNAfaKi0yx4ZQJi+gcdPnZ+Et/t3u6vEw5Gv47IFAP5SteC+DKHJabk
f1ZAScxo7IVYOylbQG2Rkm6ROsymwwtHkHM7+Nt8/FOUn9+5nmpluwFlnOMY9YIn
vjaXTXT/O15MSDe2mQ8H+Bl5E4A6IsADsqfoE5uNJ/NgLE51WJPLvZClj2WvQKNL
6wPFkNJy6u1s/zbn5pDWpJ9LePPqhOSdVjr82Lv0GGYMQOuOtHAS+1w/fgJu9iMz
wHQ2kqoZACfdFVXO/f1kegHSI/748Pa+agcSNdT+sbWH0MMOTdBiKUFLXLHluS7O
7DuPn0HuuhERqlCFpTYOo3hX/lDwoSomS2/kf0XR3U5wBj8NfQyyWvPCJ+z3elbx
LTvJZljlYNSGQqNAWzAC1zQJ4GLyr7rE6KijmxOIq6+5GYdNZSxxPQf7/wv00IJ5
ntJtDvlP4CIk5qv9k0DOgXxQ12znwsSO/Q4QbPgFeR0FGi4Dwq47VaalNvnhdGxt
42iq5vSJ5YFeGohNa+72n20waumTZxb2Ed6YJYImPWeInLwYQNg7+5NDVRfH2DWY
h7kUiWDq+wv1UcWVVYA72RKpaexDk3LgXgVaUhdbVTTK/Mpo3ubhLutaAyJ36e7F
UiqcE7FVoZ3MlOzJNFsf
=KmA0
-----END PGP SIGNATURE-----

--UFMLoheMaWcIEZAi--
