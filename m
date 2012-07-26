From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH] be2net: Fix to parse RSS hash from Receive completions correctly.
Date: Thu, 26 Jul 2012 12:59:50 +0530
Message-ID: <2594050c-c887-436e-a6ba-01f7d804c03c@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:30967 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab2GZHf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 03:35:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Wrong pointer variable is being used to parse the rss hash from
receive completions leading to corrupted rss_hash values filled into skb.

Please apply to net.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4d96771..d38bf6c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1397,7 +1397,7 @@ static void be_parse_rx_compl_v1(struct be_eth_rx_compl *compl,
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, cast_enc, compl);
 	rxcp->rss_hash =
-		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, rsshash, rxcp);
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, rsshash, compl);
 	if (rxcp->vlanf) {
 		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm,
 					  compl);
@@ -1429,7 +1429,7 @@ static void be_parse_rx_compl_v0(struct be_eth_rx_compl *compl,
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, cast_enc, compl);
 	rxcp->rss_hash =
-		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, rsshash, rxcp);
+		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, rsshash, compl);
 	if (rxcp->vlanf) {
 		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm,
 					  compl);
-- 
1.7.9.5
