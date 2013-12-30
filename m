From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 09/19] net: ksz884x: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 15:40:59 +0800
Message-ID: <52C1238B.8050104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/micrel/ksz884x.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ddd252a..8e9dad7 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4128,10 +4128,10 @@ static int hw_add_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 	int j = ADDITIONAL_ENTRIES;
 
-	if (!memcmp(hw->override_addr, mac_addr, ETH_ALEN))
+	if (ether_addr_equal(hw->override_addr, mac_addr))
 		return 0;
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN))
+		if (ether_addr_equal(hw->address[i], mac_addr))
 			return 0;
 		if (ADDITIONAL_ENTRIES == j && empty_addr(hw->address[i]))
 			j = i;
@@ -4149,7 +4149,7 @@ static int hw_del_addr(struct ksz_hw *hw, u8 *mac_addr)
 	int i;
 
 	for (i = 0; i < hw->addr_list_size; i++) {
-		if (!memcmp(hw->address[i], mac_addr, ETH_ALEN)) {
+		if (ether_addr_equal(hw->address[i], mac_addr)) {
 			memset(hw->address[i], 0, ETH_ALEN);
 			writel(0, hw->io + ADD_ADDR_INCR * i +
 				KS_ADD_ADDR_0_HI);
@@ -7104,8 +7104,7 @@ static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 			       ETH_ALEN);
 		else {
 			memcpy(dev->dev_addr, sw->other_addr, ETH_ALEN);
-			if (!memcmp(sw->other_addr, hw->override_addr,
-				    ETH_ALEN))
+			if (ether_addr_equal(sw->other_addr, hw->override_addr))
 				dev->dev_addr[5] += port->first_port;
 		}
 
-- 
1.8.0
