From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: synproxy: correct wscale option passing
Date: Thu, 21 Nov 2013 10:05:24 +0100
Message-ID: <1385024728-4057-4-git-send-email-pablo@netfilter.org>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34596 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab3KUJGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 04:06:00 -0500
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Topholm <mph@one.com>

Timestamp are used to store additional syncookie parameters such as sack,
ecn, and wscale. The wscale value we need to encode is the client's
wscale, since we can't recover that later in the session. Next overwrite
the wscale option so the later synproxy_send_client_synack will send
the backend's wscale to the client.

Signed-off-by: Martin Topholm <mph@one.com>
Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_synproxy_core.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index cdf4567..9858e3e 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -151,9 +151,10 @@ void synproxy_init_timestamp_cookie(const struct xt_synproxy_info *info,
 	opts->tsecr = opts->tsval;
 	opts->tsval = tcp_time_stamp & ~0x3f;
 
-	if (opts->options & XT_SYNPROXY_OPT_WSCALE)
-		opts->tsval |= info->wscale;
-	else
+	if (opts->options & XT_SYNPROXY_OPT_WSCALE) {
+		opts->tsval |= opts->wscale;
+		opts->wscale = info->wscale;
+	} else
 		opts->tsval |= 0xf;
 
 	if (opts->options & XT_SYNPROXY_OPT_SACK_PERM)
-- 
1.7.10.4
