From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Wed, 4 Jan 2012 15:06:58 +1100
Message-ID: <20120104150658.aafd5ae8ebce944e897f1079@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0469422998750001846=="
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
 linux-next@vger.kernel.org, Olof Johansson <olof@lixom.net>,
 Richard Zhao <richard.zhao@linaro.org>, linux-arm-kernel@lists.infradead.org,
 Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============0469422998750001846==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__4_Jan_2012_15_06_58_+1100_EE_gJhZvLnF10E3h"

--Signature=_Wed__4_Jan_2012_15_06_58_+1100_EE_gJhZvLnF10E3h
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/freescale/fec.c between commit 0ebafefcaa7a ("net:
fec: add clk_prepare/clk_unprepare") from the arm-soc tree and commit
e163cc97f9ac ("net/fec: fix the .remove code") from the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/freescale/fec.c
index 112af9b,b0b0445..0000000
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@@ -1638,13 -1657,18 +1657,18 @@@ fec_drv_remove(struct platform_device *
  	struct net_device *ndev =3D platform_get_drvdata(pdev);
  	struct fec_enet_private *fep =3D netdev_priv(ndev);
  	struct resource *r;
+ 	int i;
 =20
- 	fec_stop(ndev);
+ 	unregister_netdev(ndev);
  	fec_enet_mii_remove(fep);
+ 	for (i =3D 0; i < FEC_IRQ_NUM; i++) {
+ 		int irq =3D platform_get_irq(pdev, i);
+ 		if (irq > 0)
+ 			free_irq(irq, ndev);
+ 	}
 -	clk_disable(fep->clk);
 +	clk_disable_unprepare(fep->clk);
  	clk_put(fep->clk);
  	iounmap(fep->hwp);
- 	unregister_netdev(ndev);
  	free_netdev(ndev);
 =20
  	r =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);

--Signature=_Wed__4_Jan_2012_15_06_58_+1100_EE_gJhZvLnF10E3h
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPA9BiAAoJEECxmPOUX5FEPDsP/14/DwT4uwfSLdGOt99ZWL1A
ETiUykRTREyEI5fdHXf1l8iigmGFErmv25+jFiyBHiZU6eu3okpX2VL8ysPSqRel
SQKS1vO1iuV+5boBGxHMekB12C+pDZj/1cPuAPa5CVtZVQyBR47sujqshm8f+wXG
u4HOlFuy+Ct/eqz75e50kBeHBITd8Sp63Av2Vr7/77U5iVAxSzY7q2kwoMtppB/p
cZcdS7oAvf9JmvtIJ5gRgFV5hX6cHoSU1BGqgbrItmn29PDnraESALsSckjBcaQQ
+V+L0jOpcMSImgCWU6ZguXFClI2WsRWg/k3z/iUeHfWoM4V2bIaBD3UlIJCs8Ch3
3djbAHE4sUd8mEO4gceOaY+N43Wda9xLXDhckuVaVnAZC7lC+jcx9n2Fjv+DkMuF
4Tz6dmxV+65UiHSgbas6GQ1nXdkKtSiN8oAOBisZlmb2Wkc8VJlk+Uo6wqXsNv0I
ewIMuKXoRTiNAbAWmUDcgeMahauHnv6YkOy3sNzAfY80fe027hIhcq3zdh+ExbxM
bjv96ARb31Hg4jvkxhvrM1BXcDLKSM4OGYtjjun8DWWtrcGu0t2B9mg39zZZJPAu
Rcad111rJ501o/DvkSm9/l//kdPKeb88gBijw+fjE/9IQ8GhYaYLsdb1x9fT4DKc
YIq3IwTcGYDBfNa85dzz
=oSr8
-----END PGP SIGNATURE-----

--Signature=_Wed__4_Jan_2012_15_06_58_+1100_EE_gJhZvLnF10E3h--


--===============0469422998750001846==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0469422998750001846==--
