From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH v2 net-next] ixgbe: Fix for RAR0 not being set to default MAC addr
Date: Thu,  7 Jan 2016 14:17:03 -0800
Message-ID: <1452205023-23499-1-git-send-email-tushar.n.dave@oracle.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org (open list:INTEL ETHERNET DRIVERS),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit c9f53e63c208 ("ixgbe: Refactor MAC address configuration code")
introduced code that doesn't set HW register RAR0 to default mac address
but FF:FF:FF:FF:FF:FF. Due to this, ixgbe HW discards all incoming packets
that doesn't have destination mac address equals to FF:FF:FF:FF:FF:FF.

This commit sets RAR0 correctly to default HW mac address.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---

v2:
Minor change in code comment
This time send to all ixgbe maintainers as per get_maintainer.pl


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ea9537d..3e6b208 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9084,6 +9084,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	/* Set hw->mac.addr to permanent MAC address */
+	ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
 	ixgbe_mac_set_default_filter(adapter);
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
-- 
1.9.1
