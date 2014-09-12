From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/8] be2net: replace strcpy with strlcpy
Date: Fri, 12 Sep 2014 17:39:15 +0530
Message-ID: <1410523761-1744-3-git-send-email-sathya.perla@emulex.com>
References: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21722 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbaILMGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:06:48 -0400
In-Reply-To: <1410523761-1744-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Replace strcpy with strlcpy, as it avoids a possible buffer overflow.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d6685ab..8bb6fd9 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1770,8 +1770,10 @@ int be_cmd_get_fw_ver(struct be_adapter *adapter)
 	if (!status) {
 		struct be_cmd_resp_get_fw_version *resp = embedded_payload(wrb);
 
-		strcpy(adapter->fw_ver, resp->firmware_version_string);
-		strcpy(adapter->fw_on_flash, resp->fw_on_flash_version_string);
+		strlcpy(adapter->fw_ver, resp->firmware_version_string,
+			sizeof(adapter->fw_ver));
+		strlcpy(adapter->fw_on_flash, resp->fw_on_flash_version_string,
+			sizeof(adapter->fw_on_flash));
 	}
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
@@ -2209,7 +2211,7 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 	req->write_offset = cpu_to_le32(data_offset);
-	strcpy(req->object_name, obj_name);
+	strlcpy(req->object_name, obj_name, sizeof(req->object_name));
 	req->descriptor_count = cpu_to_le32(1);
 	req->buf_len = cpu_to_le32(data_size);
 	req->addr_low = cpu_to_le32((cmd->dma +
@@ -2262,7 +2264,7 @@ int lancer_cmd_delete_object(struct be_adapter *adapter, const char *obj_name)
 			       OPCODE_COMMON_DELETE_OBJECT,
 			       sizeof(*req), wrb, NULL);
 
-	strcpy(req->object_name, obj_name);
+	strlcpy(req->object_name, obj_name, sizeof(req->object_name));
 
 	status = be_mcc_notify_wait(adapter);
 err:
-- 
1.7.1
