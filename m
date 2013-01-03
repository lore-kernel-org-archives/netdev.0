From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Thu, 3 Jan 2013 14:23:53 +1100
Message-ID: <20130103142353.b4fee0ccd57730e4fbd63ba9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__3_Jan_2013_14_23_53_+1100_=PxiS5waLSlD40H5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__3_Jan_2013_14_23_53_+1100_=PxiS5waLSlD40H5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/built-in.o: In function `pci_get_domain_bus_and_slot':
(.opd+0x449e8): multiple definition of `pci_get_domain_bus_and_slot'
drivers/pci/built-in.o:(.opd+0x1c98): first defined here

Caused by commit 13159183ec7a ("qlcnic: 83xx base driver") from the
net-next tree.  Why is this commit adding a function that already exists
globally?

I added this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 3 Jan 2013 14:19:16 +1100
Subject: [PATCH] qlcnic: do not duplicate infrastructure functions

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   20 +-----------------=
--
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net=
/ethernet/qlogic/qlcnic/qlcnic_main.c
index e1a3625..3bdb1beae 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2,12 +2,6 @@
  * QLogic qlcnic NIC Driver
  * Copyright (c)  2009-2010 QLogic Corporation
  *
- * PCI searching functions pci_get_domain_bus_and_slot & pci_channel_offli=
ne
- * Copyright (C) 1993 -- 1997 Drew Eckhardt, Frederic Potter,
- *					David Mosberger-Tang
- * Copyright (C) 1997 -- 2000 Martin Mares <mj@ucw.cz>
- * Copyright (C) 2003 -- 2004 Greg Kroah-Hartman <greg@kroah.com>.
- *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
=20
@@ -25,6 +19,7 @@
 #include <linux/inetdevice.h>
 #include <linux/aer.h>
 #include <linux/log2.h>
+#include <linux/pci.h>
=20
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver"=
);
 MODULE_LICENSE("GPL");
@@ -2907,19 +2902,6 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
=20
-struct pci_dev *pci_get_domain_bus_and_slot(int domain, unsigned int bus,
-					    unsigned int devfn)
-{
-	struct pci_dev *dev =3D NULL;
-
-	while ((dev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) !=3D NULL) {
-		if (pci_domain_nr(dev->bus) =3D=3D domain &&
-		    (dev->bus->number =3D=3D bus && dev->devfn =3D=3D devfn))
-			return dev;
-	}
-	return NULL;
-}
-
 static int qlcnic_is_first_func(struct pci_dev *pdev)
 {
 	struct pci_dev *oth_pdev;
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__3_Jan_2013_14_23_53_+1100_=PxiS5waLSlD40H5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ5PnJAAoJEECxmPOUX5FETf8P/3SoQNa3E4QqL/QJ8mPKb7tV
tovw8ATSJydQQbkSqj5Oo1I8f0Qx9rMaffNlKLoCu/qmDTxgt5iKM57JSQS1I1wh
uxhD2ndUh6FLAEG41dZl06XeOn5nRoSF5Htx2kdVvZqs02uQCaGRm8XpJ6lYlXXI
c8b4r8HtT5sLC2MIichmg8kSOQaPQyeYKhqFmS3v6238BfWThX0xGz3Borxds2hL
Prv7iX2e9GgIIh0fcpr8OowkXUlAHX5S6Qqr7giIC2nn175qMoWLUEwifUNv3yaN
fQJCg+X4vvFFR3bVjkjytXE9XpR0umIGEv5WHN18qMlSf8h/GNtMMjtbvIM9knvG
pQB/ESXrGJ+4SaMfgihZXi90Yq7QW164pa/gX/hq0hBW6PHckseyCdihFF5S/FHi
7v6QrUp+G0cH5BcigRKh0uCoggwa4MkDMmQfsBlHvRmrfwSIIwyRSWqQF2Whq/Cw
qwGm3d4TGOH4zkE0CmDB+bDx9GpfpQpEmK42jllyDKmOs1vHrlqlx4zASZ5JvoxL
IexZTty/ABNWHD8Enl9Q9hOTyx8GOF5TfB5ZEoELXmH5Q7O3ZS4TiNuMd2zWUWjB
73wSV4egRb7Xwf5/GNuQThZWlw/XBKNCZ+5P/Tamtx8ZjfXfdwJm851ch3ddvQBO
8LxiSvFCeNmL4GrhT8c8
=JDVG
-----END PGP SIGNATURE-----

--Signature=_Thu__3_Jan_2013_14_23_53_+1100_=PxiS5waLSlD40H5--
