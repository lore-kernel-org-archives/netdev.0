From: roy.qing.li@gmail.com
Subject: [RFC][PATCH] ipv6: fix the check when handle RA
Date: Thu, 10 Jul 2014 16:29:06 +0800
Message-ID: <1404980946-3289-1-git-send-email-roy.qing.li@gmail.com>
Cc: greearb@candelatech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:44643 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaGJI3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:29:04 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so10291970pdj.8
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:29:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made
ndisc_router_discovery to skip to handle RA when accept_ra_from_local
is 0 and saddr of packet is not the device address, in fact, this
condition should be handled

Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
Cc: Ben Greear <greearb@candelatech.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ndisc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a845e3d..e70e805 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1152,8 +1152,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	 * accept_ra_from_local is set to true.
 	 */
 	if (!(in6_dev->cnf.accept_ra_from_local ||
-	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			    NULL, 0))) {
+	      !ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			     NULL, 0))) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: default router ignored\n",
 			  skb->dev->name);
@@ -1295,8 +1295,8 @@ skip_linkparms:
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	if (!(in6_dev->cnf.accept_ra_from_local ||
-	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			    NULL, 0))) {
+	      !ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			     NULL, 0))) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: router info ignored.\n",
 			  skb->dev->name);
-- 
1.7.10.4
