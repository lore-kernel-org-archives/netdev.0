From: Stefan Lippers-Hollmann <s.L-H@gmx.de>
Subject: Re: [PATCH] Add IP1000A Driver
Date: Tue, 11 Sep 2007 15:57:56 +0200
Message-ID: <200709111557.57605.s.L-H@gmx.de>
References: <1189524638.3261.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2155061.hnLgWxdG7r";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:39095 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750780AbXIKN6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 09:58:36 -0400
In-Reply-To: <1189524638.3261.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2155061.hnLgWxdG7r
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi

Just some very basic comments to actually get it compiling, adding Francois=
=20
Romieu to CC because he has been involved with this driver in the past.

On Dienstag, 11. September 2007, Jesse Huang wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
>
> Change Logs: Add IP1000A Driver to kernel tree.
>
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> ---
>
> drivers/net/ipg.c | 2331 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++++
> drivers/net/ipg.h |  856 +++++++++++++++++++
>  2 files changed, 3187 insertions(+), 0 deletions(-)
>  create mode 100755 drivers/net/ipg.c
>  create mode 100755 drivers/net/ipg.h

Kconfig/ Makefile adaptions missing (borrowed from=20
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.19-rc2/ip1000/0001-ipg-new-=
gigabit-ethernet-device-driver.txt):

diff -Nrup a/drivers/net/Kconfig b/drivers/net/Kconfig
=2D-- a/drivers/net/Kconfig       2007-09-11 12:56:50.000000000 +0200
+++ b/drivers/net/Kconfig       2007-09-11 13:00:52.000000000 +0200
@@ -159,6 +159,15 @@ config NET_SB1000

          If you don't have this card, of course say N.

+config IP1000
+       tristate "IP1000 Gigabit Ethernet support"
+       depends on PCI && EXPERIMENTAL
+       ---help---
+         This driver supports IP1000 gigabit Ethernet cards.
+
+         To compile this driver as a module, choose M here: the module
+         will be called ipg.  This is recommended.
+
 source "drivers/net/arcnet/Kconfig"

 source "drivers/net/phy/Kconfig"
diff -Nrup a/drivers/net/Makefile b/drivers/net/Makefile
=2D-- a/drivers/net/Makefile      2007-09-11 13:17:23.000000000 +0200
+++ b/drivers/net/Makefile      2007-09-11 13:28:00.000000000 +0200
@@ -4,6 +4,7 @@

 obj-$(CONFIG_E1000) +=3D e1000/
 obj-$(CONFIG_IBM_EMAC) +=3D ibm_emac/
+obj-$(CONFIG_IP1000) +=3D ipg.o
 obj-$(CONFIG_IXGB) +=3D ixgb/
 obj-$(CONFIG_CHELSIO_T1) +=3D chelsio/
 obj-$(CONFIG_CHELSIO_T3) +=3D cxgb3/


> e804d1c265bf1d843f845457f925a1728bbfdff7
> diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
> new file mode 100755
> index 0000000..bdc2b8d
> --- /dev/null
> +++ b/drivers/net/ipg.c
[...]
> +static struct pci_device_id ipg_pci_tbl[] __devinitdata =3D {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_SUNDANCE,	0x1023), 0, 0, 0 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_SUNDANCE,	0x2021), 0, 0, 1 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_SUNDANCE,	0x1021), 0, 0, 2 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x9021), 0, 0, 3 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4000), 0, 0, 4 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4020), 0, 0, 5 },
> +	{ 0, }
> +};

PCI_VENDOR_ID_SUNDANCE is undefined in kernel 2.6.23-rc6:

diff -Nrup a/include/linux/pci_ids.h b/include/linux/pci_ids.h
=2D-- a/include/linux/pci_ids.h   2007-09-11 13:17:25.000000000 +0200
+++ b/include/linux/pci_ids.h   2007-09-11 13:15:34.000000000 +0200
@@ -1841,6 +1841,8 @@
 #define PCI_VENDOR_ID_ABOCOM           0x13D1
 #define PCI_DEVICE_ID_ABOCOM_2BD1       0x2BD1

+#define PCI_VENDOR_ID_SUNDANCE         0x13F0
+
 #define PCI_VENDOR_ID_CMEDIA           0x13f6
 #define PCI_DEVICE_ID_CMEDIA_CM8338A   0x0100
 #define PCI_DEVICE_ID_CMEDIA_CM8338B   0x0101

After these changes it seems to work in a 100 MBit/s network for me.
00:0a.0 Ethernet controller [0200]: Sundance Technology Inc / IC Plus Corp =
IC Plus IP1000 Family Gigabit Ethernet [13f0:1023] (rev 41)

> --- /dev/null
> +++ b/drivers/net/ipg.h
[...]=20
> +
> +/* Miscellaneous Constants. */
> +#define   TRUE  1
> +#define   FALSE 0

Using the generic boolean definitions might be preferred.

Regards
	Stefan Lippers-Hollmann

--nextPart2155061.hnLgWxdG7r
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG5p7lORbEMfgJlPYRAm7QAJ9VWISJVKtjo/macCf45omsllEAdgCeIhgO
9EIKJ0Z5Y2/+Gcgz/OoNrVI=
=6If5
-----END PGP SIGNATURE-----

--nextPart2155061.hnLgWxdG7r--
