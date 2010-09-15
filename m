From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/9] tg3: Use skb_is_gso_v6()
Date: Wed, 15 Sep 2010 11:59:59 -0700
Message-ID: <1284577201-6117-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2586 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755134Ab0IOTBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 15:01:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the driver to prefer the skb_is_gso_v6() helper over
the explicit inlined version.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 179eb65..a4fbe4f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5574,9 +5574,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			goto out_unlock;
 		}
 
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+		if (skb_is_gso_v6(skb)) {
 			hdrlen = skb_headlen(skb) - ETH_HLEN;
-		else {
+		} else {
 			struct iphdr *iph = ip_hdr(skb);
 
 			tcp_opt_len = tcp_optlen(skb);
@@ -5798,7 +5798,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 		iph = ip_hdr(skb);
 		tcp_opt_len = tcp_optlen(skb);
 
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+		if (skb_is_gso_v6(skb)) {
 			hdr_len = skb_headlen(skb) - ETH_HLEN;
 		} else {
 			u32 ip_tcp_len;
-- 
1.7.1


