From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] i40evf: hide unused variable
Date: Wed, 19 Apr 2017 19:29:48 +0200
Message-ID: <20170419173008.3648215-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Bimmy Pujari <bimmy.pujari@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Alan Brady <alan.brady@intel.com>,
        Joe Perches <joe@perches.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Preethi Banala <preethi.banala@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On architectures with larger pages, we get a warning about an unused variable:

drivers/net/ethernet/intel/i40evf/i40evf_main.c: In function 'i40evf_configure_rx':
drivers/net/ethernet/intel/i40evf/i40evf_main.c:690:21: error: unused variable 'netdev' [-Werror=unused-variable]

This moves the declaration into the #ifdef to avoid the warning.

Fixes: dab86afdbbd1 ("i40e/i40evf: Change the way we limit the maximum frame size for Rx")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 12a930e879af..1bb13c864edd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -687,13 +687,14 @@ static void i40evf_configure_tx(struct i40evf_adapter *adapter)
 static void i40evf_configure_rx(struct i40evf_adapter *adapter)
 {
 	unsigned int rx_buf_len = I40E_RXBUFFER_2048;
-	struct net_device *netdev = adapter->netdev;
 	struct i40e_hw *hw = &adapter->hw;
 	int i;
 
 	/* Legacy Rx will always default to a 2048 buffer size. */
 #if (PAGE_SIZE < 8192)
 	if (!(adapter->flags & I40EVF_FLAG_LEGACY_RX)) {
+		struct net_device *netdev = adapter->netdev;
+
 		/* For jumbo frames on systems with 4K pages we have to use
 		 * an order 1 page, so we might as well increase the size
 		 * of our Rx buffer to make better use of the available space
-- 
2.9.0
