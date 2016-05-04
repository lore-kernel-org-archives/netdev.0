From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] vrf: add exit function and allow module unload
Date: Wed,  4 May 2016 12:20:36 +0200
Message-ID: <1462357236-6297-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35085 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbcEDKUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 06:20:40 -0400
Received: by mail-wm0-f49.google.com with SMTP id e201so181205230wme.0
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 03:20:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/vrf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 8a8f1e5..b217c2d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -839,7 +839,14 @@ error:
 	return rc;
 }
 
+static void __exit vrf_exit_module(void)
+{
+	rtnl_link_unregister(&vrf_link_ops);
+	unregister_netdevice_notifier(&vrf_notifier_block);
+}
+
 module_init(vrf_init_module);
+module_exit(vrf_exit_module);
 MODULE_AUTHOR("Shrijeet Mukherjee, David Ahern");
 MODULE_DESCRIPTION("Device driver to instantiate VRF domains");
 MODULE_LICENSE("GPL");
-- 
2.5.5
