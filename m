From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 06/20] net: igbvf: slight optimization of addr compare
Date: Fri, 27 Dec 2013 14:48:27 +0800
Message-ID: <52BD22BB.1060705@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 04bf22e..675435f 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1745,7 +1745,7 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 
 	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
 
-	if (memcmp(addr->sa_data, hw->mac.addr, 6))
+	if (!ether_addr_equal(addr->sa_data, hw->mac.addr))
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-- 
1.8.0
