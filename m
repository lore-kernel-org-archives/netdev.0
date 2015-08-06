From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/2] netfilter: ip6t_SYNPROXY: fix sending window update to client
Date: Thu,  6 Aug 2015 14:34:57 +0200
Message-ID: <1438864497-3767-2-git-send-email-phil@nwl.cc>
References: <20150804175302.GA19650@salvia>
 <1438864497-3767-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438864497-3767-1-git-send-email-phil@nwl.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the identical fix as "netfilter: ipt_SYNPROXY: fix sending
window update to client" but for the IPv6 variant which obviously
suffers from the same issue.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index f5af323..ca30a04 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -242,7 +242,8 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size, snet);
+	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	                  niph, nth, tcp_hdr_size, snet);
 }
 
 static bool
-- 
2.1.2

