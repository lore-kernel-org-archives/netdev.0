From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 1/2] net: use dev->name in netdev_pr* when it's available
Date: Thu, 17 Jul 2014 19:46:09 +0200
Message-ID: <1405619171-18172-2-git-send-email-vfalico@gmail.com>
References: <1405619171-18172-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbaGQRuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 13:50:40 -0400
In-Reply-To: <1405619171-18172-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_name() returns dev->name only when the net_device is in
NETREG_REGISTERED state.

However, dev->name is always populated on creation, so we can easily use
it.

There are two cases when there's no real name - when it's an empty string
or when the name is in form of "eth%d", then netdev_name() returns "unnamed
net_device".

CC: "David S. Miller" <davem@davemloft.net>
CC: Tom Gundersen <teg@jklm.no>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---

Notes:
    v1->v2:
    Also account for an empty string, as Tom Gundersen suggested.

 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15ed750..70256aa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3383,8 +3383,8 @@ extern struct pernet_operations __net_initdata loopback_net_ops;
 
 static inline const char *netdev_name(const struct net_device *dev)
 {
-	if (dev->reg_state != NETREG_REGISTERED)
-		return "(unregistered net_device)";
+	if (!dev->name[0] || strchr(dev->name, '%'))
+		return "(unnamed net_device)";
 	return dev->name;
 }
 
-- 
1.8.4
