From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6]  net: net/core/dev.c cleanups
Date: Thu, 3 Sep 2009 13:50:28 +0200
Message-ID: <20090903115026.GD2885@psychotron.lab.eng.brq.redhat.com>
References: <4A9F7BFC.5000401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953AbZICLuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 07:50:35 -0400
Content-Disposition: inline
In-Reply-To: <4A9F7BFC.5000401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm, this patch causes following warnings for me:

eth%d dev=ffff88007b9dc000 queue_count=1 tx=ffff88007c565e00
------------[ cut here ]------------
WARNING: at net/core/dev.c:5159 alloc_netdev_mq+0xda/0x1fa()
Hardware name: Product Name To Be Filled By O.E.M.
Modules linked in: e1000e(+) 8139too pcspkr snd_timer snd soundcore mii snd_page_alloc ata_generic pata_acpi
Pid: 1396, comm: work_for_cpu Tainted: G        W  2.6.31-rc5testing #6
Call Trace:
 [<ffffffff812f99a4>] ? alloc_netdev_mq+0xda/0x1fa
 [<ffffffff8104d08c>] warn_slowpath_common+0x77/0xa4
 [<ffffffff8104d0c8>] warn_slowpath_null+0xf/0x11
 [<ffffffff812f99a4>] alloc_netdev_mq+0xda/0x1fa
 [<ffffffff811af36e>] ? pci_find_capability+0x6f/0x71
 [<ffffffff81308262>] ? ether_setup+0x0/0x5c
 [<ffffffff8105e674>] ? do_work_for_cpu+0x0/0x25
 [<ffffffff81308260>] alloc_etherdev_mq+0x19/0x1b
 [<ffffffffa00649eb>] e1000_probe+0x16e/0xb85 [e1000e]
 [<ffffffff81038b31>] ? __wake_up_common+0x46/0x76
 [<ffffffff8105e674>] ? do_work_for_cpu+0x0/0x25
 [<ffffffff811b21cf>] local_pci_probe+0x12/0x16
 [<ffffffff8105e687>] do_work_for_cpu+0x13/0x25
 [<ffffffff8105e674>] ? do_work_for_cpu+0x0/0x25
 [<ffffffff81062068>] kthread+0x88/0x90
 [<ffffffff81011c6a>] child_rip+0xa/0x20
 [<ffffffff81061fe0>] ? kthread+0x0/0x90
 [<ffffffff81011c60>] ? child_rip+0x0/0x20
---[ end trace 4eaa2a86a8e2da27 ]---

Thu, Sep 03, 2009 at 10:19:08AM CEST, eric.dumazet@gmail.com wrote:
>Pure style cleanup patch before surgery :)
>
>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>---
> net/core/dev.c |  589 +++++++++++++++++++++++------------------------
> 1 files changed, 292 insertions(+), 297 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 4b33566..dd94ae6 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -191,7 +191,6 @@ static struct list_head ptype_all __read_mostly;	/* Taps */
>  * semaphore held.
>  */
> DEFINE_RWLOCK(dev_base_lock);
>-
> EXPORT_SYMBOL(dev_base_lock);
> 
> #define NETDEV_HASHBITS	8
>@@ -248,6 +247,7 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
>  */
> 
> DEFINE_PER_CPU(struct softnet_data, softnet_data);
>+EXPORT_PER_CPU_SYMBOL(softnet_data);
> 
> #ifdef CONFIG_LOCKDEP
> /*
>@@ -381,6 +381,7 @@ void dev_add_pack(struct packet_type *pt)
> 	}
> 	spin_unlock_bh(&ptype_lock);
> }
>+EXPORT_SYMBOL(dev_add_pack);
> 
> /**
>  *	__dev_remove_pack	 - remove packet handler
>@@ -418,6 +419,8 @@ void __dev_remove_pack(struct packet_type *pt)
> out:
> 	spin_unlock_bh(&ptype_lock);
> }
>+EXPORT_SYMBOL(__dev_remove_pack);
>+
> /**
>  *	dev_remove_pack	 - remove packet handler
>  *	@pt: packet type declaration
>@@ -436,6 +439,7 @@ void dev_remove_pack(struct packet_type *pt)
> 
> 	synchronize_net();
> }
>+EXPORT_SYMBOL(dev_remove_pack);
> 
> /******************************************************************************
> 
>@@ -499,6 +503,7 @@ int netdev_boot_setup_check(struct net_device *dev)
> 	}
> 	return 0;
> }
>+EXPORT_SYMBOL(netdev_boot_setup_check);
> 
> 
> /**
>@@ -591,6 +596,7 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name)
> 	}
> 	return NULL;
> }
>+EXPORT_SYMBOL(__dev_get_by_name);
> 
> /**
>  *	dev_get_by_name		- find a device by its name
>@@ -615,6 +621,7 @@ struct net_device *dev_get_by_name(struct net *net, const char *name)
> 	read_unlock(&dev_base_lock);
> 	return dev;
> }
>+EXPORT_SYMBOL(dev_get_by_name);
> 
> /**
>  *	__dev_get_by_index - find a device by its ifindex
>@@ -640,6 +647,7 @@ struct net_device *__dev_get_by_index(struct net *net, int ifindex)
> 	}
> 	return NULL;
> }
>+EXPORT_SYMBOL(__dev_get_by_index);
> 
> 
> /**
>@@ -664,6 +672,7 @@ struct net_device *dev_get_by_index(struct net *net, int ifindex)
> 	read_unlock(&dev_base_lock);
> 	return dev;
> }
>+EXPORT_SYMBOL(dev_get_by_index);
> 
> /**
>  *	dev_getbyhwaddr - find a device by its hardware address
>@@ -693,7 +702,6 @@ struct net_device *dev_getbyhwaddr(struct net *net, unsigned short type, char *h
> 
> 	return NULL;
> }
>-
> EXPORT_SYMBOL(dev_getbyhwaddr);
> 
> struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type)
>@@ -707,7 +715,6 @@ struct net_device *__dev_getfirstbyhwtype(struct net *net, unsigned short type)
> 
> 	return NULL;
> }
>-
> EXPORT_SYMBOL(__dev_getfirstbyhwtype);
> 
> struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
>@@ -721,7 +728,6 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
> 	rtnl_unlock();
> 	return dev;
> }
>-
> EXPORT_SYMBOL(dev_getfirstbyhwtype);
> 
> /**
>@@ -736,7 +742,8 @@ EXPORT_SYMBOL(dev_getfirstbyhwtype);
>  *	dev_put to indicate they have finished with it.
>  */
> 
>-struct net_device * dev_get_by_flags(struct net *net, unsigned short if_flags, unsigned short mask)
>+struct net_device *dev_get_by_flags(struct net *net, unsigned short if_flags,
>+				    unsigned short mask)
> {
> 	struct net_device *dev, *ret;
> 
>@@ -752,6 +759,7 @@ struct net_device * dev_get_by_flags(struct net *net, unsigned short if_flags, u
> 	read_unlock(&dev_base_lock);
> 	return ret;
> }
>+EXPORT_SYMBOL(dev_get_by_flags);
> 
> /**
>  *	dev_valid_name - check if name is okay for network device
>@@ -777,6 +785,7 @@ int dev_valid_name(const char *name)
> 	}
> 	return 1;
> }
>+EXPORT_SYMBOL(dev_valid_name);
> 
> /**
>  *	__dev_alloc_name - allocate a name for a device
>@@ -870,6 +879,7 @@ int dev_alloc_name(struct net_device *dev, const char *name)
> 		strlcpy(dev->name, buf, IFNAMSIZ);
> 	return ret;
> }
>+EXPORT_SYMBOL(dev_alloc_name);
> 
> 
> /**
>@@ -906,8 +916,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
> 		err = dev_alloc_name(dev, newname);
> 		if (err < 0)
> 			return err;
>-	}
>-	else if (__dev_get_by_name(net, newname))
>+	} else if (__dev_get_by_name(net, newname))
> 		return -EEXIST;
> 	else
> 		strlcpy(dev->name, newname, IFNAMSIZ);
>@@ -970,7 +979,7 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
> 		return 0;
> 	}
> 
>-	dev->ifalias = krealloc(dev->ifalias, len+1, GFP_KERNEL);
>+	dev->ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
> 	if (!dev->ifalias)
> 		return -ENOMEM;
> 
>@@ -1006,6 +1015,7 @@ void netdev_state_change(struct net_device *dev)
> 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
> 	}
> }
>+EXPORT_SYMBOL(netdev_state_change);
> 
> void netdev_bonding_change(struct net_device *dev)
> {
>@@ -1034,6 +1044,7 @@ void dev_load(struct net *net, const char *name)
> 	if (!dev && capable(CAP_SYS_MODULE))
> 		request_module("%s", name);
> }
>+EXPORT_SYMBOL(dev_load);
> 
> /**
>  *	dev_open	- prepare an interface for use.
>@@ -1118,6 +1129,7 @@ int dev_open(struct net_device *dev)
> 
> 	return ret;
> }
>+EXPORT_SYMBOL(dev_open);
> 
> /**
>  *	dev_close - shutdown an interface.
>@@ -1184,6 +1196,7 @@ int dev_close(struct net_device *dev)
> 
> 	return 0;
> }
>+EXPORT_SYMBOL(dev_close);
> 
> 
> /**
>@@ -1279,6 +1292,7 @@ rollback:
> 	raw_notifier_chain_unregister(&netdev_chain, nb);
> 	goto unlock;
> }
>+EXPORT_SYMBOL(register_netdevice_notifier);
> 
> /**
>  *	unregister_netdevice_notifier - unregister a network notifier block
>@@ -1299,6 +1313,7 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
> 	rtnl_unlock();
> 	return err;
> }
>+EXPORT_SYMBOL(unregister_netdevice_notifier);
> 
> /**
>  *	call_netdevice_notifiers - call all network notifier blocks
>@@ -1321,11 +1336,13 @@ void net_enable_timestamp(void)
> {
> 	atomic_inc(&netstamp_needed);
> }
>+EXPORT_SYMBOL(net_enable_timestamp);
> 
> void net_disable_timestamp(void)
> {
> 	atomic_dec(&netstamp_needed);
> }
>+EXPORT_SYMBOL(net_disable_timestamp);
> 
> static inline void net_timestamp(struct sk_buff *skb)
> {
>@@ -1359,7 +1376,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
> 		if ((ptype->dev == dev || !ptype->dev) &&
> 		    (ptype->af_packet_priv == NULL ||
> 		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
>-			struct sk_buff *skb2= skb_clone(skb, GFP_ATOMIC);
>+			struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
> 			if (!skb2)
> 				break;
> 
>@@ -1527,6 +1544,7 @@ out_set_summed:
> out:
> 	return ret;
> }
>+EXPORT_SYMBOL(skb_checksum_help);
> 
> /**
>  *	skb_gso_segment - Perform segmentation on skb.
>@@ -1589,7 +1607,6 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
> 
> 	return segs;
> }
>-
> EXPORT_SYMBOL(skb_gso_segment);
> 
> /* Take action when hardware reception checksum errors are detected. */
>@@ -1755,7 +1772,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
> 
> 	if (skb_rx_queue_recorded(skb)) {
> 		hash = skb_get_rx_queue(skb);
>-		while (unlikely (hash >= dev->real_num_tx_queues))
>+		while (unlikely(hash >= dev->real_num_tx_queues))
> 			hash -= dev->real_num_tx_queues;
> 		return hash;
> 	}
>@@ -1890,7 +1907,7 @@ gso:
> 	q = rcu_dereference(txq->qdisc);
> 
> #ifdef CONFIG_NET_CLS_ACT
>-	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
>+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
> #endif
> 	if (q->enqueue) {
> 		rc = __dev_xmit_skb(skb, q, dev, txq);
>@@ -1946,6 +1963,7 @@ out:
> 	rcu_read_unlock_bh();
> 	return rc;
> }
>+EXPORT_SYMBOL(dev_queue_xmit);
> 
> 
> /*=======================================================================
>@@ -2012,6 +2030,7 @@ enqueue:
> 	kfree_skb(skb);
> 	return NET_RX_DROP;
> }
>+EXPORT_SYMBOL(netif_rx);
> 
> int netif_rx_ni(struct sk_buff *skb)
> {
>@@ -2025,7 +2044,6 @@ int netif_rx_ni(struct sk_buff *skb)
> 
> 	return err;
> }
>-
> EXPORT_SYMBOL(netif_rx_ni);
> 
> static void net_tx_action(struct softirq_action *h)
>@@ -2358,6 +2376,7 @@ out:
> 	rcu_read_unlock();
> 	return ret;
> }
>+EXPORT_SYMBOL(netif_receive_skb);
> 
> /* Network device is going away, flush any packets still pending  */
> static void flush_backlog(void *arg)
>@@ -2874,7 +2893,7 @@ softnet_break:
> 	goto out;
> }
> 
>-static gifconf_func_t * gifconf_list [NPROTO];
>+static gifconf_func_t *gifconf_list[NPROTO];
> 
> /**
>  *	register_gifconf	-	register a SIOCGIF handler
>@@ -2885,13 +2904,14 @@ static gifconf_func_t * gifconf_list [NPROTO];
>  *	that is passed must not be freed or reused until it has been replaced
>  *	by another handler.
>  */
>-int register_gifconf(unsigned int family, gifconf_func_t * gifconf)
>+int register_gifconf(unsigned int family, gifconf_func_t *gifconf)
> {
> 	if (family >= NPROTO)
> 		return -EINVAL;
> 	gifconf_list[family] = gifconf;
> 	return 0;
> }
>+EXPORT_SYMBOL(register_gifconf);
> 
> 
> /*
>@@ -3102,7 +3122,7 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
> 	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
> 		   s->total, s->dropped, s->time_squeeze, 0,
> 		   0, 0, 0, 0, /* was fastroute */
>-		   s->cpu_collision );
>+		   s->cpu_collision);
> 	return 0;
> }
> 
>@@ -3338,6 +3358,7 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
> 	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
> 	return 0;
> }
>+EXPORT_SYMBOL(netdev_set_master);
> 
> static void dev_change_rx_flags(struct net_device *dev, int flags)
> {
>@@ -3416,6 +3437,7 @@ int dev_set_promiscuity(struct net_device *dev, int inc)
> 		dev_set_rx_mode(dev);
> 	return err;
> }
>+EXPORT_SYMBOL(dev_set_promiscuity);
> 
> /**
>  *	dev_set_allmulti	- update allmulti count on a device
>@@ -3459,6 +3481,7 @@ int dev_set_allmulti(struct net_device *dev, int inc)
> 	}
> 	return 0;
> }
>+EXPORT_SYMBOL(dev_set_allmulti);
> 
> /*
>  *	Upload unicast and multicast address lists to device and
>@@ -4088,6 +4111,7 @@ unsigned dev_get_flags(const struct net_device *dev)
> 
> 	return flags;
> }
>+EXPORT_SYMBOL(dev_get_flags);
> 
> /**
>  *	dev_change_flags - change device settings
>@@ -4138,12 +4162,13 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
> 	}
> 
> 	if (dev->flags & IFF_UP &&
>-	    ((old_flags ^ dev->flags) &~ (IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
>+	    ((old_flags ^ dev->flags) & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
> 					  IFF_VOLATILE)))
> 		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> 
> 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
>-		int inc = (flags & IFF_PROMISC) ? +1 : -1;
>+		int inc = (flags & IFF_PROMISC) ? 1 : -1;
>+
> 		dev->gflags ^= IFF_PROMISC;
> 		dev_set_promiscuity(dev, inc);
> 	}
>@@ -4153,7 +4178,8 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
> 	   IFF_ALLMULTI is requested not asking us and not reporting.
> 	 */
> 	if ((flags ^ dev->gflags) & IFF_ALLMULTI) {
>-		int inc = (flags & IFF_ALLMULTI) ? +1 : -1;
>+		int inc = (flags & IFF_ALLMULTI) ? 1 : -1;
>+
> 		dev->gflags ^= IFF_ALLMULTI;
> 		dev_set_allmulti(dev, inc);
> 	}
>@@ -4165,6 +4191,7 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
> 
> 	return ret;
> }
>+EXPORT_SYMBOL(dev_change_flags);
> 
> /**
>  *	dev_set_mtu - Change maximum transfer unit
>@@ -4198,6 +4225,7 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
> 		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
> 	return err;
> }
>+EXPORT_SYMBOL(dev_set_mtu);
> 
> /**
>  *	dev_set_mac_address - Change Media Access Control Address
>@@ -4222,6 +4250,7 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
> 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> 	return err;
> }
>+EXPORT_SYMBOL(dev_set_mac_address);
> 
> /*
>  *	Perform the SIOCxIFxxx calls, inside read_lock(dev_base_lock)
>@@ -4235,56 +4264,56 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
> 		return -ENODEV;
> 
> 	switch (cmd) {
>-		case SIOCGIFFLAGS:	/* Get interface flags */
>-			ifr->ifr_flags = (short) dev_get_flags(dev);
>-			return 0;
>+	case SIOCGIFFLAGS:	/* Get interface flags */
>+		ifr->ifr_flags = (short) dev_get_flags(dev);
>+		return 0;
> 
>-		case SIOCGIFMETRIC:	/* Get the metric on the interface
>-					   (currently unused) */
>-			ifr->ifr_metric = 0;
>-			return 0;
>+	case SIOCGIFMETRIC:	/* Get the metric on the interface
>+				   (currently unused) */
>+		ifr->ifr_metric = 0;
>+		return 0;
> 
>-		case SIOCGIFMTU:	/* Get the MTU of a device */
>-			ifr->ifr_mtu = dev->mtu;
>-			return 0;
>+	case SIOCGIFMTU:	/* Get the MTU of a device */
>+		ifr->ifr_mtu = dev->mtu;
>+		return 0;
> 
>-		case SIOCGIFHWADDR:
>-			if (!dev->addr_len)
>-				memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
>-			else
>-				memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
>-				       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
>-			ifr->ifr_hwaddr.sa_family = dev->type;
>-			return 0;
>+	case SIOCGIFHWADDR:
>+		if (!dev->addr_len)
>+			memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
>+		else
>+			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
>+			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
>+		ifr->ifr_hwaddr.sa_family = dev->type;
>+		return 0;
> 
>-		case SIOCGIFSLAVE:
>-			err = -EINVAL;
>-			break;
>+	case SIOCGIFSLAVE:
>+		err = -EINVAL;
>+		break;
> 
>-		case SIOCGIFMAP:
>-			ifr->ifr_map.mem_start = dev->mem_start;
>-			ifr->ifr_map.mem_end   = dev->mem_end;
>-			ifr->ifr_map.base_addr = dev->base_addr;
>-			ifr->ifr_map.irq       = dev->irq;
>-			ifr->ifr_map.dma       = dev->dma;
>-			ifr->ifr_map.port      = dev->if_port;
>-			return 0;
>+	case SIOCGIFMAP:
>+		ifr->ifr_map.mem_start = dev->mem_start;
>+		ifr->ifr_map.mem_end   = dev->mem_end;
>+		ifr->ifr_map.base_addr = dev->base_addr;
>+		ifr->ifr_map.irq       = dev->irq;
>+		ifr->ifr_map.dma       = dev->dma;
>+		ifr->ifr_map.port      = dev->if_port;
>+		return 0;
> 
>-		case SIOCGIFINDEX:
>-			ifr->ifr_ifindex = dev->ifindex;
>-			return 0;
>+	case SIOCGIFINDEX:
>+		ifr->ifr_ifindex = dev->ifindex;
>+		return 0;
> 
>-		case SIOCGIFTXQLEN:
>-			ifr->ifr_qlen = dev->tx_queue_len;
>-			return 0;
>+	case SIOCGIFTXQLEN:
>+		ifr->ifr_qlen = dev->tx_queue_len;
>+		return 0;
> 
>-		default:
>-			/* dev_ioctl() should ensure this case
>-			 * is never reached
>-			 */
>-			WARN_ON(1);
>-			err = -EINVAL;
>-			break;
>+	default:
>+		/* dev_ioctl() should ensure this case
>+		 * is never reached
>+		 */
>+		WARN_ON(1);
>+		err = -EINVAL;
>+		break;
> 
> 	}
> 	return err;
>@@ -4305,92 +4334,91 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
> 	ops = dev->netdev_ops;
> 
> 	switch (cmd) {
>-		case SIOCSIFFLAGS:	/* Set interface flags */
>-			return dev_change_flags(dev, ifr->ifr_flags);
>-
>-		case SIOCSIFMETRIC:	/* Set the metric on the interface
>-					   (currently unused) */
>-			return -EOPNOTSUPP;
>-
>-		case SIOCSIFMTU:	/* Set the MTU of a device */
>-			return dev_set_mtu(dev, ifr->ifr_mtu);
>+	case SIOCSIFFLAGS:	/* Set interface flags */
>+		return dev_change_flags(dev, ifr->ifr_flags);
> 
>-		case SIOCSIFHWADDR:
>-			return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
>+	case SIOCSIFMETRIC:	/* Set the metric on the interface
>+				   (currently unused) */
>+		return -EOPNOTSUPP;
> 
>-		case SIOCSIFHWBROADCAST:
>-			if (ifr->ifr_hwaddr.sa_family != dev->type)
>-				return -EINVAL;
>-			memcpy(dev->broadcast, ifr->ifr_hwaddr.sa_data,
>-			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
>-			call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>-			return 0;
>+	case SIOCSIFMTU:	/* Set the MTU of a device */
>+		return dev_set_mtu(dev, ifr->ifr_mtu);
> 
>-		case SIOCSIFMAP:
>-			if (ops->ndo_set_config) {
>-				if (!netif_device_present(dev))
>-					return -ENODEV;
>-				return ops->ndo_set_config(dev, &ifr->ifr_map);
>-			}
>-			return -EOPNOTSUPP;
>+	case SIOCSIFHWADDR:
>+		return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
> 
>-		case SIOCADDMULTI:
>-			if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
>-			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
>-				return -EINVAL;
>-			if (!netif_device_present(dev))
>-				return -ENODEV;
>-			return dev_mc_add(dev, ifr->ifr_hwaddr.sa_data,
>-					  dev->addr_len, 1);
>+	case SIOCSIFHWBROADCAST:
>+		if (ifr->ifr_hwaddr.sa_family != dev->type)
>+			return -EINVAL;
>+		memcpy(dev->broadcast, ifr->ifr_hwaddr.sa_data,
>+		       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
>+		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>+		return 0;
> 
>-		case SIOCDELMULTI:
>-			if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
>-			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
>-				return -EINVAL;
>+	case SIOCSIFMAP:
>+		if (ops->ndo_set_config) {
> 			if (!netif_device_present(dev))
> 				return -ENODEV;
>-			return dev_mc_delete(dev, ifr->ifr_hwaddr.sa_data,
>-					     dev->addr_len, 1);
>+			return ops->ndo_set_config(dev, &ifr->ifr_map);
>+		}
>+		return -EOPNOTSUPP;
> 
>-		case SIOCSIFTXQLEN:
>-			if (ifr->ifr_qlen < 0)
>-				return -EINVAL;
>-			dev->tx_queue_len = ifr->ifr_qlen;
>-			return 0;
>+	case SIOCADDMULTI:
>+		if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
>+		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
>+			return -EINVAL;
>+		if (!netif_device_present(dev))
>+			return -ENODEV;
>+		return dev_mc_add(dev, ifr->ifr_hwaddr.sa_data,
>+				  dev->addr_len, 1);
>+
>+	case SIOCDELMULTI:
>+		if ((!ops->ndo_set_multicast_list && !ops->ndo_set_rx_mode) ||
>+		    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
>+			return -EINVAL;
>+		if (!netif_device_present(dev))
>+			return -ENODEV;
>+		return dev_mc_delete(dev, ifr->ifr_hwaddr.sa_data,
>+				     dev->addr_len, 1);
> 
>-		case SIOCSIFNAME:
>-			ifr->ifr_newname[IFNAMSIZ-1] = '\0';
>-			return dev_change_name(dev, ifr->ifr_newname);
>+	case SIOCSIFTXQLEN:
>+		if (ifr->ifr_qlen < 0)
>+			return -EINVAL;
>+		dev->tx_queue_len = ifr->ifr_qlen;
>+		return 0;
> 
>-		/*
>-		 *	Unknown or private ioctl
>-		 */
>+	case SIOCSIFNAME:
>+		ifr->ifr_newname[IFNAMSIZ-1] = '\0';
>+		return dev_change_name(dev, ifr->ifr_newname);
> 
>-		default:
>-			if ((cmd >= SIOCDEVPRIVATE &&
>-			    cmd <= SIOCDEVPRIVATE + 15) ||
>-			    cmd == SIOCBONDENSLAVE ||
>-			    cmd == SIOCBONDRELEASE ||
>-			    cmd == SIOCBONDSETHWADDR ||
>-			    cmd == SIOCBONDSLAVEINFOQUERY ||
>-			    cmd == SIOCBONDINFOQUERY ||
>-			    cmd == SIOCBONDCHANGEACTIVE ||
>-			    cmd == SIOCGMIIPHY ||
>-			    cmd == SIOCGMIIREG ||
>-			    cmd == SIOCSMIIREG ||
>-			    cmd == SIOCBRADDIF ||
>-			    cmd == SIOCBRDELIF ||
>-			    cmd == SIOCSHWTSTAMP ||
>-			    cmd == SIOCWANDEV) {
>-				err = -EOPNOTSUPP;
>-				if (ops->ndo_do_ioctl) {
>-					if (netif_device_present(dev))
>-						err = ops->ndo_do_ioctl(dev, ifr, cmd);
>-					else
>-						err = -ENODEV;
>-				}
>-			} else
>-				err = -EINVAL;
>+	/*
>+	 *	Unknown or private ioctl
>+	 */
>+	default:
>+		if ((cmd >= SIOCDEVPRIVATE &&
>+		    cmd <= SIOCDEVPRIVATE + 15) ||
>+		    cmd == SIOCBONDENSLAVE ||
>+		    cmd == SIOCBONDRELEASE ||
>+		    cmd == SIOCBONDSETHWADDR ||
>+		    cmd == SIOCBONDSLAVEINFOQUERY ||
>+		    cmd == SIOCBONDINFOQUERY ||
>+		    cmd == SIOCBONDCHANGEACTIVE ||
>+		    cmd == SIOCGMIIPHY ||
>+		    cmd == SIOCGMIIREG ||
>+		    cmd == SIOCSMIIREG ||
>+		    cmd == SIOCBRADDIF ||
>+		    cmd == SIOCBRDELIF ||
>+		    cmd == SIOCSHWTSTAMP ||
>+		    cmd == SIOCWANDEV) {
>+			err = -EOPNOTSUPP;
>+			if (ops->ndo_do_ioctl) {
>+				if (netif_device_present(dev))
>+					err = ops->ndo_do_ioctl(dev, ifr, cmd);
>+				else
>+					err = -ENODEV;
>+			}
>+		} else
>+			err = -EINVAL;
> 
> 	}
> 	return err;
>@@ -4447,135 +4475,135 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
> 	 */
> 
> 	switch (cmd) {
>-		/*
>-		 *	These ioctl calls:
>-		 *	- can be done by all.
>-		 *	- atomic and do not require locking.
>-		 *	- return a value
>-		 */
>-		case SIOCGIFFLAGS:
>-		case SIOCGIFMETRIC:
>-		case SIOCGIFMTU:
>-		case SIOCGIFHWADDR:
>-		case SIOCGIFSLAVE:
>-		case SIOCGIFMAP:
>-		case SIOCGIFINDEX:
>-		case SIOCGIFTXQLEN:
>-			dev_load(net, ifr.ifr_name);
>-			read_lock(&dev_base_lock);
>-			ret = dev_ifsioc_locked(net, &ifr, cmd);
>-			read_unlock(&dev_base_lock);
>-			if (!ret) {
>-				if (colon)
>-					*colon = ':';
>-				if (copy_to_user(arg, &ifr,
>-						 sizeof(struct ifreq)))
>-					ret = -EFAULT;
>-			}
>-			return ret;
>+	/*
>+	 *	These ioctl calls:
>+	 *	- can be done by all.
>+	 *	- atomic and do not require locking.
>+	 *	- return a value
>+	 */
>+	case SIOCGIFFLAGS:
>+	case SIOCGIFMETRIC:
>+	case SIOCGIFMTU:
>+	case SIOCGIFHWADDR:
>+	case SIOCGIFSLAVE:
>+	case SIOCGIFMAP:
>+	case SIOCGIFINDEX:
>+	case SIOCGIFTXQLEN:
>+		dev_load(net, ifr.ifr_name);
>+		read_lock(&dev_base_lock);
>+		ret = dev_ifsioc_locked(net, &ifr, cmd);
>+		read_unlock(&dev_base_lock);
>+		if (!ret) {
>+			if (colon)
>+				*colon = ':';
>+			if (copy_to_user(arg, &ifr,
>+					 sizeof(struct ifreq)))
>+				ret = -EFAULT;
>+		}
>+		return ret;
> 
>-		case SIOCETHTOOL:
>-			dev_load(net, ifr.ifr_name);
>-			rtnl_lock();
>-			ret = dev_ethtool(net, &ifr);
>-			rtnl_unlock();
>-			if (!ret) {
>-				if (colon)
>-					*colon = ':';
>-				if (copy_to_user(arg, &ifr,
>-						 sizeof(struct ifreq)))
>-					ret = -EFAULT;
>-			}
>-			return ret;
>+	case SIOCETHTOOL:
>+		dev_load(net, ifr.ifr_name);
>+		rtnl_lock();
>+		ret = dev_ethtool(net, &ifr);
>+		rtnl_unlock();
>+		if (!ret) {
>+			if (colon)
>+				*colon = ':';
>+			if (copy_to_user(arg, &ifr,
>+					 sizeof(struct ifreq)))
>+				ret = -EFAULT;
>+		}
>+		return ret;
> 
>-		/*
>-		 *	These ioctl calls:
>-		 *	- require superuser power.
>-		 *	- require strict serialization.
>-		 *	- return a value
>-		 */
>-		case SIOCGMIIPHY:
>-		case SIOCGMIIREG:
>-		case SIOCSIFNAME:
>-			if (!capable(CAP_NET_ADMIN))
>-				return -EPERM;
>-			dev_load(net, ifr.ifr_name);
>-			rtnl_lock();
>-			ret = dev_ifsioc(net, &ifr, cmd);
>-			rtnl_unlock();
>-			if (!ret) {
>-				if (colon)
>-					*colon = ':';
>-				if (copy_to_user(arg, &ifr,
>-						 sizeof(struct ifreq)))
>-					ret = -EFAULT;
>-			}
>-			return ret;
>+	/*
>+	 *	These ioctl calls:
>+	 *	- require superuser power.
>+	 *	- require strict serialization.
>+	 *	- return a value
>+	 */
>+	case SIOCGMIIPHY:
>+	case SIOCGMIIREG:
>+	case SIOCSIFNAME:
>+		if (!capable(CAP_NET_ADMIN))
>+			return -EPERM;
>+		dev_load(net, ifr.ifr_name);
>+		rtnl_lock();
>+		ret = dev_ifsioc(net, &ifr, cmd);
>+		rtnl_unlock();
>+		if (!ret) {
>+			if (colon)
>+				*colon = ':';
>+			if (copy_to_user(arg, &ifr,
>+					 sizeof(struct ifreq)))
>+				ret = -EFAULT;
>+		}
>+		return ret;
> 
>-		/*
>-		 *	These ioctl calls:
>-		 *	- require superuser power.
>-		 *	- require strict serialization.
>-		 *	- do not return a value
>-		 */
>-		case SIOCSIFFLAGS:
>-		case SIOCSIFMETRIC:
>-		case SIOCSIFMTU:
>-		case SIOCSIFMAP:
>-		case SIOCSIFHWADDR:
>-		case SIOCSIFSLAVE:
>-		case SIOCADDMULTI:
>-		case SIOCDELMULTI:
>-		case SIOCSIFHWBROADCAST:
>-		case SIOCSIFTXQLEN:
>-		case SIOCSMIIREG:
>-		case SIOCBONDENSLAVE:
>-		case SIOCBONDRELEASE:
>-		case SIOCBONDSETHWADDR:
>-		case SIOCBONDCHANGEACTIVE:
>-		case SIOCBRADDIF:
>-		case SIOCBRDELIF:
>-		case SIOCSHWTSTAMP:
>-			if (!capable(CAP_NET_ADMIN))
>-				return -EPERM;
>-			/* fall through */
>-		case SIOCBONDSLAVEINFOQUERY:
>-		case SIOCBONDINFOQUERY:
>+	/*
>+	 *	These ioctl calls:
>+	 *	- require superuser power.
>+	 *	- require strict serialization.
>+	 *	- do not return a value
>+	 */
>+	case SIOCSIFFLAGS:
>+	case SIOCSIFMETRIC:
>+	case SIOCSIFMTU:
>+	case SIOCSIFMAP:
>+	case SIOCSIFHWADDR:
>+	case SIOCSIFSLAVE:
>+	case SIOCADDMULTI:
>+	case SIOCDELMULTI:
>+	case SIOCSIFHWBROADCAST:
>+	case SIOCSIFTXQLEN:
>+	case SIOCSMIIREG:
>+	case SIOCBONDENSLAVE:
>+	case SIOCBONDRELEASE:
>+	case SIOCBONDSETHWADDR:
>+	case SIOCBONDCHANGEACTIVE:
>+	case SIOCBRADDIF:
>+	case SIOCBRDELIF:
>+	case SIOCSHWTSTAMP:
>+		if (!capable(CAP_NET_ADMIN))
>+			return -EPERM;
>+		/* fall through */
>+	case SIOCBONDSLAVEINFOQUERY:
>+	case SIOCBONDINFOQUERY:
>+		dev_load(net, ifr.ifr_name);
>+		rtnl_lock();
>+		ret = dev_ifsioc(net, &ifr, cmd);
>+		rtnl_unlock();
>+		return ret;
>+
>+	case SIOCGIFMEM:
>+		/* Get the per device memory space. We can add this but
>+		 * currently do not support it */
>+	case SIOCSIFMEM:
>+		/* Set the per device memory buffer space.
>+		 * Not applicable in our case */
>+	case SIOCSIFLINK:
>+		return -EINVAL;
>+
>+	/*
>+	 *	Unknown or private ioctl.
>+	 */
>+	default:
>+		if (cmd == SIOCWANDEV ||
>+		    (cmd >= SIOCDEVPRIVATE &&
>+		     cmd <= SIOCDEVPRIVATE + 15)) {
> 			dev_load(net, ifr.ifr_name);
> 			rtnl_lock();
> 			ret = dev_ifsioc(net, &ifr, cmd);
> 			rtnl_unlock();
>+			if (!ret && copy_to_user(arg, &ifr,
>+						 sizeof(struct ifreq)))
>+				ret = -EFAULT;
> 			return ret;
>-
>-		case SIOCGIFMEM:
>-			/* Get the per device memory space. We can add this but
>-			 * currently do not support it */
>-		case SIOCSIFMEM:
>-			/* Set the per device memory buffer space.
>-			 * Not applicable in our case */
>-		case SIOCSIFLINK:
>-			return -EINVAL;
>-
>-		/*
>-		 *	Unknown or private ioctl.
>-		 */
>-		default:
>-			if (cmd == SIOCWANDEV ||
>-			    (cmd >= SIOCDEVPRIVATE &&
>-			     cmd <= SIOCDEVPRIVATE + 15)) {
>-				dev_load(net, ifr.ifr_name);
>-				rtnl_lock();
>-				ret = dev_ifsioc(net, &ifr, cmd);
>-				rtnl_unlock();
>-				if (!ret && copy_to_user(arg, &ifr,
>-							 sizeof(struct ifreq)))
>-					ret = -EFAULT;
>-				return ret;
>-			}
>-			/* Take care of Wireless Extensions */
>-			if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
>-				return wext_handle_ioctl(net, &ifr, cmd, arg);
>-			return -EINVAL;
>+		}
>+		/* Take care of Wireless Extensions */
>+		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
>+			return wext_handle_ioctl(net, &ifr, cmd, arg);
>+		return -EINVAL;
> 	}
> }
> 
>@@ -4840,6 +4868,7 @@ err_uninit:
> 		dev->netdev_ops->ndo_uninit(dev);
> 	goto out;
> }
>+EXPORT_SYMBOL(register_netdevice);
> 
> /**
>  *	init_dummy_netdev	- init a dummy network device for NAPI
>@@ -5126,6 +5155,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
> 	}
> 
> 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
>+	pr_err("%s dev=%p queue_count=%d tx=%p\n", name, dev, queue_count, tx);
>+	WARN_ON(queue_count == 1);
> 	dev->padded = (char *)dev - (char *)p;
> 
> 	if (dev_addr_init(dev))
>@@ -5192,6 +5223,7 @@ void free_netdev(struct net_device *dev)
> 	/* will free via device release */
> 	put_device(&dev->dev);
> }
>+EXPORT_SYMBOL(free_netdev);
> 
> /**
>  *	synchronize_net -  Synchronize with packet receive processing
>@@ -5204,6 +5236,7 @@ void synchronize_net(void)
> 	might_sleep();
> 	synchronize_rcu();
> }
>+EXPORT_SYMBOL(synchronize_net);
> 
> /**
>  *	unregister_netdevice - remove device from the kernel
>@@ -5224,6 +5257,7 @@ void unregister_netdevice(struct net_device *dev)
> 	/* Finish processing unregister after unlock */
> 	net_set_todo(dev);
> }
>+EXPORT_SYMBOL(unregister_netdevice);
> 
> /**
>  *	unregister_netdev - remove device from the kernel
>@@ -5242,7 +5276,6 @@ void unregister_netdev(struct net_device *dev)
> 	unregister_netdevice(dev);
> 	rtnl_unlock();
> }
>-
> EXPORT_SYMBOL(unregister_netdev);
> 
> /**
>@@ -5432,7 +5465,7 @@ unsigned long netdev_increment_features(unsigned long all, unsigned long one,
> 					unsigned long mask)
> {
> 	/* If device needs checksumming, downgrade to it. */
>-        if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
>+	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
> 		all ^= NETIF_F_NO_CSUM | (one & NETIF_F_ALL_CSUM);
> 	else if (mask & NETIF_F_ALL_CSUM) {
> 		/* If one device supports v4/v6 checksumming, set for all. */
>@@ -5658,41 +5691,3 @@ static int __init initialize_hashrnd(void)
> 
> late_initcall_sync(initialize_hashrnd);
> 
>-EXPORT_SYMBOL(__dev_get_by_index);
>-EXPORT_SYMBOL(__dev_get_by_name);
>-EXPORT_SYMBOL(__dev_remove_pack);
>-EXPORT_SYMBOL(dev_valid_name);
>-EXPORT_SYMBOL(dev_add_pack);
>-EXPORT_SYMBOL(dev_alloc_name);
>-EXPORT_SYMBOL(dev_close);
>-EXPORT_SYMBOL(dev_get_by_flags);
>-EXPORT_SYMBOL(dev_get_by_index);
>-EXPORT_SYMBOL(dev_get_by_name);
>-EXPORT_SYMBOL(dev_open);
>-EXPORT_SYMBOL(dev_queue_xmit);
>-EXPORT_SYMBOL(dev_remove_pack);
>-EXPORT_SYMBOL(dev_set_allmulti);
>-EXPORT_SYMBOL(dev_set_promiscuity);
>-EXPORT_SYMBOL(dev_change_flags);
>-EXPORT_SYMBOL(dev_set_mtu);
>-EXPORT_SYMBOL(dev_set_mac_address);
>-EXPORT_SYMBOL(free_netdev);
>-EXPORT_SYMBOL(netdev_boot_setup_check);
>-EXPORT_SYMBOL(netdev_set_master);
>-EXPORT_SYMBOL(netdev_state_change);
>-EXPORT_SYMBOL(netif_receive_skb);
>-EXPORT_SYMBOL(netif_rx);
>-EXPORT_SYMBOL(register_gifconf);
>-EXPORT_SYMBOL(register_netdevice);
>-EXPORT_SYMBOL(register_netdevice_notifier);
>-EXPORT_SYMBOL(skb_checksum_help);
>-EXPORT_SYMBOL(synchronize_net);
>-EXPORT_SYMBOL(unregister_netdevice);
>-EXPORT_SYMBOL(unregister_netdevice_notifier);
>-EXPORT_SYMBOL(net_enable_timestamp);
>-EXPORT_SYMBOL(net_disable_timestamp);
>-EXPORT_SYMBOL(dev_get_flags);
>-
>-EXPORT_SYMBOL(dev_load);
>-
>-EXPORT_PER_CPU_SYMBOL(softnet_data);
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
