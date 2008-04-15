From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] e1000e: save and restore pcie/msi state
	to support EEH	recovery
Date: Tue, 15 Apr 2008 10:57:52 -0700
Message-ID: <20080415175752.12506.58573.stgit@localhost.localdomain>
References: <20080415175745.12506.67349.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	wendyx@us.ibm.com
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080415175745.12506.67349.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Wendy Xiong <wendyx@us.ibm.com>

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

Tested this EEH patch with 2ports and 4ports pci-express e1000e
adapters.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 146edf7..7282751 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3815,6 +3815,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
@@ -3941,6 +3942,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct e1000_adapter));


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
