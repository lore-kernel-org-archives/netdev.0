From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 38/45] bna: HW Error Counter Fix
Date: Mon, 18 Jul 2011 01:22:58 -0700
Message-ID: <1310977385-5268-28-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48275 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754786Ab1GRIZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:07 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Heartbeat failure counter is not incrementing under some scenarios.
   Update hbfails and hb_count stats during hwerror event.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |    1 +
 drivers/net/bna/bfa_ioc.c  |    3 +++
 drivers/net/bna/bfa_ioc.h  |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index ebe5e6c..9fe2623 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -155,6 +155,7 @@ struct bfa_ioc_drv_stats {
 	u32	enable_reqs;
 	u32	disable_replies;
 	u32	enable_replies;
+	u32	rsvd;
 };
 
 /**
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 6e17abd..e612ca4 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -2217,6 +2217,8 @@ bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc)
 void
 bfa_nw_ioc_error_isr(struct bfa_ioc *ioc)
 {
+	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_ioc_stats_hb_count(ioc, ioc->hb_count);
 	bfa_fsm_send_event(ioc, IOC_E_HWERROR);
 }
 
@@ -2448,6 +2450,7 @@ bfa_ioc_recover(struct bfa_ioc *ioc)
 {
 	pr_crit("Heart Beat of IOC has failed\n");
 	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_ioc_stats_hb_count(ioc, ioc->hb_count);
 	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
 
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 9ae201a..5b6cbbe 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -252,6 +252,8 @@ struct bfa_ioc_hwif {
 	BFI_ADAPTER_GETP(NPORTS, (__ioc)->attr->adapter_prop)
 
 #define bfa_ioc_stats(_ioc, _stats)	((_ioc)->stats._stats++)
+#define bfa_ioc_stats_hb_count(_ioc, _hb_count)	\
+	((_ioc)->stats.hb_count = (_hb_count))
 #define BFA_IOC_FWIMG_MINSZ	(16 * 1024)
 #define BFA_IOC_FW_SMEM_SIZE(__ioc)					\
 	((bfa_ioc_asic_gen(__ioc) == BFI_ASIC_GEN_CB)			\
-- 
1.7.1

