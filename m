From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 19/19] ndisc: Use compound literals to build redirect
 message.
Date: Tue, 22 Jan 2013 01:49:25 +0900
Message-ID: <50FD7195.1010103@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50385 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753780Ab3AUQt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:49:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1c01566..76ef435 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1481,18 +1481,14 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_put(buff, sizeof(*msg));
-	msg = (struct rd_msg *)icmp6_hdr(buff);
-
-	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
-	msg->icmph.icmp6_type = NDISC_REDIRECT;
-
-	/*
-	 *	copy target and destination addresses
-	 */
-
-	msg->target = *target;
-	msg->dest = ipv6_hdr(skb)->daddr;
+	msg = (struct rd_msg *)skb_put(buff, sizeof(*msg));
+	*msg = (struct rd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_REDIRECT,
+		},
+		.target = *target,
+		.dest = ipv6_hdr(skb)->daddr,
+	};
 
 	/*
 	 *	include target_address option
-- 
1.7.9.5
