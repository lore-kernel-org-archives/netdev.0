From: Xiaotian Feng <xtfeng@gmail.com>
Subject: [PATCH 3/3] tipc: do not use tasklet_disable before tasklet_kill
Date: Wed, 31 Oct 2012 16:06:01 +0800
Message-ID: <1351670761-26749-3-git-send-email-xtfeng@gmail.com>
References: <1351670761-26749-1-git-send-email-xtfeng@gmail.com>
Cc: Xiaotian Feng <xtfeng@gmail.com>,
	Xiaotian Feng <dannyfeng@tencent.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351670761-26749-1-git-send-email-xtfeng@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If tasklet_disable() is called before related tasklet handled,
tasklet_kill will never be finished. tasklet_kill is enough.

Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Allan Stephens <allan.stephens@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: tipc-discussion@lists.sourceforge.net
---
 net/tipc/handler.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 111ff83..b36f0fc 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -116,7 +116,6 @@ void tipc_handler_stop(void)
 		return;
 
 	handler_enabled = 0;
-	tasklet_disable(&tipc_tasklet);
 	tasklet_kill(&tipc_tasklet);
 
 	spin_lock_bh(&qitem_lock);
-- 
1.7.9.5
