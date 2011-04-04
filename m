From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 1/1] bna: Fix for handling firmware heartbeat failure
Date: Mon, 4 Apr 2011 11:29:59 -0700
Message-ID: <1301941799-25324-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:56754 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754090Ab1DDSiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 14:38:09 -0400
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id p34IMF4a029637
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2011 11:30:28 -0700
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0a-000f0801.pphosted.com with ESMTP id vfh9j0308-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Apr 2011 11:30:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains a fix for gracefully handling firmware heartbeat
failure instead of forcing panic.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 34933cb..e3de0b8 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -2219,13 +2219,9 @@ bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
 static void
 bfa_ioc_recover(struct bfa_ioc *ioc)
 {
-	u16 bdf;
-
-	bdf = (ioc->pcidev.pci_slot << 8 | ioc->pcidev.pci_func << 3 |
-					ioc->pcidev.device_id);
-
-	pr_crit("Firmware heartbeat failure at %d", bdf);
-	BUG_ON(1);
+	pr_crit("Heart Beat of IOC has failed\n");
+	bfa_ioc_stats(ioc, ioc_hbfails);
+	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
 
 static void
-- 
1.7.1

