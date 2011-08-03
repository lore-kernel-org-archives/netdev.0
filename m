From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: fix cmd-rx-filter not notifying MCC
Date: Wed, 3 Aug 2011 17:16:33 +0530
Message-ID: <1312371993-3015-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27334 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753634Ab1HCLpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 07:45:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, I missed out on this line while composing the 4/6 patch from my
yesterday's patchset ("[PATCH net-next 4/6] be2net: use RX_FILTER cmd to program multicast addresses"). As you've already queued up the patchset for net-next,
 I'm sending the fix in a separate patch. Pls apply.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 7292be6..4278595 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1593,6 +1593,7 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
+	status = be_mcc_notify_wait(adapter);
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
-- 
1.7.4

