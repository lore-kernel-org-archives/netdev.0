From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 2/4] be2net: Fix disabling multicast promiscous mode
Date: Thu, 3 Nov 2011 17:19:27 +0530
Message-ID: <39ad2887-887b-44b2-9e51-64f0dfee6fc9@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:24415 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755800Ab1KCLuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 07:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If user tries to disable multicast promiscous mode, the adapter remains
in this mode as resetting the multicast promiscous mode was missing
in RX filter command. Fixed this.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bd8332c..03fe7cd 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1540,6 +1540,13 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 
 		req->if_flags_mask = req->if_flags =
 				cpu_to_le32(BE_IF_FLAGS_MULTICAST);
+
+		/* Reset mcast promisc mode if already set by setting mask
+		 * and not setting flags field
+		 */
+		req->if_flags_mask |=
+				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
+
 		req->mcast_num = cpu_to_le32(netdev_mc_count(adapter->netdev));
 		netdev_for_each_mc_addr(ha, adapter->netdev)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
-- 
1.6.0.2
