From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v3 09/11] xfrm: pass xfrm_user module to netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:27 +0800
Message-ID: <1349325689-16104-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/xfrm/xfrm_user.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 421f984..3d909f7 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2308,17 +2308,20 @@ static struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
+	struct module *module;
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
 	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = { .doit = xfrm_get_sa,
 						   .dump = xfrm_dump_sa,
-						   .done = xfrm_dump_sa_done  },
+						   .done = xfrm_dump_sa_done,
+						   .module = THIS_MODULE      },
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
 	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy    },
 	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy,
 						   .dump = xfrm_dump_policy,
-						   .done = xfrm_dump_policy_done },
+						   .done = xfrm_dump_policy_done,
+						   .module = THIS_MODULE      },
 	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = { .doit = xfrm_alloc_userspi },
 	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = { .doit = xfrm_add_acquire   },
 	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = { .doit = xfrm_add_sa_expire },
@@ -2362,6 +2365,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			struct netlink_dump_control c = {
 				.dump = link->dump,
 				.done = link->done,
+				.module = link->module,
 			};
 			return netlink_dump_start(net->xfrm.nlsk, skb, nlh, &c);
 		}
-- 
1.7.7.6

