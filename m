From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] conntrack: fix sysctl memory leak
Date: Thu, 10 Mar 2011 10:14:22 -0800
Message-ID: <20110310101422.62006620@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Message in log because sysctl table was not empty at netns exit
 WARNING: at net/sysctl_net.c:84 sysctl_net_exit+0x2a/0x2c()

Instrumenting showed that the nf_conntrack_timestamp was the entry
that was being created but not cleared.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netfilter/nf_conntrack_core.c	2011-03-10 09:42:10.656565623 -0800
+++ b/net/netfilter/nf_conntrack_core.c	2011-03-10 09:42:30.652821904 -0800
@@ -1301,6 +1301,7 @@ static void nf_conntrack_cleanup_net(str
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
 	nf_conntrack_ecache_fini(net);
+	nf_conntrack_tstamp_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
 	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
