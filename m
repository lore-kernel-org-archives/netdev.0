From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 04/25] ixgb: leave room for extra hardware memory
	usage
Date: Tue, 08 Jul 2008 15:51:22 -0700
Message-ID: <20080708225122.6925.69838.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43513 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347AbYGHWvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:51:24 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgb hardware (not ixgbe) has a problem where it might dma past the
end of a buffer in certain cases.  leave 8 bytes extra room.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ecd5252..ec8bce1 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -560,7 +560,7 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	hw->subsystem_id = pdev->subsystem_device;
 
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
-	adapter->rx_buffer_len = hw->max_frame_size;
+	adapter->rx_buffer_len = hw->max_frame_size + 8; /* + 8 for errata */
 
 	if((hw->device_id == IXGB_DEVICE_ID_82597EX)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
@@ -1573,7 +1573,7 @@ ixgb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
-	adapter->rx_buffer_len = max_frame;
+	adapter->rx_buffer_len = max_frame + 8; /* + 8 for errata */
 
 	netdev->mtu = new_mtu;
 

