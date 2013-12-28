From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 12/20] net: netxen: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:17:53 +0800
Message-ID: <52BE6D11.3060406@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Manish Chopra <manish.chopra@qlogic.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index b72b6be..db4280c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -661,7 +661,7 @@ static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
 	list_for_each(head, del_list) {
 		cur = list_entry(head, nx_mac_list_t, list);
 
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0) {
+		if (ether_addr_equal(addr, cur->mac_addr)) {
 			list_move_tail(head, &adapter->mac_list);
 			return 0;
 		}
-- 
1.8.0
