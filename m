From: Chris Boot <bootc@bootc.net>
Subject: [PATCH 1/2] e1000e: Disable ASPM L1 on 82574
Date: Mon, 23 Apr 2012 22:29:37 +0100
Message-ID: <1335216578-21542-2-git-send-email-bootc@bootc.net>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
Cc: linux-kernel@vger.kernel.org, nix@esperi.org.uk,
	carolyn.wyborny@intel.com, Chris Boot <bootc@bootc.net>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335216578-21542-1-git-send-email-bootc@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ASPM on the 82574 causes trouble. Currently the driver disables L0s for
this NIC but only disables L1 if the MTU is >1500. This patch simply
causes L1 to be disabled regardless of the MTU setting.

Signed-off-by: Chris Boot <bootc@bootc.net>
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Cc: Nix <nix@esperi.org.uk>
Link: https://lkml.org/lkml/2012/3/19/362
---
 drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index b3fdc69..c6d95f2 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -2061,8 +2061,9 @@ const struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
-	.flags2			  = FLAG2_CHECK_PHY_HANG
+	.flags2			= FLAG2_CHECK_PHY_HANG
 				  | FLAG2_DISABLE_ASPM_L0S
+				  | FLAG2_DISABLE_ASPM_L1
 				  | FLAG2_NO_DISABLE_RX,
 	.pba			= 32,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
-- 
1.7.10
