From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/8] qlcnic: Free up memory in error path.
Date: Fri, 2 Aug 2013 23:15:56 -0400
Message-ID: <1375499761-21141-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:65360 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755233Ab3HCD4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 23:56:35 -0400
In-Reply-To: <1375499761-21141-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 0581a48..8d401ba 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -210,10 +210,10 @@ int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *adapter, u32 fw_cmd)
 	if (err) {
 		dev_info(&adapter->pdev->dev,
 			 "Failed to set driver version in firmware\n");
-		return -EIO;
+		err = -EIO;
 	}
-
-	return 0;
+	qlcnic_free_mbx_args(&cmd);
+	return err;
 }
 
 int
-- 
1.5.6
