From: Valentin Ilie <valentin.ilie@gmail.com>
Subject: [PATCHv2] net: can: af_can.c: Fix checkpatch warnings
Date: Sun, 10 Mar 2013 23:15:13 +0200
Message-ID: <1362950113-25515-1-git-send-email-valentin.ilie@gmail.com>
References: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Valentin Ilie <valentin.ilie@gmail.com>
To: socketcan@hartkopp.net, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace printk(KERN_ERR with pr_err
Add space before {
Removed OOM messages

Signed-off-by: Valentin Ilie <valentin.ilie@gmail.com>
---
 net/can/af_can.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/can/af_can.c b/net/can/af_can.c
index c48e522..8bacf28 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -525,7 +525,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 
 	d = find_dev_rcv_lists(dev);
 	if (!d) {
-		printk(KERN_ERR "BUG: receive list not found for "
+		pr_err("BUG: receive list not found for "
 		       "dev %s, id %03X, mask %03X\n",
 		       DNAME(dev), can_id, mask);
 		goto out;
@@ -552,7 +552,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	 */
 
 	if (!r) {
-		printk(KERN_ERR "BUG: receive list entry not found for "
+		pr_err("BUG: receive list entry not found for "
 		       "dev %s, id %03X, mask %03X\n",
 		       DNAME(dev), can_id, mask);
 		r = NULL;
@@ -749,8 +749,7 @@ int can_proto_register(const struct can_proto *cp)
 	int err = 0;
 
 	if (proto < 0 || proto >= CAN_NPROTO) {
-		printk(KERN_ERR "can: protocol number %d out of range\n",
-		       proto);
+		pr_err("can: protocol number %d out of range\n", proto);
 		return -EINVAL;
 	}
 
@@ -761,8 +760,7 @@ int can_proto_register(const struct can_proto *cp)
 	mutex_lock(&proto_tab_lock);
 
 	if (proto_tab[proto]) {
-		printk(KERN_ERR "can: protocol %d already registered\n",
-		       proto);
+		pr_err("can: protocol %d already registered\n", proto);
 		err = -EBUSY;
 	} else
 		RCU_INIT_POINTER(proto_tab[proto], cp);
@@ -816,11 +814,8 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 
 		/* create new dev_rcv_lists for this device */
 		d = kzalloc(sizeof(*d), GFP_KERNEL);
-		if (!d) {
-			printk(KERN_ERR
-			       "can: allocation of receive list failed\n");
+		if (!d)
 			return NOTIFY_DONE;
-		}
 		BUG_ON(dev->ml_priv);
 		dev->ml_priv = d;
 
@@ -838,8 +833,8 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 				dev->ml_priv = NULL;
 			}
 		} else
-			printk(KERN_ERR "can: notifier: receive list not "
-			       "found for dev %s\n", dev->name);
+			pr_err("can: notifier: receive list not found for dev "
+			       "%s\n", dev->name);
 
 		spin_unlock(&can_rcvlists_lock);
 
@@ -927,7 +922,7 @@ static __exit void can_exit(void)
 	/* remove created dev_rcv_lists from still registered CAN devices */
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
-		if (dev->type == ARPHRD_CAN && dev->ml_priv){
+		if (dev->type == ARPHRD_CAN && dev->ml_priv) {
 
 			struct dev_rcv_lists *d = dev->ml_priv;
 
-- 
1.8.1.2

