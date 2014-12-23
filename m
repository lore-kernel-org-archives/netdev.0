From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v3 2/3] igb: Add
	pci_disable_pcie_error_reporting in error handling
Date: Tue, 23 Dec 2014 15:17:03 +0800
Message-ID: <1419319024-30455-2-git-send-email-baijiaju1990@163.com>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>, linux.nics@intel.com
To: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
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
The driver lacks pci_disable_pcie_error_reporting in error handling,
which should match pci_enable_pcie_error_reporting in igb_probe.
This patch fixes this problem, and it has been tested in runtime.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 487cd9c..59e0ba4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2664,6 +2664,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
+	pci_disable_pcie_error_reporting(pdev);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
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
