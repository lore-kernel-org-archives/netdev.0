From: Simon Horman <horms@verge.net.au>
Subject: Re: linux-next: Tree for February 1 (ip_vs)
Date: Thu, 3 Feb 2011 07:31:59 +0900
Message-ID: <20110202223159.GB2248@verge.net.au>
References: <20110201153403.b3a251a3.sfr@canb.auug.org.au>
 <20110201091620.64536300.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110201091620.64536300.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 01, 2011 at 09:16:20AM -0800, Randy Dunlap wrote:
> On Tue, 1 Feb 2011 15:34:03 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20110131:
> 
> 
> When CONFIG_IP_VS_PROTO_TCP is not set:
> 
> net/netfilter/ipvs/ip_vs_proto_sctp.c:1104: error: 'struct netns_ipvs' has no member named 'tcp_app_lock'
> net/netfilter/ipvs/ip_vs_proto_sctp.c:1104: error: 'struct netns_ipvs' has no member named 'tcp_app_lock'

Thanks, the following patch should resolve this problem.
Hans, could you verify this change?

The change is available at
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master


From: Simon Horman <horms@verge.net.au>

IPVS: Use correct lock in SCTP module

Use sctp_app_lock instead of tcp_app_lock in the SCTP protocol module.

This appears to be a typo introduced by the netns changes.

Cc: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index fb2d04a..b027ccc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -1101,7 +1101,7 @@ static void __ip_vs_sctp_init(struct net *net, struct ip_vs_proto_data *pd)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	ip_vs_init_hash_table(ipvs->sctp_apps, SCTP_APP_TAB_SIZE);
-	spin_lock_init(&ipvs->tcp_app_lock);
+	spin_lock_init(&ipvs->sctp_app_lock);
 	pd->timeout_table = ip_vs_create_timeout_table((int *)sctp_timeouts,
 							sizeof(sctp_timeouts));
 }
-- 
1.7.2.3
