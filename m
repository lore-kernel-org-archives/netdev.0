From: adobriyan@gmail.com
Subject: [PATCH 6/6] netns brnetfilter: small prerouting fixup
Date: Fri, 22 Aug 2008 02:34:20 +0400
Message-ID: <20080821222916.GT31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:43651 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770AbYHUWc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:32:57 -0400
Received: by mu-out-0910.google.com with SMTP id w8so261105mue.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:32:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/br_netfilter.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -357,7 +357,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			if (!ip_route_output_key(&init_net, &rt, &fl)) {
+			if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
-- 
1.5.6.3


