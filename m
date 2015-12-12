From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] ixgbe: Return error on failure to allocate mac_table
Date: Sat, 12 Dec 2015 03:14:39 -0800
Message-ID: <1449918890-145243-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:30916 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbbLLLPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:00 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Add a check to make certain mac_table was actually allocated and is not
NULL.  If it is NULL return -ENOMEM and allow the probe routine to fail
rather then causing a NULL pointer dereference further down the line.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ebd4522..c539b1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5381,6 +5381,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
 				     hw->mac.num_rar_entries,
 				     GFP_ATOMIC);
+	if (!adapter->mac_table)
+		return -ENOMEM;
 
 	/* Set MAC specific capability flags and exceptions */
 	switch (hw->mac.type) {
-- 
2.5.0
