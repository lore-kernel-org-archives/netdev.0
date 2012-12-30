From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/15] netpoll: remove usage of dev->master
Date: Sun, 30 Dec 2012 12:58:14 +0100
Message-ID: <1356868702-8144-8-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:38441 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501Ab2L3MAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:00:00 -0500
Received: by mail-ea0-f182.google.com with SMTP id a14so4970468eaa.41
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 03:59:58 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
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
