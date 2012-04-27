From: roy.qing.li@gmail.com
Subject: [PATCH net-next 2/2] drivers/net/oki-semi: Donot recompute IP header checksum
Date: Fri, 27 Apr 2012 15:01:13 +0800
Message-ID: <1335510073-14018-2-git-send-email-roy.qing.li@gmail.com>
References: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:65441 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508Ab2D0HB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 03:01:27 -0400
Received: by mail-pz0-f51.google.com with SMTP id z8so605612dad.10
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 00:01:27 -0700 (PDT)
In-Reply-To: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

If I understand correct, NETIF_F_IP_CSUM only means the hardware 
will compute the TCP/UDP checksum, IP checksum is always computed 
in software

So as a workround of hardware unable to compute small packages 
checksum, do not need to compute IP header checksum.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 835e3bb..107f41a 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1240,8 +1240,6 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 		if (skb->protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
 			unsigned int offset;
-			iph->check = 0;
-			iph->check = ip_fast_csum((u8 *) iph, iph->ihl);
 			offset = skb_transport_offset(skb);
 			if (iph->protocol == IPPROTO_TCP) {
 				skb->csum = 0;
-- 
1.7.1
