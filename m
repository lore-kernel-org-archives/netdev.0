From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] xfrm: Release dst if this dst is improper for vti tunnel
Date: Tue, 19 Nov 2013 16:53:28 +0800
Message-ID: <1384851208-30353-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <saurabh.mohan@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63206 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab3KSIxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 03:53:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After searching rt by the vti tunnel dst/src parameter,
if this rt has neither attached to any transformation
nor the transformation is not tunnel oriented, this rt
should be released back to ip layer.

otherwise causing dst memory leakage.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv4/ip_vti.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5d9c845..52b802a 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -126,6 +126,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!rt->dst.xfrm ||
 	    rt->dst.xfrm->props.mode != XFRM_MODE_TUNNEL) {
 		dev->stats.tx_carrier_errors++;
+		ip_rt_put(rt);
 		goto tx_error_icmp;
 	}
 	tdev = rt->dst.dev;
-- 
1.7.9.5
