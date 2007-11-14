From: Patrick McHardy <kaber@trash.net>
Subject: Fix net-2.6.25 compiler error
Date: Wed, 14 Nov 2007 10:52:53 +0100
Message-ID: <473AC575.7020306@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030707070907040708070707"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39554 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbXKNJxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:53:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030707070907040708070707
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix a missed NF_IP6_LOCAL_OUT conversion.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------030707070907040708070707
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 201e251..960ba17 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -164,7 +164,7 @@ static void send_reset(struct sk_buff *oldskb)
 static inline void
 send_unreach(struct sk_buff *skb_in, unsigned char code, unsigned int hooknum)
 {
-	if (hooknum == NF_IP6_LOCAL_OUT && skb_in->dev == NULL)
+	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
 		skb_in->dev = init_net.loopback_dev;
 
 	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0, NULL);

--------------030707070907040708070707--
