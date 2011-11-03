From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 1/4] be2net: Fix endian issue in RX filter command
Date: Thu, 3 Nov 2011 17:19:13 +0530
Message-ID: <fc385713-1509-494b-a956-e61454a0831a@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:24415 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755767Ab1KCLuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 07:50:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cpu_to_le32() for mcast_num field in RX filter command as this
field is of type u32.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 824b8e6..bd8332c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1540,7 +1540,7 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 
 		req->if_flags_mask = req->if_flags =
 				cpu_to_le32(BE_IF_FLAGS_MULTICAST);
-		req->mcast_num = cpu_to_le16(netdev_mc_count(adapter->netdev));
+		req->mcast_num = cpu_to_le32(netdev_mc_count(adapter->netdev));
 		netdev_for_each_mc_addr(ha, adapter->netdev)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
-- 
1.6.0.2
