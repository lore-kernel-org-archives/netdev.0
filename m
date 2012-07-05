From: roy.qing.li@gmail.com
Subject: [PATCH 1/2] be2net: Fix Endian
Date: Thu,  5 Jul 2012 10:05:42 +0800
Message-ID: <1341453942-4198-1-git-send-email-roy.qing.li@gmail.com>
Cc: somnath.kotur@emulex.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48601 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab2GECGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 22:06:02 -0400
Received: by bkwj10 with SMTP id j10so3022395bkw.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 19:06:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

ETH_P_IP is host Endian, skb->protocol is big Endian, when
compare them, we should change ETH_P_IP from host endian
to big endian, htons, not ntohs.

CC: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 7a71fb6..0490a04 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -575,7 +575,7 @@ static inline u8 is_udp_pkt(struct sk_buff *skb)
 
 static inline bool is_ipv4_pkt(struct sk_buff *skb)
 {
-	return skb->protocol == ntohs(ETH_P_IP) && ip_hdr(skb)->version == 4;
+	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
 }
 
 static inline void be_vf_eth_addr_generate(struct be_adapter *adapter, u8 *mac)
-- 
1.7.1
