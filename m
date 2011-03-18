From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 28/36] net,rcu: convert call_rcu(phonet_device_rcu_free) to
 kfree_rcu()
Date: Fri, 18 Mar 2011 12:09:03 +0800
Message-ID: <4D82DADF.4010802__40510.6446742595$1300421258$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62139 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752338Ab1CREHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 00:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback phonet_device_rcu_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(phonet_device_rcu_free).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 net/phonet/pn_dev.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 947038d..1566672 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -162,14 +162,6 @@ int phonet_address_add(struct net_device *dev, u8 addr)
 	return err;
 }
 
-static void phonet_device_rcu_free(struct rcu_head *head)
-{
-	struct phonet_device *pnd;
-
-	pnd = container_of(head, struct phonet_device, rcu);
-	kfree(pnd);
-}
-
 int phonet_address_del(struct net_device *dev, u8 addr)
 {
 	struct phonet_device_list *pndevs = phonet_device_list(dev_net(dev));
@@ -188,7 +180,7 @@ int phonet_address_del(struct net_device *dev, u8 addr)
 	mutex_unlock(&pndevs->lock);
 
 	if (pnd)
-		call_rcu(&pnd->rcu, phonet_device_rcu_free);
+		kfree_rcu(pnd, rcu);
 
 	return err;
 }
-- 
1.7.4
