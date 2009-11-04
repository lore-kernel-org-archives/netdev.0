From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netfilter: remove synchronize_net() calls in
 ip_queue/ip6_queue
Date: Wed, 04 Nov 2009 20:47:35 +0100
Message-ID: <4AF1DA57.8080202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_unregister_queue_handlers() already does a synchronize_rcu()
call, we dont need to do it again in callers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/netfilter/ip_queue.c  |    2 +-
 net/ipv6/netfilter/ip6_queue.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index c156db2..9811a45 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -622,7 +622,7 @@ cleanup_netlink_notifier:
 static void __exit ip_queue_fini(void)
 {
 	nf_unregister_queue_handlers(&nfqh);
-	synchronize_net();
+
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 1cf3f0c..a82016f 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -625,7 +625,7 @@ cleanup_netlink_notifier:
 static void __exit ip6_queue_fini(void)
 {
 	nf_unregister_queue_handlers(&nfqh);
-	synchronize_net();
+
 	ipq_flush(NULL, 0);
 
 #ifdef CONFIG_SYSCTL
