From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [patch v2 10/11] ipset: pass ipset module to netlink_dump_start
Date: Wed, 26 Sep 2012 16:41:27 +0800
Message-ID: <1348648888-24943-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348648888-24943-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, jengelh-9+2X+4sQBs8@public.gmane.org,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348648888-24943-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>
---
 net/netfilter/ipset/ip_set_core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 9730882..c4903dc 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -986,7 +986,7 @@ ip_set_dump_done(struct netlink_callback *cb)
 		pr_debug("release set %s\n", ip_set_list[cb->args[1]]->name);
 		ip_set_put_byindex((ip_set_id_t) cb->args[1]);
 	}
-	return 0;
+	return netlink_dump_done(cb);
 }
 
 static inline void
@@ -1176,6 +1176,7 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ip_set_dump_start,
 			.done = ip_set_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
