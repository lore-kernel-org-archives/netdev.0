From: Martin Topholm <mph@one.com>
Subject: [PATCH 2/2] netfilter: synproxy: correct wscale option passing
Date: Thu, 14 Nov 2013 15:35:31 +0100
Message-ID: <1384439731-16296-3-git-send-email-mph@one.com>
References: <1384439731-16296-1-git-send-email-mph@one.com>
Cc: brouer@redhat.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384439731-16296-1-git-send-email-mph@one.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timestamp are used to store additional syncookie parameters such as sack,
ecn, and wscale. The wscale value we need to encode is the client's
wscale, since we can't recover that later in the session. Next overwrite
the wscale option so the later synproxy_send_client_synack will send
the backend's wscale to the client.

Signed-off-by: Martin Topholm <mph@one.com>
Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/netfilter/nf_synproxy_core.c | 7 ++++---
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
