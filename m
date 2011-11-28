From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] net/ethernet: convert drivers/net/ethernet/* to use
 module_platform_driver()
Date: Mon, 28 Nov 2011 10:44:17 +0800
Message-ID: <1322448257.2408.6.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Nicolas Pitre <nico@fluxnic.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Daniel Hellstrom <daniel@gaisler.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jiri Kosina <jkosina@suse.cz>,
	Richard Cochran <richard.cochran@omicron.at>,
	Jonas Bonn <jonas@southpole.se>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>,
	Micha <mirq-linux@rere.qmqm.pl>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch converts the drivers in drivers/net/ethernet/* to use the
module_platform_driver() macro which makes the code smaller and a bit
simpler.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
Cc: Wan ZongShun <mcuos.com@gmail.com>
Cc: Nicolas Pitre <nico@fluxnic.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: Daniel Hellstrom <daniel@gaisler.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Richard Cochran <richard.cochran@omicron.at>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Sebastian Poehn <sebastian.poehn@belden.com>
Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Cc: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/ethernet/8390/ax88796.c                |   13 +----------
 drivers/net/ethernet/aeroflex/greth.c              |   13 +----------
 drivers/net/ethernet/amd/au1000_eth.c              |   15 +----------
 drivers/net/ethernet/amd/sunlance.c                |   15 +-----------
 drivers/net/ethernet/broadcom/sb1250-mac.c         |   13 +----------
 drivers/net/ethernet/dnet.c                        |   13 +----------
 drivers/net/ethernet/ethoc.c                       |   13 +----------
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   15 +-----------
 .../net/ethernet/freescale/fs_enet/mii-bitbang.c   |   13 +----------
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c   |   13 +----------
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |   11 +--------
 drivers/net/ethernet/freescale/gianfar.c           |   14 +----------
 drivers/net/ethernet/freescale/gianfar_ptp.c       |   16 +-----------=
-
 drivers/net/ethernet/korina.c                      |   13 +----------
 drivers/net/ethernet/marvell/pxa168_eth.c          |   13 +----------
 drivers/net/ethernet/micrel/ks8842.c               |   13 +----------
 drivers/net/ethernet/micrel/ks8851_mll.c           |   13 +----------
 drivers/net/ethernet/natsemi/jazzsonic.c           |   13 +----------
 drivers/net/ethernet/natsemi/macsonic.c            |   13 +----------
 drivers/net/ethernet/natsemi/xtsonic.c             |   13 +----------
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |   13 +----------
 drivers/net/ethernet/renesas/sh_eth.c              |   13 +----------
 drivers/net/ethernet/seeq/sgiseeq.c                |   18 +-----------=
---
 drivers/net/ethernet/sgi/meth.c                    |   19 +-----------=
----
 drivers/net/ethernet/smsc/smc911x.c                |   13 +----------
 drivers/net/ethernet/smsc/smc91x.c                 |   13 +----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   24 +-----------=
--------
 drivers/net/ethernet/sun/sunbmac.c                 |   13 +----------
 drivers/net/ethernet/tundra/tsi108_eth.c           |   20 +-----------=
----
 drivers/net/ethernet/xilinx/ll_temac_main.c        |   12 +---------
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |   22 +-----------=
------
 31 files changed, 32 insertions(+), 416 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet=
/8390/ax88796.c
index 2a3b8c2..9e8ba4f 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -990,18 +990,7 @@ static struct platform_driver axdrv =3D {
 	.resume		=3D ax_resume,
 };
=20
-static int __init axdrv_init(void)
-{
-	return platform_driver_register(&axdrv);
-}
-
-static void __exit axdrv_exit(void)
-{
-	platform_driver_unregister(&axdrv);
-}
-
-module_init(axdrv_init);
-module_exit(axdrv_exit);
+module_platform_driver(axdrv);
=20
 MODULE_DESCRIPTION("AX88796 10/100 Ethernet platform driver");
 MODULE_AUTHOR("Ben Dooks, <ben@simtec.co.uk>");
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethern=
et/aeroflex/greth.c
index 442fefa..c885aa9 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1623,18 +1623,7 @@ static struct platform_driver greth_of_driver =3D=
 {
 	.remove =3D __devexit_p(greth_of_remove),
 };
=20
-static int __init greth_init(void)
-{
-	return platform_driver_register(&greth_of_driver);
-}
-
-static void __exit greth_cleanup(void)
-{
-	platform_driver_unregister(&greth_of_driver);
-}
-
-module_init(greth_init);
-module_exit(greth_cleanup);
+module_platform_driver(greth_of_driver);
=20
 MODULE_AUTHOR("Aeroflex Gaisler AB.");
 MODULE_DESCRIPTION("Aeroflex Gaisler Ethernet MAC driver");
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethern=
et/amd/au1000_eth.c
index 4865ff1..cc9262b 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1339,18 +1339,7 @@ static struct platform_driver au1000_eth_driver =
=3D {
 		.owner  =3D THIS_MODULE,
 	},
 };
-MODULE_ALIAS("platform:au1000-eth");
-
-
-static int __init au1000_init_module(void)
-{
-	return platform_driver_register(&au1000_eth_driver);
-}
=20
-static void __exit au1000_exit_module(void)
-{
-	platform_driver_unregister(&au1000_eth_driver);
-}
+module_platform_driver(au1000_eth_driver);
=20
-module_init(au1000_init_module);
-module_exit(au1000_exit_module);
+MODULE_ALIAS("platform:au1000-eth");
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet=
/amd/sunlance.c
index 8fda457..7ea16d3 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1540,17 +1540,4 @@ static struct platform_driver sunlance_sbus_driv=
er =3D {
 	.remove		=3D __devexit_p(sunlance_sbus_remove),
 };
=20
-
-/* Find all the lance cards on the system and initialize them */
-static int __init sparc_lance_init(void)
-{
-	return platform_driver_register(&sunlance_sbus_driver);
-}
-
-static void __exit sparc_lance_exit(void)
-{
-	platform_driver_unregister(&sunlance_sbus_driver);
-}
-
-module_init(sparc_lance_init);
-module_exit(sparc_lance_exit);
+module_platform_driver(sunlance_sbus_driver);
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/e=
thernet/broadcom/sb1250-mac.c
index aa58f9e..8fa7abc 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2675,15 +2675,4 @@ static struct platform_driver sbmac_driver =3D {
 	},
 };
=20
-static int __init sbmac_init_module(void)
-{
-	return platform_driver_register(&sbmac_driver);
-}
-
-static void __exit sbmac_cleanup_module(void)
-{
-	platform_driver_unregister(&sbmac_driver);
-}
-
-module_init(sbmac_init_module);
-module_exit(sbmac_cleanup_module);
+module_platform_driver(sbmac_driver);
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index d94b968..ce88c0f 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -977,18 +977,7 @@ static struct platform_driver dnet_driver =3D {
 	},
 };
=20
-static int __init dnet_init(void)
-{
-	return platform_driver_register(&dnet_driver);
-}
-
-static void __exit dnet_exit(void)
-{
-	platform_driver_unregister(&dnet_driver);
-}
-
-module_init(dnet_init);
-module_exit(dnet_exit);
+module_platform_driver(dnet_driver);
=20
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Dave DNET Ethernet driver");
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.=
c
index 251b635..60f0e78 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1185,18 +1185,7 @@ static struct platform_driver ethoc_driver =3D {
 	},
 };
=20
-static int __init ethoc_init(void)
-{
-	return platform_driver_register(&ethoc_driver);
-}
-
-static void __exit ethoc_exit(void)
-{
-	platform_driver_unregister(&ethoc_driver);
-}
-
-module_init(ethoc_init);
-module_exit(ethoc_exit);
+module_platform_driver(ethoc_driver);
=20
 MODULE_AUTHOR("Thierry Reding <thierry.reding@avionic-design.de>");
 MODULE_DESCRIPTION("OpenCores Ethernet MAC driver");
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/dr=
ivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 5bf5471..910a8e1 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1171,16 +1171,6 @@ static struct platform_driver fs_enet_driver =3D=
 {
 	.remove =3D fs_enet_remove,
 };
=20
-static int __init fs_init(void)
-{
-	return platform_driver_register(&fs_enet_driver);
-}
-
-static void __exit fs_cleanup(void)
-{
-	platform_driver_unregister(&fs_enet_driver);
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void fs_enet_netpoll(struct net_device *dev)
 {
@@ -1190,7 +1180,4 @@ static void fs_enet_netpoll(struct net_device *de=
v)
 }
 #endif
=20
-/*********************************************************************=
*****************/
-
-module_init(fs_init);
-module_exit(fs_cleanup);
+module_platform_driver(fs_enet_driver);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/dri=
vers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index b09270b..2f96019 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -232,15 +232,4 @@ static struct platform_driver fs_enet_bb_mdio_driv=
er =3D {
 	.remove =3D fs_enet_mdio_remove,
 };
=20
-static int fs_enet_mdio_bb_init(void)
-{
-	return platform_driver_register(&fs_enet_bb_mdio_driver);
-}
-
-static void fs_enet_mdio_bb_exit(void)
-{
-	platform_driver_unregister(&fs_enet_bb_mdio_driver);
-}
-
-module_init(fs_enet_mdio_bb_init);
-module_exit(fs_enet_mdio_bb_exit);
+module_platform_driver(fs_enet_bb_mdio_driver);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers=
/net/ethernet/freescale/fs_enet/mii-fec.c
index e0e9d6c..55bb867 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -237,15 +237,4 @@ static struct platform_driver fs_enet_fec_mdio_dri=
ver =3D {
 	.remove =3D fs_enet_mdio_remove,
 };
=20
-static int fs_enet_mdio_fec_init(void)
-{
-	return platform_driver_register(&fs_enet_fec_mdio_driver);
-}
-
-static void fs_enet_mdio_fec_exit(void)
-{
-	platform_driver_unregister(&fs_enet_fec_mdio_driver);
-}
-
-module_init(fs_enet_mdio_fec_init);
-module_exit(fs_enet_mdio_fec_exit);
+module_platform_driver(fs_enet_fec_mdio_driver);
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net=
/ethernet/freescale/fsl_pq_mdio.c
index 8dee1ae..f109602 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -443,15 +443,6 @@ static struct platform_driver fsl_pq_mdio_driver =3D=
 {
 	.remove =3D fsl_pq_mdio_remove,
 };
=20
-int __init fsl_pq_mdio_init(void)
-{
-	return platform_driver_register(&fsl_pq_mdio_driver);
-}
-module_init(fsl_pq_mdio_init);
+module_platform_driver(fsl_pq_mdio_driver);
=20
-void fsl_pq_mdio_exit(void)
-{
-	platform_driver_unregister(&fsl_pq_mdio_driver);
-}
-module_exit(fsl_pq_mdio_exit);
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/eth=
ernet/freescale/gianfar.c
index 8e21ceb..e01cdaa 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3281,16 +3281,4 @@ static struct platform_driver gfar_driver =3D {
 	.remove =3D gfar_remove,
 };
=20
-static int __init gfar_init(void)
-{
-	return platform_driver_register(&gfar_driver);
-}
-
-static void __exit gfar_exit(void)
-{
-	platform_driver_unregister(&gfar_driver);
-}
-
-module_init(gfar_init);
-module_exit(gfar_exit);
-
+module_platform_driver(gfar_driver);
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net=
/ethernet/freescale/gianfar_ptp.c
index f67b8ae..83e0ed7 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -562,21 +562,7 @@ static struct platform_driver gianfar_ptp_driver =3D=
 {
 	.remove      =3D gianfar_ptp_remove,
 };
=20
-/* module operations */
-
-static int __init ptp_gianfar_init(void)
-{
-	return platform_driver_register(&gianfar_ptp_driver);
-}
-
-module_init(ptp_gianfar_init);
-
-static void __exit ptp_gianfar_exit(void)
-{
-	platform_driver_unregister(&gianfar_ptp_driver);
-}
-
-module_exit(ptp_gianfar_exit);
+module_platform_driver(gianfar_ptp_driver);
=20
 MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
 MODULE_DESCRIPTION("PTP clock using the eTSEC");
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korin=
a.c
index d8430f4..6ad094f 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1230,18 +1230,7 @@ static struct platform_driver korina_driver =3D =
{
 	.remove =3D korina_remove,
 };
=20
-static int __init korina_init_module(void)
-{
-	return platform_driver_register(&korina_driver);
-}
-
-static void korina_cleanup_module(void)
-{
-	return platform_driver_unregister(&korina_driver);
-}
-
-module_init(korina_init_module);
-module_exit(korina_cleanup_module);
+module_platform_driver(korina_driver);
=20
 MODULE_AUTHOR("Philip Rischel <rischelp@idt.com>");
 MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/et=
hernet/marvell/pxa168_eth.c
index d17d062..5ec409e 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1645,18 +1645,7 @@ static struct platform_driver pxa168_eth_driver =
=3D {
 		   },
 };
=20
-static int __init pxa168_init_module(void)
-{
-	return platform_driver_register(&pxa168_eth_driver);
-}
-
-static void __exit pxa168_cleanup_module(void)
-{
-	platform_driver_unregister(&pxa168_eth_driver);
-}
-
-module_init(pxa168_init_module);
-module_exit(pxa168_cleanup_module);
+module_platform_driver(pxa168_eth_driver);
=20
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Ethernet driver for Marvell PXA168");
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/etherne=
t/micrel/ks8842.c
index de9f2e2..0a85690 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1264,18 +1264,7 @@ static struct platform_driver ks8842_platform_dr=
iver =3D {
 	.remove		=3D ks8842_remove,
 };
=20
-static int __init ks8842_init(void)
-{
-	return platform_driver_register(&ks8842_platform_driver);
-}
-
-static void __exit ks8842_exit(void)
-{
-	platform_driver_unregister(&ks8842_platform_driver);
-}
-
-module_init(ks8842_init);
-module_exit(ks8842_exit);
+module_platform_driver(ks8842_platform_driver);
=20
 MODULE_DESCRIPTION("Timberdale KS8842 ethernet driver");
 MODULE_AUTHOR("Mocean Laboratories <info@mocean-labs.com>");
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/eth=
ernet/micrel/ks8851_mll.c
index 228c5c0..e58e78e 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1658,18 +1658,7 @@ static struct platform_driver ks8851_platform_dr=
iver =3D {
 	.remove =3D __devexit_p(ks8851_remove),
 };
=20
-static int __init ks8851_init(void)
-{
-	return platform_driver_register(&ks8851_platform_driver);
-}
-
-static void __exit ks8851_exit(void)
-{
-	platform_driver_unregister(&ks8851_platform_driver);
-}
-
-module_init(ks8851_init);
-module_exit(ks8851_exit);
+module_platform_driver(ks8851_platform_driver);
=20
 MODULE_DESCRIPTION("KS8851 MLL Network driver");
 MODULE_AUTHOR("David Choi <david.choi@micrel.com>");
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/eth=
ernet/natsemi/jazzsonic.c
index fc7c6a9..5b89fd3 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -294,15 +294,4 @@ static struct platform_driver jazz_sonic_driver =3D=
 {
 	},
 };
=20
-static int __init jazz_sonic_init_module(void)
-{
-	return platform_driver_register(&jazz_sonic_driver);
-}
-
-static void __exit jazz_sonic_cleanup_module(void)
-{
-	platform_driver_unregister(&jazz_sonic_driver);
-}
-
-module_init(jazz_sonic_init_module);
-module_exit(jazz_sonic_cleanup_module);
+module_platform_driver(jazz_sonic_driver);
diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethe=
rnet/natsemi/macsonic.c
index a2eacbf..70367d7 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -643,15 +643,4 @@ static struct platform_driver mac_sonic_driver =3D=
 {
 	},
 };
=20
-static int __init mac_sonic_init_module(void)
-{
-	return platform_driver_register(&mac_sonic_driver);
-}
-
-static void __exit mac_sonic_cleanup_module(void)
-{
-	platform_driver_unregister(&mac_sonic_driver);
-}
-
-module_init(mac_sonic_init_module);
-module_exit(mac_sonic_cleanup_module);
+module_platform_driver(mac_sonic_driver);
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ether=
net/natsemi/xtsonic.c
index ccf61b9..e01c0a0 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -319,15 +319,4 @@ static struct platform_driver xtsonic_driver =3D {
 	},
 };
=20
-static int __init xtsonic_init(void)
-{
-	return platform_driver_register(&xtsonic_driver);
-}
-
-static void __exit xtsonic_cleanup(void)
-{
-	platform_driver_unregister(&xtsonic_driver);
-}
-
-module_init(xtsonic_init);
-module_exit(xtsonic_cleanup);
+module_platform_driver(xtsonic_driver);
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net=
/ethernet/nuvoton/w90p910_ether.c
index f1bfb8f..b75a049 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -1103,18 +1103,7 @@ static struct platform_driver w90p910_ether_driv=
er =3D {
 	},
 };
=20
-static int __init w90p910_ether_init(void)
-{
-	return platform_driver_register(&w90p910_ether_driver);
-}
-
-static void __exit w90p910_ether_exit(void)
-{
-	platform_driver_unregister(&w90p910_ether_driver);
-}
-
-module_init(w90p910_ether_init);
-module_exit(w90p910_ether_exit);
+module_platform_driver(w90p910_ether_driver);
=20
 MODULE_AUTHOR("Wan ZongShun <mcuos.com@gmail.com>");
 MODULE_DESCRIPTION("w90p910 MAC driver!");
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethern=
et/renesas/sh_eth.c
index 9b23074..ebfb682 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1957,18 +1957,7 @@ static struct platform_driver sh_eth_driver =3D =
{
 	},
 };
=20
-static int __init sh_eth_init(void)
-{
-	return platform_driver_register(&sh_eth_driver);
-}
-
-static void __exit sh_eth_cleanup(void)
-{
-	platform_driver_unregister(&sh_eth_driver);
-}
-
-module_init(sh_eth_init);
-module_exit(sh_eth_cleanup);
+module_platform_driver(sh_eth_driver);
=20
 MODULE_AUTHOR("Nobuhiro Iwamatsu, Yoshihiro Shimoda");
 MODULE_DESCRIPTION("Renesas SuperH Ethernet driver");
diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet=
/seeq/sgiseeq.c
index c3673f1..f955a19 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -834,23 +834,7 @@ static struct platform_driver sgiseeq_driver =3D {
 	}
 };
=20
-static int __init sgiseeq_module_init(void)
-{
-	if (platform_driver_register(&sgiseeq_driver)) {
-		printk(KERN_ERR "Driver registration failed\n");
-		return -ENODEV;
-	}
-
-	return 0;
-}
-
-static void __exit sgiseeq_module_exit(void)
-{
-	platform_driver_unregister(&sgiseeq_driver);
-}
-
-module_init(sgiseeq_module_init);
-module_exit(sgiseeq_module_exit);
+module_platform_driver(sgiseeq_driver);
=20
 MODULE_DESCRIPTION("SGI Seeq 8003 driver");
 MODULE_AUTHOR("Linux/MIPS Mailing List <linux-mips@linux-mips.org>");
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi=
/meth.c
index 60135aa..f98c6c6 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -830,24 +830,7 @@ static struct platform_driver meth_driver =3D {
 	}
 };
=20
-static int __init meth_init_module(void)
-{
-	int err;
-
-	err =3D platform_driver_register(&meth_driver);
-	if (err)
-		printk(KERN_ERR "Driver registration failed\n");
-
-	return err;
-}
-
-static void __exit meth_exit_module(void)
-{
-	platform_driver_unregister(&meth_driver);
-}
-
-module_init(meth_init_module);
-module_exit(meth_exit_module);
+module_platform_driver(meth_driver);
=20
 MODULE_AUTHOR("Ilya Volynets <ilya@theIlya.com>");
 MODULE_DESCRIPTION("SGI O2 Builtin Fast Ethernet driver");
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet=
/smsc/smc911x.c
index 8f61fe9..313ba3b 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -2196,15 +2196,4 @@ static struct platform_driver smc911x_driver =3D=
 {
 	},
 };
=20
-static int __init smc911x_init(void)
-{
-	return platform_driver_register(&smc911x_driver);
-}
-
-static void __exit smc911x_cleanup(void)
-{
-	platform_driver_unregister(&smc911x_driver);
-}
-
-module_init(smc911x_init);
-module_exit(smc911x_cleanup);
+module_platform_driver(smc911x_driver);
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/=
smsc/smc91x.c
index f47f81e..64ad3ed 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2417,15 +2417,4 @@ static struct platform_driver smc_driver =3D {
 	},
 };
=20
-static int __init smc_init(void)
-{
-	return platform_driver_register(&smc_driver);
-}
-
-static void __exit smc_cleanup(void)
-{
-	platform_driver_unregister(&smc_driver);
-}
-
-module_init(smc_init);
-module_exit(smc_cleanup);
+module_platform_driver(smc_driver);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
index 20e8267..24c2bf6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2131,27 +2131,6 @@ static struct platform_driver stmmac_driver =3D =
{
 	},
 };
=20
-/**
- * stmmac_init_module - Entry point for the driver
- * Description: This function is the entry point for the driver.
- */
-static int __init stmmac_init_module(void)
-{
-	int ret;
-
-	ret =3D platform_driver_register(&stmmac_driver);
-	return ret;
-}
-
-/**
- * stmmac_cleanup_module - Cleanup routine for the driver
- * Description: This function is the cleanup routine for the driver.
- */
-static void __exit stmmac_cleanup_module(void)
-{
-	platform_driver_unregister(&stmmac_driver);
-}
-
 #ifndef MODULE
 static int __init stmmac_cmdline_opt(char *str)
 {
@@ -2211,8 +2190,7 @@ err:
 __setup("stmmaceth=3D", stmmac_cmdline_opt);
 #endif
=20
-module_init(stmmac_init_module);
-module_exit(stmmac_cleanup_module);
+module_platform_driver(stmmac_driver);
=20
 MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet driver");
 MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/=
sun/sunbmac.c
index 0d8cfd9..220f724 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1293,15 +1293,4 @@ static struct platform_driver bigmac_sbus_driver=
 =3D {
 	.remove		=3D __devexit_p(bigmac_sbus_remove),
 };
=20
-static int __init bigmac_init(void)
-{
-	return platform_driver_register(&bigmac_sbus_driver);
-}
-
-static void __exit bigmac_exit(void)
-{
-	platform_driver_unregister(&bigmac_sbus_driver);
-}
-
-module_init(bigmac_init);
-module_exit(bigmac_exit);
+module_platform_driver(bigmac_sbus_driver);
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/eth=
ernet/tundra/tsi108_eth.c
index a8df7ec..a9ce01ba 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1688,18 +1688,6 @@ static void tsi108_timed_checker(unsigned long d=
ev_ptr)
 	mod_timer(&data->timer, jiffies + CHECK_PHY_INTERVAL);
 }
=20
-static int tsi108_ether_init(void)
-{
-	int ret;
-	ret =3D platform_driver_register (&tsi_eth_driver);
-	if (ret < 0){
-		printk("tsi108_ether_init: error initializing ethernet "
-		       "device\n");
-		return ret;
-	}
-	return 0;
-}
-
 static int tsi108_ether_remove(struct platform_device *pdev)
 {
 	struct net_device *dev =3D platform_get_drvdata(pdev);
@@ -1714,13 +1702,7 @@ static int tsi108_ether_remove(struct platform_d=
evice *pdev)
=20
 	return 0;
 }
-static void tsi108_ether_exit(void)
-{
-	platform_driver_unregister(&tsi_eth_driver);
-}
-
-module_init(tsi108_ether_init);
-module_exit(tsi108_ether_exit);
+module_platform_driver(tsi_eth_driver);
=20
 MODULE_AUTHOR("Tundra Semiconductor Corporation");
 MODULE_DESCRIPTION("Tsi108 Gigabit Ethernet driver");
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/=
ethernet/xilinx/ll_temac_main.c
index 1ade9e1..282330d 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1181,17 +1181,7 @@ static struct platform_driver temac_of_driver =3D=
 {
 	},
 };
=20
-static int __init temac_init(void)
-{
-	return platform_driver_register(&temac_of_driver);
-}
-module_init(temac_init);
-
-static void __exit temac_exit(void)
-{
-	platform_driver_unregister(&temac_of_driver);
-}
-module_exit(temac_exit);
+module_platform_driver(temac_of_driver);
=20
 MODULE_DESCRIPTION("Xilinx LL_TEMAC Ethernet driver");
 MODULE_AUTHOR("Yoshio Kashiwagi");
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/ne=
t/ethernet/xilinx/xilinx_emaclite.c
index 8018d7d..dca6541 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1303,27 +1303,7 @@ static struct platform_driver xemaclite_of_drive=
r =3D {
 	.remove		=3D __devexit_p(xemaclite_of_remove),
 };
=20
-/**
- * xgpiopss_init - Initial driver registration call
- *
- * Return:	0 upon success, or a negative error upon failure.
- */
-static int __init xemaclite_init(void)
-{
-	/* No kernel boot options used, we just need to register the driver *=
/
-	return platform_driver_register(&xemaclite_of_driver);
-}
-
-/**
- * xemaclite_cleanup - Driver un-registration call
- */
-static void __exit xemaclite_cleanup(void)
-{
-	platform_driver_unregister(&xemaclite_of_driver);
-}
-
-module_init(xemaclite_init);
-module_exit(xemaclite_cleanup);
+module_platform_driver(xemaclite_of_driver);
=20
 MODULE_AUTHOR("Xilinx, Inc.");
 MODULE_DESCRIPTION("Xilinx Ethernet MAC Lite driver");
--=20
1.7.5.4
