From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] ixgbe: Return 64 bit stats values
Date: Wed,  4 May 2016 09:26:43 -0700
Message-ID: <1462379208-3997-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:11585 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbcEDQ04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:26:56 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

The code was ignoring higher 32 bits of stats registers. This patch
correctly fills out 64 bit value in two 32 bit words.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index d3efcb4..a696192 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -720,8 +720,10 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[939] = IXGBE_GET_STAT(adapter, bprc);
 	regs_buff[940] = IXGBE_GET_STAT(adapter, mprc);
 	regs_buff[941] = IXGBE_GET_STAT(adapter, gptc);
-	regs_buff[942] = IXGBE_GET_STAT(adapter, gorc);
-	regs_buff[944] = IXGBE_GET_STAT(adapter, gotc);
+	regs_buff[942] = (u32)IXGBE_GET_STAT(adapter, gorc);
+	regs_buff[943] = (u32)(IXGBE_GET_STAT(adapter, gorc) >> 32);
+	regs_buff[944] = (u32)IXGBE_GET_STAT(adapter, gotc);
+	regs_buff[945] = (u32)(IXGBE_GET_STAT(adapter, gotc) >> 32);
 	for (i = 0; i < 8; i++)
 		regs_buff[946 + i] = IXGBE_GET_STAT(adapter, rnbc[i]);
 	regs_buff[954] = IXGBE_GET_STAT(adapter, ruc);
@@ -731,7 +733,8 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[958] = IXGBE_GET_STAT(adapter, mngprc);
 	regs_buff[959] = IXGBE_GET_STAT(adapter, mngpdc);
 	regs_buff[960] = IXGBE_GET_STAT(adapter, mngptc);
-	regs_buff[961] = IXGBE_GET_STAT(adapter, tor);
+	regs_buff[961] = (u32)IXGBE_GET_STAT(adapter, tor);
+	regs_buff[962] = (u32)(IXGBE_GET_STAT(adapter, tor) >> 32);
 	regs_buff[963] = IXGBE_GET_STAT(adapter, tpr);
 	regs_buff[964] = IXGBE_GET_STAT(adapter, tpt);
 	regs_buff[965] = IXGBE_GET_STAT(adapter, ptc64);
-- 
2.5.5
