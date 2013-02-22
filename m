From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/2] VXLAN: Use tunnel_ip_select_ident() for tunnel IP-Identification.
Date: Fri, 22 Feb 2013 09:30:40 -0800
Message-ID: <1361554240-1678-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:53290 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756963Ab3BVVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 16:49:40 -0500
Received: by mail-vc0-f200.google.com with SMTP id p1so1634091vcq.3
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 13:49:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel_ip_select_ident() is more efficient when generating ip-header
id given inner packet is of ipv4 type.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9d70421..f736823 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -33,6 +33,7 @@
 #include <net/arp.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
+#include <net/ipip.h>
 #include <net/icmp.h>
 #include <net/udp.h>
 #include <net/rtnetlink.h>
@@ -962,13 +963,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->daddr	= dst;
 	iph->saddr	= fl4.saddr;
 	iph->ttl	= ttl ? : ip4_dst_hoplimit(&rt->dst);
+	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
 
 	vxlan_set_owner(dev, skb);
 
 	/* See iptunnel_xmit() */
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(iph, &rt->dst, NULL);
 
 	err = ip_local_out(skb);
 	if (likely(net_xmit_eval(err) == 0)) {
-- 
1.7.1
