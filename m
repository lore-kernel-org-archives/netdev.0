From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 04/10] bonding: Call dev_kfree_skby_any instead of kfree_skb.
Date: Tue, 11 Mar 2014 14:16:58 -0700
Message-ID: <8761nkbflh.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<87r468bfqj.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40530 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbaCKVRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:17:05 -0400
In-Reply-To: <87r468bfqj.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:13:56 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/bonding/bond_3ad.c  |    2 +-
 drivers/net/bonding/bond_alb.c  |    2 +-
 drivers/net/bonding/bond_main.c |   10 +++++-----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index a2ef3f72de88..dee2a84a2929 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2479,7 +2479,7 @@ out:
 	return NETDEV_TX_OK;
 err_free:
 	/* no suitable interface, frame not sent */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	goto out;
 }
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index aaeeacf767f2..9cf836b67b15 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1464,7 +1464,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	}
 
 	/* no suitable interface, frame not sent */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 out:
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 730d72c706c9..60f35e5c7f74 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3548,7 +3548,7 @@ static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int sl
 		}
 	}
 	/* no slave that can tx has been found */
-	kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 }
 
 /**
@@ -3624,7 +3624,7 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	if (slave)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -3667,7 +3667,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	if (slave && IS_UP(slave->dev) && slave->link == BOND_LINK_UP)
 		bond_dev_queue_xmit(bond, skb, slave->dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
@@ -3754,7 +3754,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 		pr_err("%s: Error: Unknown bonding mode %d\n",
 		       dev->name, bond->params.mode);
 		WARN_ON_ONCE(1);
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 }
@@ -3775,7 +3775,7 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bond_has_slaves(bond))
 		ret = __bond_start_xmit(skb, dev);
 	else
-		kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	rcu_read_unlock();
 
 	return ret;
-- 
1.7.5.4
