From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [net-next-2.6 PATCH 1/3 v2] ipv6: cancel to setting local_df in ip6_xmit()
Date: Fri, 16 Apr 2010 10:39:14 +0800
Message-ID: <4BC7CDD2.5020004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>,
	eric.dumazet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	emils.tantilov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60383 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757035Ab0DPCk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 22:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f88037(sctp: Drop ipfargok in sctp_xmit function)
has droped ipfragok and set local_df value properly.

So the change of commit 77e2f1(ipv6: Fix ip6_xmit to 
send fragments if ipfragok is true) is not needed. 
So the patch remove them.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
Resend the patches with fixed cc list, no content changes.
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

