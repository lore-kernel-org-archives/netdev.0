From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] ixgbe: save and restore pcie/msi state to
	support EEH	recovery
Date: Tue, 15 Apr 2008 10:57:46 -0700
Message-ID: <20080415175745.12506.67349.stgit@localhost.localdomain>
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

From: Wendy Xiong <wendyx@us.ibm.com>

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

Tested this EEH patch with Intel 10G pci-express ixgbe adapter.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index cb371a8..7b85922 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3431,6 +3431,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX_QUEUES);
@@ -3721,6 +3722,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
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
