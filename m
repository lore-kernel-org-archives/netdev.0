From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 56/71] macb: Move the Atmel driver
Date: Tue, 02 Aug 2011 22:59:28 -0700
Message-ID: <1312351168.2294.92.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-57-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E36BCEF.8080703@atmel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-HcBbnPvnCGyM6LziCzls"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64282 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400Ab1HCF73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 01:59:29 -0400
In-Reply-To: <4E36BCEF.8080703@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HcBbnPvnCGyM6LziCzls
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 07:49 -0700, Nicolas Ferre wrote:
> On 07/31/2011 04:27 AM, Jeff Kirsher wrote:
> > Move the Atmel driver into drivers/net/ethernet/cadence/ and
> > make the necessary Kconfig and Makefile changes.
> >
> > CC: Nicolas Ferre<nicolas.ferre@atmel.com>
>=20
> You can add my:
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>=20
> > CC: Jamie Iles<jamie@jamieiles.com>
> > Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>=20

Nicolas/Jamie-

I have a v3 series of patches coming out here imminently, and I have
tweaked the Kconfig just a bit based on feedback from others.  Since the
"tweak" made sense for all the Kconfig, I applied it across the board.
Here is the new Kconfig:

+#
+# Atmel device configuration
+#
+
+config HAVE_NET_MACB
+       bool
+
+config NET_ATMEL
+       bool "Atmel devices"
+       depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
+       ---help---
+         If you have a network (Ethernet) card belonging to this class,
say Y.
+         Make sure you know the name of your card. Read the
Ethernet-HOWTO,
+         available from <http://www.tldp.org/docs.html#howto>.
+
+         If unsure, say Y.
+
+         Note that the answer to this question doesn't directly affect
the
+         kernel: saying N will just cause the configurator to skip all
+         the remaining Atmel network card questions. If you say Y, you
will be
+         asked for your specific card in the following questions.
+
+if NET_ATMEL
+
+config ARM_AT91_ETHER
+       tristate "AT91RM9200 Ethernet support"
+       depends on ARM && ARCH_AT91RM9200
+       select MII
+       ---help---
+         If you wish to compile a kernel for the AT91RM9200 and enable
+         ethernet support, then you should always answer Y to this.
+
+config MACB
+       tristate "Atmel MACB support"
+       depends on HAVE_NET_MACB
+       select PHYLIB
+       ---help---
+         The Atmel MACB ethernet interface is found on many AT32 and
AT91
+         parts. Say Y to include support for the MACB chip.
+
+         To compile this driver as a module, choose M here: the module
+         will be called macb.
+
+endif # NET_ATMEL

If these changes are fine, I can add your ACK's.

--=-HcBbnPvnCGyM6LziCzls
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOOOPAAAoJECTsCADr/EWUBRYH/2KnqoxEalAFL3AmVTtaLFRu
J7+D3YI807PvMaVMEK/PwouWNeqsXm7fuSeo854MyHDhWD1GpQCXrRUAIZJVVUna
slL4I4G164cZcuEUgE1btFaJGui/9uPLTR2Ui1Ob+4GRCCuOVlyOhUgmzYcFIcIh
L8zPTfO4bHu/7xlQsmJimAnNwn0aqRVwlE5/plXDWqAnrJF39LpWRO6FGOSCz1LM
uqizZJOiDAbJ7by/yDnHATj0kcDmSfMm7Ohv9A9DdhOc4rnupO7Tgibj15Im8SoJ
z8b9JahcXiQIJCyog10qzzzyfha6ruZxcb0FfkaWEeu7G/gDhr+m0pO4CykXvCk=
=otYz
-----END PGP SIGNATURE-----

--=-HcBbnPvnCGyM6LziCzls--

