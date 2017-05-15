From: linzhang <xiaolou4617@gmail.com>
Subject: [PATCH] net: x25: fix one potential use-after-free issue
Date: Mon, 15 May 2017 12:12:49 +0800
Message-ID: <1494821569-18572-1-git-send-email-xiaolou4617@gmail.com>
Cc: nhorman@tuxdriver.com, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linzhang <xiaolou4617@gmail.com>
To: andrew.hendry@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32880 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdEOENF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 00:13:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function x25_init is not properly unregister related resources
on error handler.It is will result in kernel oops if x25_init init
failed, so add right unregister call on error handler.

Signed-off-by: linzhang <xiaolou4617@gmail.com>
---
 net/x25/af_x25.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 8b911c2..e01e09a 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1811,12 +1811,14 @@ static int __init x25_init(void)
 	x25_register_sysctl();
 	rc = x25_proc_init();
 	if (rc != 0)
-		goto out_dev;
+		goto out_sysctl;
 out:
 	return rc;
-out_dev:
+out_sysctl:
+	x25_unregister_sysctl();
 	unregister_netdevice_notifier(&x25_dev_notifier);
 out_sock:
+	dev_remove_pack(&x25_packet_type);
 	sock_unregister(AF_X25);
 out_proto:
 	proto_unregister(&x25_proto);
-- 
1.8.3.1
