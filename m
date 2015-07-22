From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] ip_tunnel: Provide tunnel metadata API for CONFIG_INET=n
Date: Wed, 22 Jul 2015 14:43:58 +0200
Message-ID: <592e4753a6a5752b12cebab65ad426cce20535ca.1437568711.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswtich.org,
	roopa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46319 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535AbbGVMoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Account for the configuration FIB_RULES=y && INET=n as FIB_RULES can
be selected by IPV6 or DECNET without INET.

Fixes: e7030878fc84 ("fib: Add fib rule match on tunnel id")
Fixes: 3093fbe7ff4b ("route: Per route IP tunnel metadata via lightweight tunnel")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/ip_tunnels.h | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 0a5a776..d975b3e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -314,6 +314,21 @@ static inline int ip_tunnel_collect_metadata(void)
 void ip_tunnel_need_metadata(void);
 void ip_tunnel_unneed_metadata(void);
 
+#else /* CONFIG_INET */
+
+static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstate)
+{
+	return NULL;
+}
+
+static inline void ip_tunnel_need_metadata(void)
+{
+}
+
+static inline void ip_tunnel_unneed_metadata(void)
+{
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
-- 
2.4.3
