From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix build failure when CONFIG_INET not defined.
Date: Thu, 20 Jun 2013 15:03:51 -0700
Message-ID: <1371765831-3678-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:59856 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757843Ab3FTWDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:03:55 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so6755089pab.24
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 15:03:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds CONFIG_INET guard for ip_tunnel header. Fixes following
build error:-

 In file included from net/openvswitch/flow.c:43:0:
   include/net/ip_tunnels.h: In function 'tunnel_ip_select_ident':
>> include/net/ip_tunnels.h:155:3: error: implicit declaration of function '__ip_select_ident' [-Werror=implicit-function-declaration]
      __ip_select_ident(iph, dst,

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 10bbb42..317f4a8 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -18,6 +18,18 @@
 #include <net/ip6_route.h>
 #endif
 
+#define TUNNEL_CSUM	__cpu_to_be16(0x01)
+#define TUNNEL_ROUTING	__cpu_to_be16(0x02)
+#define TUNNEL_KEY	__cpu_to_be16(0x04)
+#define TUNNEL_SEQ	__cpu_to_be16(0x08)
+#define TUNNEL_STRICT	__cpu_to_be16(0x10)
+#define TUNNEL_REC	__cpu_to_be16(0x20)
+#define TUNNEL_VERSION	__cpu_to_be16(0x40)
+#define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
+#define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
+
+#ifdef CONFIG_INET
+
 /* Keep error state on tunnel for 30 sec */
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
 
@@ -65,16 +77,6 @@ struct ip_tunnel {
 	struct gro_cells	gro_cells;
 };
 
-#define TUNNEL_CSUM	__cpu_to_be16(0x01)
-#define TUNNEL_ROUTING	__cpu_to_be16(0x02)
-#define TUNNEL_KEY	__cpu_to_be16(0x04)
-#define TUNNEL_SEQ	__cpu_to_be16(0x08)
-#define TUNNEL_STRICT	__cpu_to_be16(0x10)
-#define TUNNEL_REC	__cpu_to_be16(0x20)
-#define TUNNEL_VERSION	__cpu_to_be16(0x40)
-#define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
-#define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
-
 struct tnl_ptk_info {
 	__be16 flags;
 	__be16 proto;
@@ -180,4 +182,6 @@ static inline void iptunnel_xmit_stats(int err,
 		err_stats->tx_dropped++;
 	}
 }
+
+#endif /* CONFIG_INET */
 #endif /* __NET_IP_TUNNELS_H */
-- 
1.7.1
