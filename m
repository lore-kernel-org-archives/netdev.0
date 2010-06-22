From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 7/8] qlcnic: mark context state freed after destroy
Date: Tue, 22 Jun 2010 06:19:04 -0700
Message-ID: <1277212745-26857-8-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48236 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755015Ab0FVNTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:08 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

After destroying recv ctx, context state remain same.
Fix it by marking as FREED.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h     |    2 +-
 drivers/net/qlcnic/qlcnic_ctx.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 6ec34a7..7fa761a 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -573,7 +573,7 @@ struct qlcnic_recv_context {
 /*
  * Context state
  */
-
+#define QLCNIC_HOST_CTX_STATE_FREED	0
 #define QLCNIC_HOST_CTX_STATE_ACTIVE	2
 
 /*
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index be341c1..941cd08 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -280,6 +280,8 @@ qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
 		dev_err(&adapter->pdev->dev,
 			"Failed to destroy rx ctx in firmware\n");
 	}
+
+	recv_ctx->state = QLCNIC_HOST_CTX_STATE_FREED;
 }
 
 static int
-- 
1.6.0.2

