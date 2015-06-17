From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 1/3] bna: remove unnecessary cast of BIT value
Date: Wed, 17 Jun 2015 18:41:56 +0200
Message-ID: <1434559318-31070-2-git-send-email-ivecera@redhat.com>
References: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033AbbFQQlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:41:23 -0400
In-Reply-To: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BIT value is already unsigned so casting is not necessary.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c | 3 +--
 drivers/net/ethernet/brocade/bna/bna_enet.c   | 4 ++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index 4247d8a..8d5c239 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -23,8 +23,7 @@
 #include "bfi_reg.h"
 #include "bfa_defs.h"
 
-#define bfa_ioc_ct_sync_pos(__ioc)	\
-		((u32)BIT(bfa_ioc_pcifn(__ioc)))
+#define bfa_ioc_ct_sync_pos(__ioc)	BIT(bfa_ioc_pcifn(__ioc))
 #define BFA_IOC_SYNC_REQD_SH		16
 #define bfa_ioc_ct_get_sync_ackd(__val) (__val & 0x0000ffff)
 #define bfa_ioc_ct_clear_sync_ackd(__val) (__val & 0xffff0000)
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 05680e0..4e5c387 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -207,7 +207,7 @@ bna_bfi_stats_get_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr)
 	for (i = 0; i < BFI_ENET_CFG_MAX; i++) {
 		stats_dst = (u64 *)&(bna->stats.hw_stats.rxf_stats[i]);
 		memset(stats_dst, 0, sizeof(struct bfi_enet_stats_rxf));
-		if (rx_enet_mask & ((u32)BIT(i))) {
+		if (rx_enet_mask & BIT(i)) {
 			int k;
 			count = sizeof(struct bfi_enet_stats_rxf) /
 				sizeof(u64);
@@ -222,7 +222,7 @@ bna_bfi_stats_get_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr)
 	for (i = 0; i < BFI_ENET_CFG_MAX; i++) {
 		stats_dst = (u64 *)&(bna->stats.hw_stats.txf_stats[i]);
 		memset(stats_dst, 0, sizeof(struct bfi_enet_stats_txf));
-		if (tx_enet_mask & ((u32)BIT(i))) {
+		if (tx_enet_mask & BIT(i)) {
 			int k;
 			count = sizeof(struct bfi_enet_stats_txf) /
 				sizeof(u64);
-- 
2.3.6
