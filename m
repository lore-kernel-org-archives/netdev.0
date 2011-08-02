From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 70/71] tile: Move the Tilera driver
Date: Mon, 01 Aug 2011 20:53:18 -0700
Message-ID: <1312257199.2294.11.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E36E0B2.60900@tilera.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-T6eowCkJ/oiQsaUBP/3K"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Chris Metcalf <cmetcalf@tilera.com>,
	H Hartley Sweeten <hartleys@visionengravers.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3632 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589Ab1HBDxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 23:53:30 -0400
In-Reply-To: <4E36E0B2.60900@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T6eowCkJ/oiQsaUBP/3K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 10:21 -0700, Chris Metcalf wrote:
> On 7/30/2011 11:27 PM, Jeff Kirsher wrote:
> > Move the Tilera driver into drivers/net/ethernet/tile and
> > make the necessary Kconfig and Makefile changes.
> >
> > CC: Chris Metcalf <cmetcalf@tilera.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > [...]
> > +++ b/drivers/net/ethernet/tile/Kconfig
> > @@ -0,0 +1,28 @@
> > +#
> > +# Tilera network device configuration
> > +#
> > +
> > +config NET_VENDOR_TILERA
> > +	bool "Tilera devices"
> > +	depends on TILE
> > +	---help---
> > +	  If you have a network (Ethernet) card belonging to this class, say =
Y
> > +	  and read the Ethernet-HOWTO, available from
> > +	  <http://www.tldp.org/docs.html#howto>.
> > +
> > +	  Note that the answer to this question doesn't directly affect the
> > +	  kernel: saying N will just cause the configurator to skip all
> > +	  the questions about Tilera cards. If you say Y, you will be asked f=
or
> > +	  your specific card in the following questions.
> > +
> > +config TILE_NET
> > +	tristate "Tilera GBE/XGBE network driver support"
> > +	depends on NET_VENDOR_TILERA && TILE
> > +	default y
> > +	select CRC32
> > +	---help---
> > +	  This is a standard Linux network device driver for the
> > +	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
> > +
> > +	  To compile this driver as a module, choose M here: the module
> > +	  will be called tile_net.
>=20
> Overall, this seems fine, since the Tilera drivers get grouped more
> appropriately as a result.  However, the drivers in question are not
> Ethernet cards (and Tilera is not an Ethernet card vendor and has no plan=
s
> to become one).  Instead, this is the driver support for the built-in
> networking hardware on the Tilera multicore CPU chip.  I'm happy to group
> this support under drivers/net/ethernet/tile/, but I think it's appropria=
te
> to default it to "Y" if you are building a TILE kernel (since you are
> guaranteed to have the networking hardware available).
>=20
> I suspect for now the cleanest thing to do is to fold the two config
> options together, using NET_VENDOR_TILERA for consistency with other
> NET_VENDOR_xxx symbols, and defaulting it to "Y" via "depends on TILE".  =
I
> don't think the Ethernet-HOWO reference is particularly helpful since it
> mostly tackles all the various card issues, kernel boot param issues, etc=
.,
> none of which are relevant to this driver.  Something like:
>=20
> +config NET_VENDOR_TILERA
> +	bool "Tilera devices"
> +	depends on TILE
> +	default y
> +	select CRC32
> +	---help---
> +	  This is a standard Linux network device driver for the arch/tile
> +	  on-chip Gigabit Ethernet and XAUI interfaces.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called tile_net.
>=20
>=20
> Obviously you'd also need to tweak the TILE_NET symbol in the Makefile to
> be VENDOR_TILERA.  If this makes sense to you, go ahead and make the
> change, and feel free to use my
>=20
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
>=20

Sounds fine, I will make the necessary changes.

Also based on feedback from Hartley Sweeten and Geert Uytterhoeven, I
will make a change to the Kconifg's to make it less a maintenance issue
going forward by wrapping the drivers in the Kconfig with "if
NET_VENDOR_<blah> ... endif.  This way new drivers will not have to add
the dependency of NET_VENDOR_<blah>.

--=-T6eowCkJ/oiQsaUBP/3K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJON3SuAAoJECTsCADr/EWU6VAIAJJmUp+GbrJZwD8f493exoDq
nf5C4jLynEOy6fuH7pEk34WAaw5ZCfHQdOxFcewV/5dWkviZaajUC4yEolTs7OfO
UMiRf6wuAAzjXUvHAQadmqN/4hB4c9YWaEcihzDyri6RTG/14qKz7MhmJNarGjrY
WxKUGyBzahk7UG98ShT0oc/fYXzhbf1oJEfw/D0nqEUyMv2NC8YXUdbSAQJ7/2Ny
uVmiDOMIlNh/WT/GMEHBMUQOhqoVDz8tfGA68x1jyx1dSpeWygZBSc+XppTriPJO
YlpycfVyhVRnH3dQ4fzr1teUfnBi49e4NvTvr0FCn1K1OVBC+eQ/1P/Wmm7GEeQ=
=onxy
-----END PGP SIGNATURE-----

--=-T6eowCkJ/oiQsaUBP/3K--

