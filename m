From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2: Eliminate TSO header modifications.
Date: Thu,  9 Oct 2008 10:16:06 -0700
Message-ID: <1223572568-1298-4-git-send-email-mchan@broadcom.com>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2468 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835AbYJIRKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 13:10:46 -0400
In-Reply-To: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is now possible with updated firmware.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 21711c7..f147204 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6008,7 +6008,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 	if ((mss = skb_shinfo(skb)->gso_size)) {
-		u32 tcp_opt_len, ip_tcp_len;
+		u32 tcp_opt_len;
 		struct iphdr *iph;
 
 		vlan_tag_flags |= TX_BD_FLAGS_SW_LSO;
@@ -6032,21 +6032,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				mss |= (tcp_off & 0xc) << TX_BD_TCP6_OFF2_SHL;
 			}
 		} else {
-			if (skb_header_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-				dev_kfree_skb(skb);
-				return NETDEV_TX_OK;
-			}
-
-			ip_tcp_len = ip_hdrlen(skb) + sizeof(struct tcphdr);
-
 			iph = ip_hdr(skb);
-			iph->check = 0;
-			iph->tot_len = htons(mss + ip_tcp_len + tcp_opt_len);
-			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
 			if (tcp_opt_len || (iph->ihl > 5)) {
 				vlan_tag_flags |= ((iph->ihl - 5) +
 						   (tcp_opt_len >> 2)) << 8;
-- 
1.5.6.GIT


