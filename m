From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] RDS: IB: Delete an error message for a failed memory
 allocation in rds_ib_add_one()
Date: Mon, 22 May 2017 16:11:37 +0200
Message-ID: <e3491aaa-f471-c67c-43dc-41d592159c8e@users.sourceforge.net>
References: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:58602 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933734AbdEVOLy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 10:11:54 -0400
In-Reply-To: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 15:34:28 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/rds/ib.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 7a64c8db81ab..c5514d058171 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -166,8 +166,5 @@ static void rds_ib_add_one(struct ib_device *device)
-	if (!rds_ibdev->vector_load) {
-		pr_err("RDS/IB: %s failed to allocate vector memory\n",
-			__func__);
+	if (!rds_ibdev->vector_load)
 		goto put_dev;
-	}
 
 	rds_ibdev->dev = device;
 	rds_ibdev->pd = ib_alloc_pd(device, 0);
-- 
2.13.0
