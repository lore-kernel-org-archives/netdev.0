From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 02/30] netfilter: Store net in nf_hook_state
Date: Tue, 15 Sep 2015 20:03:50 -0500
Message-ID: <1442365458-16349-2-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h         | 5 ++++-
 include/linux/netfilter_ingress.h | 2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 1abac85ec907..889ac0e11f01 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,6 +54,7 @@ struct nf_hook_state {
 	struct net_device *in;
 	struct net_device *out;
 	struct sock *sk;
+	struct net *net;
 	struct list_head *hook_list;
 	int (*okfn)(struct sock *, struct sk_buff *);
 };
@@ -65,6 +66,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      struct net_device *indev,
 				      struct net_device *outdev,
 				      struct sock *sk,
+				      struct net *net,
 				      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	p->hook = hook;
@@ -73,6 +75,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->in = indev;
 	p->out = outdev;
 	p->sk = sk;
+	p->net = net;
 	p->hook_list = hook_list;
 	p->okfn = okfn;
 }
@@ -181,7 +184,7 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 		struct nf_hook_state state;
 
 		nf_hook_state_init(&state, hook_list, hook, thresh,
-				   pf, indev, outdev, sk, okfn);
+				   pf, indev, outdev, sk, net, okfn);
 		return nf_hook_slow(skb, &state);
 	}
 	return 1;
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index cb0727fe2b3d..187feabe557c 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -17,7 +17,7 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 
 	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
 			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV, NULL,
-			   skb->dev, NULL, NULL);
+			   skb->dev, NULL, dev_net(skb->dev), NULL);
 	return nf_hook_slow(skb, &state);
 }
 
-- 
2.2.1

