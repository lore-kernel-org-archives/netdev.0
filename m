From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: honor ifindex in case we receive ll addresses in router advertisements
Date: Wed, 23 Dec 2015 22:44:37 +0100
Message-ID: <1450907077-19424-1-git-send-email-hannes@stressinduktion.org>
Cc: Marc Haber <mh+netdev@zugschlus.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43296 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411AbbLWVop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 16:44:45 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 7F04F20997
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 16:44:44 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Haber reported we don't honor interface indexes when we receive link
local router addresses in router advertisements. Luckily the non-strict
version of ipv6_chk_addr already does the correct job here, so we can
simply use it to lighten the checks and use those addresses by default
without any configuration change.

Link: <http://permalink.gmane.org/gmane.linux.network/391348>
Reported-by: Marc Haber <mh+netdev@zugschlus.de>
Cc: Marc Haber <mh+netdev@zugschlus.de>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ndisc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d6161e1c48c86f..84afb9a7727848 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1183,7 +1183,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	 */
 	if (!in6_dev->cnf.accept_ra_from_local &&
 	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			  NULL, 0)) {
+			  in6_dev->dev, 0)) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: default router ignored\n",
 			  skb->dev->name);
@@ -1337,7 +1337,7 @@ skip_linkparms:
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	if (!in6_dev->cnf.accept_ra_from_local &&
 	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			  NULL, 0)) {
+			  in6_dev->dev, 0)) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: router info ignored.\n",
 			  skb->dev->name);
-- 
2.5.0
