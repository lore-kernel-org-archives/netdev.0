From: pablo@netfilter.org
Subject: [PATCH 1/5] ipvs: freeing uninitialized pointer on error
Date: Sat,  9 Feb 2013 13:03:56 +0100
Message-ID: <1360411440-6526-2-git-send-email-pablo@netfilter.org>
References: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

If state != IP_VS_STATE_BACKUP then tinfo->buf is uninitialized.  If
kthread_run() fails then it means we free random memory resulting in an
oops.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index effa10c..44fd10c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1795,6 +1795,8 @@ int start_sync_thread(struct net *net, int state, char *mcast_ifn, __u8 syncid)
 					     GFP_KERNEL);
 			if (!tinfo->buf)
 				goto outtinfo;
+		} else {
+			tinfo->buf = NULL;
 		}
 		tinfo->id = id;
 
-- 
1.7.10.4

