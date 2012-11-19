From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 410/493] isdn: remove use of __devexit
Date: Mon, 19 Nov 2012 13:25:59 -0500
Message-ID: <1353349642-3677-410-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Armin Schindler <mac@melware.de>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41487 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab2KSSe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:59 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Karsten Keil <isdn@linux-pingi.de> 
Cc: Armin Schindler <mac@melware.de> 
Cc: netdev@vger.kernel.org 
---
 drivers/isdn/hardware/avm/b1pci.c           | 2 +-
 drivers/isdn/hardware/eicon/divasmain.c     | 4 ++--
 drivers/isdn/hardware/mISDN/avmfritz.c      | 2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c      | 2 +-
 drivers/isdn/hardware/mISDN/hfcpci.c        | 2 +-
 drivers/isdn/hardware/mISDN/mISDNinfineon.c | 2 +-
 drivers/isdn/hardware/mISDN/netjet.c        | 2 +-
 drivers/isdn/hardware/mISDN/speedfax.c      | 2 +-
 drivers/isdn/hardware/mISDN/w6692.c         | 2 +-
 drivers/isdn/hisax/avma1_cs.c               | 4 ++--
 drivers/isdn/hisax/elsa_cs.c                | 4 ++--
 drivers/isdn/hisax/hfc4s8s_l1.c             | 2 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c         | 6 +++---
 drivers/isdn/hisax/sedlbauer_cs.c           | 4 ++--
 drivers/isdn/hisax/teles_cs.c               | 4 ++--
 drivers/isdn/hysdn/hysdn_init.c             | 2 +-
 16 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/hardware/avm/b1pci.c b/drivers/isdn/hardware/avm/b1pci.c
index cedf68d..1da5115 100644
--- a/drivers/isdn/hardware/avm/b1pci.c
+++ b/drivers/isdn/hardware/avm/b1pci.c
@@ -344,7 +344,7 @@ static int b1pci_pci_probe(struct pci_dev *pdev,
 	return retval;
 }
 
-static void __devexit b1pci_pci_remove(struct pci_dev *pdev)
+static void b1pci_pci_remove(struct pci_dev *pdev)
 {
 #ifdef CONFIG_ISDN_DRV_AVMB1_B1PCIV4
 	avmcard *card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 26454e2..52700b3 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -150,7 +150,7 @@ MODULE_DEVICE_TABLE(pci, divas_pci_tbl);
 
 static int divas_init_one(struct pci_dev *pdev,
 			  const struct pci_device_id *ent);
-static void __devexit divas_remove_one(struct pci_dev *pdev);
+static void divas_remove_one(struct pci_dev *pdev);
 
 static struct pci_driver diva_pci_driver = {
 	.name     = "divas",
@@ -749,7 +749,7 @@ static int divas_init_one(struct pci_dev *pdev,
 	return (0);
 }
 
-static void __devexit divas_remove_one(struct pci_dev *pdev)
+static void divas_remove_one(struct pci_dev *pdev)
 {
 	void *pdiva = pci_get_drvdata(pdev);
 
diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 2620876..292991c 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -1130,7 +1130,7 @@ fritzpci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void __devexit
+static void
 fritz_remove_pci(struct pci_dev *pdev)
 {
 	struct fritzcard *card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 36798bf..28543d7 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5274,7 +5274,7 @@ free_card:
 	return ret_err;
 }
 
-static void __devexit hfc_remove_pci(struct pci_dev *pdev)
+static void hfc_remove_pci(struct pci_dev *pdev)
 {
 	struct hfc_multi	*card = pci_get_drvdata(pdev);
 	u_long			flags;
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index ff06897..a7e4939 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2246,7 +2246,7 @@ hfc_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void __devexit
+static void
 hfc_remove_pci(struct pci_dev *pdev)
 {
 	struct hfc_pci	*card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index f8ab56d..3d045e5 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -1134,7 +1134,7 @@ inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void __devexit
+static void
 inf_remove(struct pci_dev *pdev)
 {
 	struct inf_hw	*card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index cc68656..8e29447 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1124,7 +1124,7 @@ nj_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 }
 
 
-static void __devexit nj_remove(struct pci_dev *pdev)
+static void nj_remove(struct pci_dev *pdev)
 {
 	struct tiger_hw *card = pci_get_drvdata(pdev);
 
diff --git a/drivers/isdn/hardware/mISDN/speedfax.c b/drivers/isdn/hardware/mISDN/speedfax.c
index f728992..9815bb4 100644
--- a/drivers/isdn/hardware/mISDN/speedfax.c
+++ b/drivers/isdn/hardware/mISDN/speedfax.c
@@ -480,7 +480,7 @@ sfaxpci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void __devexit
+static void
 sfax_remove_pci(struct pci_dev *pdev)
 {
 	struct sfax_hw	*card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 6033fa1..de69f68 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1387,7 +1387,7 @@ w6692_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void __devexit
+static void
 w6692_remove_pci(struct pci_dev *pdev)
 {
 	struct w6692_hw	*card = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index ed534d3..4e676bc 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -40,7 +40,7 @@ module_param(isdnprot, int, 0);
 
 static int avma1cs_config(struct pcmcia_device *link);
 static void avma1cs_release(struct pcmcia_device *link);
-static void avma1cs_detach(struct pcmcia_device *p_dev) __devexit;
+static void avma1cs_detach(struct pcmcia_device *p_dev);
 
 static int avma1cs_probe(struct pcmcia_device *p_dev)
 {
@@ -54,7 +54,7 @@ static int avma1cs_probe(struct pcmcia_device *p_dev)
 	return avma1cs_config(p_dev);
 } /* avma1cs_attach */
 
-static void __devexit avma1cs_detach(struct pcmcia_device *link)
+static void avma1cs_detach(struct pcmcia_device *link)
 {
 	dev_dbg(&link->dev, "avma1cs_detach(0x%p)\n", link);
 	avma1cs_release(link);
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index 8366a37..ebe5691 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -64,7 +64,7 @@ module_param(protocol, int, 0);
 
 static int elsa_cs_config(struct pcmcia_device *link);
 static void elsa_cs_release(struct pcmcia_device *link);
-static void elsa_cs_detach(struct pcmcia_device *p_dev) __devexit;
+static void elsa_cs_detach(struct pcmcia_device *p_dev);
 
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
@@ -90,7 +90,7 @@ static int elsa_cs_probe(struct pcmcia_device *link)
 	return elsa_cs_config(link);
 } /* elsa_cs_attach */
 
-static void __devexit elsa_cs_detach(struct pcmcia_device *link)
+static void elsa_cs_detach(struct pcmcia_device *link)
 {
 	local_info_t *info = link->priv;
 
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index ef7c07b..c49c294 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1640,7 +1640,7 @@ out:
 /**************************************/
 /* PCI hotplug interface: remove card */
 /**************************************/
-static void __devexit
+static void
 hfc4s8s_remove(struct pci_dev *pdev)
 {
 	hfc4s8s_hw *hw = pci_get_drvdata(pdev);
diff --git a/drivers/isdn/hisax/hisax_fcpcipnp.c b/drivers/isdn/hisax/hisax_fcpcipnp.c
index cd06398..300a97b 100644
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -825,7 +825,7 @@ err:
 	return retval;
 }
 
-static void __devexit fcpcipnp_release(struct fritz_adapter *adapter)
+static void fcpcipnp_release(struct fritz_adapter *adapter)
 {
 	DBG(1, "");
 
@@ -958,7 +958,7 @@ err:
 	return retval;
 }
 
-static void __devexit fcpnp_remove(struct pnp_dev *pdev)
+static void fcpnp_remove(struct pnp_dev *pdev)
 {
 	struct fritz_adapter *adapter = pnp_get_drvdata(pdev);
 
@@ -977,7 +977,7 @@ static struct pnp_driver fcpnp_driver = {
 };
 #endif
 
-static void __devexit fcpci_remove(struct pci_dev *pdev)
+static void fcpci_remove(struct pci_dev *pdev)
 {
 	struct fritz_adapter *adapter = pci_get_drvdata(pdev);
 
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index ac3f9fd..90f8129 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -65,7 +65,7 @@ module_param(protocol, int, 0);
 static int sedlbauer_config(struct pcmcia_device *link);
 static void sedlbauer_release(struct pcmcia_device *link);
 
-static void sedlbauer_detach(struct pcmcia_device *p_dev) __devexit;
+static void sedlbauer_detach(struct pcmcia_device *p_dev);
 
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
@@ -90,7 +90,7 @@ static int sedlbauer_probe(struct pcmcia_device *link)
 	return sedlbauer_config(link);
 } /* sedlbauer_attach */
 
-static void __devexit sedlbauer_detach(struct pcmcia_device *link)
+static void sedlbauer_detach(struct pcmcia_device *link)
 {
 	dev_dbg(&link->dev, "sedlbauer_detach(0x%p)\n", link);
 
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index 685ecab..f2476ff 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -45,7 +45,7 @@ module_param(protocol, int, 0);
 
 static int teles_cs_config(struct pcmcia_device *link);
 static void teles_cs_release(struct pcmcia_device *link);
-static void teles_detach(struct pcmcia_device *p_dev) __devexit;
+static void teles_detach(struct pcmcia_device *p_dev);
 
 typedef struct local_info_t {
 	struct pcmcia_device	*p_dev;
@@ -72,7 +72,7 @@ static int teles_probe(struct pcmcia_device *link)
 	return teles_cs_config(link);
 } /* teles_attach */
 
-static void __devexit teles_detach(struct pcmcia_device *link)
+static void teles_detach(struct pcmcia_device *link)
 {
 	local_info_t *info = link->priv;
 
diff --git a/drivers/isdn/hysdn/hysdn_init.c b/drivers/isdn/hysdn/hysdn_init.c
index f2603aa..241162f5 100644
--- a/drivers/isdn/hysdn/hysdn_init.c
+++ b/drivers/isdn/hysdn/hysdn_init.c
@@ -109,7 +109,7 @@ err_out:
 	return rc;
 }
 
-static void __devexit hysdn_pci_remove_one(struct pci_dev *akt_pcidev)
+static void hysdn_pci_remove_one(struct pci_dev *akt_pcidev)
 {
 	hysdn_card *card = pci_get_drvdata(akt_pcidev);
 
-- 
1.8.0
