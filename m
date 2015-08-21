From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 791/1189] net/ipv4/netfilter/nft_dup_ipv4.c:29:37:
 sparse: incorrect type in initializer (different base types)
Date: Fri, 21 Aug 2015 14:29:15 +0800
Message-ID: <201508211410.93yao6GX%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56962 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754070AbbHUG1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 02:27:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   a9e01ed986aa80d3092134428f453072752da223
commit: d877f07112f1e5a247c6b585c971a93895c9f738 [791/1189] netfilter: nf_tables: add nft_dup expression
reproduce:
  # apt-get install sparse
  git checkout d877f07112f1e5a247c6b585c971a93895c9f738
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv4/netfilter/nft_dup_ipv4.c:29:37: sparse: incorrect type in initializer (different base types)
   net/ipv4/netfilter/nft_dup_ipv4.c:29:37:    expected restricted __be32 [usertype] s_addr
   net/ipv4/netfilter/nft_dup_ipv4.c:29:37:    got unsigned int [unsigned] <noident>

vim +29 net/ipv4/netfilter/nft_dup_ipv4.c

    13	#include <linux/netfilter.h>
    14	#include <linux/netfilter/nf_tables.h>
    15	#include <net/netfilter/nf_tables.h>
    16	#include <net/netfilter/ipv4/nf_dup_ipv4.h>
    17	
    18	struct nft_dup_ipv4 {
    19		enum nft_registers	sreg_addr:8;
    20		enum nft_registers	sreg_dev:8;
    21	};
    22	
    23	static void nft_dup_ipv4_eval(const struct nft_expr *expr,
    24				      struct nft_regs *regs,
    25				      const struct nft_pktinfo *pkt)
    26	{
    27		struct nft_dup_ipv4 *priv = nft_expr_priv(expr);
    28		struct in_addr gw = {
  > 29			.s_addr = regs->data[priv->sreg_addr],
    30		};
    31		int oif = regs->data[priv->sreg_dev];
    32	
    33		nf_dup_ipv4(pkt->skb, pkt->ops->hooknum, &gw, oif);
    34	}
    35	
    36	static int nft_dup_ipv4_init(const struct nft_ctx *ctx,
    37				     const struct nft_expr *expr,

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
