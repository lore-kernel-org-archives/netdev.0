From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC 1/5] net: bridge - use is_multicast_ether_addr helper
Date: Mon, 11 May 2009 15:46:40 +0400
Message-ID: <20090511125350.555985895@openvz.org>
References: <20090511114639.440944109@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:25787 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbZEKMx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 08:53:57 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2140704rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 05:53:57 -0700 (PDT)
Content-Disposition: inline; filename=net-br-use-is_multicast
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of handwritten constrcution it's better 
to use is_multicast_ether_addr.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/bridge/br_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/net/bridge/br_device.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_device.c
+++ linux-2.6.git/net/bridge/br_device.c
@@ -32,7 +32,7 @@ int br_dev_xmit(struct sk_buff *skb, str
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (dest[0] & 1)
+	if (is_multicast_ether_addr(dest))
 		br_flood_deliver(br, skb);
 	else if ((dst = __br_fdb_get(br, dest)) != NULL)
 		br_deliver(dst->dst, skb);

