From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/2] be2net: fix multicast filter programming
Date: Tue, 27 Sep 2011 16:55:13 +0530
Message-ID: <1317122713-5640-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:5099 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753428Ab1I0LZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 07:25:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Re-posting with subject fixed!

 Multicast programming has been broken since commit 5b8821b7. Setting the
 MULTICAST flag while sending the cmd to the FW was missing. Fixed this.

Also fixed-up some indentation in the adjacent lines.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bebeee6..6bc07c7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1580,14 +1580,16 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 					BE_IF_FLAGS_VLAN_PROMISCUOUS);
 		if (value == ON)
 			req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
-					BE_IF_FLAGS_VLAN_PROMISCUOUS);
+						BE_IF_FLAGS_VLAN_PROMISCUOUS);
 	} else if (flags & IFF_ALLMULTI) {
 		req->if_flags_mask = req->if_flags =
-			cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
+				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
 	} else {
 		struct netdev_hw_addr *ha;
 		int i = 0;
 
+		req->if_flags_mask = req->if_flags =
+				cpu_to_le32(BE_IF_FLAGS_MULTICAST);
 		req->mcast_num = cpu_to_le16(netdev_mc_count(adapter->netdev));
 		netdev_for_each_mc_addr(ha, adapter->netdev)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
-- 
1.7.4
