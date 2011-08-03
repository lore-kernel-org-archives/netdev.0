From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [net-next v2 42/71] cirrus: Move the Cirrus network driver
Date: Tue, 02 Aug 2011 22:29:59 -0700
Message-ID: <1312349400.2294.76.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-43-git-send-email-jeffrey.t.kirsher@intel.com>
	 <ADE657CA350FB648AAC2C43247A983F001F3882B82AF@AUSP01VMBX24.collaborationhost.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-6+rqOzcA9GW9ssccZYE5"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64139 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604Ab1HCFaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 01:30:01 -0400
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F3882B82AF@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6+rqOzcA9GW9ssccZYE5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 13:23 -0700, H Hartley Sweeten wrote:
> On Saturday, July 30, 2011 8:27 PM, Jeff Kirsher wrote:
> >
> > Move the Cirrus Ethernet driver into drivers/net/ethernet/cirrus/
> > and make the necessary Kconfig and Makefile changes
> >=20
> > CC: Hartley Sweeten <hsweeten@visionengravers.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> I'm not sure why this is being done... Are all the Ethernet drivers being
> moved into "vendor" sub-directories?

Sue to the size of drivers/net and the volume of drivers, some
organization was in dire need.  The method of organization is
drivers/net/<protocol>/.  For most protocol's that is all that will be
needed to organize the drivers.  For the Ethernet protocol directory
(which has the majority of drivers) another level of organization is
need to help maintain drivers and flex the ability to use "common" code.
So after much discussion, I grouped the drivers by the silicon used.
This allowed us to group common drivers like the LANCE, 825xx, and so
on.  These two particular examples have common code shared amongst the
drivers.  With this type of organization, it will make it easier for
this sharing of common code while keeping it easy to maintain.

I apologize that this may seem to come out of the blue to you, since the
first round of organization had the Cirrus driver grouped under a arm/,
but after review, it made more sense moving the drivers under arm/ to
directories with similar silicon rather than using architecture to group
the drivers.

>=20
> A couple comments below...
>=20
> > ---
> >  MAINTAINERS                                       |    2 +-
> >  drivers/net/arm/Kconfig                           |    8 -------
> >  drivers/net/arm/Makefile                          |    1 -
> >  drivers/net/ethernet/Kconfig                      |    1 +
> >  drivers/net/ethernet/Makefile                     |    1 +
> >  drivers/net/ethernet/cirrus/Kconfig               |   24 +++++++++++++=
++++++++
> >  drivers/net/ethernet/cirrus/Makefile              |    5 ++++
> >  drivers/net/{arm =3D> ethernet/cirrus}/ep93xx_eth.c |    0
> >  8 files changed, 32 insertions(+), 10 deletions(-)
> >  create mode 100644 drivers/net/ethernet/cirrus/Kconfig
> >  create mode 100644 drivers/net/ethernet/cirrus/Makefile
> >  rename drivers/net/{arm =3D> ethernet/cirrus}/ep93xx_eth.c (100%)
> >=20
> > diff --git a/MAINTAINERS b/MAINTAINERS
> > index 3c28188..d84f2c6 100644
> > --- a/MAINTAINERS
> > +++ b/MAINTAINERS
> > @@ -1761,7 +1761,7 @@ CIRRUS LOGIC EP93XX ETHERNET DRIVER
> >  M:	Hartley Sweeten <hsweeten@visionengravers.com>
> >  L:	netdev@vger.kernel.org
> >  S:	Maintained
> > -F:	drivers/net/arm/ep93xx_eth.c
> > +F:	drivers/net/ethernet/cirrus/ep93xx_eth.c
> > =20
> >  CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
> >  M:	Lennert Buytenhek <kernel@wantstofly.org>
> > diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
> > index 4f748cc..fc94b4b 100644
> > --- a/drivers/net/arm/Kconfig
> > +++ b/drivers/net/arm/Kconfig
> > @@ -11,14 +11,6 @@ config ARM_AT91_ETHER
> >  	  If you wish to compile a kernel for the AT91RM9200 and enable
> >  	  ethernet support, then you should always answer Y to this.
> > =20
> > -config EP93XX_ETH
> > -	tristate "EP93xx Ethernet support"
> > -	depends on ARM && ARCH_EP93XX
> > -	select MII
> > -	help
> > -	  This is a driver for the ethernet hardware included in EP93xx CPUs.
> > -	  Say Y if you are building a kernel for EP93xx based devices.
> > -
> >  config W90P910_ETH
> >  	tristate "Nuvoton w90p910 Ethernet support"
> >  	depends on ARM && ARCH_W90X900
> > diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
> > index 316b06c..462b3a4 100644
> > --- a/drivers/net/arm/Makefile
> > +++ b/drivers/net/arm/Makefile
> > @@ -4,5 +4,4 @@
> >  #
> > =20
> >  obj-$(CONFIG_ARM_AT91_ETHER)	+=3D at91_ether.o
> > -obj-$(CONFIG_EP93XX_ETH)	+=3D ep93xx_eth.o
> >  obj-$(CONFIG_W90P910_ETH)	+=3D w90p910_ether.o
> > diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfi=
g
> > index b15b1e2..ff07408 100644
> > --- a/drivers/net/ethernet/Kconfig
> > +++ b/drivers/net/ethernet/Kconfig
> > @@ -18,6 +18,7 @@ source "drivers/net/ethernet/atheros/Kconfig"
> >  source "drivers/net/ethernet/broadcom/Kconfig"
> >  source "drivers/net/ethernet/brocade/Kconfig"
> >  source "drivers/net/ethernet/chelsio/Kconfig"
> > +source "drivers/net/ethernet/cirrus/Kconfig"
> >  source "drivers/net/ethernet/cisco/Kconfig"
> >  source "drivers/net/ethernet/dec/Kconfig"
> >  source "drivers/net/ethernet/dlink/Kconfig"
> > diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makef=
ile
> > index 1f45ec9..3a17413 100644
> > --- a/drivers/net/ethernet/Makefile
> > +++ b/drivers/net/ethernet/Makefile
> > @@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_ATHEROS) +=3D atheros/
> >  obj-$(CONFIG_NET_VENDOR_BROADCOM) +=3D broadcom/
> >  obj-$(CONFIG_NET_VENDOR_BROCADE) +=3D brocade/
> >  obj-$(CONFIG_NET_VENDOR_CHELSIO) +=3D chelsio/
> > +obj-$(CONFIG_NET_VENDOR_CIRRUS) +=3D cirrus/
> >  obj-$(CONFIG_NET_VENDOR_CISCO) +=3D cisco/
> >  obj-$(CONFIG_NET_VENDOR_DEC) +=3D dec/
> >  obj-$(CONFIG_NET_VENDOR_DLINK) +=3D dlink/
> > diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet=
/cirrus/Kconfig
> > new file mode 100644
> > index 0000000..b48128b
> > --- /dev/null
> > +++ b/drivers/net/ethernet/cirrus/Kconfig
> > @@ -0,0 +1,24 @@
> > +#
> > +# Cirrus network device configuration
> > +#
> > +
> > +config NET_VENDOR_CIRRUS
> > +	bool "Cirrus devices"
> > +	depends on ARM && ARCH_EP93XX
>=20
> I'm not sure this depends on is correct.
>=20
> Cirrus also manufactures the CS8900A and CS8952 Ethernet controllers.  As=
 far as I
> can tell, these controllers are general purpose and not limited to ARM or=
 ARCH_EP93XX.
>=20

I will leave the dependency changes up to you, because you have a more
intimate knowledge of the hardware and what would be a more appropriate
depends.  I am simply used the current dependency for the current Cirrus
driver.  As more Cirrus drivers get added, this dependency would expand
to encompass all the drivers.  By using a the dependency here, the
Kconfig option of "Cirrus devices" would only be visible when the kernel
is being built with these dependencies, it helps by not visibly showing
an "empty" option for those users who have a config/system which would
not support a Cirrus device.

> > +	---help---
> > +	  If you have a network (Ethernet) card belonging to this class, say =
Y
> > +	  and read the Ethernet-HOWTO, available from
> > +	  <http://www.tldp.org/docs.html#howto>.
> > +
> > +	  Note that the answer to this question doesn't directly affect the
> > +	  kernel: saying N will just cause the configurator to skip all
> > +	  the questions about Cirrus cards. If you say Y, you will be asked
> > +	  for your specific card in the following questions.
> > +
> > +config EP93XX_ETH
> > +	tristate "EP93xx Ethernet support"
> > +	depends on NET_VENDOR_CIRRUS && ARM && ARCH_EP93XX
>=20
> The depends on ARM is redundant.  ARCH_EP93XX can only be selected if ARM=
 is already
> selected.

I can change this to simply be ARCH_EP93XX if you would like, I was just
using what the current dependency was in drivers/net/Kconfig.

>=20
> If drivers exist for the other two Cirrus controllers and are going to be=
 moved
> to this directory it might be cleaner to just block all the drivers in a
>=20
> +if NET_VENDOR_CIRRUS
> # add all config options for Cirrus Ethernet controllers
> +endif=20

I agree and this was suggested by a few others, so I have made this
change to all the Kconfig's under drivers/net/ethernet where applicable.

Thanks!

>=20
> > +	select MII
> > +	help
> > +	  This is a driver for the ethernet hardware included in EP93xx CPUs.
> > +	  Say Y if you are building a kernel for EP93xx based devices.
> > diff --git a/drivers/net/ethernet/cirrus/Makefile b/drivers/net/etherne=
t/cirrus/Makefile
> > new file mode 100644
> > index 0000000..9905ea2
> > --- /dev/null
> > +++ b/drivers/net/ethernet/cirrus/Makefile
> > @@ -0,0 +1,5 @@
> > +#
> > +# Makefile for the Cirrus network device drivers.
> > +#
> > +
> > +obj-$(CONFIG_EP93XX_ETH) +=3D ep93xx_eth.o
> > diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/ethernet/cirrus=
/ep93xx_eth.c
> > similarity index 100%
> > rename from drivers/net/arm/ep93xx_eth.c
> > rename to drivers/net/ethernet/cirrus/ep93xx_eth.c
>=20
> Other than those comments...
>=20
> Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>


--=-6+rqOzcA9GW9ssccZYE5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOONzXAAoJECTsCADr/EWUsrQH/jQkBlxkGBgjXJBMYLCGqokd
1wwIyGIeYyYBWjKF0Yy4WyV2jRAVpKb9JHCxqVzHbKmQIi984hoZgIxBImo457Sd
thkeUPURyubLHFstQMcJSW1EvgZI2g917/Ae2n7miXg+KGr3wOOUoa6XZnWPTISq
252dIacPWFNATVDS/Kf7k6CBj8uKlGQt1KzlPsj0OgsKvqcF6HA5QrKNHzLWYc3c
zjX7zzgz4YhuojWvWRDWVn2QMoM2pXC0s6nZTOQw+kC3NJeJHzf89Q0yMSn38L8B
D2rifo9i4/biqnRdPmSZV4D8N7whBiF0lxgX6wKsJqlz6n8IlXFbNQijslWx/i0=
=oRqY
-----END PGP SIGNATURE-----

--=-6+rqOzcA9GW9ssccZYE5--

