From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 18:07:31 +0100
Message-ID: <20160419170731.GB3217@sirena.org.uk>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <8665E2433BC68541A24DFFCA87B70F5B360B6C90@DFRE01.ent.ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="m3zcgECJg5Qgddwj"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B360BF614-1tpBd5JUCm6IQmiDNMet8wC/G2K4zDHf@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--m3zcgECJg5Qgddwj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 18, 2016 at 05:55:51AM +0000, Reizer, Eyal wrote:

> > I would suggest fixing this using a new API function from the SPI core,=
 if we
> > don't already have a generic way to do it.

> Originally this is what I have done until I was pointed to the generic cs=
-gpio mechanism=20
> in the SPI core.=20
> It is a generic mechanism already in the SPI core driver.
> See: Documentation/devicetree/bindings/spi/spi-bus.txt

> It is also part of the generic spi.h (include/Linux/spi/spi.h), already p=
art of=20
> " struct spi_device" So it seemed redundant adding another mechanism for=
=20
> implementing the same.

No!  This is a *terrible* and broken idea.  Client drivers should *not*
be peering inside controller implementations like this, and they should
especially not be trying to change the chip select without the core
knowing about it.  This is at best going to be fragile, at worst it will
actively break some systems.  Whatever you are trying to do needs to go
through the SPI core with some degree of abstraction, the core needs to
know what's going on and the driver needs to support systems that don't
or can't mux the chip select out as a GPIO.

--m3zcgECJg5Qgddwj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXFmXSAAoJECTWi3JdVIfQQzwH/3Rjx9TUJqPDdISE8n7y1lN+
c4IwT396JHdP0+B9ewcv1CMp7OqBj4/HQIQcZPW+PS5w3awzRyzWxs/Smir+qet5
mOPxB+GJAXB5H/fp1LH0Z/q/WFf2/1PimTvEztP4smIiOa9WDYiWlW7ppGOGNbu2
3+wMVJ4X/+4MqBWyCI/T26Gn10+vAMtEazMZ48im2Vr3Fm8NxLz3JnYVzYDb4y1q
H5f0b4lzW2EAvpWyvylwbnfKAuiH+mkRiHjlee2ppeoL08d6L1UlE7gEuKweUaqp
J2cTg9VnTIi18NTkOZXWxI03QkJBZ4FiSmm3HHca00ShOzafLLdDeSYeh4Zl4OQ=
=g+t8
-----END PGP SIGNATURE-----

--m3zcgECJg5Qgddwj--
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
