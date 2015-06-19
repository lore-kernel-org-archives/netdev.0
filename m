From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net] netfilter: nf_queue: Don't recompute the hook_list head
Date: Fri, 19 Jun 2015 17:23:37 -0500
Message-ID: <87381ne3rq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


If someone sends packets from one of the netdevice ingress hooks to
the a userspace queue, and then userspace later accepts the packet,
the netfilter code can enter an infinite loop as the list head will
never be found.

Pass in the saved list_head to avoid this.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/nf_queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index cd60d397fe05..8a8b2abc35ff 100644
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
2.2.1

--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
