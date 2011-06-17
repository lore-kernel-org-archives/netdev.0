From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] netpoll: copy dev name of slaves to struct netpoll
Date: Fri, 17 Jun 2011 17:43:37 +0800
Message-ID: <1308303817-3498-1-git-send-email-amwang@redhat.com>
Cc: davem@davemloft.net, WANG Cong <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220Ab1FQJnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 05:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we will not see the name of the slave dev in error
message:

[  388.469446] (null):  doesn't support polling, aborting.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 652b30e..eafe44a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1297,6 +1297,7 @@ static inline int slave_enable_netpoll(struct slave *slave)
 		goto out;
 
 	np->dev = slave->dev;
+	strlcpy(np->dev_name, slave->dev->name, IFNAMSIZ);
 	err = __netpoll_setup(np);
 	if (err) {
 		kfree(np);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index a6b2f86..c188c80 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -243,6 +243,7 @@ int br_netpoll_enable(struct net_bridge_port *p)
 		goto out;
 
 	np->dev = p->dev;
+	strlcpy(np->dev_name, p->dev->name, IFNAMSIZ);
 
 	err = __netpoll_setup(np);
 	if (err) {
