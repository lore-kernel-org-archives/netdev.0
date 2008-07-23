From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] ip6mr: delete redundant variable
Date: Wed, 23 Jul 2008 09:46:07 +0800
Message-ID: <48868D5F.9060105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58580 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbYGWBrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 21:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*v can be removed as this patch showing.
Same as that of ipv4.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 095bc45..49c75b4 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -932,7 +932,6 @@ static int ip6mr_device_event(struct notifier_block *this,
 			      unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
-	struct mif_device *v;
 	int ct;
 
 	if (!net_eq(dev_net(dev), &init_net))
@@ -941,9 +940,8 @@ static int ip6mr_device_event(struct notifier_block *this,
 	if (event != NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
 
-	v = &vif6_table[0];
-	for (ct = 0; ct < maxvif; ct++, v++) {
-		if (v->dev == dev)
+	for (ct = 0; ct < maxvif; ct++) {
+		if (vif6_table[ct].dev == dev)
 			mif6_delete(ct);
 	}
 	return NOTIFY_DONE;



