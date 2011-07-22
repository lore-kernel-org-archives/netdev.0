From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] ath9k: use pci_dev->subsystem_device
Date: Fri, 22 Jul 2011 19:58:23 +0400
Message-ID: <201107221958.23408.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jmalinen@atheros.com, lrodriguez@atheros.com, vasanth@atheros.com,
	senthilkumar@atheros.com
To: netdev@vger.kernel.org, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:41202 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750711Ab1GVQAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 12:00:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver reads PCI subsystem ID from the PCI configuration register while it's
already stored by the PCI subsystem in the 'subsystem_device' field of 'struct
pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/net/wireless/ath/ath9k/pci.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/net/wireless/ath/ath9k/pci.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/ath/ath9k/pci.c
+++ linux-2.6/drivers/net/wireless/ath/ath9k/pci.c
@@ -129,7 +129,6 @@ static int ath_pci_probe(struct pci_dev 
 	struct ath_softc *sc;
 	struct ieee80211_hw *hw;
 	u8 csz;
-	u16 subsysid;
 	u32 val;
 	int ret = 0;
 	char hw_name[64];
@@ -223,8 +222,8 @@ static int ath_pci_probe(struct pci_dev 
 
 	sc->irq = pdev->irq;
 
-	pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &subsysid);
-	ret = ath9k_init_device(id->device, sc, subsysid, &ath_pci_bus_ops);
+	ret = ath9k_init_device(id->device, sc, pdev->subsystem_device,
+				&ath_pci_bus_ops);
 	if (ret) {
 		dev_err(&pdev->dev, "Failed to initialize device\n");
 		goto err_init;
