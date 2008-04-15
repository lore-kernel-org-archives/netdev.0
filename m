From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/7][IP6TUNNEL]: Use proper net in hash-lookup
 functions.
Date: Tue, 15 Apr 2008 18:02:22 +0400
Message-ID: <4804B56E.1090204@openvz.org>
References: <4804B478.3040606@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58344 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757071AbYDON2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 09:28:06 -0400
In-Reply-To: <4804B478.3040606@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calls to ip6_tnl_lookup were stubbed with init_net - give them
a proper one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/ip6_tunnel.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index fad1af8..72485a3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -412,7 +412,7 @@ ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	   processing of the error. */
 
 	read_lock(&ip6_tnl_lock);
-	if ((t = ip6_tnl_lookup(&init_net, &ipv6h->daddr,
+	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->daddr,
 					&ipv6h->saddr)) == NULL)
 		goto out;
 
@@ -696,7 +696,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	read_lock(&ip6_tnl_lock);
 
-	if ((t = ip6_tnl_lookup(&init_net, &ipv6h->saddr,
+	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 					&ipv6h->daddr)) != NULL) {
 		if (t->parms.proto != ipproto && t->parms.proto != 0) {
 			read_unlock(&ip6_tnl_lock);
-- 
1.5.3.4

