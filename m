From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 5/7] ixgbe: use pcie_capability_read_word() to
	simplify code
Date: Tue, 3 Sep 2013 15:35:13 +0800
Message-ID: <1378193715-25328-5-git-send-email-wangyijing@huawei.com>
References: <1378193715-25328-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-pci@vger.kernel.org,
	Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Yijing Wang <wangyijing@huawei.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Gavin Shan
	<shangw@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, "James
	E.J. Bottomley" <JBottomley@parallels.com>, "David S. Miller"
	<davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1378193715-25328-1-git-send-email-wangyijing@huawei.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

use pcie_capability_read_word() to simplify code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bad8f14..bfa0b06 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -152,7 +152,6 @@ MODULE_VERSION(DRV_VERSION);
 static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 					  u32 reg, u16 *value)
 {
-	int pos = 0;
 	struct pci_dev *parent_dev;
 	struct pci_bus *parent_bus;
 
@@ -164,11 +163,10 @@ static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
 	if (!parent_dev)
 		return -1;
 
-	pos = pci_find_capability(parent_dev, PCI_CAP_ID_EXP);
-	if (!pos)
+	if (!pci_is_pcie(parent_dev))
 		return -1;
 
-	pci_read_config_word(parent_dev, pos + reg, value);
+	pcie_capability_read_word(parent_dev, reg, value);
 	return 0;
 }
 
-- 
1.7.1



------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
