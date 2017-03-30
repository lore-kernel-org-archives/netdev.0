From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net] be2net: Fix endian issue in logical link config command
Date: Thu, 30 Mar 2017 00:58:32 -0400
Message-ID: <20170330045832.2287-1-suresh.reddy@broadcom.com>
References: <suresh.reddy@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:50985 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754586AbdC3FFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 01:05:32 -0400
Received: from s84.localdomain (unknown [10.192.238.84])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 337261A020F
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 21:58:34 -0700 (PDT)
In-Reply-To: <suresh.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cpu_to_le32() for link_config variable in set_logical_link_config
command as this variable is of type u32.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 0e74529..7c027d7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4939,8 +4939,9 @@ static int
 __be_cmd_set_logical_link_config(struct be_adapter *adapter,
 				 int link_state, int version, u8 domain)
 {
-	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_ll_link *req;
+	struct be_mcc_wrb *wrb;
+	u32 link_config = 0;
 	int status;
 
 	mutex_lock(&adapter->mcc_lock);
@@ -4962,10 +4963,12 @@ __be_cmd_set_logical_link_config(struct be_adapter *adapter,
 
 	if (link_state == IFLA_VF_LINK_STATE_ENABLE ||
 	    link_state == IFLA_VF_LINK_STATE_AUTO)
-		req->link_config |= PLINK_ENABLE;
+		link_config |= PLINK_ENABLE;
 
 	if (link_state == IFLA_VF_LINK_STATE_AUTO)
-		req->link_config |= PLINK_TRACK;
+		link_config |= PLINK_TRACK;
+
+	req->link_config = cpu_to_le32(link_config);
 
 	status = be_mcc_notify_wait(adapter);
 err:
-- 
2.10.1
