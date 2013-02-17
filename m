From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/6] qlcnic: fix unsupported CDRP command error message.
Date: Sat, 16 Feb 2013 23:53:46 -0500
Message-ID: <1361076831-31746-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361076831-31746-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:36805 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751391Ab3BQFPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 00:15:44 -0500
In-Reply-To: <1361076831-31746-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Add debug messages for FW CDRP command failure.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |   32 +++++++++++++++++++++-
 1 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 4a3bd64..51461ad 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -147,8 +147,36 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
 		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
-		dev_err(&pdev->dev, "failed card response code:0x%x\n",
-			cmd->rsp.arg[0]);
+		switch (cmd->rsp.arg[0]) {
+		case QLCNIC_RCODE_INVALID_ARGS:
+			dev_err(&pdev->dev, "CDRP invalid args 0x%x\n",
+				cmd->rsp.arg[0]);
+			break;
+		case QLCNIC_RCODE_NOT_SUPPORTED:
+		case QLCNIC_RCODE_NOT_IMPL:
+			dev_err(&pdev->dev,
+				"CDRP command not supported: 0x%x.\n",
+				cmd->rsp.arg[0]);
+			break;
+		case QLCNIC_RCODE_NOT_PERMITTED:
+			dev_err(&pdev->dev,
+				"CDRP requested action not permitted: 0x%x.\n",
+				cmd->rsp.arg[0]);
+			break;
+		case QLCNIC_RCODE_INVALID:
+			dev_err(&pdev->dev,
+				"CDRP invalid or unknown cmd received: 0x%x.\n",
+				cmd->rsp.arg[0]);
+			break;
+		case QLCNIC_RCODE_TIMEOUT:
+			dev_err(&pdev->dev, "CDRP command timeout: 0x%x.\n",
+				cmd->rsp.arg[0]);
+			break;
+		default:
+			dev_err(&pdev->dev, "CDRP command failed: 0x%x.\n",
+				cmd->rsp.arg[0]);
+			break;
+		}
 	} else if (rsp == QLCNIC_CDRP_RSP_OK)
 		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
 
-- 
1.7.1
