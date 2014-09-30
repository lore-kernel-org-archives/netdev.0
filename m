From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 18:04:19 +0200
Message-ID: <542AD483.2020808@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana> <542AB6E9.9000907@ti.com> <20140930141909.GP1325@katana> <542ABC90.7010900@pengutronix.de> <20140930144950.GQ1325@katana> <542AC5B2.9040406@pengutronix.de> <20140930152550.GR1325@katana>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="cIMFxGvl905iTE77CLLL0HVQphLfjjS2C"
Cc: Roger Quadros <rogerq@ti.com>, wg@grandegger.com, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57674 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbaI3QHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 12:07:51 -0400
In-Reply-To: <20140930152550.GR1325@katana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cIMFxGvl905iTE77CLLL0HVQphLfjjS2C
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2014 05:25 PM, Wolfram Sang wrote:
>=20
>> Yes, but syscon_regmap_lookup_by_phandle() doesn't need any support fo=
r
>> additional parameters. Have a look at:
>>
>> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>>
>> First get the regmap, then the 1st argument is the offset in the regma=
p,
>> the 2nd and 3rd could be the bits.
>=20
> So, for one driver the extra arguments are: <reg> <start_bit> <stop_bit=
>
> For another driver (the stmmac example): <reg_offset> <reg_shift>

The DCAN's "reg" is a "reg_offset" as in the stmmc.

Roger, can we derive both start and done bit from a common reg_shift?

> Phew... Then we should really have a "syscon-raminit" property probably=
,
> so that at least plain "syscon" has a consistent syntax?

I think^whope we can have the same syntax as the stmmc :D

>>> So, I'd rather drop additional arguments.
>>>
>>> Why would you like to have it encoded in DT?
>>
>> Where put the information then? Into the driver, but where do you get
>> the reference which instance of the DCAN you are, so that you can look=

>> up the correct bits?
>=20
> Agreed. I thought we had this information in the driver already, but we=

> haven't...
>=20

The current driver relies on the of_alias_get_id(), which isn't
considered best practice, is it? So I want to avoid this when switching
to syscon.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cIMFxGvl905iTE77CLLL0HVQphLfjjS2C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQq1IMACgkQjTAFq1RaXHM9GQCeOwY/cTIUO8H6WqNCDJQfY4fI
ouEAniGjIrfync1tgm544wlncuj28V0O
=Gh9I
-----END PGP SIGNATURE-----

--cIMFxGvl905iTE77CLLL0HVQphLfjjS2C--
