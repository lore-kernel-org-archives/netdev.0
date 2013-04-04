From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: nf_conntrack: fix error return code
Date: Thu,  4 Apr 2013 14:56:08 +0200
Message-ID: <1365080169-6880-5-git-send-email-pablo@netfilter.org>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in function
nf_conntrack_standalone_init().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_standalone.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 6bcce40..fedee39 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -568,6 +568,7 @@ static int __init nf_conntrack_standalone_init(void)
 		register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
 	if (!nf_ct_netfilter_header) {
 		pr_err("nf_conntrack: can't register to sysctl.\n");
+		ret = -ENOMEM;
 		goto out_sysctl;
 	}
 #endif
-- 
1.7.10.4

