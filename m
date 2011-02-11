From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] ip_gre: Add IPPROTO_GRE to flowi in ipgre_tunnel_xmit
Date: Fri, 11 Feb 2011 10:30:40 +0100
Message-ID: <20110211093040.GB29583@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50203 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934Ab1BKJuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 04:50:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5811662b15db018c740c57d037523683fd3e6123 accidentally
removed the setting of IPPROTO_GRE from the struct flowi
in ipgre_tunnel_xmit. This patch restores it.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_gre.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index eb68a0e..6613edf 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -775,6 +775,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			.fl4_dst = dst,
 			.fl4_src = tiph->saddr,
 			.fl4_tos = RT_TOS(tos),
+			.proto = IPPROTO_GRE,
 			.fl_gre_key = tunnel->parms.o_key
 		};
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
-- 
1.7.0.4

