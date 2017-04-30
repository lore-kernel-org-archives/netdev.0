From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40evf: hide unused variable
Date: Sun, 30 Apr 2017 06:24:51 -0700
Message-ID: <20170430132451.68494-14-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:58118 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164823AbdD3NZV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:25:21 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

On architectures with larger pages, we get a warning about an unused variable:

drivers/net/ethernet/intel/i40evf/i40evf_main.c: In function 'i40evf_configure_rx':
drivers/net/ethernet/intel/i40evf/i40evf_main.c:690:21: error: unused variable 'netdev' [-Werror=unused-variable]

This moves the declaration into the #ifdef to avoid the warning.

Fixes: dab86afdbbd1 ("i40e/i40evf: Change the way we limit the maximum frame size for Rx")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 445a97a57853..ea110a730e16 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -694,13 +694,14 @@ static void i40evf_configure_tx(struct i40evf_adapter *adapter)
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
2.12.2
