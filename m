From: Roman Kapl <roman.kapl@sysgo.com>
Subject: [PATCH] net: set default value for somaxconn
Date: Mon, 22 May 2017 14:22:41 +0200
Message-ID: <20170522122241.28389-1-roman.kapl@sysgo.com>
Cc: Roman Kapl <roman.kapl@sysgo.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sysgo.com ([176.9.12.79]:46188 "EHLO mail.sysgo.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751127AbdEVMci (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 08:32:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default value for somaxconn is set in sysctl_core_net_init(), but this
function is not called when kernel is configured without CONFIG_SYSCTL.

This results in the kernel not being able to accept TCP connections,
because the backlog has zero size. Usually, the user ends up with:
"TCP: request_sock_TCP: Possible SYN flooding on port 7. Dropping request.  Check SNMP counters."

Before ef547f2ac16 (tcp: remove max_qlen_log), the effects were less
severe, because the backlog was always at least eight slots long.

Signed-off-by: Roman Kapl <roman.kapl@sysgo.com>
---
 net/core/net_namespace.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1934efd..4f3bbff 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -37,6 +37,9 @@ EXPORT_SYMBOL_GPL(net_namespace_list);
 struct net init_net = {
 	.count		= ATOMIC_INIT(1),
 	.dev_base_head	= LIST_HEAD_INIT(init_net.dev_base_head),
+	.core = {
+		.sysctl_somaxconn = SOMAXCONN,
+	},
 };
 EXPORT_SYMBOL(init_net);
 
-- 
2.10.1
