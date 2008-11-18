From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: ip_sockglue.c add static, annotate ports' endianness
Date: Tue, 18 Nov 2008 12:24:01 -0800
Message-ID: <1227039841.13182.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:38086 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbYKRUYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 15:24:06 -0500
Received: by an-out-0708.google.com with SMTP id d40so1360580and.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 12:24:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes sparse warnings:
net/ipv4/ip_sockglue.c:146:15: warning: incorrect type in assignment (different base types)
net/ipv4/ip_sockglue.c:146:15:    expected restricted __be16 [assigned] [usertype] sin_port
net/ipv4/ip_sockglue.c:146:15:    got unsigned short [unsigned] [short] [usertype] <noident>
net/ipv4/ip_sockglue.c:130:6: warning: symbol 'ip_cmsg_recv_dstaddr' was not declared. Should it be static?

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
These are new warnings between next-20081117 and next-20081118

 net/ipv4/ip_sockglue.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 624b534..43c0585 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -127,11 +127,11 @@ static void ip_cmsg_recv_security(struct msghdr *msg, struct sk_buff *skb)
 	security_release_secctx(secdata, seclen);
 }
 
-void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
+static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 {
 	struct sockaddr_in sin;
 	struct iphdr *iph = ip_hdr(skb);
-	u16 *ports = (u16 *) skb_transport_header(skb);
+	__be16 *ports = (__be16 *)skb_transport_header(skb);
 
 	if (skb_transport_offset(skb) + 4 > skb->len)
 		return;
-- 
1.6.0.4.994.g16bd3e



