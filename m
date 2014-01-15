From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 02/11] be2net: don't set "pport" field when querying "pvid"
Date: Wed, 15 Jan 2014 13:23:32 +0530
Message-ID: <1389772421-24925-3-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20735 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaAOHtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:08 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

In the GET_HSW_CONFIG cmd, the "pport" field must be set only while
querying the switch mode.  When the "pport" field is set, the
"interface_id" field must be set to the port number, otherwise, it
must be set to adapter->if_handle.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 95eeb24..d9bdeba 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2996,7 +2996,7 @@ int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 		      ctxt, intf_id);
 	AMAP_SET_BITS(struct amap_get_hsw_req_context, pvid_valid, ctxt, 1);
 
-	if (!BEx_chip(adapter)) {
+	if (!BEx_chip(adapter) && mode) {
 		AMAP_SET_BITS(struct amap_get_hsw_req_context, interface_id,
 			      ctxt, adapter->hba_port_num);
 		AMAP_SET_BITS(struct amap_get_hsw_req_context, pport, ctxt, 1);
-- 
1.7.1
