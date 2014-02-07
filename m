From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/18] netfilter: nf_tables: fix overrun in nf_tables_set_alloc_name()
Date: Fri,  7 Feb 2014 18:41:33 +0100
Message-ID: <1391794904-4017-8-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41414 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667AbaBGRmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:42:03 -0500
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The map that is used to allocate anonymous sets is indeed
BITS_PER_BYTE * PAGE_SIZE long.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 9ce3053..2a22a18 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1989,13 +1989,13 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 
 			if (!sscanf(i->name, name, &tmp))
 				continue;
-			if (tmp < 0 || tmp > BITS_PER_LONG * PAGE_SIZE)
+			if (tmp < 0 || tmp >= BITS_PER_BYTE * PAGE_SIZE)
 				continue;
 
 			set_bit(tmp, inuse);
 		}
 
-		n = find_first_zero_bit(inuse, BITS_PER_LONG * PAGE_SIZE);
+		n = find_first_zero_bit(inuse, BITS_PER_BYTE * PAGE_SIZE);
 		free_page((unsigned long)inuse);
 	}
 
-- 
1.7.10.4
