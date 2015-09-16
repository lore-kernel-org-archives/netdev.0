From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 23/30] ipv6: Compute net once in raw6_send_hdrinc
Date: Tue, 15 Sep 2015 20:04:11 -0500
Message-ID: <1442365458-16349-23-git-send-email-ebiederm@xmission.com>
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
 net/ipv6/raw.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 1636537705f5..5aa461302716 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -614,6 +614,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 			unsigned int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	int err;
@@ -652,7 +653,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	if (err)
 		goto error_fault;
 
-	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
+	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
 		      NULL, rt->dst.dev, dst_output);
 	if (err > 0)
@@ -666,7 +667,7 @@ error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
-	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	if (err == -ENOBUFS && !np->recverr)
 		err = 0;
 	return err;
-- 
2.2.1

