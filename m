From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/3] netfilter: nf_tables: avoid uninitialized variable warning
Date: Fri, 30 Sep 2016 18:05:34 +0200
Message-ID: <20160930160559.4102745-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added nft_range_eval() function handles the two possible
nft range operations, but as the compiler warning points out,
any unexpected value would lead to the 'mismatch' variable being
used without being initialized:

net/netfilter/nft_range.c: In function 'nft_range_eval':
net/netfilter/nft_range.c:45:5: error: 'mismatch' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This can be trivially avoided by added a 'default:' clause.

Fixes: 0f3cd9b36977 ("netfilter: nf_tables: add range expression")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/netfilter/nft_range.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index c6d5358482d1..72dff5bffca8 100644
--- a/net/netfilter/nft_range.c
+++ b/net/netfilter/nft_range.c
@@ -40,6 +40,8 @@ static void nft_range_eval(const struct nft_expr *expr,
 	case NFT_RANGE_NEQ:
 		mismatch = (d1 >= 0 && d2 <= 0);
 		break;
+	default:
+		mismatch = 0;
 	}
 
 	if (mismatch)
-- 
2.9.0
