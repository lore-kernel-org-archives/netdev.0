From: pablo@netfilter.org
Subject: [PATCH 4/6] netfilter: nfnetlink_log: fix error return code in init path
Date: Fri, 31 Aug 2012 16:03:07 +0200
Message-ID: <1346421789-3449-5-git-send-email-pablo@netfilter.org>
References: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Initialize return variable before exiting on an error path.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}

// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 592091c1..14e2f39 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -996,8 +996,10 @@ static int __init nfnetlink_log_init(void)
 
 #ifdef CONFIG_PROC_FS
 	if (!proc_create("nfnetlink_log", 0440,
-			 proc_net_netfilter, &nful_file_ops))
+			 proc_net_netfilter, &nful_file_ops)) {
+		status = -ENOMEM;
 		goto cleanup_logger;
+	}
 #endif
 	return status;
 
-- 
1.7.10.4

