From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] netpoll: Remove unused EXPORT_SYMBOLs of netpoll_poll and netpoll_poll_dev
Date: Thu, 30 Jun 2011 18:08:57 -0700
Message-ID: <282ce7d68b97c4dbfb759c1c0752e6cbddfeeafc.1309482314.git.joe@perches.com>
References: <cover.1309482314.git.joe@perches.com>
Cc: WANG Cong <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309482314.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unused symbols waste space.

Commit 0e34e93177fb
"(netpoll: add generic support for bridge and bonding devices)"
added the symbol more than a year ago with the promise of "future use".

Because it is so far unused, remove it for now.
It can be easily readded if or when it actually needs to be used.

cc: WANG Cong <amwang@redhat.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netpoll.h |    2 --
 net/core/netpoll.c      |    6 ++----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 79358bb..5dfa091 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -40,8 +40,6 @@ struct netpoll_info {
 	struct netpoll *netpoll;
 };
 
-void netpoll_poll_dev(struct net_device *dev);
-void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 18d9cbd..4ce595e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -177,7 +177,7 @@ static void service_arp_queue(struct netpoll_info *npi)
 	}
 }
 
-void netpoll_poll_dev(struct net_device *dev)
+static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
 
@@ -208,13 +208,11 @@ void netpoll_poll_dev(struct net_device *dev)
 
 	zap_completion_queue();
 }
-EXPORT_SYMBOL(netpoll_poll_dev);
 
-void netpoll_poll(struct netpoll *np)
+static void netpoll_poll(struct netpoll *np)
 {
 	netpoll_poll_dev(np->dev);
 }
-EXPORT_SYMBOL(netpoll_poll);
 
 static void refill_skbs(void)
 {
-- 
1.7.6.rc1
