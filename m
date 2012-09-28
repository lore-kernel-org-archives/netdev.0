From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 1/4] be2net: remove type argument of be_cmd_mac_addr_query()
Date: Fri, 28 Sep 2012 20:09:41 +0530
Message-ID: <29e503e4-1dc2-4430-8a25-b20f49c1b3f4@CMEXHTCAS2.ad.emulex.com>
References: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49342 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758393Ab2I1PDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 11:03:24 -0400
In-Reply-To: <1348843184-22214-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All invocations of this routine use the same type value.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 ++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   18 ++++++------------
 3 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 701b3e9..6fbfb20 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -717,7 +717,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 
 /* Use MCC */
 int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
-			u8 type, bool permanent, u32 if_handle, u32 pmac_id)
+			  bool permanent, u32 if_handle, u32 pmac_id)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_mac_query *req;
@@ -734,7 +734,7 @@ int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_MAC_QUERY, sizeof(*req), wrb, NULL);
-	req->type = type;
+	req->type = MAC_ADDRESS_TYPE_NETWORK;
 	if (permanent) {
 		req->permanent = 1;
 	} else {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 250f19b..1f5b839 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1687,7 +1687,7 @@ struct be_cmd_req_set_ext_fat_caps {
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_fw_wait_ready(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
-			u8 type, bool permanent, u32 if_handle, u32 pmac_id);
+				 bool permanent, u32 if_handle, u32 pmac_id);
 extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 			u32 if_id, u32 *pmac_id, u32 domain);
 extern int be_cmd_pmac_del(struct be_adapter *adapter, u32 if_id,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 84379f4..fa17430 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -241,9 +241,8 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	status = be_cmd_mac_addr_query(adapter, current_mac,
-				MAC_ADDRESS_TYPE_NETWORK, false,
-				adapter->if_handle, 0);
+	status = be_cmd_mac_addr_query(adapter, current_mac, false,
+				       adapter->if_handle, 0);
 	if (status)
 		goto err;
 
@@ -2693,21 +2692,16 @@ static int be_get_mac_addr(struct be_adapter *adapter, u8 *mac, u32 if_handle,
 		status = be_cmd_get_mac_from_list(adapter, mac,
 						  active_mac, pmac_id, 0);
 		if (*active_mac) {
-			status = be_cmd_mac_addr_query(adapter, mac,
-						       MAC_ADDRESS_TYPE_NETWORK,
-						       false, if_handle,
-						       *pmac_id);
+			status = be_cmd_mac_addr_query(adapter, mac, false,
+						       if_handle, *pmac_id);
 		}
 	} else if (be_physfn(adapter)) {
 		/* For BE3, for PF get permanent MAC */
-		status = be_cmd_mac_addr_query(adapter, mac,
-					       MAC_ADDRESS_TYPE_NETWORK, true,
-					       0, 0);
+		status = be_cmd_mac_addr_query(adapter, mac, true, 0, 0);
 		*active_mac = false;
 	} else {
 		/* For BE3, for VF get soft MAC assigned by PF*/
-		status = be_cmd_mac_addr_query(adapter, mac,
-					       MAC_ADDRESS_TYPE_NETWORK, false,
+		status = be_cmd_mac_addr_query(adapter, mac, false,
 					       if_handle, 0);
 		*active_mac = true;
 	}
-- 
1.7.4
