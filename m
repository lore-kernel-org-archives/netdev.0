From: pablo@netfilter.org
Subject: [PATCH 2/7] netfilter: xt_HMARK: potential NULL dereference in get_inner_hdr()
Date: Thu, 17 May 2012 01:06:39 +0200
Message-ID: <1337209604-3412-3-git-send-email-pablo@netfilter.org>
References: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

There is a typo in the error checking and "&&" was used instead of "||".
If skb_header_pointer() returns NULL then it leads to a NULL
dereference.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_HMARK.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
-- 
1.7.10

