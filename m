From: pablo@netfilter.org
Subject: [PATCH 07/12] netfilter: nfnetlink_log: fix possible compilation issue due to missing include
Date: Fri, 28 Dec 2012 12:52:46 +0100
Message-ID: <1356695571-3305-8-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51021 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab2L1LxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:18 -0500
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

In (0c36b48 netfilter: nfnetlink_log: fix mac address for 6in4 tunnels)
the include file that defines ARPD_SIT was missing. This passed unnoticed
during my tests (I did not hit this problem here).

net/netfilter/nfnetlink_log.c: In function '__build_packet_message':
net/netfilter/nfnetlink_log.c:494:25: error: 'ARPHRD_SIT' undeclared (first use in this function)
net/netfilter/nfnetlink_log.c:494:25: note: each undeclared identifier is reported only once for
+each function it appears in

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4e210e0..92fd8ec 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -13,6 +13,7 @@
  */
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/if_arp.h>
 #include <linux/init.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
-- 
1.7.10.4
