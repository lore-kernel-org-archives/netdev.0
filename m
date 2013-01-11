From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 11 Jan 2013 13:18:07 +1100
Message-ID: <20130111131807.5d41574cda2c8d6a8b08ae1f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__11_Jan_2013_13_18_07_+1100_H3f8pzYHr7Dlwwaq"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Sony Chacko <sony.chacko@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__11_Jan_2013_13_18_07_+1100_H3f8pzYHr7Dlwwaq
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:1721:1: error: expected '=
=3D', ',', ';', 'asm' or '__attribute__' before 'qlcnic_probe'
drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:1912:23: error: expected '=
=3D', ',', ';', 'asm' or '__attribute__' before 'qlcnic_remove'

Caused by commits 7e2cf4feba05 ("qlcnic: change driver hardware interface
mechanism") and 13159183ec7a ("qlcnic: 83xx base driver") from the
net-next tree interacting with commit 54b956b90360 ("Remove __dev*
markings from init.h") from the drover-core.current tree.

I have added the following merge fix patch for today which could be added
directly to the scsi tree (please).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 11 Jan 2013 13:15:05 +1100
Subject: [PATCH] qlcnic: remove new __dev* annotations

CONFIG_HOTPLUG is always true now and the __dev* macros have been removed.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net=
/ethernet/qlogic/qlcnic/qlcnic_main.c
index d331313..fb7ac8e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1717,7 +1717,7 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adap=
ter,
 	return 0;
 }
=20
-static int __devinit
+static int
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev =3D NULL;
@@ -1909,7 +1909,7 @@ err_out_disable_pdev:
 	return err;
 }
=20
-static void __devexit qlcnic_remove(struct pci_dev *pdev)
+static void qlcnic_remove(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter;
 	struct net_device *netdev;
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__11_Jan_2013_13_18_07_+1100_H3f8pzYHr7Dlwwaq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ73ZfAAoJEECxmPOUX5FEpXAQAJJYXe+e+bOS0/n2aPwgL8la
oBUhO2quamBaxJb4/6emP7nCSFnGCs0Shgy1wDrYjGqcw+Uvfxdda4/vdpYhjyCn
Y3bkhaqyru+dTJ6J4538lKNPvzQhVMnxLnCpNBJL7TRc63oWJFSaFEbGntbCmRkm
F1zfwrDxOnsX/U+2yuNM9Czs3mXxOXGAE8gx9qB10jPeIPX5t4DS4Hfc6YSGSa42
zenXaP0sZw/t48YvGxci8zCBdRRtjTZCXX/XUwyaaH4d/zPqVwIDkNX2OLFWBpV9
khIf+fdC1KFwYyWmrM5sLtnieLXyS9YnLl28K8r1x3wqnYAPXpLk5/+z2d8Paxym
0UPlHlAFxNb0a5t+a+PwR5CxEgnSrptA3MjuZuQQFZCKKXWnBPSGveKjDflNsMzq
XuyuZRV6vPmrIj2XR+PrL6Fyi5puLoQwZ+SeZrcLQrs6gII7Xl9bYwv8o+2A8IuA
5q3GR2FA7tuYrA/u8r5Od6lRzPA8XL3G9ZKQ2T3sth11gk1QX/89mLmQ2nW2qAzf
znfBOUGAHz7tV86OExsKYMNnlTKd1c08OvmPQ9u+JeMR/tARknh+kNh/Cpp1VfUt
7/oocaXecVmsd/aRTjLrEExTo6X1lOgDbsM4/cpGUKLMh4zD4GwiN9uXwMh35v85
t+8dgVSYRbh4doH0YY+t
=zQKj
-----END PGP SIGNATURE-----

--Signature=_Fri__11_Jan_2013_13_18_07_+1100_H3f8pzYHr7Dlwwaq--
