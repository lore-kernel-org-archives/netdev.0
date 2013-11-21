From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: synproxy: send mss option to backend
Date: Thu, 21 Nov 2013 10:05:23 +0100
Message-ID: <1385024728-4057-3-git-send-email-pablo@netfilter.org>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Topholm <mph@one.com>

When the synproxy_parse_options is called on the client ack the mss
option will not be present. Consequently mss wont be included in the
backend syn packet, which falls back to 536 bytes mss.

Therefore XT_SYNPROXY_OPT_MSS is explicitly flagged when recovering mss
value from cookie.

Signed-off-by: Martin Topholm <mph@one.com>
Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  |    1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 01cffea..f13bd91 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -244,6 +244,7 @@ synproxy_recv_client_ack(const struct synproxy_net *snet,
 
 	this_cpu_inc(snet->stats->cookie_valid);
 	opts->mss = mss;
+	opts->options |= XT_SYNPROXY_OPT_MSS;
 
 	if (opts->options & XT_SYNPROXY_OPT_TIMESTAMP)
 		synproxy_check_timestamp_cookie(opts);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index bf9f612..f78f41a 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -259,6 +259,7 @@ synproxy_recv_client_ack(const struct synproxy_net *snet,
 
 	this_cpu_inc(snet->stats->cookie_valid);
 	opts->mss = mss;
+	opts->options |= XT_SYNPROXY_OPT_MSS;
 
 	if (opts->options & XT_SYNPROXY_OPT_TIMESTAMP)
 		synproxy_check_timestamp_cookie(opts);
-- 
1.7.10.4

