From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/18] netfilter: ctnetlink: remove null test before kfree
Date: Fri, 18 Jul 2014 13:00:55 +0200
Message-ID: <1405681272-4994-2-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 5857963..aee017f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -742,8 +742,7 @@ static int ctnetlink_done(struct netlink_callback *cb)
 {
 	if (cb->args[1])
 		nf_ct_put((struct nf_conn *)cb->args[1]);
-	if (cb->data)
-		kfree(cb->data);
+	kfree(cb->data);
 	return 0;
 }
 
-- 
1.7.10.4

