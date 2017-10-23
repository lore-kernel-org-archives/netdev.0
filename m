From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] ipv4: icmp: use BUG_ON instead of if condition followed by
 BUG
Date: Mon, 23 Oct 2017 13:08:14 -0500
Message-ID: <20171023180814.GA25198@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway22.websitewelcome.com ([192.185.46.187]:26627 "EHLO
        gateway22.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751208AbdJWSIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:08:15 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway22.websitewelcome.com (Postfix) with ESMTP id 0CBD9D093
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 13:08:15 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use BUG_ON instead of if condition followed by BUG in icmp_timestamp.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/ipv4/icmp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 3c1570d..1617604 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -968,8 +968,9 @@ static bool icmp_timestamp(struct sk_buff *skb)
 	 */
 	icmp_param.data.times[1] = inet_current_timestamp();
 	icmp_param.data.times[2] = icmp_param.data.times[1];
-	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
-		BUG();
+
+	BUG_ON(skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4));
+
 	icmp_param.data.icmph	   = *icmp_hdr(skb);
 	icmp_param.data.icmph.type = ICMP_TIMESTAMPREPLY;
 	icmp_param.data.icmph.code = 0;
-- 
2.7.4
