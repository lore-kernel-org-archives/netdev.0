From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 38/53] netfilter: decnet: only register hooks in init namespace
Date: Mon,  1 May 2017 12:47:05 +0200
Message-ID: <1493635640-24325-39-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

looks like decnet isn't namespacified in first place, so restrict hook
registration to the initial namespace.

Prepares for eventual removal of legacy nf_register_hook() api.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/decnet/netfilter/dn_rtmsg.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 85f2fdc360c2..f44303a40105 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -134,7 +134,7 @@ static int __init dn_rtmsg_init(void)
 		return -ENOMEM;
 	}
 
-	rv = nf_register_hook(&dnrmg_ops);
+	rv = nf_register_net_hook(&init_net, &dnrmg_ops);
 	if (rv) {
 		netlink_kernel_release(dnrmg);
 	}
@@ -144,7 +144,7 @@ static int __init dn_rtmsg_init(void)
 
 static void __exit dn_rtmsg_fini(void)
 {
-	nf_unregister_hook(&dnrmg_ops);
+	nf_unregister_net_hook(&init_net, &dnrmg_ops);
 	netlink_kernel_release(dnrmg);
 }
 
-- 
2.1.4

