From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/4] be2net: fix payload_len value for GET_MAC_LIST cmd req
Date: Wed, 8 May 2013 17:35:48 +0530
Message-ID: <1368014750-25065-3-git-send-email-sathya.perla@emulex.com>
References: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:57221 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab3EHMDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:03:11 -0400
In-Reply-To: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The buffer size for a FW cmd request must be big enough to fit the response,
else the cmd fails. For GET_MAC_LIST cmd, though the memory allocated for
the cmd is big enough to fit the response, the payload_len value in the
WRB hdr is being set to the request length only.
Fix this for GET_MAC_LIST cmd.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index e1e5bb9..fd7b547 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2640,9 +2640,8 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 	req = get_mac_list_cmd.va;
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-				OPCODE_COMMON_GET_MAC_LIST, sizeof(*req),
-				wrb, &get_mac_list_cmd);
-
+			       OPCODE_COMMON_GET_MAC_LIST,
+			       get_mac_list_cmd.size, wrb, &get_mac_list_cmd);
 	req->hdr.domain = domain;
 	req->mac_type = MAC_ADDRESS_TYPE_NETWORK;
 	req->perm_override = 1;
-- 
1.7.1
