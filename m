From: Ram Amrani <Ram.Amrani@cavium.com>
Subject: [RFC v2 12/12] IB/core: add a protection to ib_get_dma_mr
Date: Tue, 20 Sep 2016 13:36:04 +0300
Message-ID: <1474367764-9555-13-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@cavium.com>, <Michal.Kalderon@cavium.com>,
        <Yuval.Mintz@cavium.com>, <rajesh.borundia@cavium.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram amrani <Ram.Amrani@cavium.com>
To: <davem@davemloft.net>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32962 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932990AbcITKhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:37:22 -0400
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram amrani <Ram.Amrani@cavium.com>

Add a check that prevents ib_get_dma_mr from executing if
IB_ACCESS_MW_BIND is set.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
---
 drivers/infiniband/core/verbs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index f2b776e..8cc6f79 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1400,6 +1400,9 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
 	if (err)
 		return ERR_PTR(err);
 
+	if (mr_access_flags & IB_ACCESS_MW_BIND)
+		return ERR_PTR(-EINVAL);
+
 	mr = pd->device->get_dma_mr(pd, mr_access_flags);
 
 	if (!IS_ERR(mr)) {
-- 
1.8.3.1
