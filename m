From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 1/31]: igb: Kill CONFIG_NETDEVICES_MULTIQUEUE references,
 no longer exists.
Date: Thu, 17 Jul 2008 05:15:38 -0700 (PDT)
Message-ID: <20080717.051538.150945526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/igb/igb.h      |    2 -
 drivers/net/igb/igb_main.c |   51 --------------------------------------------
 2 files changed, 0 insertions(+), 53 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 56de7ec..4ff6f05 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -287,9 +287,7 @@ struct igb_adapter {
 	int bars;
 	int need_ioport;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
-#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 #ifdef CONFIG_IGB_LRO
 	unsigned int lro_max_aggr;
 	unsigned int lro_aggregated;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 74dc43e..64a150a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -532,10 +532,8 @@ msi_only:
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->flags |= IGB_FLAG_HAS_MSI;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
 	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
-#endif
 	return;
 }
 
@@ -824,10 +822,8 @@ void igb_down(struct igb_adapter *adapter)
 	/* flush and sleep below */
 
 	netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		netif_stop_subqueue(netdev, i);
-#endif
 
 	/* disable transmits in the hardware */
 	tctl = rd32(E1000_TCTL);
@@ -1042,11 +1038,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	pci_save_state(pdev);
 
 	err = -ENOMEM;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev = alloc_etherdev_mq(sizeof(struct igb_adapter), IGB_MAX_TX_QUEUES);
-#else
-	netdev = alloc_etherdev(sizeof(struct igb_adapter));
-#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -1163,9 +1155,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netdev->features |= NETIF_F_MULTI_QUEUE;
-#endif
 
 	netdev->features |= NETIF_F_LLTX;
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(&adapter->hw);
@@ -1279,10 +1269,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	/* tell the stack to leave us alone until igb_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		netif_stop_subqueue(netdev, i);
-#endif
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
@@ -1432,11 +1420,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	/* Number of supported queues. */
 	/* Having more queues than CPUs doesn't make sense. */
 	adapter->num_rx_queues = min((u32)IGB_MAX_RX_QUEUES, (u32)num_online_cpus());
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	adapter->num_tx_queues = min(IGB_MAX_TX_QUEUES, num_online_cpus());
-#else
-	adapter->num_tx_queues = 1;
-#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 
 	/* This call may decrease the number of queues depending on
 	 * interrupt mode. */
@@ -1619,9 +1603,7 @@ err:
 static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 {
 	int i, err = 0;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	int r_idx;
-#endif	
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = igb_setup_tx_resources(adapter, &adapter->tx_ring[i]);
@@ -1634,12 +1616,10 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 		}
 	}
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	for (i = 0; i < IGB_MAX_TX_QUEUES; i++) {
 		r_idx = i % adapter->num_tx_queues;
 		adapter->multi_tx_table[i] = &adapter->tx_ring[r_idx];
 	}	
-#endif		
 	return err;
 }
 
@@ -2337,9 +2317,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	u32 link;
 	s32 ret_val;
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	int i;
-#endif
 
 	if ((netif_carrier_ok(netdev)) &&
 	    (rd32(E1000_STATUS) & E1000_STATUS_LU))
@@ -2396,10 +2374,8 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			for (i = 0; i < adapter->num_tx_queues; i++)
 				netif_wake_subqueue(netdev, i);
-#endif
 
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -2412,10 +2388,8 @@ static void igb_watchdog_task(struct work_struct *work)
 			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			for (i = 0; i < adapter->num_tx_queues; i++)
 				netif_stop_subqueue(netdev, i);
-#endif
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2943,11 +2917,7 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_stop_queue(netdev);
-#endif
 
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
@@ -2960,11 +2930,7 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! */
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_wake_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_wake_queue(netdev);
-#endif	
 	++adapter->restart_queue;
 	return 0;
 }
@@ -3051,14 +3017,9 @@ static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *netdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *tx_ring;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	int r_idx = 0;
 	r_idx = skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);
 	tx_ring = adapter->multi_tx_table[r_idx];
-#else
-	tx_ring = &adapter->tx_ring[0];
-#endif
-
 
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3745,19 +3706,11 @@ done_cleaning:
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
 		    !(test_bit(__IGB_DOWN, &adapter->state))) {
 			netif_wake_subqueue(netdev, tx_ring->queue_index);
 			++adapter->restart_queue;
 		}
-#else
-		if (netif_queue_stopped(netdev) &&
-		    !(test_bit(__IGB_DOWN, &adapter->state))) {
-			netif_wake_queue(netdev);
-			++adapter->restart_queue;
-		}
-#endif		
 	}
 
 	if (tx_ring->detect_tx_hung) {
@@ -3793,11 +3746,7 @@ done_cleaning:
 				tx_ring->buffer_info[i].time_stamp,
 				jiffies,
 				tx_desc->upper.fields.status);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 			netif_stop_subqueue(netdev, tx_ring->queue_index);
-#else
-			netif_stop_queue(netdev);
-#endif
 		}
 	}
 	tx_ring->total_bytes += total_bytes;
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
