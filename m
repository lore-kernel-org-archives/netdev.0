From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] ixgbe: Fix PFC mask generation
Date: Thu,  6 Oct 2011 04:02:33 -0700
Message-ID: <1317898959-16550-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701Ab1JFLCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:43 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Fix PFC mask generation to OR in only a single bit for each priority in
the PFC mask returned via netlink.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index 83bf7cc..3d44b15 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -184,7 +184,7 @@ void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en)
 
 	*pfc_en = 0;
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-		*pfc_en |= (cfg->tc_config[i].dcb_pfc & 0xF) << i;
+		*pfc_en |= !!(cfg->tc_config[i].dcb_pfc & 0xF) << i;
 }
 
 void ixgbe_dcb_unpack_refill(struct ixgbe_dcb_config *cfg, int direction,
-- 
1.7.6.4
