From: Ben Greear <greearb@candelatech.com>
Subject: VLAN patch try 2, tabs instead of spaces
Date: Tue, 05 Aug 2003 21:15:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3080C4.9070507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Same as last time, but now using tabs instead of spaces.

--- linux-2.4.21/net/8021q/vlan_dev.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan_dev.c	2003-08-05 20:38:25.000000000 -0700
@@ -1,18 +1,18 @@
-/*
+/* -*- linux-c -*-
   * INET		802.1Q VLAN
   *		Ethernet-type device handling.
   *
   * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
- *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
+ *		Please send support related email to: vlan@scry.wanfear.com
+ *		VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
   *
- * Fixes:       Mar 22 2001: Martin Bokaemper <mbokaemper@unispherenetworks.com>
- *                - reset skb->pkt_type on incoming packets when MAC was changed
- *                - see that changed MAC is saddr for outgoing packets
- *              Oct 20, 2001:  Ard van Breeman:
- *                - Fix MC-list, finally.
- *                - Flush MC-list on VLAN destroy.
- *
+ * Fixes:	Mar 22 2001: Martin Bokaemper <mbokaemper@unispherenetworks.com>
+ *		  - reset skb->pkt_type on incoming packets when MAC was changed
+ *		  - see that changed MAC is saddr for outgoing packets
+ *		Oct 20, 2001:  Ard van Breeman:
+ *		  - Fix MC-list, finally.
+ *		  - Flush MC-list on VLAN destroy.
+ *		
   *
   *		This program is free software; you can redistribute it and/or
   *		modify it under the terms of the GNU General Public License
@@ -99,18 +99,18 @@
   *  NOTE:  Should be similar to ethernet/eth.c.
   *
   *  SANITY NOTE:  This method is called when a packet is moving up the stack
- *                towards userland.  To get here, it would have already passed
- *                through the ethernet/eth.c eth_type_trans() method.
+ *		  towards userland.  To get here, it would have already passed
+ *		  through the ethernet/eth.c eth_type_trans() method.
   *  SANITY NOTE 2: We are referencing to the VLAN_HDR frields, which MAY be
- *                 stored UNALIGNED in the memory.  RISC systems don't like
- *                 such cases very much...
+ *		   stored UNALIGNED in the memory.  RISC systems don't like
+ *		   such cases very much...
   *  SANITY NOTE 2a:  According to Dave Miller & Alexey, it will always be aligned,
- *                 so there doesn't need to be any of the unaligned stuff.  It has
- *                 been commented out now...  --Ben
+ *		   so there doesn't need to be any of the unaligned stuff.  It has
+ *		   been commented out now...  --Ben
   *
   */
  int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-                  struct packet_type* ptype)
+		  struct packet_type* ptype)
  {
  	unsigned char *rawp = NULL;
  	struct vlan_hdr *vhdr = (struct vlan_hdr *)(skb->data);
@@ -170,7 +170,7 @@
  		spin_unlock_bh(&vlan_group_lock);

  #ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: dropping skb: %p because came in on wrong device, dev: %s  real_dev: %s, skb_dev: %s\n",
+		printk(VLAN_DBG "%s: dropping skb: %p because came in on wrong device, dev: %s	real_dev: %s, skb_dev: %s\n",
  			__FUNCTION__ skb, dev->name,
  			VLAN_DEV_INFO(skb->dev)->real_dev->name,
  			skb->dev->name);
@@ -324,8 +324,8 @@
   *  physical devices.
   */
  int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
-                         unsigned short type, void *daddr, void *saddr,
-                         unsigned len)
+			 unsigned short type, void *daddr, void *saddr,
+			 unsigned len)
  {
  	struct vlan_hdr *vhdr;
  	unsigned short veth_TCI = 0;
@@ -613,7 +613,7 @@
  				dev_put(dev);
  				return 0;
  			} else {
-				printk(KERN_ERR  "%s: flag %i is not valid.\n",
+				printk(KERN_ERR	 "%s: flag %i is not valid.\n",
  					__FUNCTION__, (int)(flag));
  				dev_put(dev);
  				return -EINVAL;
@@ -625,13 +625,66 @@
  			dev_put(dev);
  		}
  	} else {
-		printk(KERN_ERR  "%s: Could not find device: %s\n",
+		printk(KERN_ERR	 "%s: Could not find device: %s\n",
  			__FUNCTION__, dev_name);
  	}

  	return -EINVAL;
  }

+
+int vlan_dev_get_realdev_name(const char *dev_name, char* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
+			dev_put(dev);
+			rv = 0;
+		} else {
+			printk(KERN_ERR
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);
+			dev_put(dev);
+			rv = -EINVAL;
+		}
+	} else {
+		printk(KERN_ERR	 "%s: Could not find device: %s\n",
+			__FUNCTION__, dev_name);
+		rv = -ENODEV;
+	}
+
+	return rv;
+}
+
+int vlan_dev_get_vid(const char *dev_name, unsigned short* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			*result = VLAN_DEV_INFO(dev)->vlan_id;
+			dev_put(dev);
+			rv = 0;
+		} else {
+			printk(KERN_ERR
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);
+			dev_put(dev);
+			rv = -EINVAL;
+		}
+	} else {
+		printk(KERN_ERR	 "%s: Could not find device: %s\n",
+			__FUNCTION__, dev_name);
+		rv = -ENODEV;
+	}
+
+	return rv;
+}
+
  int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
  {
  	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
@@ -671,7 +724,7 @@
  }

  static inline int vlan_dmi_equals(struct dev_mc_list *dmi1,
-                                  struct dev_mc_list *dmi2)
+				  struct dev_mc_list *dmi2)
  {
  	return ((dmi1->dmi_addrlen == dmi2->dmi_addrlen) &&
  		(memcmp(dmi1->dmi_addr, dmi2->dmi_addr, dmi1->dmi_addrlen) == 0));
--- linux-2.4.21/net/8021q/vlan.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan.c	2003-08-05 20:53:31.000000000 -0700
@@ -1,13 +1,13 @@
-/*
+/* -*- linux-c -*-
   * INET		802.1Q VLAN
   *		Ethernet-type device handling.
   *
   * Authors:	Ben Greear <greearb@candelatech.com>
- *              Please send support related email to: vlan@scry.wanfear.com
- *              VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
+ *		Please send support related email to: vlan@scry.wanfear.com
+ *		VLAN Home Page: http://www.candelatech.com/~greear/vlan.html
   *
   * Fixes:
- *              Fix for packet capture - Nick Eggleston <nick@dccinc.com>;
+ *		Fix for packet capture - Nick Eggleston <nick@dccinc.com>;
   *		Add HW acceleration hooks - David S. Miller <davem@redhat.com>;
   *		Correct all the locking - David S. Miller <davem@redhat.com>;
   *		Use hash table for VLAN groups - David S. Miller <davem@redhat.com>
@@ -173,7 +173,7 @@
  	*pprev = grp->next;
  }

-/*  Find the protocol handler.  Assumes VID < VLAN_VID_MASK.
+/*  Find the protocol handler.	Assumes VID < VLAN_VID_MASK.
   *
   * Must be invoked with vlan_group_lock held.
   */
@@ -183,7 +183,7 @@
  	struct vlan_group *grp = __vlan_find_group(real_dev->ifindex);

  	if (grp)
-                return grp->vlan_devices[VID];
+		return grp->vlan_devices[VID];

  	return NULL;
  }
@@ -270,7 +270,7 @@
  		}
  	}

-        return ret;
+	return ret;
  }

  static int unregister_vlan_device(const char *vlan_IF_name)
@@ -655,17 +655,14 @@
  int vlan_ioctl_handler(unsigned long arg)
  {
  	int err = 0;
+	unsigned short vid = 0;
  	struct vlan_ioctl_args args;

-	/* everything here needs root permissions, except aguably the
-	 * hack ioctls for sending packets.  However, I know _I_ don't
-	 * want users running that on my network! --BLG
-	 */
  	if (!capable(CAP_NET_ADMIN))
  		return -EPERM;

  	if (copy_from_user(&args, (void*)arg,
-                           sizeof(struct vlan_ioctl_args)))
+			   sizeof(struct vlan_ioctl_args)))
  		return -EFAULT;

  	/* Null terminate this sucker, just in case. */
@@ -678,24 +675,32 @@

  	switch (args.cmd) {
  	case SET_VLAN_INGRESS_PRIORITY_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		err = vlan_dev_set_ingress_priority(args.device1,
  						    args.u.skb_priority,
  						    args.vlan_qos);
  		break;

  	case SET_VLAN_EGRESS_PRIORITY_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		err = vlan_dev_set_egress_priority(args.device1,
  						   args.u.skb_priority,
  						   args.vlan_qos);
  		break;

  	case SET_VLAN_FLAG_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		err = vlan_dev_set_vlan_flag(args.device1,
  					     args.u.flag,
  					     args.vlan_qos);
  		break;

  	case SET_VLAN_NAME_TYPE_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		if ((args.u.name_type >= 0) &&
  		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
  			vlan_name_type = args.u.name_type;
@@ -705,17 +710,9 @@
  		}
  		break;

-		/* TODO:  Figure out how to pass info back...
-		   case GET_VLAN_INGRESS_PRIORITY_IOCTL:
-		   err = vlan_dev_get_ingress_priority(args);
-		   break;
-
-		   case GET_VLAN_EGRESS_PRIORITY_IOCTL:
-		   err = vlan_dev_get_egress_priority(args);
-		   break;
-		*/
-
  	case ADD_VLAN_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		/* we have been given the name of the Ethernet Device we want to
  		 * talk to:  args.dev1	 We also have the
  		 * VLAN ID:  args.u.VID
@@ -728,12 +725,53 @@
  		break;

  	case DEL_VLAN_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
  		/* Here, the args.dev1 is the actual VLAN we want
  		 * to get rid of.
  		 */
  		err = unregister_vlan_device(args.device1);
  		break;

+	case GET_VLAN_INGRESS_PRIORITY_CMD:
+		/* TODO:  Implement
+		err = vlan_dev_get_ingress_priority(args);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		*/
+		err = -EINVAL;
+		break;
+
+	case GET_VLAN_EGRESS_PRIORITY_CMD:
+		/* TODO:  Implement
+		err = vlan_dev_get_egress_priority(args.device1, &(args.args);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		*/
+		err = -EINVAL;
+		break;
+
+	case GET_VLAN_REALDEV_NAME_CMD:
+		err = vlan_dev_get_realdev_name(args.device1, args.u.device2);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		break;
+
+	case GET_VLAN_VID_CMD:
+		err = vlan_dev_get_vid(args.device1, &vid);
+		args.u.VID = vid;
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		break;
+
  	default:
  		/* pass on to underlying device instead?? */
  		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
--- linux-2.4.21/net/8021q/vlan.h	2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan.h	2003-07-30 16:30:53.000000000 -0700
@@ -72,6 +72,8 @@
  int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
  int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
  int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
+int vlan_dev_get_realdev_name(const char* dev_name, char* result);
+int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
  void vlan_dev_set_multicast_list(struct net_device *vlan_dev);

  #endif /* !(__BEN_VLAN_802_1Q_INC__) */
--- linux-2.4.21/include/linux/if_vlan.h	2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.21.amds/include/linux/if_vlan.h	2003-07-30 16:29:30.000000000 -0700
@@ -212,7 +212,9 @@
  	GET_VLAN_INGRESS_PRIORITY_CMD,
  	GET_VLAN_EGRESS_PRIORITY_CMD,
  	SET_VLAN_NAME_TYPE_CMD,
-	SET_VLAN_FLAG_CMD
+	SET_VLAN_FLAG_CMD,
+        GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
+        GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
  };

  enum vlan_name_types {




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
