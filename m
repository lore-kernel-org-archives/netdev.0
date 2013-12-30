From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 07/19] net: ixgbe: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 15:40:50 +0800
Message-ID: <52C12382.4080702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
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
Cc: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d6f0c0d..9ce07f3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -715,8 +715,7 @@ static int ixgbe_set_vf_mac_addr(struct ixgbe_adapter *adapter,
 	}
 
 	if (adapter->vfinfo[vf].pf_set_mac &&
-	    memcmp(adapter->vfinfo[vf].vf_mac_addresses, new_mac,
-		   ETH_ALEN)) {
+	    !ether_addr_equal(adapter->vfinfo[vf].vf_mac_addresses, new_mac)) {
 		e_warn(drv,
 		       "VF %d attempted to override administratively set MAC address\n"
 		       "Reload the VF driver to resume operations\n",
-- 
1.8.0
