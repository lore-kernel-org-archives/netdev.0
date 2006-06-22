From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/21] e1000: fix CONFIG_PM blocks
Date: Wed, 21 Jun 2006 22:20:14 -0700
Message-ID: <20060622052013.25497.38959.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:44808 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932796AbWFVFOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


e1000_suspend is called even when !CONFIG_PM. The non-PM code inside of it
is properly #ifdef'd. This fixes the compiler warnings when !CONFIG_PM.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 813d5e0..7cf5e5d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -177,8 +177,8 @@ static void e1000_vlan_rx_add_vid(struct
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
-#ifdef CONFIG_PM
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
+#ifdef CONFIG_PM
 static int e1000_resume(struct pci_dev *pdev);
 #endif
 static void e1000_shutdown(struct pci_dev *pdev);
@@ -205,8 +205,8 @@ static struct pci_driver e1000_driver = 
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 	/* Power Managment Hooks */
-#ifdef CONFIG_PM
 	.suspend  = e1000_suspend,
+#ifdef CONFIG_PM
 	.resume   = e1000_resume,
 #endif
 	.shutdown = e1000_shutdown,
@@ -4498,7 +4498,9 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t ctrl, ctrl_ext, rctl, manc, status;
 	uint32_t wufc = adapter->wol;
+#ifdef CONFIG_PM
 	int retval = 0;
+#endif
 
 	netif_device_detach(netdev);
 



--
Auke Kok <auke-jan.h.kok@intel.com>
