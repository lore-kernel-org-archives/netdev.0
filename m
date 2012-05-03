From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Thu,  3 May 2012 02:56:28 -0700
Message-ID: <1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Chris Boot <bootc@bootc.net>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	Nix <nix@esperi.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9910 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196Ab2ECJ4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 05:56:36 -0400
In-Reply-To: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Boot <bootc@bootc.net>

ASPM on the 82574 causes trouble. Currently the driver disables L0s for
this NIC but only disables L1 if the MTU is >1500. This patch simply
causes L1 to be disabled regardless of the MTU setting.

Signed-off-by: Chris Boot <bootc@bootc.net>
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Cc: Nix <nix@esperi.org.uk>
Link: https://lkml.org/lkml/2012/3/19/362
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 98632f4..6a8a908 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2072,8 +2072,9 @@ const struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.flags2			  = FLAG2_CHECK_PHY_HANG
+	.flags2			 = FLAG2_CHECK_PHY_HANG
 				  | FLAG2_DISABLE_ASPM_L0S
+				  | FLAG2_DISABLE_ASPM_L1
 				  | FLAG2_NO_DISABLE_RX
 				  | FLAG2_DMA_BURST,
 	.pba			= 32,
-- 
1.7.7.6
