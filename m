From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v2 04/20] net: atl1: slight optimization of addr compare
Date: Tue, 24 Dec 2013 19:27:40 +0800
Message-ID: <52B96FAC.9020004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..f33995c 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3122,7 +3122,7 @@ static void atl1_remove(struct pci_dev *pdev)
 	 * from the BIOS during POST.  If we've been messing with the MAC
 	 * address, we need to save the permanent one.
 	 */
-	if (memcmp(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN)) {
+	if (!ether_addr_equal_unaligned(adapter->hw.mac_addr, adapter->hw.perm_mac_addr)) {
 		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr,
 			ETH_ALEN);
 		atl1_set_mac_addr(&adapter->hw);
-- 
1.8.0
