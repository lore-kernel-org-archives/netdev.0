From: Jonathan Toppins <jtoppins@redhat.com>
Subject: [PATCH net-next 1/2] bnxt_en: don't consider building bnxt_tc.o if option not enabled
Date: Fri,  6 Oct 2017 15:48:30 -0400
Message-ID: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org (open list)
To: michael.chan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of zeroing out bnxt_tc.c with a #ifdef foo, instead don't compile
the file when the option is not enabled. Now make and the preprocessor do
not have to waste time compiling a no-op.

Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>
---
 drivers/net/ethernet/broadcom/bnxt/Makefile  | 3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 5 -----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/Makefile b/drivers/net/ethernet/broadcom/bnxt/Makefile
index 4f0cb8e1ffc0..457201f409a7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/Makefile
+++ b/drivers/net/ethernet/broadcom/bnxt/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_BNXT) += bnxt_en.o
 
-bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o bnxt_xdp.o bnxt_vfr.o bnxt_tc.o
+bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o bnxt_xdp.o bnxt_vfr.o
+bnxt_en-$(CONFIG_BNXT_FLOWER_OFFLOAD) += bnxt_tc.o
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index 7dd3d131043a..4730c048ed9b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -23,8 +23,6 @@
 #include "bnxt_tc.h"
 #include "bnxt_vfr.h"
 
-#ifdef CONFIG_BNXT_FLOWER_OFFLOAD
-
 #define BNXT_FID_INVALID			0xffff
 #define VLAN_TCI(vid, prio)	((vid) | ((prio) << VLAN_PRIO_SHIFT))
 
@@ -833,6 +831,3 @@ void bnxt_shutdown_tc(struct bnxt *bp)
 	rhashtable_destroy(&tc_info->flow_table);
 	rhashtable_destroy(&tc_info->l2_table);
 }
-
-#else
-#endif
-- 
2.13.6
