From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [RESEND] igb: save and restore pcie/msi state
	to support EEH	recovery
Date: Wed, 16 Apr 2008 11:08:42 -0700
Message-ID: <20080416180842.24843.20982.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	wendyx@us.ibm.com
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
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

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

[after similar patches for ixgbe and e1000e from Wendy Xiong]

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Wendy Xiong <wendyx@us.ibm.com>
---

 drivers/net/igb/igb_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index aaee02e..ae398f0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -871,6 +871,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct igb_adapter));
@@ -4079,6 +4080,7 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
 
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
