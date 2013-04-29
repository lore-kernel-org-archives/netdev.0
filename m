From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Use GET_FUNCTION_CONFIG V1 cmd
Date: Mon, 29 Apr 2013 13:51:13 +0530
Message-ID: <41c8bb00-18f0-474f-b5f2-041333b7f208@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kalesh AP <kalesh.purayil@emulex.com>,
	"Somnath Kotur" <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:45695 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab3D2IWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 04:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Skyhawk-R requires V1 version of GET_FUNCTION_CONFIG cmd to be used for
querrying resources available per function.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d837e4c..9080c27 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2936,7 +2936,7 @@ static struct be_nic_resource_desc *be_get_nic_desc(u8 *buf, u32 desc_count,
 	int i;
 
 	for (i = 0; i < desc_count; i++) {
-		desc->desc_len = RESOURCE_DESC_SIZE;
+		desc->desc_len = desc->desc_len ? : RESOURCE_DESC_SIZE;
 		if (((void *)desc + desc->desc_len) >
 		    (void *)(buf + max_buf_size)) {
 			desc = NULL;
@@ -2987,6 +2987,9 @@ int be_cmd_get_func_config(struct be_adapter *adapter)
 			       OPCODE_COMMON_GET_FUNC_CONFIG,
 			       cmd.size, wrb, &cmd);
 
+	if (skyhawk_chip(adapter))
+		req->hdr.version = 1;
+
 	status = be_mbox_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_get_func_config *resp = cmd.va;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 0fc9b47..1b01e9b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1741,7 +1741,7 @@ struct be_cmd_req_get_func_config {
 };
 
 struct be_cmd_resp_get_func_config {
-	struct be_cmd_req_hdr hdr;
+	struct be_cmd_resp_hdr hdr;
 	u32 desc_count;
 	u8 func_param[MAX_RESOURCE_DESC * RESOURCE_DESC_SIZE];
 };
-- 
1.6.0.2
