From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: nf_tables: Use 32 bit addressing register from nft_type_to_reg()
Date: Thu,  3 Sep 2015 11:50:56 +0200
Message-ID: <1441273861-31092-2-git-send-email-pablo@netfilter.org>
References: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nft_type_to_reg() needs to return the register in the new 32 bit addressing,
otherwise we hit EINVAL when using mappings.

Fixes: 49499c3 ("netfilter: nf_tables: switch registers to 32 bit addressing")
Reported-by: Andreas Schultz <aschultz@tpip.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 2a24668..aa8bee7 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -125,7 +125,7 @@ static inline enum nft_data_types nft_dreg_to_type(enum nft_registers reg)
 
 static inline enum nft_registers nft_type_to_reg(enum nft_data_types type)
 {
-	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1;
+	return type == NFT_DATA_VERDICT ? NFT_REG_VERDICT : NFT_REG_1 * NFT_REG_SIZE / NFT_REG32_SIZE;
 }
 
 unsigned int nft_parse_register(const struct nlattr *attr);
-- 
1.7.10.4

