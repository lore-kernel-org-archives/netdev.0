From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: bridge: refcount fix
Date: Mon, 24 Aug 2009 19:18:31 +0200
Message-ID: <4A92CB67.1080401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Bart De Schuymer <bdschuym@pandora.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44665 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZHXRSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:18:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I found following by code review only, I am not sure it is critical enough for net-2.6

This is a stable candidate, bug is more than 2 years old.

Thanks

commit f216f082b2b37c4943f1e7c393e2786648d48f6f
([NETFILTER]: bridge netfilter: deal with martians correctly)
added a refcount leak on in_dev.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4fde742..c62eca3 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -386,6 +386,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 				dst_release((struct dst_entry *)rt);
 			}
 free_skb:
+			in_dev_put(in_dev);
 			kfree_skb(skb);
 			return 0;
 		} else {

