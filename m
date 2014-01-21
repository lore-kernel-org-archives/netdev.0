From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ip_tunnel: clear IPCB in ip_tunnel_xmit() in case dst_link_failure()
 is called
Date: Tue, 21 Jan 2014 15:18:56 +0800
Message-ID: <52DE1F60.2060109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Daniel Petre <daniel.petre@rcs-rds.ro>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:24930 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbaAUHTe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 02:19:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


commit a622260254ee48("ip_tunnel: fix kernel panic with icmp_dest_unreach")
clear IPCB in ip_tunnel_xmit()  , or else skb->cb[] may contain garbage from
GSO segmentation layer.

But commit 0e6fbc5b6c621("ip_tunnels: extend iptunnel_xmit()") refactor codes,
and it clear IPCB behind the dst_link_failure().

So clear IPCB in ip_tunnel_xmit() just like commti a622260254ee48("ip_tunnel:
fix kernel panic with icmp_dest_unreach").

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/ip_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 90ff957..dda1e9a 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -535,6 +535,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	dst = tnl_params->daddr;
 	if (dst == 0) {
 		/* NBMA tunnel */
-- 
1.8.3.1
