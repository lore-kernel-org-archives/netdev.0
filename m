From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 05/27] drivers/usb/of: don't use deprecated field in
	of_platform_driver
Date: Thu, 11 Mar 2010 11:22:15 -0700
Message-ID: <20100311182215.13103.45160.stgit__218.604892916296$1268332280$gmane$org@angua>
References: <20100311181604.13103.30088.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64108 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498Ab0CKSa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:30:26 -0500
In-Reply-To: <20100311181604.13103.30088.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.name, .match_table and .owner are duplicated in both of_platform_driver
and device_driver, so the of_platform_driver copies will be removed soon.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/usb/gadget/fsl_qe_udc.c   |    7 +++++--
 drivers/usb/host/ehci-ppc-of.c    |    9 ++++-----
 drivers/usb/host/ehci-xilinx-of.c |    9 ++++-----
 drivers/usb/host/fhci-hcd.c       |    7 +++++--
 drivers/usb/host/isp1760-if.c     |    7 +++++--
 drivers/usb/host/ohci-ppc-of.c    |   13 ++++---------
 6 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/drivers/usb/gadget/fsl_qe_udc.c b/drivers/usb/gadget/fsl_qe_udc.c
index 3537d51..2928523 100644
--- a/drivers/usb/gadget/fsl_qe_udc.c
+++ b/drivers/usb/gadget/fsl_qe_udc.c
@@ -2768,8 +2768,11 @@ static const struct of_device_id qe_udc_match[] __devinitconst = {
 MODULE_DEVICE_TABLE(of, qe_udc_match);
 
 static struct of_platform_driver udc_driver = {
-	.name           = (char *)driver_name,
-	.match_table    = qe_udc_match,
+	.driver = {
+		.name = (char *)driver_name,
+		.owner = THIS_MODULE,
+		.of_match_table = qe_udc_match,
+	},
 	.probe          = qe_udc_probe,
 	.remove         = __devexit_p(qe_udc_remove),
 #ifdef CONFIG_PM
diff --git a/drivers/usb/host/ehci-ppc-of.c b/drivers/usb/host/ehci-ppc-of.c
index ad06623..5aec928 100644
--- a/drivers/usb/host/ehci-ppc-of.c
+++ b/drivers/usb/host/ehci-ppc-of.c
@@ -274,13 +274,12 @@ MODULE_DEVICE_TABLE(of, ehci_hcd_ppc_of_match);
 
 
 static struct of_platform_driver ehci_hcd_ppc_of_driver = {
-	.name		= "ppc-of-ehci",
-	.match_table	= ehci_hcd_ppc_of_match,
 	.probe		= ehci_hcd_ppc_of_probe,
 	.remove		= ehci_hcd_ppc_of_remove,
 	.shutdown	= ehci_hcd_ppc_of_shutdown,
-	.driver		= {
-		.name	= "ppc-of-ehci",
-		.owner	= THIS_MODULE,
+	.driver = {
+		.name = "ppc-of-ehci",
+		.owner = THIS_MODULE,
+		.of_match_table = ehci_hcd_ppc_of_match,
 	},
 };
diff --git a/drivers/usb/host/ehci-xilinx-of.c b/drivers/usb/host/ehci-xilinx-of.c
index f603bb2..013972b 100644
--- a/drivers/usb/host/ehci-xilinx-of.c
+++ b/drivers/usb/host/ehci-xilinx-of.c
@@ -288,13 +288,12 @@ static const struct of_device_id ehci_hcd_xilinx_of_match[] = {
 MODULE_DEVICE_TABLE(of, ehci_hcd_xilinx_of_match);
 
 static struct of_platform_driver ehci_hcd_xilinx_of_driver = {
-	.name		= "xilinx-of-ehci",
-	.match_table	= ehci_hcd_xilinx_of_match,
 	.probe		= ehci_hcd_xilinx_of_probe,
 	.remove		= ehci_hcd_xilinx_of_remove,
 	.shutdown	= ehci_hcd_xilinx_of_shutdown,
-	.driver		= {
-		.name	= "xilinx-of-ehci",
-		.owner	= THIS_MODULE,
+	.driver = {
+		.name = "xilinx-of-ehci",
+		.owner = THIS_MODULE,
+		.of_match_table = ehci_hcd_xilinx_of_match,
 	},
 };
diff --git a/drivers/usb/host/fhci-hcd.c b/drivers/usb/host/fhci-hcd.c
index 5dcfb3d..dba7af7 100644
--- a/drivers/usb/host/fhci-hcd.c
+++ b/drivers/usb/host/fhci-hcd.c
@@ -812,8 +812,11 @@ static const struct of_device_id of_fhci_match[] = {
 MODULE_DEVICE_TABLE(of, of_fhci_match);
 
 static struct of_platform_driver of_fhci_driver = {
-	.name		= "fsl,usb-fhci",
-	.match_table	= of_fhci_match,
+	.driver = {
+		.name = "fsl,usb-fhci",
+		.owner = THIS_MODULE,
+		.of_match_table = of_fhci_match,
+	},
 	.probe		= of_fhci_probe,
 	.remove		= __devexit_p(of_fhci_remove),
 };
diff --git a/drivers/usb/host/isp1760-if.c b/drivers/usb/host/isp1760-if.c
index 36360e2..100d5fa 100644
--- a/drivers/usb/host/isp1760-if.c
+++ b/drivers/usb/host/isp1760-if.c
@@ -121,8 +121,11 @@ static const struct of_device_id of_isp1760_match[] = {
 MODULE_DEVICE_TABLE(of, of_isp1760_match);
 
 static struct of_platform_driver isp1760_of_driver = {
-	.name           = "nxp-isp1760",
-	.match_table    = of_isp1760_match,
+	.driver = {
+		.name = "nxp-isp1760",
+		.owner = THIS_MODULE,
+		.of_match_table = of_isp1760_match,
+	},
 	.probe          = of_isp1760_probe,
 	.remove         = of_isp1760_remove,
 };
diff --git a/drivers/usb/host/ohci-ppc-of.c b/drivers/usb/host/ohci-ppc-of.c
index 003aea2..df16591 100644
--- a/drivers/usb/host/ohci-ppc-of.c
+++ b/drivers/usb/host/ohci-ppc-of.c
@@ -244,18 +244,13 @@ MODULE_DEVICE_TABLE(of, ohci_hcd_ppc_of_match);
 
 
 static struct of_platform_driver ohci_hcd_ppc_of_driver = {
-	.name		= "ppc-of-ohci",
-	.match_table	= ohci_hcd_ppc_of_match,
 	.probe		= ohci_hcd_ppc_of_probe,
 	.remove		= ohci_hcd_ppc_of_remove,
 	.shutdown 	= ohci_hcd_ppc_of_shutdown,
-#ifdef CONFIG_PM
-	/*.suspend	= ohci_hcd_ppc_soc_drv_suspend,*/
-	/*.resume	= ohci_hcd_ppc_soc_drv_resume,*/
-#endif
-	.driver		= {
-		.name	= "ppc-of-ohci",
-		.owner	= THIS_MODULE,
+	.driver = {
+		.name = "ppc-of-ohci",
+		.owner = THIS_MODULE,
+		.of_match_table = ohci_hcd_ppc_of_match,
 	},
 };
 

