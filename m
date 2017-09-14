From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net] udpv6: Fix the checksum computation when HW checksum does not apply
Date: Wed, 13 Sep 2017 19:30:51 -0600
Message-ID: <1505352651-14828-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55230 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751279AbdINBbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 21:31:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying an ESP transport mode encryption for UDPv6 packets of
datagram size 1436 with MTU 1500, checksum error was observed in
the secondary fragment.

This error occurs due to the UDP payload checksum being missed out
when computing the full checksum for these packets in
udp6_hwcsum_outgoing().

Fixes: d39d938c8228 ("ipv6: Introduce udpv6_send_skb()")
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv6/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e2ecfb1..40d7234 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1015,6 +1015,7 @@ static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
 		 */
 		offset = skb_transport_offset(skb);
 		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		csum = skb->csum;
 
 		skb->ip_summed = CHECKSUM_NONE;
 
-- 
1.9.1
