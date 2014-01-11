From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: copy traffic class from ping request to reply
Date: Sat, 11 Jan 2014 11:55:46 +0100
Message-ID: <20140111105546.GB30388@order.stressinduktion.org>
References: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56146 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaAKKzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 05:55:48 -0500
Content-Disposition: inline
In-Reply-To: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Simon Schneider <simon-schneider@gmx.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/icmp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9a809a4..8003b49 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -67,6 +67,7 @@
 #include <net/icmp.h>
 #include <net/xfrm.h>
 #include <net/inet_common.h>
+#include <net/dsfield.h>
 
 #include <asm/uaccess.h>
 
@@ -553,6 +554,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct dst_entry *dst;
 	int err = 0;
 	int hlimit;
+	u8 tclass;
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
@@ -603,8 +605,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	msg.offset = 0;
 	msg.type = ICMPV6_ECHO_REPLY;
 
+	tclass = ipv6_get_dsfield(ipv6_hdr(skb));
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl6,
+				sizeof(struct icmp6hdr), hlimit, tclass, NULL, &fl6,
 				(struct rt6_info *)dst, MSG_DONTWAIT,
 				np->dontfrag);
 
-- 
1.8.4.2
