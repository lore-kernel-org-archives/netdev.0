From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 2/2] be2net: Reset multicast promiscuous mode when its
 enabled
Date: Fri, 2 May 2014 14:43:36 -0500
Message-ID: <20140502194336.GA20113@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20364 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbaEBTnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:43:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we are resetting the multicast promiscuous mode everytime
we send a multicast list to the FW. It is unnecessary.
With this fix we disable multicast promiscuous mode only when enabled.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d1ec15a..78888ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1858,9 +1858,11 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 		/* Reset mcast promisc mode if already set by setting mask
 		 * and not setting flags field
 		 */
-		req->if_flags_mask |=
-			cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS &
-				    be_if_cap_flags(adapter));
+		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
+			req->if_flags_mask |=
+				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS &
+					    be_if_cap_flags(adapter));
+
 		req->mcast_num = cpu_to_le32(netdev_mc_count(adapter->netdev));
 		netdev_for_each_mc_addr(ha, adapter->netdev)
 			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
-- 
1.8.3.2
