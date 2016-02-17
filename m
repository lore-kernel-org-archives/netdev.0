From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] tipc: unlock in error path
Date: Wed, 17 Feb 2016 11:47:35 -0500
Message-ID: <1455727655-32106-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: jon.maloy@ericsson.com, ying.xue@windriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tipc_bcast_unlock need to be unlocked in error path.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 net/tipc/link.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0c2944f..347cdc9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1973,8 +1973,10 @@ int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg)
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
 			  NLM_F_MULTI, TIPC_NL_LINK_GET);
-	if (!hdr)
+	if (!hdr) {
+		tipc_bcast_unlock(net);
 		return -EMSGSIZE;
+	}
 
 	attrs = nla_nest_start(msg->skb, TIPC_NLA_LINK);
 	if (!attrs)
-- 
1.9.1
