From: sfeldma@gmail.com
Subject: [PATCH net-next 1/2] switchdev: fix CONFIG_IP_MULTIPLE_TABLES compile issue
Date: Fri,  6 Mar 2015 01:14:36 -0800
Message-ID: <1425633277-32929-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:40557 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbbCFJNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 04:13:51 -0500
Received: by padfb1 with SMTP id fb1so40872821pad.7
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 01:13:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index f4fd575..19e4e72 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -309,8 +309,12 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	 * IPv4 FIB offloading has been disabled completely.
 	 */
 
-	if (fi->fib_net->ipv4.fib_has_custom_rules |
-	    fi->fib_net->ipv4.fib_offload_disabled)
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	if (fi->fib_net->ipv4.fib_has_custom_rules)
+		return 0;
+#endif
+
+	if (fi->fib_net->ipv4.fib_offload_disabled)
 		return 0;
 
 	dev = netdev_switch_get_dev_by_nhs(fi);
-- 
1.7.10.4
