From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH NEXT 3/6] netxen_nic: Fix phy link status
Date: Fri, 3 Feb 2012 13:35:12 -0800
Message-ID: <1328304915-12858-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:10583
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757973Ab2BCVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:51:12 -0500
In-Reply-To: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Pass the adapter phy link status to the caller.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_ctx.c    |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index 8f89c05..f3c0057 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -559,7 +559,11 @@ nx_fw_cmd_query_phy(struct netxen_adapter *adapter, u32 reg, u32 *val)
 	if (rcode != NX_RCODE_SUCCESS)
 		return -EIO;
 
-	return cmd.rsp.arg1;
+	if (val == NULL)
+		return -EIO;
+
+	*val = cmd.rsp.arg1;
+	return 0;
 }
 
 int
-- 
1.7.3.3
