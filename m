From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 3/3] be2net: fix bug in vlan rx path for big endian
 architecture
Date: Wed, 31 Mar 2010 17:30:32 +0530
Message-ID: <20100331120021.GA9185@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:54490 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755790Ab0CaMAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 08:00:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan traffic on big endian architecture is broken.
Need to swap the vid before giving packet to stack.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index b0faaa2..ec6ace8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -807,7 +807,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 			return;
 		}
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		vid = be16_to_cpu(vid);
+		vid = swab16(vid);
 		vlan_hwaccel_receive_skb(skb, adapter->vlan_grp, vid);
 	} else {
 		netif_receive_skb(skb);
@@ -884,7 +884,7 @@ static void be_rx_compl_process_gro(struct be_adapter *adapter,
 		napi_gro_frags(&eq_obj->napi);
 	} else {
 		vid = AMAP_GET_BITS(struct amap_eth_rx_compl, vlan_tag, rxcp);
-		vid = be16_to_cpu(vid);
+		vid = swab16(vid);
 
 		if (!adapter->vlan_grp || adapter->vlans_added == 0)
 			return;
-- 
1.6.3.3

