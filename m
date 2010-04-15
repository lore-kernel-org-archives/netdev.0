From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [net-next-2.6 PATCH 1/2] ipv6: cancel to setting local_df in ip6_xmit()
Date: Thu, 15 Apr 2010 21:04:38 +0800
Message-ID: <4BC70EE6.5070100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	eric.dumazet@gmail.com, sri@us.ibm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	emils.tantilov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50712 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753464Ab0DONFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 09:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f88037(sctp: Drop ipfargok in sctp_xmit function)
has droped ipfragok and set local_df value properly.

So the change of commit 77e2f1(ipv6: Fix ip6_xmit to 
send fragments if ipfragok is true) is not needed. 
So the patch remove them.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 16c4391..f3a847e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -231,10 +231,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	/* Allow local fragmentation. */
-	if (ipfragok)
-		skb->local_df = 1;
-
 	/*
 	 *	Fill in the IPv6 header
 	 */
--
1.6.3.3 
