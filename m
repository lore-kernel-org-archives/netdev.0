From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/7] be2net: remove LANCER A0 workaround
Date: Wed, 7 Nov 2012 09:18:55 +0530
Message-ID: <5a4c06cc-b6ee-47c4-8813-c27cc7dffc7b@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46376 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab2KGDqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:10 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not needed anymore.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5e48674..d982cb0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -621,16 +621,6 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 			hdr, skb_shinfo(skb)->gso_size);
 		if (skb_is_gso_v6(skb) && !lancer_chip(adapter))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso6, hdr, 1);
-		if (lancer_chip(adapter) && adapter->sli_family  ==
-							LANCER_A0_SLI_FAMILY) {
-			AMAP_SET_BITS(struct amap_eth_hdr_wrb, ipcs, hdr, 1);
-			if (is_tcp_pkt(skb))
-				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
-								tcpcs, hdr, 1);
-			else if (is_udp_pkt(skb))
-				AMAP_SET_BITS(struct amap_eth_hdr_wrb,
-								udpcs, hdr, 1);
-		}
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (is_tcp_pkt(skb))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, tcpcs, hdr, 1);
-- 
1.7.1
