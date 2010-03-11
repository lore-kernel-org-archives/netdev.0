From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 25/27] arch/powerpc/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:24:06 -0700
Message-ID: <20100311182405.13103.14199.stgit__11810.5330774144$1268331962$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:49500 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934268Ab0CKSYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:24:09 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/kernel/of_platform.c             |    3 ++-
 arch/powerpc/platforms/52xx/mpc52xx_gpio.c    |   14 ++++++++----
 arch/powerpc/platforms/52xx/mpc52xx_gpt.c     |    7 ++++--
 arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c |    8 ++++---
 arch/powerpc/platforms/82xx/ep8248e.c         |    3 ++-
 arch/powerpc/platforms/83xx/suspend.c         |    7 ++++--
 arch/powerpc/platforms/cell/axon_msi.c        |    7 +++---
 arch/powerpc/platforms/pasemi/gpio_mdio.c     |    7 +++---
 arch/powerpc/sysdev/axonram.c                 |    8 +++----
 arch/powerpc/sysdev/bestcomm/bestcomm.c       |   10 +++-----
 arch/powerpc/sysdev/fsl_msi.c                 |    7 ++++--
 arch/powerpc/sysdev/fsl_pmc.c                 |    7 ++++--
 arch/powerpc/sysdev/fsl_rio.c                 |    7 ++++--
 arch/powerpc/sysdev/pmi.c                     |    7 +++---
 arch/powerpc/sysdev/qe_lib/qe.c               |    7 ++++--
 drivers/dma/fsldma.c                          |   13 +++++++----
 drivers/dma/ppc4xx/adma.c                     |    2 +-
 drivers/edac/mpc85xx_edac.c                   |   30 ++++++++++---------------
 drivers/edac/ppc4xx_edac.c                    |   10 ++++----
 19 files changed, 95 insertions(+), 69 deletions(-)

diff --git a/arch/powerpc/kernel/of_platform.c b/arch/powerpc/kernel/of_platform.c
index e047126..c08eb85 100644
--- a/arch/powerpc/kernel/of_platform.c
+++ b/arch/powerpc/kernel/of_platform.c
@@ -307,10 +307,11 @@ static struct of_device_id of_pci_phb_ids[] = {
 };
 
 static struct of_platform_driver of_pci_phb_driver = {
-	.match_table = of_pci_phb_ids,
 	.probe = of_pci_phb_probe,
 	.driver = {
 		.name = "of-pci",
+		.owner = THIS_MODULE,
+		.of_match_table = of_pci_phb_ids,
 	},
 };
 
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_gpio.c b/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
index fce30e2..8f65de0 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
@@ -192,8 +192,11 @@ static const struct of_device_id mpc52xx_wkup_gpiochip_match[] = {
 };
 
 static struct of_platform_driver mpc52xx_wkup_gpiochip_driver = {
-	.name = "gpio_wkup",
-	.match_table = mpc52xx_wkup_gpiochip_match,
+	.driver = {
+		.name = "gpio_wkup",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_wkup_gpiochip_match,
+	},
 	.probe = mpc52xx_wkup_gpiochip_probe,
 	.remove = mpc52xx_gpiochip_remove,
 };
@@ -348,8 +351,11 @@ static const struct of_device_id mpc52xx_simple_gpiochip_match[] = {
 };
 
 static struct of_platform_driver mpc52xx_simple_gpiochip_driver = {
-	.name = "gpio",
-	.match_table = mpc52xx_simple_gpiochip_match,
+	.driver = {
+		.name = "gpio",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_simple_gpiochip_match,
+	},
 	.probe = mpc52xx_simple_gpiochip_probe,
 	.remove = mpc52xx_gpiochip_remove,
 };
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_gpt.c b/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
index a34bffa..59a58e9 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
@@ -779,8 +779,11 @@ static const struct of_device_id mpc52xx_gpt_match[] = {
 };
 
 static struct of_platform_driver mpc52xx_gpt_driver = {
-	.name = "mpc52xx-gpt",
-	.match_table = mpc52xx_gpt_match,
+	.driver = {
+		.name = "mpc52xx-gpt",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_gpt_match,
+	},
 	.probe = mpc52xx_gpt_probe,
 	.remove = mpc52xx_gpt_remove,
 };
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c b/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
index 046d314..35baf0f 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
@@ -535,9 +535,11 @@ static struct of_device_id mpc52xx_lpbfifo_match[] __devinitconst = {
 };
 
 static struct of_platform_driver mpc52xx_lpbfifo_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc52xx-lpbfifo",
-	.match_table = mpc52xx_lpbfifo_match,
+	.driver = {
+		.name = "mpc52xx-lpbfifo",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_lpbfifo_match,
+	},
 	.probe = mpc52xx_lpbfifo_probe,
 	.remove = __devexit_p(mpc52xx_lpbfifo_remove),
 };
diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index 3848500..3d1b718 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -169,8 +169,9 @@ static const struct of_device_id ep8248e_mdio_match[] = {
 static struct of_platform_driver ep8248e_mdio_driver = {
 	.driver = {
 		.name = "ep8248e-mdio-bitbang",
+		.owner = THIS_MODULE,
+		.of_match_table = ep8248e_mdio_match,
 	},
-	.match_table = ep8248e_mdio_match,
 	.probe = ep8248e_mdio_probe,
 	.remove = ep8248e_mdio_remove,
 };
diff --git a/arch/powerpc/platforms/83xx/suspend.c b/arch/powerpc/platforms/83xx/suspend.c
index aa0b764..ebe6c35 100644
--- a/arch/powerpc/platforms/83xx/suspend.c
+++ b/arch/powerpc/platforms/83xx/suspend.c
@@ -423,8 +423,11 @@ static struct of_device_id pmc_match[] = {
 };
 
 static struct of_platform_driver pmc_driver = {
-	.name = "mpc83xx-pmc",
-	.match_table = pmc_match,
+	.driver = {
+		.name = "mpc83xx-pmc",
+		.owner = THIS_MODULE,
+		.of_match_table = pmc_match,
+	},
 	.probe = pmc_probe,
 	.remove = pmc_remove
 };
diff --git a/arch/powerpc/platforms/cell/axon_msi.c b/arch/powerpc/platforms/cell/axon_msi.c
index e341a70..10b86f6 100644
--- a/arch/powerpc/platforms/cell/axon_msi.c
+++ b/arch/powerpc/platforms/cell/axon_msi.c
@@ -446,11 +446,12 @@ static const struct of_device_id axon_msi_device_id[] = {
 };
 
 static struct of_platform_driver axon_msi_driver = {
-	.match_table	= axon_msi_device_id,
 	.probe		= axon_msi_probe,
 	.shutdown	= axon_msi_shutdown,
-	.driver		= {
-		.name	= "axon-msi"
+	.driver = {
+		.name = "axon-msi",
+		.owner = THIS_MODULE,
+		.of_match_table = axon_msi_device_id,
 	},
 };
 
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index b7027db..4857059 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -300,11 +300,12 @@ MODULE_DEVICE_TABLE(of, gpio_mdio_match);
 
 static struct of_platform_driver gpio_mdio_driver =
 {
-	.match_table	= gpio_mdio_match,
 	.probe		= gpio_mdio_probe,
 	.remove		= gpio_mdio_remove,
-	.driver		= {
-		.name	= "gpio-mdio-bitbang",
+	.driver = {
+		.name = "gpio-mdio-bitbang",
+		.owner = THIS_MODULE,
+		.of_match_table = gpio_mdio_match,
 	},
 };
 
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 88b21fc..402d221 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -327,12 +327,12 @@ static struct of_device_id axon_ram_device_id[] = {
 };
 
 static struct of_platform_driver axon_ram_driver = {
-	.match_table	= axon_ram_device_id,
 	.probe		= axon_ram_probe,
 	.remove		= axon_ram_remove,
-	.driver		= {
-		.owner	= THIS_MODULE,
-		.name	= AXON_RAM_MODULE_NAME,
+	.driver = {
+		.name = AXON_RAM_MODULE_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = axon_ram_device_id,
 	},
 };
 
diff --git a/arch/powerpc/sysdev/bestcomm/bestcomm.c b/arch/powerpc/sysdev/bestcomm/bestcomm.c
index d32d538..a7c5c47 100644
--- a/arch/powerpc/sysdev/bestcomm/bestcomm.c
+++ b/arch/powerpc/sysdev/bestcomm/bestcomm.c
@@ -494,14 +494,12 @@ MODULE_DEVICE_TABLE(of, mpc52xx_bcom_of_match);
 
 
 static struct of_platform_driver mpc52xx_bcom_of_platform_driver = {
-	.owner		= THIS_MODULE,
-	.name		= DRIVER_NAME,
-	.match_table	= mpc52xx_bcom_of_match,
 	.probe		= mpc52xx_bcom_probe,
 	.remove		= mpc52xx_bcom_remove,
-	.driver		= {
-		.name	= DRIVER_NAME,
-		.owner	= THIS_MODULE,
+	.driver = {
+		.name = DRIVER_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table = mpc52xx_bcom_of_match,
 	},
 };
 
diff --git a/arch/powerpc/sysdev/fsl_msi.c b/arch/powerpc/sysdev/fsl_msi.c
index d17841f..7200bdd 100644
--- a/arch/powerpc/sysdev/fsl_msi.c
+++ b/arch/powerpc/sysdev/fsl_msi.c
@@ -344,8 +344,11 @@ static const struct of_device_id fsl_of_msi_ids[] = {
 };
 
 static struct of_platform_driver fsl_of_msi_driver = {
-	.name = "fsl-msi",
-	.match_table = fsl_of_msi_ids,
+	.driver = {
+		.name = "fsl-msi",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_of_msi_ids,
+	},
 	.probe = fsl_of_msi_probe,
 };
 
diff --git a/arch/powerpc/sysdev/fsl_pmc.c b/arch/powerpc/sysdev/fsl_pmc.c
index 2ebe817..9082eb9 100644
--- a/arch/powerpc/sysdev/fsl_pmc.c
+++ b/arch/powerpc/sysdev/fsl_pmc.c
@@ -76,8 +76,11 @@ static const struct of_device_id pmc_ids[] = {
 };
 
 static struct of_platform_driver pmc_driver = {
-	.driver.name = "fsl-pmc",
-	.match_table = pmc_ids,
+	.driver = {
+		.name = "fsl-pmc",
+		.owner = THIS_MODULE,
+		.of_match_table = pmc_ids,
+	},
 	.probe = pmc_probe,
 };
 
diff --git a/arch/powerpc/sysdev/fsl_rio.c b/arch/powerpc/sysdev/fsl_rio.c
index 757a83f..67f2653 100644
--- a/arch/powerpc/sysdev/fsl_rio.c
+++ b/arch/powerpc/sysdev/fsl_rio.c
@@ -1214,8 +1214,11 @@ static const struct of_device_id fsl_of_rio_rpn_ids[] = {
 };
 
 static struct of_platform_driver fsl_of_rio_rpn_driver = {
-	.name = "fsl-of-rio",
-	.match_table = fsl_of_rio_rpn_ids,
+	.driver = {
+		.name = "fsl-of-rio",
+		.owner = THIS_MODULE,
+		.of_match_table = fsl_of_rio_rpn_ids,
+	},
 	.probe = fsl_of_rio_rpn_probe,
 };
 
diff --git a/arch/powerpc/sysdev/pmi.c b/arch/powerpc/sysdev/pmi.c
index b92cb3a..738d8aa 100644
--- a/arch/powerpc/sysdev/pmi.c
+++ b/arch/powerpc/sysdev/pmi.c
@@ -205,11 +205,12 @@ static int pmi_of_remove(struct of_device *dev)
 }
 
 static struct of_platform_driver pmi_of_platform_driver = {
-	.match_table	= pmi_match,
 	.probe		= pmi_of_probe,
 	.remove		= pmi_of_remove,
-	.driver		= {
-		.name	= "pmi",
+	.driver = {
+		.name = "pmi",
+		.owner = THIS_MODULE,
+		.of_match_table = pmi_match,
 	},
 };
 
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_lib/qe.c
index 149393c..093e0ae 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -669,8 +669,11 @@ static const struct of_device_id qe_ids[] = {
 };
 
 static struct of_platform_driver qe_driver = {
-	.driver.name = "fsl-qe",
-	.match_table = qe_ids,
+	.driver = {
+		.name = "fsl-qe",
+		.owner = THIS_MODULE,
+		.of_match_table = qe_ids,
+	},
 	.probe = qe_probe,
 	.resume = qe_resume,
 };
diff --git a/drivers/dma/fsldma.c b/drivers/dma/fsldma.c
index bbb4be5..9a2a158 100644
--- a/drivers/dma/fsldma.c
+++ b/drivers/dma/fsldma.c
@@ -1407,11 +1407,14 @@ static const struct of_device_id fsldma_of_ids[] = {
 	{}
 };
 
-static struct of_platform_driver fsldma_of_driver = {
-	.name		= "fsl-elo-dma",
-	.match_table	= fsldma_of_ids,
-	.probe		= fsldma_of_probe,
-	.remove		= fsldma_of_remove,
+static struct of_platform_driver of_fsl_dma_driver = {
+	.driver = {
+		.name = "fsl-elo-dma",
+		.owner = THIS_MODULE,
+		.of_match_table = fsldma_of_ids,
+	},
+	.probe = fsldma_of_probe,
+	.remove = fsldma_of_remove,
 };
 
 /*----------------------------------------------------------------------------*/
diff --git a/drivers/dma/ppc4xx/adma.c b/drivers/dma/ppc4xx/adma.c
index e69d87f..b88f1fa 100644
--- a/drivers/dma/ppc4xx/adma.c
+++ b/drivers/dma/ppc4xx/adma.c
@@ -4948,12 +4948,12 @@ static const struct of_device_id ppc440spe_adma_of_match[] __devinitconst = {
 MODULE_DEVICE_TABLE(of, ppc440spe_adma_of_match);
 
 static struct of_platform_driver ppc440spe_adma_driver = {
-	.match_table = ppc440spe_adma_of_match,
 	.probe = ppc440spe_adma_probe,
 	.remove = __devexit_p(ppc440spe_adma_remove),
 	.driver = {
 		.name = "PPC440SP(E)-ADMA",
 		.owner = THIS_MODULE,
+		.of_match_table = ppc440spe_adma_of_match,
 	},
 };
 
diff --git a/drivers/edac/mpc85xx_edac.c b/drivers/edac/mpc85xx_edac.c
index ecd5928..4f5ad74 100644
--- a/drivers/edac/mpc85xx_edac.c
+++ b/drivers/edac/mpc85xx_edac.c
@@ -339,15 +339,13 @@ static struct of_device_id mpc85xx_pci_err_of_match[] = {
 };
 
 static struct of_platform_driver mpc85xx_pci_err_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc85xx_pci_err",
-	.match_table = mpc85xx_pci_err_of_match,
 	.probe = mpc85xx_pci_err_probe,
 	.remove = __devexit_p(mpc85xx_pci_err_remove),
 	.driver = {
-		   .name = "mpc85xx_pci_err",
-		   .owner = THIS_MODULE,
-		   },
+		.name = "mpc85xx_pci_err",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc85xx_pci_err_of_match,
+	},
 };
 
 #endif				/* CONFIG_PCI */
@@ -655,15 +653,13 @@ static struct of_device_id mpc85xx_l2_err_of_match[] = {
 };
 
 static struct of_platform_driver mpc85xx_l2_err_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc85xx_l2_err",
-	.match_table = mpc85xx_l2_err_of_match,
 	.probe = mpc85xx_l2_err_probe,
 	.remove = mpc85xx_l2_err_remove,
 	.driver = {
-		   .name = "mpc85xx_l2_err",
-		   .owner = THIS_MODULE,
-		   },
+		.name = "mpc85xx_l2_err",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc85xx_l2_err_of_match,
+	},
 };
 
 /**************************** MC Err device ***************************/
@@ -992,15 +988,13 @@ static struct of_device_id mpc85xx_mc_err_of_match[] = {
 };
 
 static struct of_platform_driver mpc85xx_mc_err_driver = {
-	.owner = THIS_MODULE,
-	.name = "mpc85xx_mc_err",
-	.match_table = mpc85xx_mc_err_of_match,
 	.probe = mpc85xx_mc_err_probe,
 	.remove = mpc85xx_mc_err_remove,
 	.driver = {
-		   .name = "mpc85xx_mc_err",
-		   .owner = THIS_MODULE,
-		   },
+		.name = "mpc85xx_mc_err",
+		.owner = THIS_MODULE,
+		.of_match_table = mpc85xx_mc_err_of_match,
+	},
 };
 
 #ifdef CONFIG_MPC85xx
diff --git a/drivers/edac/ppc4xx_edac.c b/drivers/edac/ppc4xx_edac.c
index 11f2172..9d6f678 100644
--- a/drivers/edac/ppc4xx_edac.c
+++ b/drivers/edac/ppc4xx_edac.c
@@ -202,13 +202,13 @@ static struct of_device_id ppc4xx_edac_match[] = {
 };
 
 static struct of_platform_driver ppc4xx_edac_driver = {
-	.match_table		= ppc4xx_edac_match,
 	.probe			= ppc4xx_edac_probe,
 	.remove			= ppc4xx_edac_remove,
-	.driver			= {
-		.owner	= THIS_MODULE,
-		.name	= PPC4XX_EDAC_MODULE_NAME
-	}
+	.driver = {
+		.owner = THIS_MODULE,
+		.name = PPC4XX_EDAC_MODULE_NAME
+		.of_match_table = ppc4xx_edac_match,
+	},
 };
 
 /*

