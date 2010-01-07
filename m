From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 7/7] Staging: Octeon Ethernet: Use constants from in.h
Date: Thu,  7 Jan 2010 11:05:06 -0800
Message-ID: <1262891106-32146-7-git-send-email-ddaney@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17180 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516Ab0AGTGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:02 -0500
In-Reply-To: <4B463005.8060505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-defines.h |    3 ---
 drivers/staging/octeon/ethernet-tx.c      |    8 ++++----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index 9c4910e..00a8561 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -98,9 +98,6 @@
 #define MAX_SKB_TO_FREE 10
 #define MAX_OUT_QUEUE_DEPTH 1000
 
-#define IP_PROTOCOL_TCP             6
-#define IP_PROTOCOL_UDP             0x11
-
 #define FAU_NUM_PACKET_BUFFERS_TO_FREE (CVMX_FAU_REG_END - sizeof(uint32_t))
 #define TOTAL_NUMBER_OF_PORTS       (CVMX_PIP_NUM_INPUT_PORTS+1)
 
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index bc67e41..62258bd 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -359,8 +359,8 @@ dont_put_skbuff_in_hw:
 	if (USE_HW_TCPUDP_CHECKSUM && (skb->protocol == htons(ETH_P_IP)) &&
 	    (ip_hdr(skb)->version == 4) && (ip_hdr(skb)->ihl == 5) &&
 	    ((ip_hdr(skb)->frag_off == 0) || (ip_hdr(skb)->frag_off == 1 << 14))
-	    && ((ip_hdr(skb)->protocol == IP_PROTOCOL_TCP)
-		|| (ip_hdr(skb)->protocol == IP_PROTOCOL_UDP))) {
+	    && ((ip_hdr(skb)->protocol == IPPROTO_TCP)
+		|| (ip_hdr(skb)->protocol == IPPROTO_UDP))) {
 		/* Use hardware checksum calc */
 		pko_command.s.ipoffp1 = sizeof(struct ethhdr) + 1;
 	}
@@ -550,8 +550,8 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 		work->word2.s.dec_ipcomp = 0;	/* FIXME */
 #endif
 		work->word2.s.tcp_or_udp =
-		    (ip_hdr(skb)->protocol == IP_PROTOCOL_TCP)
-		    || (ip_hdr(skb)->protocol == IP_PROTOCOL_UDP);
+		    (ip_hdr(skb)->protocol == IPPROTO_TCP)
+		    || (ip_hdr(skb)->protocol == IPPROTO_UDP);
 #if 0
 		/* FIXME */
 		work->word2.s.dec_ipsec = 0;
-- 
1.6.0.6

