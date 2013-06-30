From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] ip_tunnels: Use skb-len to PMTU check.
Date: Sat, 29 Jun 2013 22:40:18 -0700
Message-ID: <1372570818-15651-1-git-send-email-pshelar@nicira.com>
Cc: timo.teras@iki.fi, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:33780 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750744Ab3F3FkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 01:40:23 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld11so3822650pab.36
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 22:40:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In path mtu check, ip header total length works for gre device
but not for gre-tap device.  Use skb len which is consistent
for all tunneling types.  This also fixes bug introduced by
commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).

Reported-by: Timo Teras <timo.teras@iki.fi>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 7fa8f08..4e9f530 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -595,7 +595,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 		if (!skb_is_gso(skb) &&
 		    (inner_iph->frag_off&htons(IP_DF)) &&
-		     mtu < ntohs(inner_iph->tot_len)) {
+		     mtu < skb->len) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 			ip_rt_put(rt);
 			goto tx_error;
-- 
1.7.1
