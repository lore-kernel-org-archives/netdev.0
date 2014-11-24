From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/17] netfilter: nfnetlink_log: Make use of pr_fmt where applicable
Date: Mon, 24 Nov 2014 14:27:54 +0100
Message-ID: <1416835674-11871-18-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754155AbaKXN0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:26:02 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Leitner <mleitner@redhat.com>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 51996ec..405cf58 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -12,6 +12,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
@@ -1063,19 +1066,19 @@ static int __init nfnetlink_log_init(void)
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
-		pr_err("log: failed to create netlink socket\n");
+		pr_err("failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
 	status = nf_log_register(NFPROTO_UNSPEC, &nfulnl_logger);
 	if (status < 0) {
-		pr_err("log: failed to register logger\n");
+		pr_err("failed to register logger\n");
 		goto cleanup_subsys;
 	}
 
 	status = register_pernet_subsys(&nfnl_log_net_ops);
 	if (status < 0) {
-		pr_err("log: failed to register pernet ops\n");
+		pr_err("failed to register pernet ops\n");
 		goto cleanup_logger;
 	}
 	return status;
-- 
1.7.10.4
