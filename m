From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH v2] tcp: don't require root to read tcp_metrics
Date: Wed, 30 Jul 2014 13:50:17 -0400
Message-ID: <1406742617-10556-1-git-send-email-dbanerje@akamai.com>
References: <53D92D92.4090403@cogentembedded.com>
Cc: Debabrata Banerjee <dbanerje@akamai.com>,
	Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53D92D92.4090403@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d23ff7016 (tcp: add generic netlink support for tcp_metrics) introduced
netlink support for the new tcp_metrics, however it restricted getting of
tcp_metrics to root user only. This is a change from how these values could
have been fetched when in the old route cache. Unless there's a legitimate
reason to restrict the reading of these values it would be better if normal
users could fetch them.

Cc: Julian Anastasov <ja@ssi.bg>
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
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
