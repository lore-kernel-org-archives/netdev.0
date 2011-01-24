From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v3 0/3] can: at91_can: fix for errata 50.2.6.3 & 50.3.5.3
Date: Mon, 24 Jan 2011 15:19:16 +0100
Message-ID: <4D3D8A64.6000305@pengutronix.de>
References: <1295878532-15769-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8858848502913150110=="
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1295878532-15769-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============8858848502913150110==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig475F52056A8B169DE66D6096"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig475F52056A8B169DE66D6096
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/24/2011 03:15 PM, Marc Kleine-Budde wrote:
> Hello,
>=20
> as promised I've implemented the proposed workaround for the errata
> 50.2.6.3 & 50.3.5.3:
> "Contents of Mailbox 0 can be sent Even if Mailbox is Disabled"
>=20
> This means under high bus load it can happen that the mailbox 0 is send=

> to the bus. And it does happen, even with the mainline driver where
> Mailbox 0 is a receive mailbox. The errata proposes not to use mailbox =
0
> and load it with an unused can_id that will not disturb the bus.
>=20
> The first patch cleans up the driver without any functional changes, so=

> that the mailbox 0 can be disabled in the second patch. The third patch=

> adds a sysfs parameter to the driver, so that the identifier of mailbox=
 0
> can configured.
>=20
> This series applies to net-2.6/master. It has been tested on a ronetix =
pm9263
> board against a PCI-SJA1000 card with the canfdtest utility and on cust=
om
> at91 boards against each other.

I've updated the patch series in my git-repo, too.

The following changes since commit b30532515f0a62bfe17207ab00883dd2624970=
06:

  bonding: Ensure that we unshare skbs prior to calling pskb_may_pull (20=
11-01-20 16:45:56 -0800)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git can/at91_can-for-net-2.6=


Marc Kleine-Budde (3):
      can: at91_can: clean up usage of AT91_MB_RX_FIRST and AT91_MB_RX_NU=
M
      can: at91_can: don't use mailbox 0
      can: at91_can: make can_id of mailbox 0 configurable

 Documentation/ABI/testing/sysfs-platform-at91 |   25 +++++
 drivers/net/can/at91_can.c                    |  138 +++++++++++++++++++=
+-----
 2 files changed, 137 insertions(+), 26 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-platform-at91

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig475F52056A8B169DE66D6096
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk09imgACgkQjTAFq1RaXHMK2QCglV0LHn2osRZfHF59zaHd9pdX
wzMAniuRguQ5TSWcUcKvzD13elG6zNV+
=ipYJ
-----END PGP SIGNATURE-----

--------------enig475F52056A8B169DE66D6096--

--===============8858848502913150110==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8858848502913150110==--
