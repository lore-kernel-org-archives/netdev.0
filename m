From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 1/6] netfilter: nf_queue: Don't recompute the hook_list head
Date: Fri, 10 Jul 2015 18:12:50 -0500
Message-ID: <87380vsj2l.fsf_-_@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<87r3pae5hn.fsf@x220.int.ebiederm.org>
	<878uansj4d.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55270 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbGJXS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 19:18:28 -0400
In-Reply-To: <878uansj4d.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 10 Jul 2015 18:11:46 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
