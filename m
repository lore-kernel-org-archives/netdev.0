From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] net: core: fix unused variable sparse warning
Date: Fri,  7 Dec 2012 00:06:44 +0000
Message-ID: <1354838913-20084-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the variables zero and unres_qlen_max are only used when CONFIG_SYSCTL is
defined, otherwise it causes the following sparse warning when we turn on
CONFIG_SYSCTL.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 net/core/neighbour.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 36fc692..4a15278 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -62,8 +62,10 @@ static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 
+#ifdef CONFIG_SYSCTL
 static int zero;
 static int unres_qlen_max = INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
+#endif
 
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
-- 
1.7.4.5
