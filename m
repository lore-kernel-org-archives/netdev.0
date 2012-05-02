From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netfilter: remove two dropwatch false positives
Date: Wed, 02 May 2012 09:13:10 +0200
Message-ID: <1335942790.22133.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

After skb_copy_expand() call, we want to switch skbs without dropping
original one. Call consume_skb() to avoid drop_monitor sending a drop
event.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/netfilter/ip_queue.c  |    2 +-
 net/ipv6/netfilter/ip6_queue.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 09775a1..dd88537 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -296,7 +296,7 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct nf_queue_entry *e)
 				      "in mangle, dropping packet\n");
 				return -ENOMEM;
 			}
-			kfree_skb(e->skb);
+			consume_skb(e->skb);
 			e->skb = nskb;
 		}
 		skb_put(e->skb, diff);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 3ca9303..e1d5465 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -296,7 +296,7 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct nf_queue_entry *e)
 				      "in mangle, dropping packet\n");
 				return -ENOMEM;
 			}
-			kfree_skb(e->skb);
+			consume_skb(e->skb);
 			e->skb = nskb;
 		}
 		skb_put(e->skb, diff);


