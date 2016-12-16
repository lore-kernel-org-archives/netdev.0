From: =?UTF-8?q?Mantas=20Mikul=C4=97nas?= <grawity@gmail.com>
Subject: [PATCH] net: ipv6: check route protocol when deleting routes
Date: Fri, 16 Dec 2016 10:30:59 +0200
Message-ID: <20161216083059.251368-1-grawity@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Mantas=20Mikul=C4=97nas?= <grawity@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The protocol field is checked when deleting IPv4 routes, but ignored for
IPv6, which causes problems with routing daemons accidentally deleting
externally set routes (observed by multiple bird6 users).

This can be verified using `ip -6 route del <prefix> proto something`.

Signed-off-by: Mantas Mikulėnas <grawity@gmail.com>
---
 net/ipv6/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 947ed1ded026..ef6de8f9e5a2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2163,6 +2163,8 @@ static int ip6_route_del(struct fib6_config *cfg)
 				continue;
 			if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
 				continue;
+			if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
+				continue;
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 
-- 
2.11.0
