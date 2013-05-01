From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 4/4] be2net: Fix to receive Multicast Packets when
 Promiscuous mode is enabled on certain devices
Date: Wed, 1 May 2013 14:38:24 -0500
Message-ID: <20130501193824.GA3841@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6216 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427Ab3EATi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:38:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user requests Promiscuous mode on SkyHawk-R devices,
the FW enables Desparate Promiscuous mode.
Due to this, we need to explicitly enable Multicast Promiscuous mode
so that Multicast packets are received as well.

This patch fixes that.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3c1632a..c4a3e20 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1764,10 +1764,12 @@ int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 	req->if_id = cpu_to_le32(adapter->if_handle);
 	if (flags & IFF_PROMISC) {
 		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
-					BE_IF_FLAGS_VLAN_PROMISCUOUS);
+					BE_IF_FLAGS_VLAN_PROMISCUOUS |
+					BE_IF_FLAGS_MCAST_PROMISCUOUS);
 		if (value == ON)
 			req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
-						BE_IF_FLAGS_VLAN_PROMISCUOUS);
+						BE_IF_FLAGS_VLAN_PROMISCUOUS |
+						BE_IF_FLAGS_MCAST_PROMISCUOUS);
 	} else if (flags & IFF_ALLMULTI) {
 		req->if_flags_mask = req->if_flags =
 				cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
-- 
1.7.10.4
