From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 09/10] bna: HW Error Counter Fix
Date: Fri, 22 Jul 2011 11:07:48 -0700
Message-ID: <1311358069-32067-10-git-send-email-rmody@brocade.com>
References: <1311358069-32067-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39799 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754632Ab1GVSIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 14:08:47 -0400
In-Reply-To: <1311358069-32067-1-git-send-email-rmody@brocade.com>
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
index fa81f3c..b080b36 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -153,6 +153,7 @@ struct bfa_ioc_drv_stats {
 	u32	enable_reqs;
 	u32	disable_replies;
 	u32	enable_replies;
+	u32	rsvd;
 };
 
 /**
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index c3b62a3..126b0aa 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -2029,6 +2029,8 @@ bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc)
 void
 bfa_nw_ioc_error_isr(struct bfa_ioc *ioc)
 {
+	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_ioc_stats_hb_count(ioc, ioc->hb_count);
 	bfa_fsm_send_event(ioc, IOC_E_HWERROR);
 }
 
@@ -2255,6 +2257,7 @@ bfa_ioc_recover(struct bfa_ioc *ioc)
 {
 	pr_crit("Heart Beat of IOC has failed\n");
 	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_ioc_stats_hb_count(ioc, ioc->hb_count);
 	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
 
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index c6cf218..4b5dc98 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -237,6 +237,8 @@ struct bfa_ioc_hwif {
 	BFI_ADAPTER_GETP(NPORTS, (__ioc)->attr->adapter_prop)
 
 #define bfa_ioc_stats(_ioc, _stats)	((_ioc)->stats._stats++)
+#define bfa_ioc_stats_hb_count(_ioc, _hb_count)	\
+	((_ioc)->stats.hb_count = (_hb_count))
 #define BFA_IOC_FWIMG_MINSZ	(16 * 1024)
 #define BFA_IOC_FWIMG_TYPE(__ioc)					\
 	(((__ioc)->ctdev) ?						\
-- 
1.7.1

