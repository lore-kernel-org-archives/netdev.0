From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 1/2 net-next v3.16]r8169:  Disable set bit multicast enable per multicast address.
Date: Sat, 26 Mar 2016 12:57:00 +0200
Message-ID: <1458989821-19782-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-230-247.residential.rdsnet.ro ([5.14.230.247]:45263 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbcCZLYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 07:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch correct set bit multicast enable only once per set_rx_mode
 invocation.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7f6fb1f..f7b0dfb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4619,12 +4619,11 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	} else {
 		struct netdev_hw_addr *ha;
 
-		rx_mode = AcceptBroadcast | AcceptMyPhys;
+		rx_mode = AcceptBroadcast | AcceptMyPhys | AcceptMulticast;
 		mc_filter[1] = mc_filter[0] = 0;
 		netdev_for_each_mc_addr(ha, dev) {
 			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-			rx_mode |= AcceptMulticast;
 		}
 	}
 
-- 
2.1.4
