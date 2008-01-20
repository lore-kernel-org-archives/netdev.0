From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 15/18]: checkpatch cleanups
Date: Sun, 20 Jan 2008 18:11:38 +0100 (MET)
Message-ID: <20080120171138.7980.14317.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62375 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbYATRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:39 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: checkpatch cleanups

Checkpatch cleanups, consisting mainly of overly long lines and missing
spaces.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit bea0af04454189d656afd69168e0e3ec3209b6b2
tree 6b7d57540dbaf1e40c295d4ba0d40d021a0fec50
parent 40048c4ab8a08ea7f0e2df52f0ec02a8010d2a0e
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 net/8021q/vlan.c     |   20 ++++++----
 net/8021q/vlan.h     |    2 +
 net/8021q/vlan_dev.c |   98 +++++++++++++++++++++++++-------------------------
 net/8021q/vlanproc.c |   42 +++++++++++----------
 net/8021q/vlanproc.h |   11 +++---
 5 files changed, 89 insertions(+), 84 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d058c0e..8b93799 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -43,7 +43,6 @@
 
 /* Our listing of VLAN group(s) */
 static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
-#define vlan_grp_hashfn(IDX)	((((IDX) >> VLAN_GRP_HASH_SHIFT) ^ (IDX)) & VLAN_GRP_HASH_MASK)
 
 static char vlan_fullname[] = "802.1Q VLAN Support";
 static char vlan_version[] = DRV_VERSION;
@@ -60,6 +59,11 @@ static struct packet_type vlan_packet_type = {
 
 /* End of global variables definitions. */
 
+static inline unsigned int vlan_grp_hashfn(unsigned int idx)
+{
+	return ((idx >> VLAN_GRP_HASH_SHIFT) ^ idx) & VLAN_GRP_HASH_MASK;
+}
+
 /* Must be invoked with RCU read lock (no preempt) */
 static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
 {
@@ -94,7 +98,7 @@ static void vlan_group_free(struct vlan_group *grp)
 {
 	int i;
 
-	for (i=0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
+	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
 		kfree(grp->vlan_devices_arrays[i]);
 	kfree(grp);
 }
@@ -174,7 +178,8 @@ void unregister_vlan_dev(struct net_device *dev)
 	unregister_netdevice(dev);
 }
 
-static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)
+static void vlan_transfer_operstate(const struct net_device *dev,
+				    struct net_device *vlandev)
 {
 	/* Have to respect userspace enforced dormant state
 	 * of real device, also must allow supplicant running
@@ -369,7 +374,8 @@ static void vlan_sync_address(struct net_device *dev,
 	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
 }
 
-static int vlan_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
+static int vlan_device_event(struct notifier_block *unused, unsigned long event,
+			     void *ptr)
 {
 	struct net_device *dev = ptr;
 	struct vlan_group *grp = __vlan_find_group(dev->ifindex);
@@ -569,9 +575,8 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = 0;
 		vlan_dev_get_realdev_name(dev, args.u.device2);
 		if (copy_to_user(arg, &args,
-				 sizeof(struct vlan_ioctl_args))) {
+				 sizeof(struct vlan_ioctl_args)))
 			err = -EFAULT;
-		}
 		break;
 
 	case GET_VLAN_VID_CMD:
@@ -579,9 +584,8 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		vlan_dev_get_vid(dev, &vid);
 		args.u.VID = vid;
 		if (copy_to_user(arg, &args,
-				 sizeof(struct vlan_ioctl_args))) {
+				 sizeof(struct vlan_ioctl_args)))
 		      err = -EFAULT;
-		}
 		break;
 
 	default:
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 0cfdf77..73efcc7 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -20,7 +20,7 @@ extern unsigned short vlan_name_type;
  *  Must be invoked with rcu_read_lock (ie preempt disabled)
  *  or with RTNL.
  */
-struct net_device *__find_vlan_dev(struct net_device* real_dev,
+struct net_device *__find_vlan_dev(struct net_device *real_dev,
 				   unsigned short VID); /* vlan.c */
 
 /* found in vlan_dev.c */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index a846559..2ff7659 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -106,13 +106,13 @@ static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
  *  SANITY NOTE 2: We are referencing to the VLAN_HDR frields, which MAY be
  *                 stored UNALIGNED in the memory.  RISC systems don't like
  *                 such cases very much...
- *  SANITY NOTE 2a:  According to Dave Miller & Alexey, it will always be aligned,
- *                 so there doesn't need to be any of the unaligned stuff.  It has
- *                 been commented out now...  --Ben
+ *  SANITY NOTE 2a: According to Dave Miller & Alexey, it will always be
+ *  		    aligned, so there doesn't need to be any of the unaligned
+ *  		    stuff.  It has been commented out now...  --Ben
  *
  */
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type* ptype, struct net_device *orig_dev)
+		  struct packet_type *ptype, struct net_device *orig_dev)
 {
 	unsigned char *rawp = NULL;
 	struct vlan_hdr *vhdr;
@@ -126,7 +126,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		return -1;
 	}
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (skb == NULL)
 		return -1;
 
 	if (unlikely(!pskb_may_pull(skb, VLAN_HLEN))) {
@@ -156,8 +157,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	skb->dev = __find_vlan_dev(dev, vid);
 	if (!skb->dev) {
 		rcu_read_unlock();
-		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s [%i]\n",
-			 __FUNCTION__, (unsigned int)vid, dev->name, dev->ifindex);
+		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
+			 __FUNCTION__, (unsigned int)vid, dev->name);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -175,7 +176,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	/*
 	 * Deal with ingress priority mapping.
 	 */
-	skb->priority = vlan_get_ingress_priority(skb->dev, ntohs(vhdr->h_vlan_TCI));
+	skb->priority = vlan_get_ingress_priority(skb->dev,
+						  ntohs(vhdr->h_vlan_TCI));
 
 	pr_debug("%s: priority: %u for TCI: %hu\n",
 		 __FUNCTION__, skb->priority, ntohs(vhdr->h_vlan_TCI));
@@ -185,7 +187,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 */
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST: /* Yeah, stats collect these together.. */
-		// stats->broadcast ++; // no such counter :-(
+		/* stats->broadcast ++; // no such counter :-( */
 		break;
 
 	case PACKET_MULTICAST:
@@ -194,13 +196,13 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	case PACKET_OTHERHOST:
 		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the underlying
-		 * device, and still route correctly.
+		 * This allows the VLAN to have a different MAC than the
+		 * underlying device, and still route correctly.
 		 */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest, skb->dev->dev_addr)) {
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+					skb->dev->dev_addr))
 			/* It is for our (changed) MAC-address! */
 			skb->pkt_type = PACKET_HOST;
-		}
 		break;
 	default:
 		break;
@@ -244,8 +246,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	 */
 	if (*(unsigned short *)rawp == 0xFFFF) {
 		skb->protocol = htons(ETH_P_802_3);
-		/* place it back on the queue to be handled by true layer 3 protocols.
-		 */
+		/* place it back on the queue to be handled by true layer 3
+		 * protocols. */
 
 		/* See if we are configured to re-write the VLAN header
 		 * to make it look like ethernet...
@@ -286,17 +288,17 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
-static inline unsigned short vlan_dev_get_egress_qos_mask(struct net_device* dev,
-							  struct sk_buff* skb)
+static inline unsigned short
+vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 {
-	struct vlan_priority_tci_mapping *mp =
-		vlan_dev_info(dev)->egress_priority_map[(skb->priority & 0xF)];
+	struct vlan_priority_tci_mapping *mp;
 
+	mp = vlan_dev_info(dev)->egress_priority_map[(skb->priority & 0xF)];
 	while (mp) {
 		if (mp->priority == skb->priority) {
-			return mp->vlan_qos; /* This should already be shifted to mask
-					      * correctly with the VLAN's TCI
-					      */
+			return mp->vlan_qos; /* This should already be shifted
+					      * to mask correctly with the
+					      * VLAN's TCI */
 		}
 		mp = mp->next;
 	}
@@ -321,10 +323,11 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned short veth_TCI = 0;
 	int rc = 0;
 	int build_vlan_header = 0;
-	struct net_device *vdev = dev; /* save this for the bottom of the method */
+	struct net_device *vdev = dev;
 
 	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
-		 __FUNCTION__, skb, type, len, vlan_dev_info(dev)->vlan_id, daddr);
+		 __FUNCTION__, skb, type, len, vlan_dev_info(dev)->vlan_id,
+		 daddr);
 
 	/* build vlan header only if re_order_header flag is NOT set.  This
 	 * fixes some programs that get confused when they see a VLAN device
@@ -342,8 +345,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 		/* build the four bytes that make this a VLAN header. */
 
-		/* Now, construct the second two bytes. This field looks something
-		 * like:
+		/* Now, construct the second two bytes. This field looks
+		 * something like:
 		 * usr_priority: 3 bits	 (high bits)
 		 * CFI		 1 bit
 		 * VLAN ID	 12 bits (low bits)
@@ -355,16 +358,15 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		vhdr->h_vlan_TCI = htons(veth_TCI);
 
 		/*
-		 *  Set the protocol type.
-		 *  For a packet of type ETH_P_802_3 we put the length in here instead.
-		 *  It is up to the 802.2 layer to carry protocol information.
+		 *  Set the protocol type. For a packet of type ETH_P_802_3 we
+		 *  put the length in here instead. It is up to the 802.2
+		 *  layer to carry protocol information.
 		 */
 
-		if (type != ETH_P_802_3) {
+		if (type != ETH_P_802_3)
 			vhdr->h_vlan_encapsulated_proto = htons(type);
-		} else {
+		else
 			vhdr->h_vlan_encapsulated_proto = htons(len);
-		}
 
 		skb->protocol = htons(ETH_P_8021Q);
 		skb_reset_network_header(skb);
@@ -376,14 +378,14 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 	dev = vlan_dev_info(dev)->real_dev;
 
-	/* MPLS can send us skbuffs w/out enough space.	 This check will grow the
-	 * skb if it doesn't have enough headroom.  Not a beautiful solution, so
-	 * I'll tick a counter so that users can know it's happening...	 If they
-	 * care...
+	/* MPLS can send us skbuffs w/out enough space.	This check will grow
+	 * the skb if it doesn't have enough headroom. Not a beautiful solution,
+	 * so I'll tick a counter so that users can know it's happening...
+	 * If they care...
 	 */
 
-	/* NOTE:  This may still break if the underlying device is not the final
-	 * device (and thus there are more headers to add...)  It should work for
+	/* NOTE: This may still break if the underlying device is not the final
+	 * device (and thus there are more headers to add...) It should work for
 	 * good-ole-ethernet though.
 	 */
 	if (skb_headroom(skb) < dev->hard_header_len) {
@@ -396,7 +398,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			return -ENOMEM;
 		}
 		vlan_dev_info(vdev)->cnt_inc_headroom_on_tx++;
-		pr_debug("%s: %s: had to grow skb.\n", __FUNCTION__, vdev->name);
+		pr_debug("%s: %s: had to grow skb\n", __FUNCTION__, vdev->name);
 	}
 
 	if (build_vlan_header) {
@@ -408,10 +410,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		else if (rc < 0)
 			rc -= VLAN_HLEN;
 	} else
-		/* If here, then we'll just make a normal looking ethernet frame,
-		 * but, the hard_start_xmit method will insert the tag (it has to
-		 * be able to do this for bridged and other skbs that don't come
-		 * down the protocol stack in an orderly manner.
+		/* If here, then we'll just make a normal looking ethernet
+		 * frame, but, the hard_start_xmit method will insert the tag
+		 * (it has to be able to do this for bridged and other skbs
+		 * that don't come down the protocol stack in an orderly manner.
 		 */
 		rc = dev_hard_header(skb, dev, type, daddr, saddr, len);
 
@@ -454,9 +456,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			return 0;
 		}
 
-		if (orig_headroom < VLAN_HLEN) {
+		if (orig_headroom < VLAN_HLEN)
 			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
-		}
 	}
 
 	pr_debug("%s: about to send skb: %p to dev: %s\n",
@@ -572,11 +573,10 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 {
 	/* verify flag is supported */
 	if (flag == VLAN_FLAG_REORDER_HDR) {
-		if (flag_val) {
+		if (flag_val)
 			vlan_dev_info(dev)->flags |= VLAN_FLAG_REORDER_HDR;
-		} else {
+		else
 			vlan_dev_info(dev)->flags &= ~VLAN_FLAG_REORDER_HDR;
-		}
 		return 0;
 	}
 	return -EINVAL;
@@ -667,7 +667,7 @@ static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	strncpy(ifrr.ifr_name, real_dev->name, IFNAMSIZ);
 	ifrr.ifr_ifru = ifr->ifr_ifru;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index b520244..2a4e1aa 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -125,10 +125,10 @@ static struct proc_dir_entry *proc_vlan_conf;
 
 /* Strings */
 static const char *vlan_name_type_str[VLAN_NAME_TYPE_HIGHEST] = {
-    [VLAN_NAME_TYPE_RAW_PLUS_VID]       = "VLAN_NAME_TYPE_RAW_PLUS_VID",
-    [VLAN_NAME_TYPE_PLUS_VID_NO_PAD]	= "VLAN_NAME_TYPE_PLUS_VID_NO_PAD",
-    [VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD]= "VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD",
-    [VLAN_NAME_TYPE_PLUS_VID]		= "VLAN_NAME_TYPE_PLUS_VID",
+    [VLAN_NAME_TYPE_RAW_PLUS_VID]        = "VLAN_NAME_TYPE_RAW_PLUS_VID",
+    [VLAN_NAME_TYPE_PLUS_VID_NO_PAD]	 = "VLAN_NAME_TYPE_PLUS_VID_NO_PAD",
+    [VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD] = "VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD",
+    [VLAN_NAME_TYPE_PLUS_VID]		 = "VLAN_NAME_TYPE_PLUS_VID",
 };
 /*
  *	Interface functions
@@ -178,7 +178,7 @@ err:
  *	Add directory entry for VLAN device.
  */
 
-int vlan_proc_add_dev (struct net_device *vlandev)
+int vlan_proc_add_dev(struct net_device *vlandev)
 {
 	struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 
@@ -200,7 +200,8 @@ int vlan_proc_rem_dev(struct net_device *vlandev)
 {
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
 	if (vlan_dev_info(vlandev)->dent) {
-		remove_proc_entry(vlan_dev_info(vlandev)->dent->name, proc_vlan_dir);
+		remove_proc_entry(vlan_dev_info(vlandev)->dent->name,
+				  proc_vlan_dir);
 		vlan_dev_info(vlandev)->dent = NULL;
 	}
 	return 0;
@@ -275,7 +276,7 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 		    nmtype =  vlan_name_type_str[vlan_name_type];
 
 		seq_printf(seq, "Name-Type: %s\n",
-			   nmtype ? nmtype :  "UNKNOWN" );
+			   nmtype ? nmtype :  "UNKNOWN");
 	} else {
 		const struct net_device *vlandev = v;
 		const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
@@ -297,9 +298,10 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN))
 		return 0;
 
-	seq_printf(seq, "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
-		       vlandev->name, dev_info->vlan_id,
-		       (int)(dev_info->flags & 1), vlandev->priv_flags);
+	seq_printf(seq,
+		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
+		   vlandev->name, dev_info->vlan_id,
+		   (int)(dev_info->flags & 1), vlandev->priv_flags);
 
 	seq_printf(seq, fmt, "total frames received", stats->rx_packets);
 	seq_printf(seq, fmt, "total bytes received", stats->rx_bytes);
@@ -313,16 +315,16 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 		   dev_info->cnt_encap_on_xmit);
 	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
 	/* now show all PRIORITY mappings relating to this VLAN */
-	seq_printf(seq,
-		       "\nINGRESS priority mappings: 0:%u  1:%u  2:%u  3:%u  4:%u  5:%u  6:%u 7:%u\n",
-		       dev_info->ingress_priority_map[0],
-		       dev_info->ingress_priority_map[1],
-		       dev_info->ingress_priority_map[2],
-		       dev_info->ingress_priority_map[3],
-		       dev_info->ingress_priority_map[4],
-		       dev_info->ingress_priority_map[5],
-		       dev_info->ingress_priority_map[6],
-		       dev_info->ingress_priority_map[7]);
+	seq_printf(seq, "\nINGRESS priority mappings: "
+			"0:%u  1:%u  2:%u  3:%u  4:%u  5:%u  6:%u 7:%u\n",
+		   dev_info->ingress_priority_map[0],
+		   dev_info->ingress_priority_map[1],
+		   dev_info->ingress_priority_map[2],
+		   dev_info->ingress_priority_map[3],
+		   dev_info->ingress_priority_map[4],
+		   dev_info->ingress_priority_map[5],
+		   dev_info->ingress_priority_map[6],
+		   dev_info->ingress_priority_map[7]);
 
 	seq_printf(seq, "EGRESSS priority Mappings: ");
 	for (i = 0; i < 16; i++) {
diff --git a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
index f908ee3..da542ca 100644
--- a/net/8021q/vlanproc.h
+++ b/net/8021q/vlanproc.h
@@ -4,16 +4,15 @@
 #ifdef CONFIG_PROC_FS
 int vlan_proc_init(void);
 int vlan_proc_rem_dev(struct net_device *vlandev);
-int vlan_proc_add_dev (struct net_device *vlandev);
-void vlan_proc_cleanup (void);
+int vlan_proc_add_dev(struct net_device *vlandev);
+void vlan_proc_cleanup(void);
 
 #else /* No CONFIG_PROC_FS */
 
 #define vlan_proc_init()	(0)
-#define vlan_proc_cleanup()	do {} while(0)
-#define vlan_proc_add_dev(dev)	({(void)(dev), 0;})
-#define vlan_proc_rem_dev(dev)	({(void)(dev), 0;})
-
+#define vlan_proc_cleanup()	do {} while (0)
+#define vlan_proc_add_dev(dev)	({(void)(dev), 0; })
+#define vlan_proc_rem_dev(dev)	({(void)(dev), 0; })
 #endif
 
 #endif /* !(__BEN_VLAN_PROC_INC__) */
