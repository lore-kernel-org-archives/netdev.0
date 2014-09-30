From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 17:01:06 +0200
Message-ID: <542AC5B2.9040406@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB137.30507@ti.com> <20140930135226.GO1325@katana> <542AB6E9.9000907@ti.com> <20140930141909.GP1325@katana> <542ABC90.7010900@pengutronix.de> <20140930144950.GQ1325@katana>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Q2teAWMSj68LmqGThNPIuel11IXG1dWUA"
Cc: Roger Quadros <rogerq@ti.com>, wg@grandegger.com, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140930144950.GQ1325@katana>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Q2teAWMSj68LmqGThNPIuel11IXG1dWUA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2014 04:49 PM, Wolfram Sang wrote:
> On Tue, Sep 30, 2014 at 04:22:08PM +0200, Marc Kleine-Budde wrote:
>> On 09/30/2014 04:19 PM, Wolfram Sang wrote:
>>>
>>>> As just TI is using this out of band RAMINIT mechanism, should it be=
 "ti,syscon" or just "syscon"?
>>>
>>> Yes, only TI uses this out-of-band RAMINIT (currently, at least). So,=
 we
>>> need an (optional) way to describe that. However, accessing syscon
>>> registers in general is not TI specific and a generic way to do this
>>> should be used. Which looks to me like the "syscon" property to allow=

>>> access to the register. Still, we should ask DT maintainers about it,=

>>> maybe they prefer a more precise property like "syscon-raminit" to al=
low
>>> for further syscon extensions later or something...
>>
>> What do you think about putting the bit information in the
>> syscon-raminit phandle as additional arguments?
>=20
> Then we'd have <n> syscon phandles for <n> instances?
>=20
> Also, judging from Markus patch [1] there is already some
> infrastructure, namely syscon_regmap_lookup_by_phandle(). From a
> glimpse, it doesn't look viable to add such a support to it.

Yes, but syscon_regmap_lookup_by_phandle() doesn't need any support for
additional parameters. Have a look at:

drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c

First get the regmap, then the 1st argument is the offset in the regmap,
the 2nd and 3rd could be the bits.

> So, I'd rather drop additional arguments.
>=20
> Why would you like to have it encoded in DT?

Where put the information then? Into the driver, but where do you get
the reference which instance of the DCAN you are, so that you can look
up the correct bits?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Q2teAWMSj68LmqGThNPIuel11IXG1dWUA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQqxbIACgkQjTAFq1RaXHMR3wCfe3l+YvpKzt20cEcx8/Y/xu/N
HLEAn0jJrXsj0mrumczXKVJmwh5ydmF6
=Tllu
-----END PGP SIGNATURE-----

--Q2teAWMSj68LmqGThNPIuel11IXG1dWUA--
