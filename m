From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH vxlan v2 1/8] vxlan: Fix module cleanup.
Date: Wed, 26 Jun 2013 13:13:29 -0700
Message-ID: <1372277609-17467-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:42315 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752452Ab3FZUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:13:33 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr13so14658143pbb.34
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 13:13:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan private per net object can be accessed in device unregister.
therefore unregister pernet device at the end.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 227b54a..0ba1e7e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1916,9 +1916,9 @@ late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-	unregister_pernet_device(&vxlan_net_ops);
 	rtnl_link_unregister(&vxlan_link_ops);
 	destroy_workqueue(vxlan_wq);
+	unregister_pernet_device(&vxlan_net_ops);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
-- 
1.7.1
