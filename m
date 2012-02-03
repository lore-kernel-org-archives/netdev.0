From: Shawn Lu <shawn.lu@ericsson.com>
Subject: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Fri, 3 Feb 2012 12:16:52 -0800
Message-ID: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiaoclu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:45562 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755956Ab2BCURI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 15:17:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding RST packet outgoing interface to incomming interface
for tcp v4. This has few benefits:
1. tcp_v6_send_reset already did that.
2. This helps tcp connect with SO_BINDTODEVICE set. When connection
is lost, we still able to sending out RST using same interface.
3. limit RST traffic in ingress interface reduce the impact of
RST attack.

Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
---
 net/ipv4/tcp_ipv4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 90e4793..994b1ea 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -676,6 +676,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
+	arg.bound_dev_if = inet_iif(skb);
 
 	net = dev_net(skb_dst(skb)->dev);
 	arg.tos = ip_hdr(skb)->tos;
-- 
1.7.0.4
