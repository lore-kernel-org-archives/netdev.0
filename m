From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 18/40] ixgbe: fix bit mask for DCB version
Date: Tue,  7 Jun 2011 05:32:53 -0700
Message-ID: <1307449995-9458-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54890 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240Ab1FGMd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:26 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This bit mask is wrong DCBX_HOST is always set. It was missed up
until now because lldpad reprograms the device on a link
event. However this is still wrong and it is best not to be
mis-configured for some time immediately following ixgbe_up().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2634c67..fad1803 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3744,7 +3744,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 
 	/* reconfigure the hardware */
-	if (adapter->dcbx_cap & (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE)) {
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
 #ifdef CONFIG_FCOE
 		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
 			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
-- 
1.7.5.2

