From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 4/9] netpoll: use DEFINE_STATIC_SRCU() to define netpoll_srcu
Date: Sat, 16 Mar 2013 00:50:52 +0800
Message-ID: <1363366257-4886-5-git-send-email-laijs@cn.fujitsu.com>
References: <1363366257-4886-1-git-send-email-laijs@cn.fujitsu.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363366257-4886-1-git-send-email-laijs@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DEFINE_STATIC_SRCU() defines srcu struct and do init at build time.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/core/netpoll.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fa32899..a3a17ae 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -47,7 +47,7 @@ static struct sk_buff_head skb_pool;
 
 static atomic_t trapped;
 
-static struct srcu_struct netpoll_srcu;
+DEFINE_STATIC_SRCU(netpoll_srcu);
 
 #define USEC_PER_POLL	50
 #define NETPOLL_RX_ENABLED  1
@@ -1212,7 +1212,6 @@ EXPORT_SYMBOL(netpoll_setup);
 static int __init netpoll_init(void)
 {
 	skb_queue_head_init(&skb_pool);
-	init_srcu_struct(&netpoll_srcu);
 	return 0;
 }
 core_initcall(netpoll_init);
-- 
1.7.4.4
