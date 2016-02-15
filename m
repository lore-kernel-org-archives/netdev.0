From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 6/6] net: Export ip fragment sysctl to unprivileged users
Date: Mon, 15 Feb 2016 12:11:32 +0200
Message-ID: <1455531092-23184-7-git-send-email-kernel@kyup.com>
References: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Cc: netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
	pabeni@redhat.com, jmorris@namei.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1455531092-23184-1-git-send-email-kernel@kyup.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that all the ip fragmentation related sysctls are namespaceified
there is no reason to hide them anymore from "root" users inside
containers.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 net/ipv4/ip_fragment.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 957161413335..efbd47d1a531 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -789,10 +789,6 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 		table[1].extra2 = &net->ipv4.frags.high_thresh;
 		table[2].data = &net->ipv4.frags.timeout;
 		table[3].data = &net->ipv4.frags.max_dist;
-
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
-			table[0].procname = NULL;
 	}
 
 	hdr = register_net_sysctl(net, "net/ipv4", table);
-- 
2.5.0

