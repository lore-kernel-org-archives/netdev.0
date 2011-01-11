From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Increase the skb array usage
Date: Tue, 11 Jan 2011 15:45:57 -0200
Message-ID: <1294767957-25804-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:44531 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410Ab1AKRqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 12:46:30 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id p0BHaf7m027384
	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 15:36:41 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0BHrkrT2437216
	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 15:53:49 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0BHjpxQ014526
	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 15:45:51 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>

Currently the skb array is not fully allocated, and the allocation
is done as it' s requested, which is not the expected way.

This patch just allocate the full skb array at driver initialization.
Also, this patch increases ehea version to 107.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |    6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index a724a2d..6c7257b 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0106"
+#define DRV_VERSION	"EHEA_0107"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 1032b5b..f75d314 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -437,7 +437,7 @@ static void ehea_init_fill_rq1(struct ehea_port_res *pr, int nr_rq1a)
 		}
 	}
 	/* Ring doorbell */
-	ehea_update_rq1a(pr->qp, i);
+	ehea_update_rq1a(pr->qp, i - 1);
 }
 
 static int ehea_refill_rq_def(struct ehea_port_res *pr,
@@ -1329,9 +1329,7 @@ static int ehea_fill_port_res(struct ehea_port_res *pr)
 	int ret;
 	struct ehea_qp_init_attr *init_attr = &pr->qp->init_attr;
 
-	ehea_init_fill_rq1(pr, init_attr->act_nr_rwqes_rq1
-			       - init_attr->act_nr_rwqes_rq2
-			       - init_attr->act_nr_rwqes_rq3 - 1);
+	ehea_init_fill_rq1(pr, pr->rq1_skba.len);
 
 	ret = ehea_refill_rq2(pr, init_attr->act_nr_rwqes_rq2 - 1);
 
-- 
1.7.1

