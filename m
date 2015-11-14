From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-ipv6: Delete unnecessary checks before the function call
 "kfree_skb"
Date: Sat, 14 Nov 2015 20:05:17 +0100
Message-ID: <564785ED.1040906@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki Yoshfuji <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:60596 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbbKNTFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Nov 2015 14:05:51 -0500
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 14 Nov 2015 19:55:00 +0100

The kfree_skb() function tests whether its argument is NULL and then
returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/ipv6/af_inet6.c                     | 7 ++-----
 net/ipv6/netfilter/nf_conntrack_reasm.c | 3 +--
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 44bb66b..4cd9259 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -416,12 +416,9 @@ void inet6_destroy_sock(struct sock *sk)
 	/* Release rx options */
 
 	skb = xchg(&np->pktoptions, NULL);
-	if (skb)
-		kfree_skb(skb);
-
+	kfree_skb(skb);
 	skb = xchg(&np->rxpmtu, NULL);
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 
 	/* Free flowlabels */
 	fl6_free_socklist(sk);
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index d5efeb8..dbc013b 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -172,8 +172,7 @@ static unsigned int nf_hashfn(const struct inet_frag_queue *q)
 
 static void nf_skb_free(struct sk_buff *skb)
 {
-	if (NFCT_FRAG6_CB(skb)->orig)
-		kfree_skb(NFCT_FRAG6_CB(skb)->orig);
+	kfree_skb(NFCT_FRAG6_CB(skb)->orig);
 }
 
 static void nf_ct_frag6_expire(unsigned long data)
-- 
2.6.2
