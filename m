From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 1/2] qlcnic: Fix programming number of arguments in a command.
Date: Tue, 14 Oct 2014 07:41:45 -0400
Message-ID: <1413286906-14220-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:4666 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932146AbaJNMQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 08:16:29 -0400
In-Reply-To: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Initially we were programming maximum number of arguments.
  Instead we should program number of arguments required in
  a command.
o Maximum number of arguments for 82xx adapter is four. Fix it
  for GET_ESWITCH_STATS command.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index ffbae29..243752f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -32,7 +32,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
 	{QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1},
 	{QLCNIC_CMD_GET_MAC_STATS, 4, 1},
 	{QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3},
-	{QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1},
+	{QLCNIC_CMD_GET_ESWITCH_STATS, 4, 1},
 	{QLCNIC_CMD_CONFIG_PORT, 4, 1},
 	{QLCNIC_CMD_TEMP_SIZE, 4, 4},
 	{QLCNIC_CMD_GET_TEMP_HDR, 4, 1},
@@ -129,7 +129,7 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 	}
 
 	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
-	for (i = 1; i < QLCNIC_CDRP_MAX_ARGS; i++)
+	for (i = 1; i < cmd->req.num; i++)
 		QLCWR32(adapter, QLCNIC_CDRP_ARG(i), cmd->req.arg[i]);
 	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET,
 		QLCNIC_CDRP_FORM_CMD(cmd->req.arg[0]));
-- 
1.6.3.3
