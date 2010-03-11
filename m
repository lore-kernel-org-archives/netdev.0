From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 13/27] drivers/net/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:23:00 -0700
Message-ID: <20100311182259.13103.87535.stgit__21567.1228048906$1268332884$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52515 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934155Ab0CKSXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:23:13 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/can/mscan/mpc5xxx_can.c           |    8 +++++---
 drivers/net/can/sja1000/sja1000_of_platform.c |    8 +++++---
 drivers/net/ehea/ehea_main.c                  |    7 +++++--
 drivers/net/fs_enet/fs_enet-main.c            |    7 +++++--
 drivers/net/fs_enet/mii-bitbang.c             |    7 +++++--
 drivers/net/fs_enet/mii-fec.c                 |    7 +++++--
 drivers/net/fsl_pq_mdio.c                     |    7 +++++--
 drivers/net/gianfar.c                         |   10 ++++++----
 drivers/net/ibm_newemac/core.c                |    8 +++++---
 drivers/net/ibm_newemac/mal.c                 |    8 +++++---
 drivers/net/ibm_newemac/rgmii.c               |    8 +++++---
 drivers/net/ibm_newemac/tah.c                 |    8 +++++---
 drivers/net/ibm_newemac/zmii.c                |    8 +++++---
 drivers/net/ll_temac_main.c                   |    2 +-
 drivers/net/myri_sbus.c                       |    7 +++++--
 drivers/net/niu.c                             |    7 +++++--
 drivers/net/phy/mdio-gpio.c                   |    7 +++++--
 drivers/net/sunbmac.c                         |    7 +++++--
 drivers/net/sunhme.c                          |    7 +++++--
 drivers/net/sunlance.c                        |    7 +++++--
 drivers/net/sunqe.c                           |    7 +++++--
 drivers/net/ucc_geth.c                        |    7 +++++--
 drivers/net/xilinx_emaclite.c                 |    7 +++++--
 23 files changed, 112 insertions(+), 54 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 03e7c48..2120784 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -393,15 +393,17 @@ static struct of_device_id __devinitdata mpc5xxx_can_table[] = {
 };
 
 static struct of_platform_driver mpc5xxx_can_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc5xxx_can",
+	.driver = {
+		.name = "mpc5xxx_can",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc5xxx_can_table,
+	},
 	.probe = mpc5xxx_can_probe,
 	.remove = __devexit_p(mpc5xxx_can_remove),
 #ifdef CONFIG_PM
 	.suspend = mpc5xxx_can_suspend,
 	.resume = mpc5xxx_can_resume,
 #endif
-	.match_table = mpc5xxx_can_table,
 };
 
 static int __init mpc5xxx_can_init(void)
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index dc5f20c..158b76e 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -216,11 +216,13 @@ static struct of_device_id __devinitdata sja1000_ofp_table[] = {
 MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
 
 static struct of_platform_driver sja1000_ofp_driver = {
-	.owner = THIS_MODULE,
-	.name = DRV_NAME,
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = DRV_NAME,
+		.of_match_table = sja1000_ofp_table,
+	},
 	.probe = sja1000_ofp_probe,
 	.remove = __devexit_p(sja1000_ofp_remove),
-	.match_table = sja1000_ofp_table,
 };
 
 static int __init sja1000_ofp_init(void)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 3cdc938..08324e2 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -121,8 +121,11 @@ static struct of_device_id ehea_device_table[] = {
 MODULE_DEVICE_TABLE(of, ehea_device_table);
 
 static struct of_platform_driver ehea_driver = {
-	.name = "ehea",
-	.match_table = ehea_device_table,
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = "ehea",
+		.of_match_table = ehea_device_table,
+	},
 	.probe = ehea_probe_adapter,
 	.remove = ehea_remove,
 };
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 0770e2f..3e134de 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1158,8 +1158,11 @@ static struct of_device_id fs_enet_match[] = {
 MODULE_DEVICE_TABLE(of, fs_enet_match);
 
 static struct of_platform_driver fs_enet_driver = {
-	.name	= "fs_enet",
-	.match_table = fs_enet_match,
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = "fs_enet",
+		.of_match_table = fs_enet_match,
+	},
 	.probe = fs_enet_probe,
 	.remove = fs_enet_remove,
 };
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 24ff9f4..a0afd0e 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -224,8 +224,11 @@ static struct of_device_id fs_enet_mdio_bb_match[] = {
 MODULE_DEVICE_TABLE(of, fs_enet_mdio_bb_match);
 
 static struct of_platform_driver fs_enet_bb_mdio_driver = {
-	.name = "fsl-bb-mdio",
-	.match_table = fs_enet_mdio_bb_match,
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = "fsl-bb-mdio",
+		.of_match_table = fs_enet_mdio_bb_match,
+	},
 	.probe = fs_enet_mdio_probe,
 	.remove = fs_enet_mdio_remove,
 };
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 5944b65..388c6ee 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -222,8 +222,11 @@ static struct of_device_id fs_enet_mdio_fec_match[] = {
 MODULE_DEVICE_TABLE(of, fs_enet_mdio_fec_match);
 
 static struct of_platform_driver fs_enet_fec_mdio_driver = {
-	.name = "fsl-fec-mdio",
-	.match_table = fs_enet_mdio_fec_match,
+	.driver = {
+		.name = "fsl-fec-mdio",
+		.owner = THIS_MODULE,
+		.of_match_table = fs_enet_mdio_fec_match,
+	},
 	.probe = fs_enet_mdio_probe,
 	.remove = fs_enet_mdio_remove,
 };
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d5160ed..14b84be 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -461,10 +461,13 @@ static struct of_device_id fsl_pq_mdio_match[] = {
 MODULE_DEVICE_TABLE(of, fsl_pq_mdio_match);
 
 static struct of_platform_driver fsl_pq_mdio_driver = {
-	.name = "fsl-pq_mdio",
+	.driver = {
+		.name = "fsl-pq_mdio",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_pq_mdio_match,
+	},
 	.probe = fsl_pq_mdio_probe,
 	.remove = fsl_pq_mdio_remove,
-	.match_table = fsl_pq_mdio_match,
 };
 
 int __init fsl_pq_mdio_init(void)
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 61a7b43..9e986f3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -3050,14 +3050,16 @@ MODULE_DEVICE_TABLE(of, gfar_match);
 
 /* Structure for a device driver */
 static struct of_platform_driver gfar_driver = {
-	.name = "fsl-gianfar",
-	.match_table = gfar_match,
-
+	.driver = {
+		.name = "fsl-gianfar",
+		.owner = THIS_MODULE,
+		.pm = GFAR_PM_OPS,
+		.of_match_table = gfar_match,
+	},
 	.probe = gfar_probe,
 	.remove = gfar_remove,
 	.suspend = gfar_legacy_suspend,
 	.resume = gfar_legacy_resume,
-	.driver.pm = GFAR_PM_OPS,
 };
 
 static int __init gfar_init(void)
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index bad72ba..19b9e60 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2995,9 +2995,11 @@ static struct of_device_id emac_match[] =
 MODULE_DEVICE_TABLE(of, emac_match);
 
 static struct of_platform_driver emac_driver = {
-	.name = "emac",
-	.match_table = emac_match,
-
+	.driver = {
+		.name = "emac",
+		.owner = THIS_MODULE,
+		.of_match_table = emac_match,
+	},
 	.probe = emac_probe,
 	.remove = emac_remove,
 };
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 29ed695..dad3572 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -789,9 +789,11 @@ static struct of_device_id mal_platform_match[] =
 };
 
 static struct of_platform_driver mal_of_driver = {
-	.name = "mcmal",
-	.match_table = mal_platform_match,
-
+	.driver = {
+		.name = "mcmal",
+		.owner = THIS_MODULE,
+		.of_match_table = mal_platform_match,
+	},
 	.probe = mal_probe,
 	.remove = mal_remove,
 };
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ibm_newemac/rgmii.c
index 57fc784..666d4f4 100644
--- a/drivers/net/ibm_newemac/rgmii.c
+++ b/drivers/net/ibm_newemac/rgmii.c
@@ -318,9 +318,11 @@ static struct of_device_id rgmii_match[] =
 };
 
 static struct of_platform_driver rgmii_driver = {
-	.name = "emac-rgmii",
-	.match_table = rgmii_match,
-
+	.driver = {
+		.name = "emac-rgmii",
+		.owner = THIS_MODULE,
+		.of_match_table = rgmii_match,
+	},
 	.probe = rgmii_probe,
 	.remove = rgmii_remove,
 };
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ibm_newemac/tah.c
index 4f64b00..0446371 100644
--- a/drivers/net/ibm_newemac/tah.c
+++ b/drivers/net/ibm_newemac/tah.c
@@ -166,9 +166,11 @@ static struct of_device_id tah_match[] =
 };
 
 static struct of_platform_driver tah_driver = {
-	.name = "emac-tah",
-	.match_table = tah_match,
-
+	.driver = {
+		.name = "emac-tah",
+		.owner = THIS_MODULE,
+		.of_match_table = tah_match,
+	},
 	.probe = tah_probe,
 	.remove = tah_remove,
 };
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ibm_newemac/zmii.c
index 724e00e..c9e7eb7 100644
--- a/drivers/net/ibm_newemac/zmii.c
+++ b/drivers/net/ibm_newemac/zmii.c
@@ -312,9 +312,11 @@ static struct of_device_id zmii_match[] =
 };
 
 static struct of_platform_driver zmii_driver = {
-	.name = "emac-zmii",
-	.match_table = zmii_match,
-
+	.driver = {
+		.name = "emac-zmii",
+		.owner = THIS_MODULE,
+		.of_match_table = zmii_match,
+	},
 	.probe = zmii_probe,
 	.remove = zmii_remove,
 };
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index a18e348..849d3cc 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -954,12 +954,12 @@ static struct of_device_id temac_of_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, temac_of_match);
 
 static struct of_platform_driver temac_of_driver = {
-	.match_table = temac_of_match,
 	.probe = temac_of_probe,
 	.remove = __devexit_p(temac_of_remove),
 	.driver = {
 		.owner = THIS_MODULE,
 		.name = "xilinx_temac",
+		.of_match_table = temac_of_match,
 	},
 };
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index be4e6e4..955e032 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1161,8 +1161,11 @@ static const struct of_device_id myri_sbus_match[] = {
 MODULE_DEVICE_TABLE(of, myri_sbus_match);
 
 static struct of_platform_driver myri_sbus_driver = {
-	.name		= "myri",
-	.match_table	= myri_sbus_match,
+	.driver = {
+		.name = "myri",
+		.owner = THIS_MODULE,
+		.of_match_table = myri_sbus_match,
+	},
 	.probe		= myri_sbus_probe,
 	.remove		= __devexit_p(myri_sbus_remove),
 };
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1fcf1ac..cc0323b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -10206,8 +10206,11 @@ static const struct of_device_id niu_match[] = {
 MODULE_DEVICE_TABLE(of, niu_match);
 
 static struct of_platform_driver niu_of_driver = {
-	.name		= "niu",
-	.match_table	= niu_match,
+	.driver = {
+		.name = "niu",
+		.owner = THIS_MODULE,
+		.of_match_table = niu_match,
+	},
 	.probe		= niu_of_probe,
 	.remove		= __devexit_p(niu_of_remove),
 };
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 641973c..fc5fef2 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -241,8 +241,11 @@ static struct of_device_id mdio_ofgpio_match[] = {
 MODULE_DEVICE_TABLE(of, mdio_ofgpio_match);
 
 static struct of_platform_driver mdio_ofgpio_driver = {
-	.name = "mdio-gpio",
-	.match_table = mdio_ofgpio_match,
+	.driver = {
+		.name = "mdio-gpio",
+		.owner = THIS_MODULE,
+		.of_match_table = mdio_ofgpio_match,
+	},
 	.probe = mdio_ofgpio_probe,
 	.remove = __devexit_p(mdio_ofgpio_remove),
 };
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 9b6aa7c..de9d92b 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1292,8 +1292,11 @@ static const struct of_device_id bigmac_sbus_match[] = {
 MODULE_DEVICE_TABLE(of, bigmac_sbus_match);
 
 static struct of_platform_driver bigmac_sbus_driver = {
-	.name		= "sunbmac",
-	.match_table	= bigmac_sbus_match,
+	.driver = {
+		.name = "sunbmac",
+		.owner = THIS_MODULE,
+		.of_match_table = bigmac_sbus_match,
+	},
 	.probe		= bigmac_sbus_probe,
 	.remove		= __devexit_p(bigmac_sbus_remove),
 };
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index c6463f7..ad2cfc5 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3295,8 +3295,11 @@ static const struct of_device_id hme_sbus_match[] = {
 MODULE_DEVICE_TABLE(of, hme_sbus_match);
 
 static struct of_platform_driver hme_sbus_driver = {
-	.name		= "hme",
-	.match_table	= hme_sbus_match,
+	.driver = {
+		.name = "hme",
+		.owner = THIS_MODULE,
+		.of_match_table = hme_sbus_match,
+	},
 	.probe		= hme_sbus_probe,
 	.remove		= __devexit_p(hme_sbus_remove),
 };
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index a139861..79e1096 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1546,8 +1546,11 @@ static const struct of_device_id sunlance_sbus_match[] = {
 MODULE_DEVICE_TABLE(of, sunlance_sbus_match);
 
 static struct of_platform_driver sunlance_sbus_driver = {
-	.name		= "sunlance",
-	.match_table	= sunlance_sbus_match,
+	.driver = {
+		.name = "sunlance",
+		.owner = THIS_MODULE,
+		.of_match_table = sunlance_sbus_match,
+	},
 	.probe		= sunlance_sbus_probe,
 	.remove		= __devexit_p(sunlance_sbus_remove),
 };
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 9864f4f..8fe86b2 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -978,8 +978,11 @@ static const struct of_device_id qec_sbus_match[] = {
 MODULE_DEVICE_TABLE(of, qec_sbus_match);
 
 static struct of_platform_driver qec_sbus_driver = {
-	.name		= "qec",
-	.match_table	= qec_sbus_match,
+	.driver = {
+		.name = "qec",
+		.owner = THIS_MODULE,
+		.of_match_table = qec_sbus_match,
+	},
 	.probe		= qec_sbus_probe,
 	.remove		= __devexit_p(qec_sbus_remove),
 };
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 23a9751..056719f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3965,8 +3965,11 @@ static struct of_device_id ucc_geth_match[] = {
 MODULE_DEVICE_TABLE(of, ucc_geth_match);
 
 static struct of_platform_driver ucc_geth_driver = {
-	.name		= DRV_NAME,
-	.match_table	= ucc_geth_match,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = ucc_geth_match,
+	},
 	.probe		= ucc_geth_probe,
 	.remove		= ucc_geth_remove,
 	.suspend	= ucc_geth_suspend,
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 40b8fdc..54912ff 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -1292,8 +1292,11 @@ static struct of_device_id xemaclite_of_match[] __devinitdata = {
 MODULE_DEVICE_TABLE(of, xemaclite_of_match);
 
 static struct of_platform_driver xemaclite_of_driver = {
-	.name		= DRIVER_NAME,
-	.match_table	= xemaclite_of_match,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = xemaclite_of_match,
+	},
 	.probe		= xemaclite_of_probe,
 	.remove		= __devexit_p(xemaclite_of_remove),
 };

