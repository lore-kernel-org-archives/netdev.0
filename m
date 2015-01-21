From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fixes cxgb4_inet6addr_notifier unregister call
Date: Wed, 21 Jan 2015 20:57:52 +0530
Message-ID: <1421854072-6427-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1515 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752938AbbAUPWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 10:22:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b5a02f503caa0837 ("cxgb4 : Update ipv6 address handling api") introduced
a regression where unregister cxgb4_inet6addr_notifier wasn't getting called
during module_exit.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1147e1e..12c1a3f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6290,7 +6290,7 @@ static int __init cxgb4_init_module(void)
 static void __exit cxgb4_cleanup_module(void)
 {
 #if IS_ENABLED(CONFIG_IPV6)
-	if (inet6addr_registered && list_empty(&adapter_list)) {
+	if (inet6addr_registered) {
 		unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
 		inet6addr_registered = false;
 	}
-- 
1.7.1
