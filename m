From: kaber@trash.net
Subject: [PATCH 03/79] netfilter: xt_LOG: do print MAC header on FORWARD
Date: Wed, 19 Jan 2011 20:14:03 +0100
Message-ID: <1295464519-21763-4-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

I am observing consistent behavior even with bridges, so let's unlock
this. xt_mac is already usable in FORWARD, too. Section 9 of
http://ebtables.sourceforge.net/br_fw_ia/br_fw_ia.html#section9 says
the MAC source address is changed, but my observation does not match
that claim -- the MAC header is retained.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
[Patrick; code inspection seems to confirm this]
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_LOG.c  |    3 +--
 net/ipv6/netfilter/ip6t_LOG.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 72ffc8f..d76d6c9 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -442,8 +442,7 @@ ipt_log_packet(u_int8_t pf,
 	}
 #endif
 
-	/* MAC logging for input path only. */
-	if (in && !out)
+	if (in != NULL)
 		dump_mac_header(m, loginfo, skb);
 
 	dump_packet(m, loginfo, skb, 0);
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 09c8889..05027b7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -452,8 +452,7 @@ ip6t_log_packet(u_int8_t pf,
 	       in ? in->name : "",
 	       out ? out->name : "");
 
-	/* MAC logging for input path only. */
-	if (in && !out)
+	if (in != NULL)
 		dump_mac_header(m, loginfo, skb);
 
 	dump_packet(m, loginfo, skb, skb_network_offset(skb), 1);
-- 
1.7.2.3

