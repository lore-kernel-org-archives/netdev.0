From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v3 1/3] igb: Add igb_disable_sriov in error
	handling
Date: Tue, 23 Dec 2014 15:17:02 +0800
Message-ID: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>, linux.nics@intel.com
To: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com
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

For linux-3.18.0
The driver lacks igb_disable_sriov in error handling,
which should match igb_enable_sriov in igb_probe.
This patch fixes this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 487cd9c..91914e4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -179,6 +179,7 @@ static void igb_check_vf_rate_limit(struct igb_adapter *);
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
 static int igb_pci_enable_sriov(struct pci_dev *dev, int num_vfs);
+static int igb_disable_sriov(struct pci_dev *pdev);
 #endif
 
 #ifdef CONFIG_PM
@@ -2653,6 +2654,9 @@ err_register:
 	igb_release_hw_control(adapter);
 	memset(&adapter->i2c_adap, 0, sizeof(adapter->i2c_adap));
 err_eeprom:
+#ifdef CONFIG_PCI_IOV
+	igb_disable_sriov(pdev);
+#endif
 	if (!igb_check_reset_block(hw))
 		igb_reset_phy(hw);
 
-- 
1.7.9.5



------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
