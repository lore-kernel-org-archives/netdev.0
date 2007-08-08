From: Brandon Philips <bphilips@suse.de>
Subject: [PATCH] NET: Change pci_enable_device to
	pci_reenable_device to	keep device enable balance
Date: Wed, 8 Aug 2007 10:21:49 -0700
Message-ID: <20070808172149.GA6796@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, ram.vepa@neterion.com
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
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

I sent this last week as part of my devres patches but it is purely a
bug fix and can be merged now.

On a slot_reset event pci_disable_device() is never called so calling
pci_enable_device() will unbalance the enable count.

Signed-off-by: Brandon Philips <bphilips@suse.de>
Acked-by: Tejun Heo <htejun@gmail.com>

---
 drivers/net/e100.c             |    2 +-
 drivers/net/e1000/e1000_main.c |    2 +-
 drivers/net/ixgb/ixgb_main.c   |    2 +-
 drivers/net/s2io.c             |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2828,7 +2828,7 @@ static pci_ers_result_t e100_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct nic *nic = netdev_priv(netdev);
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "e100: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -5270,7 +5270,7 @@ static pci_ers_result_t e1000_io_slot_re
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/ixgb/ixgb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ixgb/ixgb_main.c
+++ linux-2.6/drivers/net/ixgb/ixgb_main.c
@@ -2294,7 +2294,7 @@ static pci_ers_result_t ixgb_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if(pci_enable_device(pdev)) {
+	if(pci_reenable_device(pdev)) {
 		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
Index: linux-2.6/drivers/net/s2io.c
===================================================================
--- linux-2.6.orig/drivers/net/s2io.c
+++ linux-2.6/drivers/net/s2io.c
@@ -7833,7 +7833,7 @@ static pci_ers_result_t s2io_io_slot_res
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct s2io_nic *sp = netdev->priv;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		printk(KERN_ERR "s2io: "
 		       "Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
