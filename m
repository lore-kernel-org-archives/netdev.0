From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/3] ssb: provide phy address for Gigabit Ethernet driver
Date: Sat, 28 Sep 2013 23:15:27 +0200
Message-ID: <1380402928-11480-2-git-send-email-hauke@hauke-m.de>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45251 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab3I1VPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 17:15:43 -0400
In-Reply-To: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to provide the phy address which should be used to the
Gigabit Ethernet driver connected to ssb.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/linux/ssb/ssb_driver_gige.h |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 86a12b0..0688472 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -108,6 +108,16 @@ static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 	return 0;
 }
 
+/* Get the device phy address */
+static inline int ssb_gige_get_phyaddr(struct pci_dev *pdev)
+{
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	if (!dev)
+		return -ENODEV;
+
+	return dev->dev->bus->sprom.et0phyaddr;
+}
+
 extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
 					  struct pci_dev *pdev);
 extern int ssb_gige_map_irq(struct ssb_device *sdev,
@@ -174,6 +184,10 @@ static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
 	return -ENODEV;
 }
+static inline int ssb_gige_get_phyaddr(struct pci_dev *pdev)
+{
+	return -ENODEV;
+}
 
 #endif /* CONFIG_SSB_DRIVER_GIGE */
 #endif /* LINUX_SSB_DRIVER_GIGE_H_ */
-- 
1.7.10.4
