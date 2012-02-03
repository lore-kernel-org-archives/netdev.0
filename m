From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 1/2] be2net: Fix link status query command
Date: Sat, 4 Feb 2012 01:19:46 +0530
Message-ID: <dfb6e835-d712-4f90-844f-6a31937379b4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:30564 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755847Ab2BCTut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 14:50:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version number in query link status command is getting overwritten in
be_wrb_cmd_hdr_prepare() routine. Move the initialization to fix this
issue. Also initialize the domain field.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 0fcb456..dd6e8e2 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1257,11 +1257,13 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 	}
 	req = embedded_payload(wrb);
 
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req), wrb, NULL);
+
 	if (adapter->generation == BE_GEN3 || lancer_chip(adapter))
 		req->hdr.version = 1;
 
-	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req), wrb, NULL);
+	req->hdr.domain = dom;
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
-- 
1.6.0.2
