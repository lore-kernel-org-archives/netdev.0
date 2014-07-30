From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH] tcp: don't require root to read tcp_metrics
Date: Wed, 30 Jul 2014 13:13:35 -0400
Message-ID: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
Cc: Debabrata Banerjee <dbanerje@akamai.com>,
	Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d23ff701643a4a725e2c7a8ba2d567d39daa29ea introduced netlink support for
the new tcp_metrics, however it restricted getting of tcp_metrics to root user
only. This is a change from how these values could have been fetched when in
the old route cache. Unless there's a legitimate reason to restrict the reading
of these values it would be better if normal users could fetch them.

Cc: Julian Anastasov <ja@ssi.bg>
Cc: linux-kernel@vger.kernel.org
---
 net/ipv4/tcp_metrics.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4fe0418..0d54e59 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1093,7 +1093,6 @@ static const struct genl_ops tcp_metrics_nl_ops[] = {
 		.doit = tcp_metrics_nl_cmd_get,
 		.dumpit = tcp_metrics_nl_dump,
 		.policy = tcp_metrics_nl_policy,
-		.flags = GENL_ADMIN_PERM,
 	},
 	{
 		.cmd = TCP_METRICS_CMD_DEL,
-- 
2.0.3
