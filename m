From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: nf_queue: Don't recompute the hook_list head
Date: Wed,  8 Jul 2015 11:48:14 +0200
Message-ID: <1436348900-13130-2-git-send-email-pablo@netfilter.org>
References: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1436348900-13130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

If someone sends packets from one of the netdevice ingress hooks to
the a userspace queue, and then userspace later accepts the packet,
the netfilter code can enter an infinite loop as the list head will
never be found.

Pass in the saved list_head to avoid this.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_queue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index cd60d39..8a8b2ab 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -213,7 +213,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 
 	if (verdict == NF_ACCEPT) {
 	next_hook:
-		verdict = nf_iterate(&nf_hooks[entry->state.pf][entry->state.hook],
+		verdict = nf_iterate(entry->state.hook_list,
 				     skb, &entry->state, &elem);
 	}
 
-- 
1.7.10.4

