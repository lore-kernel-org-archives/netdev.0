From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 09/18 v2] isdn: mISDN: call disable_pci_device() if pci_probe() failed
Date: Mon,  9 Aug 2010 23:50:53 +0400
Message-ID: <1281383456-14119-1-git-send-email-segooon@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, Peter Huewe <peterhuewe@gmx.de>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45381 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab0HITvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:51:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should call disable_pci_device() if it returns from pci_probe()
with error.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/isdn/hardware/mISDN/mISDNinfineon.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNinfineon.c b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
index d2dd61d..af25e1f 100644
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
+++ b/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -1094,6 +1094,7 @@ inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pr_info("mISDN: do not have informations about adapter at %s\n",
 			pci_name(pdev));
 		kfree(card);
+		pci_disable_device(pdev);
 		return -EINVAL;
 	} else
 		pr_notice("mISDN: found adapter %s at %s\n",
@@ -1103,7 +1104,7 @@ inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, card);
 	err = setup_instance(card);
 	if (err) {
-		pci_disable_device(card->pdev);
+		pci_disable_device(pdev);
 		kfree(card);
 		pci_set_drvdata(pdev, NULL);
 	} else if (ent->driver_data == INF_SCT_1) {
@@ -1114,6 +1115,7 @@ inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			sc = kzalloc(sizeof(struct inf_hw), GFP_KERNEL);
 			if (!sc) {
 				release_card(card);
+				pci_disable_device(pdev);
 				return -ENOMEM;
 			}
 			sc->irq = card->irq;
@@ -1121,6 +1123,7 @@ inf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			sc->ci = card->ci + i;
 			err = setup_instance(sc);
 			if (err) {
+				pci_disable_device(pdev);
 				kfree(sc);
 				release_card(card);
 				break;
-- 
1.7.0.4

