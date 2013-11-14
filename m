From: Martin Topholm <mph@one.com>
Subject: [PATCH 1/2] netfilter: synproxy: send mss option to backend
Date: Thu, 14 Nov 2013 15:35:30 +0100
Message-ID: <1384439731-16296-2-git-send-email-mph@one.com>
References: <1384439731-16296-1-git-send-email-mph@one.com>
Cc: brouer@redhat.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kontorsmtp2.one.com ([195.47.247.17]:41966 "EHLO
	kontorsmtp2.one.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab3KNOnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:43:49 -0500
In-Reply-To: <1384439731-16296-1-git-send-email-mph@one.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the synproxy_parse_options is called on the client ack the mss
option will not be present. Consequently mss wont be included in the
backend syn packet, which falls back to 536 bytes mss.

Therefore XT_SYNPROXY_OPT_MSS is explicitly flagged when recovering mss
value from cookie.

Signed-off-by: Martin Topholm <mph@one.com>
Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c  | 1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 1 +
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
