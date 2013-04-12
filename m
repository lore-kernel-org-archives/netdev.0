From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] vxlan: fix some sparse warnings
Date: Fri, 12 Apr 2013 13:00:35 +0800
Message-ID: <CAPgLHd_utCxvQJtACgTqL2cMJBV74Xw6x0iOgJvbN+Qej6c8-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, stephen@networkplumber.org,
	pshelar@nicira.com, alexander.h.duyck@intel.com,
	dlstevens@us.ibm.com, zealot0630@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:34676 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab3DLFAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 01:00:37 -0400
Received: by mail-bk0-f42.google.com with SMTP id jc3so1158013bkc.15
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 22:00:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes following warning:
drivers/net/vxlan.c:406:6: warning: symbol 'vxlan_fdb_free' was not declared. Should it be static?
drivers/net/vxlan.c:1111:37: warning: Using plain integer as NULL pointer

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9a64715..ee02ecd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -403,7 +403,7 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
 	return 0;
 }
 
-void vxlan_fdb_free(struct rcu_head *head)
+static void vxlan_fdb_free(struct rcu_head *head)
 {
 	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
 
@@ -1108,7 +1108,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		group.remote_vni = vxlan->vni;
 		group.remote_ip = vxlan->gaddr;
 		group.remote_ifindex = vxlan->link;
-		group.remote_next = 0;
+		group.remote_next = NULL;
 		rdst0 = &group;
 
 		if (group.remote_ip == htonl(INADDR_ANY) &&
