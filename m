From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] e1000e: fix use of
	pci_enable_pcie_error_reporting
Date: Fri,  7 Aug 2009 17:36:14 +0800
Message-ID: <1249637774-32419-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>
To: john.ronciak@intel.com, peter.p.waskiewicz.jr@intel.com,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

commit 111b9dc5 introduces pcie aer support for e1000e, but it is not
reasonable to disable it in e1000_remove but enable it in e1000_resume.
This patch enables aer support in e1000_probe.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 drivers/net/e1000e/netdev.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 63415bb..e2f0304 100644
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
 
+        /* AER (Advanced Error Reporting) hooks */
+        err = pci_enable_pcie_error_reporting(pdev);
+        if (err) {
+                dev_err(&pdev->dev, "pci_enable_pcie_error_reporting failed "
+                                    "0x%x\n", err);
+                /* non-fatal, continue */
+        }
+
 	pci_set_master(pdev);
 	/* PCI config space info */
 	err = pci_save_state(pdev);
-- 
1.6.2.5


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
