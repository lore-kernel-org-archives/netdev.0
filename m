From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netfilter: nf_tables: underflow in nft_parse_u32_check()
Date: Wed, 12 Oct 2016 09:08:11 +0300
Message-ID: <20161012060811.GE12841@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Laura Garcia Liebana <nevola@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't want to allow negatives here.

Fixes: 36b701fae12a ('netfilter: nf_tables: validate maximum value of u32 netlink attributes')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b70d3ea..dd55187 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4423,7 +4423,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
  */
 unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
 {
-	int val;
+	uint val;
 
 	val = ntohl(nla_get_be32(attr));
 	if (val > max)
