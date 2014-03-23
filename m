From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/core: Use RCU_INIT_POINTER(x, NULL) in netpoll.c
Date: Mon, 24 Mar 2014 00:42:46 +0530
Message-ID: <1395601966-12490-1-git-send-email-monamagarwal123@gmail.com>
To: davem@davemloft.net, ebiederm@xmission.com, nhorman@tuxdriver.com,
	cwang@twopensource.com, kaber@trash.net, antonio@meshcoding.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/core/netpoll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 7291dde..41c4e9c 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -809,7 +809,7 @@ void __netpoll_cleanup(struct netpoll *np)
 		if (ops->ndo_netpoll_cleanup)
 			ops->ndo_netpoll_cleanup(np->dev);
 
-		rcu_assign_pointer(np->dev->npinfo, NULL);
+		RCU_INIT_POINTER(np->dev->npinfo, NULL);
 		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
 	}
 }
-- 
1.7.9.5
