From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] netfilter: bridge: clarify bridge/netfilter message
Date: Wed, 28 Sep 2016 15:05:28 -0700
Message-ID: <20160928220528.17478-1-stefan@agner.ch>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pablo@netfilter.org,
        Stefan Agner <stefan@agner.ch>
To: stephen@networkplumber.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:33760 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932369AbcI1WFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 18:05:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using bridge without bridge netfilter enabled the message
displayed is rather confusing and leads to belive that a deprecated
feature is in use. Use IS_MODULE to be explicit that the message only
affects users which use bridge netfilter as module and reword the
message.

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 net/bridge/br.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 3addc05..889e564 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -227,9 +227,11 @@ static int __init br_init(void)
 	br_fdb_test_addr_hook = br_fdb_test_addr;
 #endif
 
-	pr_info("bridge: automatic filtering via arp/ip/ip6tables has been "
-		"deprecated. Update your scripts to load br_netfilter if you "
+#if IS_MODULE(CONFIG_BRIDGE_NETFILTER)
+	pr_info("bridge: filtering via arp/ip/ip6tables is no longer available "
+		"by default. Update your scripts to load br_netfilter if you "
 		"need this.\n");
+#endif
 
 	return 0;
 
-- 
2.10.0
