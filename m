From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 24 Jun 2015 17:37:10 +1000
Message-ID: <20150624173710.3248ece8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/LN_j3f2ia2e8m0Vs_L.61N/"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Suman Tripathi <stripathi@apm.com>,
	Iyappan Subramanian <isubramanian@apm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/LN_j3f2ia2e8m0Vs_L.61N/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (KCONFIG_NAME)
failed like this:

drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function 'xgene_get_po=
rt_id_acpi':
drivers/net/ethernet/apm/xgene/xgene_enet_main.c:880:2: error: implicit dec=
laration of function 'acpi_evaluate_integer' [-Werror=3Dimplicit-function-d=
eclaration]
  status =3D acpi_evaluate_integer(ACPI_HANDLE(dev), "_SUN", NULL, &temp);
  ^
drivers/net/ethernet/apm/xgene/xgene_enet_main.c: At top level:
drivers/net/ethernet/apm/xgene/xgene_enet_main.c:874:12: warning: 'xgene_ge=
t_port_id_acpi' defined but not used [-Wunused-function]
 static int xgene_get_port_id_acpi(struct device *dev,
            ^

Caused by commit 0738c54d6324 ("drivers: net: xgene: Fix the ACPI support
for RGMII/SGMII0/XFI interface of APM X-Gene SoC ethernet controller").

I have applied this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 24 Jun 2015 17:29:51 +1000
Subject: [PATCH] drivers: net: xgene: fix for ACPI support without ACPI

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net=
/ethernet/apm/xgene/xgene_enet_main.c
index b334f279ce8d..95153b234c71 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -871,6 +871,7 @@ static const struct net_device_ops xgene_ndev_ops =3D {
 	.ndo_set_mac_address =3D xgene_enet_set_mac_address,
 };
=20
+#ifdef CONFIG_ACPI
 static int xgene_get_port_id_acpi(struct device *dev,
 				  struct xgene_enet_pdata *pdata)
 {
@@ -886,6 +887,7 @@ static int xgene_get_port_id_acpi(struct device *dev,
=20
 	return 0;
 }
+#endif
=20
 static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdat=
a *pdata)
 {
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/LN_j3f2ia2e8m0Vs_L.61N/
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVil4qAAoJEMDTa8Ir7ZwV1IwP/A0OVYyBJc9zcK74M6N/rPQU
FNPJOClJI0RxzdHOkfkaC0jaQu8RMuKVDliV4L9i43HoCEJONL+FLXi8nB+XCRBk
c5cPiac0Ck8t0VkexHNtMqD/UKaKwM4SWMzFnbQOHR8/ROjiWKMUJxE+mg13SAQD
XUfWe40c9RaFgBA5yaw4Ot+bWYpXwEguWb5yEPCBLKpjH+fRPq7WBOSjfEKlP7NM
EvPoeeqsArRVLxKQKJbNnmU+VbvoQlavB6VtGRoNeXz3v1RDAMc3soBQ0zilFFIY
E3Av2akheyURjSIE5RtNKvKwVYMA6vxFhhj/RIPB2QHEooybfa+VfZ2hN3F74gPx
JhOiJ/LYVHj6yAwfqrDjmvtYr+cFE2ScSggS6cpIobhxAuZES5BADmWsZOSnDEjC
4KnjSfBZ5xuthDRaiaqrjDc953Nv2NzOhhlbQjXvw6/6WSaJYZDR399B7nWDRkbP
DexoO5PPMQ5vQPcAHonhp5SFz8mR6kBg6tEfGM1T5D2lmKV509oqivZZheDHCMUm
jK5OOZr8hSPD07cpf1LdGSflLW0d/f6+XN2VoxPJApXacyQl/NCYQqqw7MqUqUsO
femoQ1RNDVHU/jgZpd7DSmjc0Is+Ski553+uxSpqhtjwnM2IDhJU0CP38nEPnvC7
bMKoBeNWhh+EKpD7vxMP
=iHI/
-----END PGP SIGNATURE-----

--Sig_/LN_j3f2ia2e8m0Vs_L.61N/--
