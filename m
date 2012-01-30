From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: dev: Convert printks to pr_<level>
Date: Sun, 29 Jan 2012 16:20:30 -0800
Message-ID: <1327882830.2652.16.camel@joe2Laptop>
References: <1327877783.2652.10.camel@joe2Laptop>
	 <1327880872.2652.12.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.117.179.246] ([206.117.179.246]:46357 "EHLO labridge.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754069Ab2A3AUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jan 2012 19:20:50 -0500
In-Reply-To: <1327880872.2652.12.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging style.
Coalesce formats where appropriate.
Update grammar where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c |  101 +++++++++++++++++++++++++------------------------------
 1 files changed, 46 insertions(+), 55 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 115dee1..98c6b5e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -446,7 +446,7 @@ void __dev_remove_pack(struct packet_type *pt)
 		}
 	}
 
-	printk(KERN_WARNING "dev_remove_pack: %p not found.\n", pt);
+	pr_warn("dev_remove_pack: %p not found\n", pt);
 out:
 	spin_unlock(&ptype_lock);
 }
@@ -1039,8 +1039,7 @@ rollback:
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
 		} else {
-			printk(KERN_ERR
-			       "%s: name change rollback failed: %d.\n",
+			pr_err("%s: name change rollback failed: %d\n",
 			       dev->name, ret);
 		}
 	}
@@ -1139,9 +1138,10 @@ void dev_load(struct net *net, const char *name)
 		no_module = request_module("netdev-%s", name);
 	if (no_module && capable(CAP_SYS_MODULE)) {
 		if (!request_module("%s", name))
-			pr_err("Loading kernel module for a network device "
-"with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s "
-"instead\n", name);
+			pr_err(
+"Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  "
+"Use CAP_NET_ADMIN and alias netdev-%s instead\n",
+			       name);
 	}
 }
 EXPORT_SYMBOL(dev_load);
@@ -1655,10 +1655,9 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			if (skb_network_header(skb2) < skb2->data ||
 			    skb2->network_header > skb2->tail) {
 				if (net_ratelimit())
-					printk(KERN_CRIT "protocol %04x is "
-					       "buggy, dev %s\n",
-					       ntohs(skb2->protocol),
-					       dev->name);
+					pr_crit("protocol %04x is buggy, dev %s\n",
+						ntohs(skb2->protocol),
+						dev->name);
 				skb_reset_network_header(skb2);
 			}
 
@@ -1691,9 +1690,9 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 
 	/* If TC0 is invalidated disable TC mapping */
 	if (tc->offset + tc->count > txq) {
-		pr_warning("Number of in use tx queues changed "
-			   "invalidating tc mappings. Priority "
-			   "traffic classification disabled!\n");
+		pr_warn(
+"Number of in use tx queues changed invalidating tc mappings. "
+"Priority traffic classification disabled!\n");
 		dev->num_tc = 0;
 		return;
 	}
@@ -1704,11 +1703,9 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 
 		tc = &dev->tc_to_txq[q];
 		if (tc->offset + tc->count > txq) {
-			pr_warning("Number of in use tx queues "
-				   "changed. Priority %i to tc "
-				   "mapping %i is no longer valid "
-				   "setting map to 0\n",
-				   i, q);
+			pr_warn("Number of in use tx queues changed. "
+"Priority %i to tc mapping %i is no longer valid. Setting map to 0\n",
+				i, q);
 			netdev_set_prio_tc_map(dev, i, 0);
 		}
 	}
@@ -2014,8 +2011,7 @@ EXPORT_SYMBOL(skb_gso_segment);
 void netdev_rx_csum_fault(struct net_device *dev)
 {
 	if (net_ratelimit()) {
-		printk(KERN_ERR "%s: hw csum failure.\n",
-			dev ? dev->name : "<unknown>");
+		pr_err("%s: hw csum failure\n", dev ? dev->name : "<unknown>");
 		dump_stack();
 	}
 }
@@ -2332,9 +2328,9 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
 		if (net_ratelimit()) {
-			pr_warning("%s selects TX queue %d, but "
-				"real number of TX queues is %d\n",
-				dev->name, queue_index, dev->real_num_tx_queues);
+			pr_warn("%s selects TX queue %d, but real number of TX queues is %d\n",
+				dev->name, queue_index,
+				dev->real_num_tx_queues);
 		}
 		return 0;
 	}
@@ -2578,16 +2574,16 @@ int dev_queue_xmit(struct sk_buff *skb)
 			}
 			HARD_TX_UNLOCK(dev, txq);
 			if (net_ratelimit())
-				printk(KERN_CRIT "Virtual device %s asks to "
-				       "queue packet!\n", dev->name);
+				pr_crit("Virtual device %s asks to queue packet!\n",
+					dev->name);
 		} else {
 			/* Recursion is detected! It is possible,
 			 * unfortunately
 			 */
 recursion_alert:
 			if (net_ratelimit())
-				printk(KERN_CRIT "Dead loop on virtual device "
-				       "%s, fix it urgently!\n", dev->name);
+				pr_crit("Dead loop on virtual device %s, fix it urgently!\n",
+					dev->name);
 		}
 	}
 
@@ -3069,8 +3065,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	if (unlikely(MAX_RED_LOOP < ttl++)) {
 		if (net_ratelimit())
-			pr_warning( "Redir loop detected Dropping packet (%d->%d)\n",
-			       skb->skb_iif, dev->ifindex);
+			pr_warn("Redir loop detected. Dropping packet (%d->%d)\n",
+				skb->skb_iif, dev->ifindex);
 		return TC_ACT_SHOT;
 	}
 
@@ -4491,16 +4487,16 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 			dev->flags &= ~IFF_PROMISC;
 		else {
 			dev->promiscuity -= inc;
-			printk(KERN_WARNING "%s: promiscuity touches roof, "
-				"set promiscuity failed, promiscuity feature "
-				"of device might be broken.\n", dev->name);
+			pr_warn("%s: promiscuity touches roof, set promiscuity failed. "
+"promiscuity feature of device might be broken.\n",
+				dev->name);
 			return -EOVERFLOW;
 		}
 	}
 	if (dev->flags != old_flags) {
-		printk(KERN_INFO "device %s %s promiscuous mode\n",
-		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
-							       "left");
+		pr_info("device %s %s promiscuous mode\n",
+			dev->name,
+			dev->flags & IFF_PROMISC ? "entered" : "left");
 		if (audit_enabled) {
 			current_uid_gid(&uid, &gid);
 			audit_log(current->audit_context, GFP_ATOMIC,
@@ -4573,9 +4569,9 @@ int dev_set_allmulti(struct net_device *dev, int inc)
 			dev->flags &= ~IFF_ALLMULTI;
 		else {
 			dev->allmulti -= inc;
-			printk(KERN_WARNING "%s: allmulti touches roof, "
-				"set allmulti failed, allmulti feature of "
-				"device might be broken.\n", dev->name);
+			pr_warn("%s: allmulti touches roof, set allmulti failed. "
+"allmulti feature of device might be broken.\n",
+				dev->name);
 			return -EOVERFLOW;
 		}
 	}
@@ -5232,8 +5228,8 @@ static void rollback_registered_many(struct list_head *head)
 		 * devices and proceed with the remaining.
 		 */
 		if (dev->reg_state == NETREG_UNINITIALIZED) {
-			pr_debug("unregister_netdevice: device %s/%p never "
-				 "was registered\n", dev->name, dev);
+			pr_debug("unregister_netdevice: device %s/%p never was registered\n",
+				 dev->name, dev);
 
 			WARN_ON(1);
 			list_del(&dev->unreg_list);
@@ -5465,7 +5461,7 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
 	if (!rx) {
-		pr_err("netdev: Unable to allocate %u rx queues.\n", count);
+		pr_err("netdev: Unable to allocate %u rx queues\n", count);
 		return -ENOMEM;
 	}
 	dev->_rx = rx;
@@ -5499,8 +5495,7 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 
 	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
 	if (!tx) {
-		pr_err("netdev: Unable to allocate %u tx queues.\n",
-		       count);
+		pr_err("netdev: Unable to allocate %u tx queues\n", count);
 		return -ENOMEM;
 	}
 	dev->_tx = tx;
@@ -5759,10 +5754,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 		refcnt = netdev_refcnt_read(dev);
 
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
-			printk(KERN_EMERG "unregister_netdevice: "
-			       "waiting for %s to become free. Usage "
-			       "count = %d\n",
-			       dev->name, refcnt);
+			pr_emerg("unregister_netdevice: waiting for %s to become free. Usage count = %d\n",
+				 dev->name, refcnt);
 			warning_time = jiffies;
 		}
 	}
@@ -5813,7 +5806,7 @@ void netdev_run_todo(void)
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
-			printk(KERN_ERR "network todo '%s' but state %d\n",
+			pr_err("network todo '%s' but state %d\n",
 			       dev->name, dev->reg_state);
 			dump_stack();
 			continue;
@@ -5929,15 +5922,13 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	if (txqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero queues.\n");
+		pr_err("alloc_netdev: Unable to allocate device with zero queues\n");
 		return NULL;
 	}
 
 #ifdef CONFIG_RPS
 	if (rxqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero RX queues.\n");
+		pr_err("alloc_netdev: Unable to allocate device with zero RX queues\n");
 		return NULL;
 	}
 #endif
@@ -5953,7 +5944,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate device.\n");
+		pr_err("alloc_netdev: Unable to allocate device\n");
 		return NULL;
 	}
 
@@ -6486,8 +6477,8 @@ static void __net_exit default_device_exit(struct net *net)
 		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
 		err = dev_change_net_namespace(dev, &init_net, fb_name);
 		if (err) {
-			printk(KERN_EMERG "%s: failed to move %s to init_net: %d\n",
-				__func__, dev->name, err);
+			pr_emerg("%s: failed to move %s to init_net: %d\n",
+				 __func__, dev->name, err);
 			BUG();
 		}
 	}
-- 
1.7.8.111.gad25c.dirty
