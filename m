From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 5/5] be2net: Use V1 query link status command for lancer
Date: Wed, 16 Nov 2011 17:33:45 +0530
Message-ID: <120dcfc1-ba4f-4bca-b92e-761b030a3170@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:45661 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756629Ab1KPMEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 07:04:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use V1 version of query link status command for Lancer.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 1522065..64f0c1a 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1246,6 +1246,9 @@ int be_cmd_link_status_query(struct be_adapter *adapter, u8 *mac_speed,
 	}
 	req = embedded_payload(wrb);
 
+	if (lancer_chip(adapter))
+		req->hdr.version = 1;
+
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_LINK_STATUS_QUERY, sizeof(*req), wrb, NULL);
 
-- 
1.6.0.2
