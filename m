From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net 1/3] be2net: fix status check in be_cmd_pmac_add()
Date: Fri, 13 Jan 2017 22:38:27 +0100
Message-ID: <20170113213829.22722-1-cera@cera.cz>
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38388 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdAMVie (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 16:38:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return value from be_mcc_notify_wait() contains a base completion status
together with an additional status. The base_status() macro need to be
used to access base status.

Fixes: e3a7ae2 be2net: Changing MAC Address of a VF was broken
Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 0e74529..30e8550 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1118,7 +1118,7 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 err:
 	mutex_unlock(&adapter->mcc_lock);
 
-	 if (status == MCC_STATUS_UNAUTHORIZED_REQUEST)
+	 if (base_status(status) == MCC_STATUS_UNAUTHORIZED_REQUEST)
 		status = -EPERM;
 
 	return status;
-- 
2.10.2
