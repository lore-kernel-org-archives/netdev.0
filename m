From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv6: exthdrs: use swap macro in ipv6_dest_hao
Date: Thu, 26 Oct 2017 23:10:35 -0500
Message-ID: <20171027041002.GA13506@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make use of the swap macro and remove unnecessary variable tmp_addr.
This makes the code easier to read and maintain.

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ipv6/exthdrs.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 7835dea..9f918a7 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -187,7 +187,6 @@ static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	struct ipv6_destopt_hao *hao;
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-	struct in6_addr tmp_addr;
 	int ret;
 
 	if (opt->dsthao) {
@@ -229,9 +228,7 @@ static bool ipv6_dest_hao(struct sk_buff *skb, int optoff)
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->ip_summed = CHECKSUM_NONE;
 
-	tmp_addr = ipv6h->saddr;
-	ipv6h->saddr = hao->addr;
-	hao->addr = tmp_addr;
+	swap(ipv6h->saddr, hao->addr);
 
 	if (skb->tstamp == 0)
 		__net_timestamp(skb);
-- 
2.7.4
