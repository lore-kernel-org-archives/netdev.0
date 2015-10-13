From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next] BNX2: free temp_stats_blk on error path
Date: Tue, 13 Oct 2015 10:05:19 +0800
Message-ID: <561C66DF.2080302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <manish.chopra@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>, <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:21804 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbbJMCFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:05:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bnx2_init_board, missing free temp_stats_blk on error path when
some operations do failed. Just add the 'kfree' operation.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 6259064..8fc3f3c 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8476,6 +8476,8 @@ err_out_disable:
 	pci_disable_device(pdev);

 err_out:
+	kfree(bp->temp_stats_blk);
+
 	return rc;
 }

-- 
1.9.0
