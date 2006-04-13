From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/4] clip: run through Lindent
Date: Thu, 13 Apr 2006 15:22:24 -0700
Message-ID: <20060413152224.2d46df99@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19344 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932471AbWDMW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:26:08 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060412105545.3b089dd8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Run CLIP driver through Lindent script to fix formatting.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- clip.orig/net/atm/clip.c	2006-04-13 09:44:22.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-13 15:18:21.000000000 -0700
@@ -2,7 +2,6 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
-
 #include <linux/config.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -55,21 +54,23 @@
 static struct neigh_table clip_tbl;
 static struct timer_list idle_timer;
 
-static int to_atmarpd(enum atmarp_ctrl_type type,int itf,unsigned long ip)
+static int to_atmarpd(enum atmarp_ctrl_type type, int itf, unsigned long ip)
 {
 	struct sock *sk;
 	struct atmarp_ctrl *ctrl;
 	struct sk_buff *skb;
 
-	DPRINTK("to_atmarpd(%d)\n",type);
-	if (!atmarpd) return -EUNATCH;
+	DPRINTK("to_atmarpd(%d)\n", type);
+	if (!atmarpd)
+		return -EUNATCH;
 	skb = alloc_skb(sizeof(struct atmarp_ctrl),GFP_ATOMIC);
-	if (!skb) return -ENOMEM;
+	if (!skb)
+		return -ENOMEM;
 	ctrl = (struct atmarp_ctrl *) skb_put(skb,sizeof(struct atmarp_ctrl));
 	ctrl->type = type;
 	ctrl->itf_num = itf;
 	ctrl->ip = ip;
-	atm_force_charge(atmarpd,skb->truesize);
+	atm_force_charge(atmarpd, skb->truesize);
 
 	sk = sk_atm(atmarpd);
 	skb_queue_tail(&sk->sk_receive_queue, skb);
@@ -77,26 +78,24 @@
 	return 0;
 }
 
-
-static void link_vcc(struct clip_vcc *clip_vcc,struct atmarp_entry *entry)
+static void link_vcc(struct clip_vcc *clip_vcc, struct atmarp_entry *entry)
 {
-	DPRINTK("link_vcc %p to entry %p (neigh %p)\n",clip_vcc,entry,
-	    entry->neigh);
+	DPRINTK("link_vcc %p to entry %p (neigh %p)\n", clip_vcc, entry,
+		entry->neigh);
 	clip_vcc->entry = entry;
-	clip_vcc->xoff = 0; /* @@@ may overrun buffer by one packet */
+	clip_vcc->xoff = 0;	/* @@@ may overrun buffer by one packet */
 	clip_vcc->next = entry->vccs;
 	entry->vccs = clip_vcc;
 	entry->neigh->used = jiffies;
 }
 
-
 static void unlink_clip_vcc(struct clip_vcc *clip_vcc)
 {
 	struct atmarp_entry *entry = clip_vcc->entry;
 	struct clip_vcc **walk;
 
 	if (!entry) {
-		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n",clip_vcc);
+		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n", clip_vcc);
 		return;
 	}
 	spin_lock_bh(&entry->neigh->dev->xmit_lock);	/* block clip_start_xmit() */
@@ -105,24 +104,24 @@
 		if (*walk == clip_vcc) {
 			int error;
 
-			*walk = clip_vcc->next; /* atomic */
+			*walk = clip_vcc->next;	/* atomic */
 			clip_vcc->entry = NULL;
 			if (clip_vcc->xoff)
 				netif_wake_queue(entry->neigh->dev);
 			if (entry->vccs)
 				goto out;
-			entry->expires = jiffies-1;
-				/* force resolution or expiration */
+			entry->expires = jiffies - 1;
+			/* force resolution or expiration */
 			error = neigh_update(entry->neigh, NULL, NUD_NONE,
 					     NEIGH_UPDATE_F_ADMIN);
 			if (error)
 				printk(KERN_CRIT "unlink_clip_vcc: "
-				    "neigh_update failed with %d\n",error);
+				       "neigh_update failed with %d\n", error);
 			goto out;
 		}
 	printk(KERN_CRIT "ATMARP: unlink_clip_vcc failed (entry %p, vcc "
-	  "0x%p)\n",entry,clip_vcc);
-out:
+	       "0x%p)\n", entry, clip_vcc);
+      out:
 	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
 }
 
@@ -151,13 +150,13 @@
 		DPRINTK("destruction postponed with ref %d\n",
 			atomic_read(&n->refcnt));
 
-		while ((skb = skb_dequeue(&n->arp_queue)) != NULL) 
+		while ((skb = skb_dequeue(&n->arp_queue)) != NULL)
 			dev_kfree_skb(skb);
 
 		return 0;
 	}
 
-	DPRINTK("expired neigh %p\n",n);
+	DPRINTK("expired neigh %p\n", n);
 	return 1;
 }
 
@@ -165,7 +164,7 @@
 {
 	write_lock(&clip_tbl.lock);
 	__neigh_for_each_release(&clip_tbl, neigh_check_cb);
-	mod_timer(&idle_timer, jiffies+CLIP_CHECK_INTERVAL*HZ);
+	mod_timer(&idle_timer, jiffies + CLIP_CHECK_INTERVAL * HZ);
 	write_unlock(&clip_tbl.lock);
 }
 
@@ -175,13 +174,13 @@
 
 	DPRINTK("clip_arp_rcv\n");
 	vcc = ATM_SKB(skb)->vcc;
-	if (!vcc || !atm_charge(vcc,skb->truesize)) {
+	if (!vcc || !atm_charge(vcc, skb->truesize)) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
-	DPRINTK("pushing to %p\n",vcc);
-	DPRINTK("using %p\n",CLIP_VCC(vcc)->old_push);
-	CLIP_VCC(vcc)->old_push(vcc,skb);
+	DPRINTK("pushing to %p\n", vcc);
+	DPRINTK("using %p\n", CLIP_VCC(vcc)->old_push);
+	CLIP_VCC(vcc)->old_push(vcc, skb);
 	return 0;
 }
 
@@ -191,34 +190,38 @@
 	0x03,	/* Ctrl: Unnumbered Information Command PDU */
 	0x00,	/* OUI: EtherType */
 	0x00,
-	0x00 };
+	0x00
+};
 
-static void clip_push(struct atm_vcc *vcc,struct sk_buff *skb)
+static void clip_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 
 	DPRINTK("clip push\n");
 	if (!skb) {
-		DPRINTK("removing VCC %p\n",clip_vcc);
-		if (clip_vcc->entry) unlink_clip_vcc(clip_vcc);
-		clip_vcc->old_push(vcc,NULL); /* pass on the bad news */
+		DPRINTK("removing VCC %p\n", clip_vcc);
+		if (clip_vcc->entry)
+			unlink_clip_vcc(clip_vcc);
+		clip_vcc->old_push(vcc, NULL);	/* pass on the bad news */
 		kfree(clip_vcc);
 		return;
 	}
-	atm_return(vcc,skb->truesize);
+	atm_return(vcc, skb->truesize);
 	skb->dev = clip_vcc->entry ? clip_vcc->entry->neigh->dev : clip_devs;
-		/* clip_vcc->entry == NULL if we don't have an IP address yet */
+	/* clip_vcc->entry == NULL if we don't have an IP address yet */
 	if (!skb->dev) {
 		dev_kfree_skb_any(skb);
 		return;
 	}
 	ATM_SKB(skb)->vcc = vcc;
 	skb->mac.raw = skb->data;
-	if (!clip_vcc->encap || skb->len < RFC1483LLC_LEN || memcmp(skb->data,
-	    llc_oui,sizeof(llc_oui))) skb->protocol = htons(ETH_P_IP);
+	if (!clip_vcc->encap
+	    || skb->len < RFC1483LLC_LEN
+	    || memcmp(skb->data, llc_oui, sizeof (llc_oui)))
+		skb->protocol = htons(ETH_P_IP);
 	else {
 		skb->protocol = ((u16 *) skb->data)[3];
-		skb_pull(skb,RFC1483LLC_LEN);
+		skb_pull(skb, RFC1483LLC_LEN);
 		if (skb->protocol == htons(ETH_P_ARP)) {
 			PRIV(skb->dev)->stats.rx_packets++;
 			PRIV(skb->dev)->stats.rx_bytes += skb->len;
@@ -233,58 +236,54 @@
 	netif_rx(skb);
 }
 
-
 /*
  * Note: these spinlocks _must_not_ block on non-SMP. The only goal is that
  * clip_pop is atomic with respect to the critical section in clip_start_xmit.
  */
 
-
-static void clip_pop(struct atm_vcc *vcc,struct sk_buff *skb)
+static void clip_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 	struct net_device *dev = skb->dev;
 	int old;
 	unsigned long flags;
 
-	DPRINTK("clip_pop(vcc %p)\n",vcc);
-	clip_vcc->old_pop(vcc,skb);
+	DPRINTK("clip_pop(vcc %p)\n", vcc);
+	clip_vcc->old_pop(vcc, skb);
 	/* skb->dev == NULL in outbound ARP packets */
-	if (!dev) return;
-	spin_lock_irqsave(&PRIV(dev)->xoff_lock,flags);
-	if (atm_may_send(vcc,0)) {
-		old = xchg(&clip_vcc->xoff,0);
-		if (old) netif_wake_queue(dev);
+	if (!dev)
+		return;
+	spin_lock_irqsave(&PRIV(dev)->xoff_lock, flags);
+	if (atm_may_send(vcc, 0)) {
+		old = xchg(&clip_vcc->xoff, 0);
+		if (old)
+			netif_wake_queue(dev);
 	}
-	spin_unlock_irqrestore(&PRIV(dev)->xoff_lock,flags);
+	spin_unlock_irqrestore(&PRIV(dev)->xoff_lock, flags);
 }
 
-
 static void clip_neigh_destroy(struct neighbour *neigh)
 {
-	DPRINTK("clip_neigh_destroy (neigh %p)\n",neigh);
+	DPRINTK("clip_neigh_destroy (neigh %p)\n", neigh);
 	if (NEIGH2ENTRY(neigh)->vccs)
 		printk(KERN_CRIT "clip_neigh_destroy: vccs != NULL !!!\n");
 	NEIGH2ENTRY(neigh)->vccs = (void *) 0xdeadbeef;
 }
 
-
-static void clip_neigh_solicit(struct neighbour *neigh,struct sk_buff *skb)
+static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
-	DPRINTK("clip_neigh_solicit (neigh %p, skb %p)\n",neigh,skb);
-	to_atmarpd(act_need,PRIV(neigh->dev)->number,NEIGH2ENTRY(neigh)->ip);
+	DPRINTK("clip_neigh_solicit (neigh %p, skb %p)\n", neigh, skb);
+	to_atmarpd(act_need, PRIV(neigh->dev)->number, NEIGH2ENTRY(neigh)->ip);
 }
 
-
-static void clip_neigh_error(struct neighbour *neigh,struct sk_buff *skb)
+static void clip_neigh_error(struct neighbour *neigh, struct sk_buff *skb)
 {
 #ifndef CONFIG_ATM_CLIP_NO_ICMP
-	icmp_send(skb,ICMP_DEST_UNREACH,ICMP_HOST_UNREACH,0);
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 #endif
 	kfree_skb(skb);
 }
 
-
 static struct neigh_ops clip_neigh_ops = {
 	.family =		AF_INET,
 	.solicit =		clip_neigh_solicit,
@@ -295,7 +294,6 @@
 	.queue_xmit =		dev_queue_xmit,
 };
 
-
 static int clip_constructor(struct neighbour *neigh)
 {
 	struct atmarp_entry *entry = NEIGH2ENTRY(neigh);
@@ -303,9 +301,10 @@
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
 
-	DPRINTK("clip_constructor (neigh %p, entry %p)\n",neigh,entry);
+	DPRINTK("clip_constructor (neigh %p, entry %p)\n", neigh, entry);
 	neigh->type = inet_addr_type(entry->ip);
-	if (neigh->type != RTN_UNICAST) return -EINVAL;
+	if (neigh->type != RTN_UNICAST)
+		return -EINVAL;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -324,13 +323,13 @@
 	    neigh->ops->connected_output : neigh->ops->output;
 	entry->neigh = neigh;
 	entry->vccs = NULL;
-	entry->expires = jiffies-1;
+	entry->expires = jiffies - 1;
 	return 0;
 }
 
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
-	return jhash_2words(*(u32 *)pkey, dev->ifindex, clip_tbl.hash_rnd);
+	return jhash_2words(*(u32 *) pkey, dev->ifindex, clip_tbl.hash_rnd);
 }
 
 static struct neigh_table clip_tbl = {
@@ -364,7 +363,6 @@
 	.gc_thresh3 	= 1024,
 };
 
-
 /* @@@ copy bh locking from arp.c -- need to bh-enable atm code before */
 
 /*
@@ -374,15 +372,13 @@
  * clip_setentry.
  */
 
-
-static int clip_encap(struct atm_vcc *vcc,int mode)
+static int clip_encap(struct atm_vcc *vcc, int mode)
 {
 	CLIP_VCC(vcc)->encap = mode;
 	return 0;
 }
 
-
-static int clip_start_xmit(struct sk_buff *skb,struct net_device *dev)
+static int clip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct clip_priv *clip_priv = PRIV(dev);
 	struct atmarp_entry *entry;
@@ -390,7 +386,7 @@
 	int old;
 	unsigned long flags;
 
-	DPRINTK("clip_start_xmit (skb %p)\n",skb);
+	DPRINTK("clip_start_xmit (skb %p)\n", skb);
 	if (!skb->dst) {
 		printk(KERN_ERR "clip_start_xmit: skb->dst == NULL\n");
 		dev_kfree_skb(skb);
@@ -399,9 +395,9 @@
 	}
 	if (!skb->dst->neighbour) {
 #if 0
-		skb->dst->neighbour = clip_find_neighbour(skb->dst,1);
+		skb->dst->neighbour = clip_find_neighbour(skb->dst, 1);
 		if (!skb->dst->neighbour) {
-			dev_kfree_skb(skb); /* lost that one */
+			dev_kfree_skb(skb);	/* lost that one */
 			clip_priv->stats.tx_dropped++;
 			return 0;
 		}
@@ -415,73 +411,73 @@
 	if (!entry->vccs) {
 		if (time_after(jiffies, entry->expires)) {
 			/* should be resolved */
-			entry->expires = jiffies+ATMARP_RETRY_DELAY*HZ;
-			to_atmarpd(act_need,PRIV(dev)->number,entry->ip);
+			entry->expires = jiffies + ATMARP_RETRY_DELAY * HZ;
+			to_atmarpd(act_need, PRIV(dev)->number, entry->ip);
 		}
 		if (entry->neigh->arp_queue.qlen < ATMARP_MAX_UNRES_PACKETS)
-			skb_queue_tail(&entry->neigh->arp_queue,skb);
+			skb_queue_tail(&entry->neigh->arp_queue, skb);
 		else {
 			dev_kfree_skb(skb);
 			clip_priv->stats.tx_dropped++;
 		}
 		return 0;
 	}
-	DPRINTK("neigh %p, vccs %p\n",entry,entry->vccs);
+	DPRINTK("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
-	DPRINTK("using neighbour %p, vcc %p\n",skb->dst->neighbour,vcc);
+	DPRINTK("using neighbour %p, vcc %p\n", skb->dst->neighbour, vcc);
 	if (entry->vccs->encap) {
 		void *here;
 
-		here = skb_push(skb,RFC1483LLC_LEN);
-		memcpy(here,llc_oui,sizeof(llc_oui));
+		here = skb_push(skb, RFC1483LLC_LEN);
+		memcpy(here, llc_oui, sizeof(llc_oui));
 		((u16 *) here)[3] = skb->protocol;
 	}
 	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	entry->vccs->last_use = jiffies;
-	DPRINTK("atm_skb(%p)->vcc(%p)->dev(%p)\n",skb,vcc,vcc->dev);
-	old = xchg(&entry->vccs->xoff,1); /* assume XOFF ... */
+	DPRINTK("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
+	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
 		printk(KERN_WARNING "clip_start_xmit: XOFF->XOFF transition\n");
 		return 0;
 	}
 	clip_priv->stats.tx_packets++;
 	clip_priv->stats.tx_bytes += skb->len;
-	(void) vcc->send(vcc,skb);
-	if (atm_may_send(vcc,0)) {
+	(void)vcc->send(vcc, skb);
+	if (atm_may_send(vcc, 0)) {
 		entry->vccs->xoff = 0;
 		return 0;
 	}
-	spin_lock_irqsave(&clip_priv->xoff_lock,flags);
-	netif_stop_queue(dev); /* XOFF -> throttle immediately */
+	spin_lock_irqsave(&clip_priv->xoff_lock, flags);
+	netif_stop_queue(dev);	/* XOFF -> throttle immediately */
 	barrier();
 	if (!entry->vccs->xoff)
 		netif_start_queue(dev);
-		/* Oh, we just raced with clip_pop. netif_start_queue should be
-		   good enough, because nothing should really be asleep because
-		   of the brief netif_stop_queue. If this isn't true or if it
-		   changes, use netif_wake_queue instead. */
-	spin_unlock_irqrestore(&clip_priv->xoff_lock,flags);
+	/* Oh, we just raced with clip_pop. netif_start_queue should be
+	   good enough, because nothing should really be asleep because
+	   of the brief netif_stop_queue. If this isn't true or if it
+	   changes, use netif_wake_queue instead. */
+	spin_unlock_irqrestore(&clip_priv->xoff_lock, flags);
 	return 0;
 }
 
-
 static struct net_device_stats *clip_get_stats(struct net_device *dev)
 {
 	return &PRIV(dev)->stats;
 }
 
-
-static int clip_mkip(struct atm_vcc *vcc,int timeout)
+static int clip_mkip(struct atm_vcc *vcc, int timeout)
 {
 	struct clip_vcc *clip_vcc;
 	struct sk_buff_head copy;
 	struct sk_buff *skb;
 
-	if (!vcc->push) return -EBADFD;
-	clip_vcc = kmalloc(sizeof(struct clip_vcc),GFP_KERNEL);
-	if (!clip_vcc) return -ENOMEM;
-	DPRINTK("mkip clip_vcc %p vcc %p\n",clip_vcc,vcc);
+	if (!vcc->push)
+		return -EBADFD;
+	clip_vcc = kmalloc(sizeof(struct clip_vcc), GFP_KERNEL);
+	if (!clip_vcc)
+		return -ENOMEM;
+	DPRINTK("mkip clip_vcc %p vcc %p\n", clip_vcc, vcc);
 	clip_vcc->vcc = vcc;
 	vcc->user_back = clip_vcc;
 	set_bit(ATM_VF_IS_CLIP, &vcc->flags);
@@ -489,7 +485,7 @@
 	clip_vcc->xoff = 0;
 	clip_vcc->encap = 1;
 	clip_vcc->last_use = jiffies;
-	clip_vcc->idle_timeout = timeout*HZ;
+	clip_vcc->idle_timeout = timeout * HZ;
 	clip_vcc->old_push = vcc->push;
 	clip_vcc->old_pop = vcc->pop;
 	vcc->push = clip_push;
@@ -499,27 +495,25 @@
 	/* re-process everything received between connection setup and MKIP */
 	while ((skb = skb_dequeue(&copy)) != NULL)
 		if (!clip_devs) {
-			atm_return(vcc,skb->truesize);
+			atm_return(vcc, skb->truesize);
 			kfree_skb(skb);
-		}
-		else {
+		} else {
 			unsigned int len = skb->len;
 
-			clip_push(vcc,skb);
+			clip_push(vcc, skb);
 			PRIV(skb->dev)->stats.rx_packets--;
 			PRIV(skb->dev)->stats.rx_bytes -= len;
 		}
 	return 0;
 }
 
-
-static int clip_setentry(struct atm_vcc *vcc,u32 ip)
+static int clip_setentry(struct atm_vcc *vcc, u32 ip)
 {
 	struct neighbour *neigh;
 	struct atmarp_entry *entry;
 	int error;
 	struct clip_vcc *clip_vcc;
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip, .tos = 1 } } };
+	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip, .tos = 1}} };
 	struct rtable *rt;
 
 	if (vcc->push != clip_push) {
@@ -536,28 +530,29 @@
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
-	error = ip_route_output_key(&rt,&fl);
-	if (error) return error;
-	neigh = __neigh_lookup(&clip_tbl,&ip,rt->u.dst.dev,1);
+	error = ip_route_output_key(&rt, &fl);
+	if (error)
+		return error;
+	neigh = __neigh_lookup(&clip_tbl, &ip, rt->u.dst.dev, 1);
 	ip_rt_put(rt);
 	if (!neigh)
 		return -ENOMEM;
 	entry = NEIGH2ENTRY(neigh);
 	if (entry != clip_vcc->entry) {
-		if (!clip_vcc->entry) DPRINTK("setentry: add\n");
+		if (!clip_vcc->entry)
+			DPRINTK("setentry: add\n");
 		else {
 			DPRINTK("setentry: update\n");
 			unlink_clip_vcc(clip_vcc);
 		}
-		link_vcc(clip_vcc,entry);
+		link_vcc(clip_vcc, entry);
 	}
-	error = neigh_update(neigh, llc_oui, NUD_PERMANENT, 
-			     NEIGH_UPDATE_F_OVERRIDE|NEIGH_UPDATE_F_ADMIN);
+	error = neigh_update(neigh, llc_oui, NUD_PERMANENT,
+			     NEIGH_UPDATE_F_OVERRIDE | NEIGH_UPDATE_F_ADMIN);
 	neigh_release(neigh);
 	return error;
 }
 
-
 static void clip_setup(struct net_device *dev)
 {
 	dev->hard_start_xmit = clip_start_xmit;
@@ -566,15 +561,14 @@
 	dev->type = ARPHRD_ATM;
 	dev->hard_header_len = RFC1483LLC_LEN;
 	dev->mtu = RFC1626_MTU;
-	dev->tx_queue_len = 100; /* "normal" queue (packets) */
-	    /* When using a "real" qdisc, the qdisc determines the queue */
-	    /* length. tx_queue_len is only used for the default case, */
-	    /* without any more elaborate queuing. 100 is a reasonable */
-	    /* compromise between decent burst-tolerance and protection */
-	    /* against memory hogs. */
+	dev->tx_queue_len = 100;	/* "normal" queue (packets) */
+	/* When using a "real" qdisc, the qdisc determines the queue */
+	/* length. tx_queue_len is only used for the default case, */
+	/* without any more elaborate queuing. 100 is a reasonable */
+	/* compromise between decent burst-tolerance and protection */
+	/* against memory hogs. */
 }
 
-
 static int clip_create(int number)
 {
 	struct net_device *dev;
@@ -583,19 +577,19 @@
 
 	if (number != -1) {
 		for (dev = clip_devs; dev; dev = PRIV(dev)->next)
-			if (PRIV(dev)->number == number) return -EEXIST;
-	}
-	else {
+			if (PRIV(dev)->number == number)
+				return -EEXIST;
+	} else {
 		number = 0;
 		for (dev = clip_devs; dev; dev = PRIV(dev)->next)
 			if (PRIV(dev)->number >= number)
-				number = PRIV(dev)->number+1;
+				number = PRIV(dev)->number + 1;
 	}
 	dev = alloc_netdev(sizeof(struct clip_priv), "", clip_setup);
 	if (!dev)
 		return -ENOMEM;
 	clip_priv = PRIV(dev);
-	sprintf(dev->name,"atm%d",number);
+	sprintf(dev->name, "atm%d", number);
 	spin_lock_init(&clip_priv->xoff_lock);
 	clip_priv->number = number;
 	error = register_netdev(dev);
@@ -605,12 +599,11 @@
 	}
 	clip_priv->next = clip_devs;
 	clip_devs = dev;
-	DPRINTK("registered (net:%s)\n",dev->name);
+	DPRINTK("registered (net:%s)\n", dev->name);
 	return number;
 }
 
-
-static int clip_device_event(struct notifier_block *this,unsigned long event,
+static int clip_device_event(struct notifier_block *this, unsigned long event,
 			     void *arg)
 {
 	struct net_device *dev = arg;
@@ -625,40 +618,39 @@
 		return NOTIFY_DONE;
 
 	switch (event) {
-		case NETDEV_UP:
-			DPRINTK("clip_device_event NETDEV_UP\n");
-			(void) to_atmarpd(act_up,PRIV(dev)->number,0);
-			break;
-		case NETDEV_GOING_DOWN:
-			DPRINTK("clip_device_event NETDEV_DOWN\n");
-			(void) to_atmarpd(act_down,PRIV(dev)->number,0);
-			break;
-		case NETDEV_CHANGE:
-		case NETDEV_CHANGEMTU:
-			DPRINTK("clip_device_event NETDEV_CHANGE*\n");
-			(void) to_atmarpd(act_change,PRIV(dev)->number,0);
-			break;
-		case NETDEV_REBOOT:
-		case NETDEV_REGISTER:
-		case NETDEV_DOWN:
-			DPRINTK("clip_device_event %ld\n",event);
-			/* ignore */
-			break;
-		default:
-			printk(KERN_WARNING "clip_device_event: unknown event "
-			    "%ld\n",event);
-			break;
+	case NETDEV_UP:
+		DPRINTK("clip_device_event NETDEV_UP\n");
+		(void)to_atmarpd(act_up, PRIV(dev)->number, 0);
+		break;
+	case NETDEV_GOING_DOWN:
+		DPRINTK("clip_device_event NETDEV_DOWN\n");
+		(void)to_atmarpd(act_down, PRIV(dev)->number, 0);
+		break;
+	case NETDEV_CHANGE:
+	case NETDEV_CHANGEMTU:
+		DPRINTK("clip_device_event NETDEV_CHANGE*\n");
+		(void)to_atmarpd(act_change, PRIV(dev)->number, 0);
+		break;
+	case NETDEV_REBOOT:
+	case NETDEV_REGISTER:
+	case NETDEV_DOWN:
+		DPRINTK("clip_device_event %ld\n", event);
+		/* ignore */
+		break;
+	default:
+		printk(KERN_WARNING "clip_device_event: unknown event "
+		       "%ld\n", event);
+		break;
 	}
 	return NOTIFY_DONE;
 }
 
-
-static int clip_inet_event(struct notifier_block *this,unsigned long event,
-    void *ifa)
+static int clip_inet_event(struct notifier_block *this, unsigned long event,
+			   void *ifa)
 {
 	struct in_device *in_dev;
 
-	in_dev = ((struct in_ifaddr *) ifa)->ifa_dev;
+	in_dev = ((struct in_ifaddr *)ifa)->ifa_dev;
 	if (!in_dev || !in_dev->dev) {
 		printk(KERN_WARNING "clip_inet_event: no device\n");
 		return NOTIFY_DONE;
@@ -667,8 +659,9 @@
 	 * Transitions are of the down-change-up type, so it's sufficient to
 	 * handle the change on up.
 	 */
-	if (event != NETDEV_UP) return NOTIFY_DONE;
-	return clip_device_event(this,NETDEV_CHANGE,in_dev->dev);
+	if (event != NETDEV_UP)
+		return NOTIFY_DONE;
+	return clip_device_event(this, NETDEV_CHANGE, in_dev->dev);
 }
 
 
@@ -744,53 +737,53 @@
 	int err = 0;
 
 	switch (cmd) {
-		case SIOCMKCLIP:
-		case ATMARPD_CTRL:
-		case ATMARP_MKIP:
-		case ATMARP_SETENTRY:
-		case ATMARP_ENCAP:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			break;
-		default:
-			return -ENOIOCTLCMD;
+	case SIOCMKCLIP:
+	case ATMARPD_CTRL:
+	case ATMARP_MKIP:
+	case ATMARP_SETENTRY:
+	case ATMARP_ENCAP:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		break;
+	default:
+		return -ENOIOCTLCMD;
 	}
 
 	switch (cmd) {
-		case SIOCMKCLIP:
-			err = clip_create(arg);
-			break;
-		case ATMARPD_CTRL:
-			err = atm_init_atmarp(vcc);
-			if (!err) {
-				sock->state = SS_CONNECTED;
-				__module_get(THIS_MODULE);
-			}
-			break;
-		case ATMARP_MKIP:
-			err = clip_mkip(vcc ,arg);
-			break;
-		case ATMARP_SETENTRY:
-			err = clip_setentry(vcc, arg);
-			break;
-		case ATMARP_ENCAP:
-			err = clip_encap(vcc, arg);
-			break;
+	case SIOCMKCLIP:
+		err = clip_create(arg);
+		break;
+	case ATMARPD_CTRL:
+		err = atm_init_atmarp(vcc);
+		if (!err) {
+			sock->state = SS_CONNECTED;
+			__module_get(THIS_MODULE);
+		}
+		break;
+	case ATMARP_MKIP:
+		err = clip_mkip(vcc, arg);
+		break;
+	case ATMARP_SETENTRY:
+		err = clip_setentry(vcc, arg);
+		break;
+	case ATMARP_ENCAP:
+		err = clip_encap(vcc, arg);
+		break;
 	}
 	return err;
 }
 
 static struct atm_ioctl clip_ioctl_ops = {
-	.owner 	= THIS_MODULE,
-	.ioctl	= clip_ioctl,
+	.owner = THIS_MODULE,
+	.ioctl = clip_ioctl,
 };
 
 #ifdef CONFIG_PROC_FS
 
 static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
 {
-	static int code[] = { 1,2,10,6,1,0 };
-	static int e164[] = { 1,8,4,6,1,0 };
+	static int code[] = { 1, 2, 10, 6, 1, 0 };
+	static int e164[] = { 1, 8, 4, 6, 1, 0 };
 
 	if (*addr->sas_addr.pub) {
 		seq_printf(seq, "%s", addr->sas_addr.pub);
@@ -809,7 +802,7 @@
 		for (i = 0; fields[i]; i++) {
 			for (j = fields[i]; j; j--)
 				seq_printf(seq, "%02X", *prv++);
-			if (fields[i+1])
+			if (fields[i + 1])
 				seq_putc(seq, '.');
 		}
 	}
@@ -828,8 +821,7 @@
 	svc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
 	       (sk_atm(clip_vcc->vcc)->sk_family == AF_ATMSVC));
 
-	llc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
-	       clip_vcc->encap);
+	llc = ((clip_vcc == SEQ_NO_VCC_TOKEN) || clip_vcc->encap);
 
 	if (clip_vcc == SEQ_NO_VCC_TOKEN)
 		exp = entry->neigh->used;
@@ -839,10 +831,7 @@
 	exp = (jiffies - exp) / HZ;
 
 	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
-		   dev->name,
-		   svc ? "SVC" : "PVC",
-		   llc ? "LLC" : "NULL",
-		   exp);
+		   dev->name, svc ? "SVC" : "PVC", llc ? "LLC" : "NULL", exp);
 
 	off = scnprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d",
 			NIPQUAD(entry->ip));
@@ -860,8 +849,7 @@
 	} else if (!svc) {
 		seq_printf(seq, "%d.%d.%d\n",
 			   clip_vcc->vcc->dev->number,
-			   clip_vcc->vcc->vpi,
-			   clip_vcc->vcc->vci);
+			   clip_vcc->vcc->vpi, clip_vcc->vcc->vci);
 	} else {
 		svc_addr(seq, &clip_vcc->vcc->remote);
 		seq_putc(seq, '\n');
@@ -894,7 +882,7 @@
 }
 
 static void *clip_seq_vcc_walk(struct clip_seq_state *state,
-			       struct atmarp_entry *e, loff_t *pos)
+			       struct atmarp_entry *e, loff_t * pos)
 {
 	struct clip_vcc *vcc = state->vcc;
 
@@ -911,24 +899,24 @@
 
 	return vcc;
 }
-  
+
 static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
-			       struct neighbour *n, loff_t *pos)
+			       struct neighbour *n, loff_t * pos)
 {
-	struct clip_seq_state *state = (struct clip_seq_state *) _state;
+	struct clip_seq_state *state = (struct clip_seq_state *)_state;
 
 	return clip_seq_vcc_walk(state, NEIGH2ENTRY(n), pos);
 }
 
-static void *clip_seq_start(struct seq_file *seq, loff_t *pos)
+static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	return neigh_seq_start(seq, pos, &clip_tbl, NEIGH_SEQ_NEIGH_ONLY);
 }
 
 static int clip_seq_show(struct seq_file *seq, void *v)
 {
-	static char atm_arp_banner[] = 
-		"IPitf TypeEncp Idle IP address      ATM address\n";
+	static char atm_arp_banner[] =
+	    "IPitf TypeEncp Idle IP address      ATM address\n";
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, atm_arp_banner);
@@ -939,7 +927,7 @@
 
 		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
 	}
-  	return 0;
+	return 0;
 }
 
 static struct seq_operations arp_seq_ops = {
@@ -998,13 +986,13 @@
 	setup_timer(&idle_timer, idle_timer_check, 0);
 
 #ifdef CONFIG_PROC_FS
-{
-	struct proc_dir_entry *p;
+	{
+		struct proc_dir_entry *p;
 
-	p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
-	if (p)
-		p->proc_fops = &arp_seq_fops;
-}
+		p = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+		if (p)
+			p->proc_fops = &arp_seq_fops;
+	}
 #endif
 
 	return 0;
