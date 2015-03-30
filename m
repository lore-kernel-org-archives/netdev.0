From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 4/9 net-next] ipv6: replace if/BUG by BUG_ON
Date: Mon, 30 Mar 2015 23:13:12 +0200
Message-ID: <1427749998-28464-4-git-send-email-fabf@skynet.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427749998-28464-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/addrconf.c                     | 3 +--
 net/ipv6/esp6.c                         | 3 +--
 net/ipv6/netfilter/nf_conntrack_reasm.c | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2660263..e205918 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4805,8 +4805,7 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (!idev)
 		return -EAFNOSUPPORT;
 
-	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
-		BUG();
+	BUG_ON(nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0);
 
 	if (tb[IFLA_INET6_TOKEN]) {
 		err = inet6_set_iftoken(idev, nla_data(tb[IFLA_INET6_TOKEN]));
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index e48f2c7..9e51b69 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -280,8 +280,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 	if (unlikely(err))
 		goto out;
 
-	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
-		BUG();
+	BUG_ON(skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2));
 
 	err = -EINVAL;
 	padlen = nexthdr[0];
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6f187c8..cea1a4a 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -538,8 +538,7 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 			pr_debug("too short\n");
 			return -1;
 		}
-		if (skb_copy_bits(skb, start, &hdr, sizeof(hdr)))
-			BUG();
+		BUG_ON(skb_copy_bits(skb, start, &hdr, sizeof(hdr)));
 		if (nexthdr == NEXTHDR_AUTH)
 			hdrlen = (hdr.hdrlen+2)<<2;
 		else
-- 
1.9.1
