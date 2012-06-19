From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/4] netfilter updates for net-next (batch 3)
Date: Tue, 19 Jun 2012 05:37:45 +0200
Message-ID: <20120619033745.GA31405@1984>
References: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 19, 2012 at 05:16:25AM +0200, pablo@netfilter.org wrote:
[...]
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf-next master

Please, also take the small patch attached after this 4 patch series. It
fixes one linking issue.

Sorry, I'll put more care next time testing compilation options more
extensively.

--J/dobhs11T7y2rNN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-fix-missing-symbols-if-CONFIG_NETFILTER_NE.patch"

>From af6b248c22759fb7448668bbe495f1cbe0a9109d Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 19 Jun 2012 05:25:46 +0200
Subject: [PATCH] netfilter: fix missing symbols if
 CONFIG_NETFILTER_NETLINK_QUEUE_CT unset

ERROR: "nfqnl_ct_parse" [net/netfilter/nfnetlink_queue.ko] undefined!
ERROR: "nfqnl_ct_seq_adjust" [net/netfilter/nfnetlink_queue.ko] undefined!
ERROR: "nfqnl_ct_put" [net/netfilter/nfnetlink_queue.ko] undefined!
ERROR: "nfqnl_ct_get" [net/netfilter/nfnetlink_queue.ko] undefined!

We have to use CONFIG_NETFILTER_NETLINK_QUEUE_CT in
include/net/netfilter/nfnetlink_queue.h, not CONFIG_NF_CONNTRACK.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nfnetlink_queue.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/nfnetlink_queue.h b/include/net/netfilter/nfnetlink_queue.h
index 9f8095c..86267a5 100644
--- a/include/net/netfilter/nfnetlink_queue.h
+++ b/include/net/netfilter/nfnetlink_queue.h
@@ -5,7 +5,7 @@
 
 struct nf_conn;
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 struct nf_conn *nfqnl_ct_get(struct sk_buff *entskb, size_t *size,
 			     enum ip_conntrack_info *ctinfo);
 struct nf_conn *nfqnl_ct_parse(const struct sk_buff *skb,
-- 
1.7.10


--J/dobhs11T7y2rNN--
