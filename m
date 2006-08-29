From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 05/26] e1000: error out if we cannot enable PCI device on resume
Date: Tue, 29 Aug 2006 09:44:25 -0700
Message-ID: <20060829164425.6872.75037.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:30474 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965076AbWH2QgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:11 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Do not ignore errors returned by pci_enable_device, instead error out.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 426811a..630fe60 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4709,11 +4709,14 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t manc, ret_val;
+	uint32_t manc, err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	e1000_pci_restore_state(adapter);
-	ret_val = pci_enable_device(pdev);
+	if ((err = pci_enable_device(pdev))) {
+		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
+		return err;
+	}
 	pci_set_master(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);



---
Auke Kok <auke-jan.h.kok@intel.com>
