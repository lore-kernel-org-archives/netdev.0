From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/29] netfilter: nf_conntrack: restore nf_conntrack_htable_size as exported symbol
Date: Mon,  5 Sep 2016 12:58:25 +0200
Message-ID: <1473073124-5015-11-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is required to iterate over the hash table in cttimeout, ctnetlink
and nf_conntrack_ipv4.

>> ERROR: "nf_conntrack_htable_size" [net/netfilter/nfnetlink_cttimeout.ko] undefined!
   ERROR: "nf_conntrack_htable_size" [net/netfilter/nf_conntrack_netlink.ko] undefined!
   ERROR: "nf_conntrack_htable_size" [net/ipv4/netfilter/nf_conntrack_ipv4.ko] undefined!

Fixes: adf0516845bcd0 ("netfilter: remove ip_conntrack* sysctl compat code")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index aeba28c..7d90a5d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -160,6 +160,8 @@ static void nf_conntrack_all_unlock(void)
 }
 
 unsigned int nf_conntrack_htable_size __read_mostly;
+EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
+
 unsigned int nf_conntrack_max __read_mostly;
 seqcount_t nf_conntrack_generation __read_mostly;
 
-- 
2.1.4

