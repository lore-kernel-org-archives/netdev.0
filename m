From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V6 07/15] netpoll: remove usage of dev->master
Date: Fri,  4 Jan 2013 09:48:55 +0100
Message-ID: <1357289343-817-8-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:61205 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231Ab3ADItk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 03:49:40 -0500
Received: by mail-ee0-f44.google.com with SMTP id b47so7795887eek.17
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 00:49:38 -0800 (PST)
In-Reply-To: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/netpoll.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3151acf..d2bda8e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -210,9 +210,12 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
-			struct net_device *bond_dev = dev->master;
+			struct net_device *bond_dev;
 			struct sk_buff *skb;
-			struct netpoll_info *bond_ni = rcu_dereference_bh(bond_dev->npinfo);
+			struct netpoll_info *bond_ni;
+
+			bond_dev = netdev_master_upper_dev_get_rcu(dev);
+			bond_ni = rcu_dereference_bh(bond_dev->npinfo);
 			while ((skb = skb_dequeue(&ni->arp_tx))) {
 				skb->dev = bond_dev;
 				skb_queue_tail(&bond_ni->arp_tx, skb);
@@ -815,7 +818,7 @@ int netpoll_setup(struct netpoll *np)
 		return -ENODEV;
 	}
 
-	if (ndev->master) {
+	if (netdev_master_upper_dev_get(ndev)) {
 		np_err(np, "%s is a slave device, aborting\n", np->dev_name);
 		err = -EBUSY;
 		goto put;
-- 
1.8.0
