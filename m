From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: udp: check sk->sk_no_check when sending udpv6 packet
Date: Mon, 20 Jan 2014 11:51:01 +0800
Message-ID: <52DC9D25.9070809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:39115 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbaATDvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 22:51:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


According to the user's intention, if SO_NO_CHECK option is
set to true, the udpv6 packet should be out with no checksum.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/udp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 089c741..8808c69 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1001,6 +1001,10 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
+	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {
+		skb->ip_summed = CHECKSUM_NONE;
+		goto send;
+	}
 	else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 		udp6_hwcsum_outgoing(sk, skb, &fl6->saddr, &fl6->daddr,
 				     up->len);
-- 
1.8.3.1
