From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 4/5] orinoco: eliminate the suspend/resume functions if CONFIG_PM is unset
Date: Mon, 01 May 2006 02:13:30 -0400
Message-ID: <20060501061330.13342.77853.stgit@dv.roinet.com>
References: <20060501061324.13342.58195.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:58336 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751278AbWEAGNc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:13:32 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FaRf1-0007GP-JE
	for netdev@vger.kernel.org; Mon, 01 May 2006 02:13:31 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
In-Reply-To: <20060501061324.13342.58195.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco_pci.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/orinoco_pci.h b/drivers/net/wireless/orinoco_pci.h
index b05a9a5..4e8da4e 100644
--- a/drivers/net/wireless/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco_pci.h
@@ -44,6 +44,7 @@ static inline void orinoco_pci_setup_net
 	       pci_name(pdev), pdev->irq, range_type, start, end);
 }
 
+#ifdef CONFIG_PM
 static int orinoco_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -121,5 +122,9 @@ static int orinoco_pci_resume(struct pci
 
 	return 0;
 }
+#else
+#define orinoco_pci_suspend NULL
+#define orinoco_pci_resume NULL
+#endif
 
 #endif /* _ORINOCO_PCI_H */

