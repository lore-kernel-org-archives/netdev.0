From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 1/2] net: use dev->name in netdev_pr* when it's available
Date: Thu, 17 Jul 2014 13:28:10 +0200
Message-ID: <1405596491-5881-2-git-send-email-vfalico@gmail.com>
References: <1405596491-5881-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbaGQLcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 07:32:41 -0400
In-Reply-To: <1405596491-5881-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_name() returns dev->name only when the net_device is in
NETREG_REGISTERED state.

However, dev->name is always populated on creation, so we can easily use
it. The only caveat is that the device still has a name of type "eth%d", in
which case we cannot use this name as it'll change in the nearest future,
thus return "unnamed net_device".

CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15ed750..cde12a3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3383,8 +3383,8 @@ extern struct pernet_operations __net_initdata loopback_net_ops;
 
 static inline const char *netdev_name(const struct net_device *dev)
 {
-	if (dev->reg_state != NETREG_REGISTERED)
-		return "(unregistered net_device)";
+	if (strchr(dev->name, '%'))
+		return "(unnamed net_device)";
 	return dev->name;
 }
 
-- 
1.8.4
