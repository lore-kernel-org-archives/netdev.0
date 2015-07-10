From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 7/9] be2net: make the RX_FILTER command asynchronous
Date: Fri, 10 Jul 2015 05:32:49 -0400
Message-ID: <1436520771-11656-8-git-send-email-sathya.perla@avagotech.com>
References: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56758 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752586AbbGJJ0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:36 -0400
In-Reply-To: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

This fix makes the RX_FILTER cmd asynchronous, i.e., the caller issues
this cmd and doesn't wait for a completion from the FW. If the FW/adapter
is in an error state, this change helps in not holding up the rtnl_lock
and keeping bottom halves disabled while the driver timesout waiting for
a response from the FW.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index a299f7b..93934d3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1962,7 +1962,7 @@ static int __be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
-	status = be_mcc_notify_wait(adapter);
+	status = be_mcc_notify(adapter);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
-- 
2.4.1
