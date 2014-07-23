From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: nf_sockopt_find() should return ERESTARTSYS
Date: Thu, 24 Jul 2014 00:53:15 +0200
Message-ID: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

getsockopt() or setsockopt() sometimes returns -EINTR instead of
-ENOPROTOOPT, causing headaches to application developers.

This is because unsupported commands might go through nf_sockopt_find()
and this function returns -EINTR instead of -ERESTARTSYS if
a signal is pending.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/nf_sockopt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index f042ae521557..37181447715b 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -66,7 +66,7 @@ static struct nf_sockopt_ops *nf_sockopt_find(struct sock *sk, u_int8_t pf,
 	struct nf_sockopt_ops *ops;
 
 	if (mutex_lock_interruptible(&nf_sockopt_mutex) != 0)
-		return ERR_PTR(-EINTR);
+		return ERR_PTR(-ERESTARTSYS);
 
 	list_for_each_entry(ops, &nf_sockopts, list) {
 		if (ops->pf == pf) {


