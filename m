From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH] tulip: Fix compiler warning when CONFIG_DEBUG_SECTION_MISMATCH=y
Date: Thu,  6 Dec 2012 14:04:27 +0100
Message-ID: <1354799067-25680-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44041 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab2LFNOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 08:14:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: drivers/net/ethernet/dec/tulip/tulip.o(.text+0x4057): Section
mismatch in reference from the function tulip_init_one() to the variable
.devinit.rodata:early_486_chipsets
The function tulip_init_one() references
the variable __devinitconst early_486_chipsets.
This is often because tulip_init_one lacks a __devinitconst
annotation or the annotation of early_486_chipsets is wrong.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 157c8e6..6baec9c 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1301,7 +1301,7 @@ DEFINE_PCI_DEVICE_TABLE(early_486_chipsets) = {
 	{ },
 };
 
-static int tulip_init_one(struct pci_dev *pdev,
+static int __devinit tulip_init_one(struct pci_dev *pdev,
 			  const struct pci_device_id *ent)
 {
 	struct tulip_private *tp;
@@ -1970,7 +1970,7 @@ static void poll_tulip (struct net_device *dev)
 }
 #endif
 
-static struct pci_driver tulip_driver = {
+static struct __devinitdata pci_driver tulip_driver = {
 	.name		= DRV_NAME,
 	.id_table	= tulip_pci_tbl,
 	.probe		= tulip_init_one,
-- 
1.7.10.4
