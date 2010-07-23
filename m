From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 6/7] be2net: variable name changes
Date: Fri, 23 Jul 2010 17:34:54 +0530
Message-ID: <20100723120441.GA25028@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:28327 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754032Ab0GWMEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 08:04:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes names of some variables.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_cmds.c |    4 ++--
 drivers/net/benet/be_cmds.h |    2 +-
 drivers/net/benet/be_main.c |    8 ++++----
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 8cfe3c4..434bc4b 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -285,7 +285,7 @@ struct be_adapter {
 	u32 port_num;
 	bool promiscuous;
 	bool wol;
-	u32 cap;
+	u32 function_mode;
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
 	int link_speed;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index cf3af05..abca65c 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1258,7 +1258,7 @@ err:
 }
 
 /* Uses mbox */
-int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *cap)
+int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *mode)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_query_fw_cfg *req;
@@ -1279,7 +1279,7 @@ int be_cmd_query_fw_cfg(struct be_adapter *adapter, u32 *port_num, u32 *cap)
 	if (!status) {
 		struct be_cmd_resp_query_fw_cfg *resp = embedded_payload(wrb);
 		*port_num = le32_to_cpu(resp->phys_port);
-		*cap = le32_to_cpu(resp->function_cap);
+		*mode = le32_to_cpu(resp->function_mode);
 	}
 
 	spin_unlock(&adapter->mbox_lock);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 3b69e71..036531c 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -749,7 +749,7 @@ struct be_cmd_resp_query_fw_cfg {
 	u32 be_config_number;
 	u32 asic_revision;
 	u32 phys_port;
-	u32 function_cap;
+	u32 function_mode;
 	u32 rsvd[26];
 };
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 79adcdd..d5b097d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -963,7 +963,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	/* vlanf could be wrongly set in some cards.
 	 * ignore if vtm is not set */
-	if ((adapter->cap & 0x400) && !vtm)
+	if ((adapter->function_mode & 0x400) && !vtm)
 		vlanf = 0;
 
 	if (unlikely(vlanf)) {
@@ -1003,7 +1003,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 
 	/* vlanf could be wrongly set in some cards.
 	 * ignore if vtm is not set */
-	if ((adapter->cap & 0x400) && !vtm)
+	if ((adapter->function_mode & 0x400) && !vtm)
 		vlanf = 0;
 
 	skb = napi_get_frags(&eq_obj->napi);
@@ -2500,7 +2500,7 @@ static int be_get_config(struct be_adapter *adapter)
 		return status;
 
 	status = be_cmd_query_fw_cfg(adapter,
-				&adapter->port_num, &adapter->cap);
+				&adapter->port_num, &adapter->function_mode);
 	if (status)
 		return status;
 
@@ -2520,7 +2520,7 @@ static int be_get_config(struct be_adapter *adapter)
 		memcpy(adapter->netdev->perm_addr, mac, ETH_ALEN);
 	}
 
-	if (adapter->cap & 0x400)
+	if (adapter->function_mode & 0x400)
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED/4;
 	else
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
-- 
1.7.0.4

