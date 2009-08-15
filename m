From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] e1000e: fix use of pci_enable_pcie_error_reporting
Date: Fri, 14 Aug 2009 17:35:52 -0700
Message-ID: <20090815003551.2335.26888.stgit@localhost.localdomain>
References: <20090815003524.2335.3107.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Xiaotian Feng <dfeng@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:46548
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757289AbZHOAgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 20:36:08 -0400
In-Reply-To: <20090815003524.2335.3107.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <dfeng@redhat.com>

commit 111b9dc5 introduces pcie aer support for e1000e, but it is not
reasonable to disable it in e1000_remove but enable it in e1000_resume.
This patch enables aer support in e1000_probe.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 58e22fc..fa92a68 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4670,14 +4670,6 @@ static int e1000_resume(struct pci_dev *pdev)
 		return err;
 	}
 
-	/* AER (Advanced Error Reporting) hooks */
-	err = pci_enable_pcie_error_reporting(pdev);
-	if (err) {
-		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
-		                    "0x%x\n", err);
-		/* non-fatal, continue */
-	}
-
 	pci_set_master(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
@@ -4990,6 +4982,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_pci_reg;
 
+	/* AER (Advanced Error Reporting) hooks */
+	err = pci_enable_pcie_error_reporting(pdev);
+	if (err) {
+		dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+		        "0x%x\n", err);
+		/* non-fatal, continue */
+	}
+
 	pci_set_master(pdev);
 	/* PCI config space info */
 	err = pci_save_state(pdev);

