From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] netfilter: nf_tables: underflow in nft_parse_u32_check()
Date: Wed, 12 Oct 2016 12:14:29 +0300
Message-ID: <20161012091429.GA27317@mwanda>
References: <CAML_gOedjw6uJqp13YkGfXoLQTd_ikOC8OoUA4oXv15RYsgoUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Laura Garcia Liebana <nevola@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26393 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932406AbcJLJPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 05:15:54 -0400
Content-Disposition: inline
In-Reply-To: <CAML_gOedjw6uJqp13YkGfXoLQTd_ikOC8OoUA4oXv15RYsgoUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't want to allow negatives here.

Fixes: 36b701fae12a ('netfilter: nf_tables: validate maximum value of u32 netlink attributes')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: cosmetic change

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b70d3ea..dd55187 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4423,7 +4423,7 @@ static int nf_tables_check_loops(const struct nft_ctx *ctx,
  */
 unsigned int nft_parse_u32_check(const struct nlattr *attr, int max, u32 *dest)
 {
-	int val;
+	u32 val;
 
 	val = ntohl(nla_get_be32(attr));
 	if (val > max)
