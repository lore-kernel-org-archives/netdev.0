From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: fix the check when handle RA
Date: Thu, 10 Jul 2014 18:02:46 +0800
Message-ID: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Cc: hannes@redhat.com, greearb@candelatech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53022 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbaGJKCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:02:46 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so10881813pac.33
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 03:02:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made the wrong
check, whether or not to accept RA with source-addr found on local machine, when
accept_ra_from_local is 0.

Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
Cc: Ben Greear <greearb@candelatech.com>
Cc: Hannes Frederic Sowa <hannes@redhat.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ndisc.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a845e3d..139b45f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1151,9 +1151,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	/* Do not accept RA with source-addr found on local machine unless
 	 * accept_ra_from_local is set to true.
 	 */
-	if (!(in6_dev->cnf.accept_ra_from_local ||
-	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			    NULL, 0))) {
+	if (!in6_dev->cnf.accept_ra_from_local &&
+	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			  NULL, 0)) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: default router ignored\n",
 			  skb->dev->name);
@@ -1294,9 +1294,9 @@ skip_linkparms:
 	}
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	if (!(in6_dev->cnf.accept_ra_from_local ||
-	      ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
-			    NULL, 0))) {
+	if (!in6_dev->cnf.accept_ra_from_local &&
+	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
+			  NULL, 0)) {
 		ND_PRINTK(2, info,
 			  "RA from local address detected on dev: %s: router info ignored.\n",
 			  skb->dev->name);
-- 
1.7.10.4
