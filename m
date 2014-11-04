From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 2/2] geneve: Unregister pernet subsys on module unload.
Date: Mon,  3 Nov 2014 19:38:38 -0800
Message-ID: <1415072318-64442-2-git-send-email-jesse@nicira.com>
References: <1415072318-64442-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:55607 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751794AbaKDDqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 22:46:54 -0500
Received: by mail-pa0-f47.google.com with SMTP id kx10so13569122pab.34
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 19:46:54 -0800 (PST)
In-Reply-To: <1415072318-64442-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pernet ops aren't ever unregistered, which causes a memory
leak and an OOPs if the module is ever reinserted.

CC: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 6e5266c..dedb21e 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -366,6 +366,7 @@ late_initcall(geneve_init_module);
 static void __exit geneve_cleanup_module(void)
 {
 	destroy_workqueue(geneve_wq);
+	unregister_pernet_subsys(&geneve_net_ops);
 }
 module_exit(geneve_cleanup_module);
 
-- 
1.9.1
