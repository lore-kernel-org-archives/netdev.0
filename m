From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netfilter: potential NULL dereference in get_inner_hdr()
Date: Sat, 12 May 2012 14:00:03 +0300
Message-ID: <20120512110003.GB19472@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:29896 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab2ELLAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 07:00:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a typo in the error checking and "&&" was used instead of "||".
If skb_header_pointer() returns NULL then it leads to a NULL
dereference.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Btw, this is new code and Sparse complains about endian bugs.

diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 32fbd73..5817d03 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -223,7 +223,7 @@ static int get_inner_hdr(const struct sk_buff *skb, int iphsz, int *nhoff)
 
 	/* Not enough header? */
 	icmph = skb_header_pointer(skb, *nhoff + iphsz, sizeof(_ih), &_ih);
-	if (icmph == NULL && icmph->type > NR_ICMP_TYPES)
+	if (icmph == NULL || icmph->type > NR_ICMP_TYPES)
 		return 0;
 
 	/* Error message? */
