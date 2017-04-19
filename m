From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net] ipv6: sr: fix double free of skb after handling invalid SRH
Date: Wed, 19 Apr 2017 16:10:19 +0200
Message-ID: <20170419141019.8193-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>,
        Dan Carpenter <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:41556 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764068AbdDSOKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 10:10:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The icmpv6_param_prob() function already does a kfree_skb(),
this patch removes the duplicate one.

Fixes: 1ababeba4a21f3dba3da3523c670b207fb2feb62 ("ipv6: implement dataplane support for rthdr type 4 (Segment Routing Header)")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 275cac6..25192a3 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -388,7 +388,6 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((&hdr->segments_left) -
 				   skb_network_header(skb)));
-		kfree_skb(skb);
 		return -1;
 	}
 
-- 
2.10.2
