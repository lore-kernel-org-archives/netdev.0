From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 44/45] bna: Header File and Unused Code Cleanup
Date: Mon, 18 Jul 2011 01:23:04 -0700
Message-ID: <1310977385-5268-34-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48291 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755012Ab1GRIZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:28 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Header file cleanup
 - Removed unused code

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_cee.c           |    2 -
 drivers/net/bna/bfa_defs_mfg_comm.h |    1 -
 drivers/net/bna/bfi.h               |   46 -----------------------------------
 drivers/net/bna/bna.h               |   18 +++++--------
 drivers/net/bna/bna_types.h         |    3 --
 drivers/net/bna/bnad.h              |    2 -
 drivers/net/bna/cna.h               |    7 +----
 7 files changed, 9 insertions(+), 70 deletions(-)

diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/bna/bfa_cee.c
index b45b8eb..8e62718 100644
--- a/drivers/net/bna/bfa_cee.c
+++ b/drivers/net/bna/bfa_cee.c
@@ -16,8 +16,6 @@
  * www.brocade.com
  */
 
-#include "bfa_defs_cna.h"
-#include "cna.h"
 #include "bfa_cee.h"
 #include "bfi_cna.h"
 #include "bfa_ioc.h"
diff --git a/drivers/net/bna/bfa_defs_mfg_comm.h b/drivers/net/bna/bfa_defs_mfg_comm.h
index 2f00813..e275ab8 100644
--- a/drivers/net/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/bna/bfa_defs_mfg_comm.h
@@ -18,7 +18,6 @@
 #ifndef __BFA_DEFS_MFG_COMM_H__
 #define __BFA_DEFS_MFG_COMM_H__
 
-#include "cna.h"
 #include "bfa_defs.h"
 
 /**
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 17522f3..18fb350 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -73,20 +73,6 @@ struct bfi_mhdr {
  ****************************************************************************
  */
 
-#define BFI_SGE_INLINE	1
-#define BFI_SGE_INLINE_MAX	(BFI_SGE_INLINE + 1)
-
-/**
- * SG Flags
- */
-enum {
-	BFI_SGE_DATA		= 0,	/*!< data address, not last	     */
-	BFI_SGE_DATA_CPL	= 1,	/*!< data addr, last in current page */
-	BFI_SGE_DATA_LAST	= 3,	/*!< data address, last		     */
-	BFI_SGE_LINK		= 2,	/*!< link address		     */
-	BFI_SGE_PGDLEN		= 2,	/*!< cumulative data length for page */
-};
-
 /**
  * DMA addresses
  */
@@ -97,33 +83,6 @@ union bfi_addr_u {
 	} a32;
 };
 
-/**
- * Scatter Gather Element
- */
-struct bfi_sge {
-#ifdef __BIGENDIAN
-	u32	flags:2,
-			rsvd:2,
-			sg_len:28;
-#else
-	u32	sg_len:28,
-			rsvd:2,
-			flags:2;
-#endif
-	union bfi_addr_u sga;
-};
-
-/**
- * Scatter Gather Page
- */
-#define BFI_SGPG_DATA_SGES		7
-#define BFI_SGPG_SGES_MAX		(BFI_SGPG_DATA_SGES + 1)
-#define BFI_SGPG_RSVD_WD_LEN	8
-struct bfi_sgpg {
-	struct bfi_sge sges[BFI_SGPG_SGES_MAX];
-	u32	rsvd[BFI_SGPG_RSVD_WD_LEN];
-};
-
 /*
  * Large Message structure - 128 Bytes size Msgs
  */
@@ -131,11 +90,6 @@ struct bfi_sgpg {
 #define BFI_LMSG_PL_WSZ	\
 			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr)) / 4)
 
-struct bfi_msg {
-	struct bfi_mhdr mhdr;
-	u32	pl[BFI_LMSG_PL_WSZ];
-};
-
 /**
  * Mailbox message structure
  */
diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index 66725d3..c22ad49 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -10,12 +10,17 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
 #ifndef __BNA_H__
 #define __BNA_H__
 
-#include "bfa_wc.h"
+#include "bfa_defs.h"
 #include "bfa_ioc.h"
-#include "cna.h"
+#include "bfi_enet.h"
 #include "bna_types.h"
 
 extern u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
@@ -407,12 +412,8 @@ void bna_mod_init(struct bna *bna, struct bna_res_info *res_info);
 void bna_uninit(struct bna *bna);
 int bna_num_txq_set(struct bna *bna, int num_txq);
 int bna_num_rxp_set(struct bna *bna, int num_rxp);
-void bna_stats_get(struct bna *bna);
-void bna_get_perm_mac(struct bna *bna, u8 *mac);
 void bna_hw_stats_get(struct bna *bna);
 
-/* APIs for Rx */
-
 /* APIs for RxF */
 struct bna_mac *bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod);
 void bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod,
@@ -575,11 +576,6 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
-void bna_rx_hds_enable(struct bna_rx *rx, struct bna_hds_config *hds_config,
-		       void (*cbfn)(struct bnad *, struct bna_rx *));
-void bna_rx_hds_disable(struct bna_rx *rx,
-			void (*cbfn)(struct bnad *, struct bna_rx *));
-
 /**
  * ENET
  */
diff --git a/drivers/net/bna/bna_types.h b/drivers/net/bna/bna_types.h
index 7f037db..e4291b1 100644
--- a/drivers/net/bna/bna_types.h
+++ b/drivers/net/bna/bna_types.h
@@ -21,7 +21,6 @@
 #include "cna.h"
 #include "bna_hw.h"
 #include "bfa_cee.h"
-#include "bfi_enet.h"
 #include "bfa_msgq.h"
 
 /**
@@ -329,7 +328,6 @@ struct bna_attr {
 	int			num_ucmac;
 	int			num_mcmac;
 	int			max_rit_size;
-	int			max_ets_groups;
 };
 
 /**
@@ -579,7 +577,6 @@ struct bna_tx_mod {
 	int			iscsi_over_cee;
 	int			iscsi_prio;
 	int			prio_reconfigured;
-	void			*prio_indirection[BFI_TX_MAX_PRIO];
 
 	u32			rid_mask;
 
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 6e14257..5563bf9 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -63,8 +63,6 @@ struct bnad_rx_ctrl {
 
 #define BNAD_RXMODE_PROMISC_DEFAULT	BNA_RXMODE_PROMISC
 
-#define BNAD_GET_TX_ID(_skb)	(0)
-
 /*
  * GLOBAL #defines (CONSTANTS)
  */
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index 94005d6..cb48742 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -21,17 +21,14 @@
 
 #include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/mutex.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/bitops.h>
 #include <linux/timer.h>
 #include <linux/interrupt.h>
+#include <linux/if_vlan.h>
 #include <linux/if_ether.h>
-#include <asm/page.h>
-#include <asm/io.h>
-#include <asm/string.h>
-
-#include <linux/list.h>
 
 #define bfa_sm_fault(__event)    do {                            \
 	pr_err("SM Assertion failure: %s: %d: event = %d\n",	\
-- 
1.7.1

