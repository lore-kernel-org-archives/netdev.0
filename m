From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/13] netfilter: select NFNETLINK when enabling NF_TABLES
Date: Mon,  6 Jan 2014 14:46:36 +0100
Message-ID: <1389016002-9116-8-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59551 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754716AbaAFNq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:46:58 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

In Kconfig, nf_tables depends on NFNETLINK so building nf_tables as
a module or inside kernel depends on the state of NFNETLINK inside
the kernel config. If someone wants to build nf_tables inside the
kernel, it is necessary to also build NFNETLINK inside the kernel.
But NFNETLINK can not be set in the menu so it is necessary to
toggle other nfnetlink subsystems such as logging and nfacct to see
the nf_tables switch.

This patch changes the dependency from 'depend' to 'select' inside
Kconfig to allow to set the build of nftables as modules or inside
kernel independently.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 4371c98..01f9f64 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -414,7 +414,7 @@ config NETFILTER_SYNPROXY
 endif # NF_CONNTRACK
 
 config NF_TABLES
-	depends on NETFILTER_NETLINK
+	select NETFILTER_NETLINK
 	tristate "Netfilter nf_tables support"
 
 config NFT_EXTHDR
-- 
1.7.10.4
