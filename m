From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH linux-3.10.y 2/3] Revert "ip6tnl: fix use after free of fb_tnl_dev"
Date: Thu, 30 Jan 2014 11:09:22 +0100
Message-ID: <1391076563-10798-2-git-send-email-nicolas.dichtel@6wind.com>
References: <52EA1B4B.5080403@6wind.com>
 <1391076563-10798-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, williams@redhat.com, lclaudio@uudg.org,
	jkacur@redhat.com, willemb@google.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391076563-10798-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 22c3ec552c29cf4bd4a75566088950fe57d860c4.

This patch is not the right fix, it introduces a memory leak when a netns is
destroyed (the FB device is never deleted).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 209bb4d6e188..0516ebbea80b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1711,6 +1711,8 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 		}
 	}
 
+	t = rtnl_dereference(ip6n->tnls_wc[0]);
+	unregister_netdevice_queue(t->dev, &list);
 	unregister_netdevice_many(&list);
 }
 
-- 
1.8.4.1
