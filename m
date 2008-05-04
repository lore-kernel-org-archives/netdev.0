From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/2][BRIDGE]: Net device leak in br_add_bridge().
Date: Sun, 04 May 2008 10:47:29 +0400
Message-ID: <481D5C01.30906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47791 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbYEDGuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 02:50:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the register_netdevice() call fails the device is leaked,
since the out: label is just rtnl_unlock()+return.

Free the device.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/bridge/br_if.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 77a981a..bff0f5b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -280,8 +280,10 @@ int br_add_bridge(const char *name)
 	}
 
 	ret = register_netdevice(dev);
-	if (ret)
+	if (ret) {
+		free_netdev(dev);
 		goto out;
+	}
 
 	ret = br_sysfs_addbr(dev);
 	if (ret)
