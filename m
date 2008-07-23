From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] ipmr: delete redundant variable
Date: Wed, 23 Jul 2008 09:45:56 +0800
Message-ID: <48868D54.6050701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59394 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbYGWBr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 21:47:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*v can be removed as this patch showing.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c519b8d..6e715c7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1121,7 +1121,6 @@ int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 static int ipmr_device_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct vif_device *v;
 	int ct;
 
 	if (!net_eq(dev_net(dev), &init_net))
@@ -1129,9 +1128,9 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
 
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	v=&vif_table[0];
-	for (ct=0;ct<maxvif;ct++,v++) {
-		if (v->dev==dev)
+
+	for (ct = 0; ct < maxvif; ct++) {
+		if (vif_table[ct].dev == dev)
 			vif_delete(ct, 1);
 	}
 	return NOTIFY_DONE;



