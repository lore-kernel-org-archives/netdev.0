From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/38] netfilter: xt_ipcomp: Use ntohs to ease sparse warning
Date: Mon, 17 Mar 2014 13:42:22 +0100
Message-ID: <1395060178-11833-3-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59280 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932927AbaCQMnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:23 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0-DAY kernel build testing backend reported:

sparse warnings: (new ones prefixed by >>)

 >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: restricted __be16 degrades to integer
 >> >> net/netfilter/xt_ipcomp.c:63:26: sparse: cast to restricted __be32

Fix this by using ntohs without shifting.

Tested with: make C=1 CF=-D__CHECK_ENDIAN__

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_ipcomp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_ipcomp.c b/net/netfilter/xt_ipcomp.c
index a4c7561..89d5310 100644
--- a/net/netfilter/xt_ipcomp.c
+++ b/net/netfilter/xt_ipcomp.c
@@ -60,7 +60,7 @@ static bool comp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	}
 
 	return spi_match(compinfo->spis[0], compinfo->spis[1],
-			 ntohl(chdr->cpi << 16),
+			 ntohs(chdr->cpi),
 			 !!(compinfo->invflags & XT_IPCOMP_INV_SPI));
 }
 
-- 
1.7.10.4
