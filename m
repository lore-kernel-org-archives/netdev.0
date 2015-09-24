From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/18] ixgbe: Correct setting of RDRXCTL register for X550* devices
Date: Wed, 23 Sep 2015 23:59:33 -0700
Message-ID: <1443077981-55791-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932725AbbIXG76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:58 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Setting the X550* RDRXCTL register should fall through into X540
and 82599, not 82598.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9986be5..a10728c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3789,8 +3789,6 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 	u32 rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
 
 	switch (hw->mac.type) {
-	case ixgbe_mac_X550:
-	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_82598EB:
 		/*
 		 * For VMDq support of different descriptor types or
@@ -3804,6 +3802,8 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 		 */
 		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
 		break;
+	case ixgbe_mac_X550:
+	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		/* Disable RSC for ACK packets */
-- 
2.4.3
