From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Mon, 20 Jun 2011 12:56:16 +1000
Message-ID: <20110620125616.e319c55c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/netfilter/ipvs/ip_vs_core.c between commit 8f4e0a18682d ("IPVS netns
exit causes crash in conntrack") from the net-current tree and commit
503cf15a5ecc ("IPVS: rename of netns init and cleanup functions") from
the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netfilter/ipvs/ip_vs_core.c
index 24c28d2,2200bae..0000000
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@@ -1945,8 -1945,7 +1945,8 @@@ static void __net_exit __ip_vs_dev_clea
  {
  	EnterFunction(2);
  	net_ipvs(net)->enable = 0;	/* Disable packet reception */
 +	smp_wmb();
- 	__ip_vs_sync_cleanup(net);
+ 	ip_vs_sync_net_cleanup(net);
  	LeaveFunction(2);
  }
  
