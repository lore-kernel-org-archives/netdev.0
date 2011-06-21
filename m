From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] ixgbe: fix bit mask for DCB version
Date: Tue, 21 Jun 2011 01:33:44 -0700
Message-ID: <1308645228-32444-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34914 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689Ab1FUIeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 04:34:04 -0400
In-Reply-To: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index e81dc85..5caf42a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3745,7 +3745,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 
 	/* reconfigure the hardware */
-	if (adapter->dcbx_cap & (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_CEE)) {
+	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
 #ifdef CONFIG_FCOE
 		if (adapter->netdev->features & NETIF_F_FCOE_MTU)
 			max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
-- 
1.7.5.4

