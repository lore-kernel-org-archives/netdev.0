From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: bridge: fix nf_tables bridge dependencies with main core
Date: Mon,  4 Nov 2013 23:05:17 +0100
Message-ID: <1383602721-5728-2-git-send-email-pablo@netfilter.org>
References: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57701 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab3KDWFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 17:05:32 -0500
In-Reply-To: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when CONFIG_NF_TABLES[_MODULE] is not enabled,
but CONFIG_NF_TABLES_BRIDGE is enabled:

net/bridge/netfilter/nf_tables_bridge.c: In function 'nf_tables_bridge_init_net':
net/bridge/netfilter/nf_tables_bridge.c:24:5: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c:25:9: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c:28:2: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c:30:34: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c:35:11: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c: In function 'nf_tables_bridge_exit_net':
net/bridge/netfilter/nf_tables_bridge.c:41:27: error: 'struct net' has no member named 'nft'
net/bridge/netfilter/nf_tables_bridge.c:42:11: error: 'struct net' has no member named 'nft'

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 68f8128..5ca74a0 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -3,6 +3,7 @@
 #
 #
 config NF_TABLES_BRIDGE
+	depends on NF_TABLES
 	tristate "Ethernet Bridge nf_tables support"
 
 menuconfig BRIDGE_NF_EBTABLES
-- 
1.7.10.4
