From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 2/2] macvtap: Allow tap features change when
 IFF_VNET_HDR is disabled.
Date: Thu, 15 Aug 2013 23:52:45 +0300
Message-ID: <20130815205245.GB12743@redhat.com>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
 <1376586173-4242-3-git-send-email-vyasevic@redhat.com>
 <20130815173347.GA10265@redhat.com>
 <20130815.131645.1042317207899492632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab3HOUvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 16:51:01 -0400
Content-Disposition: inline
In-Reply-To: <20130815.131645.1042317207899492632.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 01:16:45PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Thu, 15 Aug 2013 20:33:47 +0300
> 
> > On Thu, Aug 15, 2013 at 01:02:53PM -0400, Vlad Yasevich wrote:
> >> When the user turns off IFF_VNET_HDR flag, attempts to change
> >> offload features via TUNSETOFFLOAD do not work.  This could cause
> >> GSO packets to be delivered to the user when the user is
> >> not prepared to handle them.
> >> 
> >> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
> >> disabled.  Also, take the setting of IFF_VNET_HDR into consideration
> >> when determining the feature set to apply to incommig traffic.
> >> If IFF_VNET_HDR is set, we use user-specfied feature set.  if the
> >> IFF_VNET_HDR is clear, we mask off all tun-specific offload features,
> >> since user can not be notified of the possbile offloads.
> >> 
> >> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> >> ---
> >>  drivers/net/macvtap.c | 30 ++++++++++++++++++++++++------
> >>  1 file changed, 24 insertions(+), 6 deletions(-)
> >> 
> >> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> >> index 8121358..df45a59 100644
> >> --- a/drivers/net/macvtap.c
> >> +++ b/drivers/net/macvtap.c
> >> @@ -269,6 +269,28 @@ static void macvtap_del_queues(struct net_device *dev)
> >>  		sock_put(&qlist[j]->sk);
> >>  }
> >>  
> >> +/* Determine features to be applied to the packet as it
> > 
> > /*
> >  * Please use comments
> >  * like this
> >  */
> 
> Not in the networking, we use:
> 
> 	/* This
> 	 * style.
> 	 */
> 
> Your misguiding people on this issue makes it hard for me
> to get people to do things properly.
> 
> Thanks.

OK in that case let's fix the rest of macvtap so I can stop getting
confused?

--->

macvtap: fix style for multiline comments

In the networking, we use:
 
 	/* This
 	 * style.
 	 */

fix up macvtap to stop misguiding people on this issue.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a98ed9f..04b7575 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -22,15 +22,13 @@
 #include <net/sock.h>
 #include <linux/virtio_net.h>
 
-/*
- * A macvtap queue is the central object of this driver, it connects
+/* A macvtap queue is the central object of this driver, it connects
  * an open character device to a macvlan interface. There can be
  * multiple queues on one interface, which map back to queues
  * implemented in hardware on the underlying device.
  *
  * macvtap_proto is used to allocate queues through the sock allocation
  * mechanism.
- *
  */
 struct macvtap_queue {
 	struct sock sk;
@@ -51,9 +49,7 @@ static struct proto macvtap_proto = {
 	.obj_size = sizeof (struct macvtap_queue),
 };
 
-/*
- * Variables for dealing with macvtaps device numbers.
- */
+/* Variables for dealing with macvtaps device numbers.  */
 static dev_t macvtap_major;
 #define MACVTAP_NUM_DEVS (1U << MINORBITS)
 static DEFINE_MUTEX(minor_lock);
@@ -68,8 +64,8 @@ static const struct proto_ops macvtap_socket_ops;
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
 		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
-/*
- * RCU usage:
+
+/* RCU usage:
  * The macvtap_queue and the macvlan_dev are loosely coupled, the
  * pointers from one to the other can only be read while rcu_read_lock
  * or rtnl is held.
@@ -162,8 +158,7 @@ static int macvtap_disable_queue(struct macvtap_queue *q)
 	return 0;
 }
 
-/*
- * The file owning the queue got closed, give up both
+/* The file owning the queue got closed, give up both
  * the reference that the files holds as well as the
  * one from the macvlan_dev if that still exists.
  *
@@ -193,8 +188,7 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 	sock_put(&q->sk);
 }
 
-/*
- * Select a queue based on the rxq of the device on which this packet
+/* Select a queue based on the rxq of the device on which this packet
  * arrived. If the incoming device is not mq, calculate a flow hash
  * to select a queue. If all fails, find the first available queue.
  * Cache vlan->numvtaps since it can become zero during the execution
@@ -238,8 +232,7 @@ out:
 	return tap;
 }
 
-/*
- * The net_device is going away, give up the reference
+/* The net_device is going away, give up the reference
  * that it holds on all queues and safely set the pointer
  * from the queues to NULL.
  */
@@ -269,8 +262,7 @@ static void macvtap_del_queues(struct net_device *dev)
 		sock_put(&qlist[j]->sk);
 }
 
-/*
- * Forward happens for data that gets sent from one macvlan
+/* Forward happens for data that gets sent from one macvlan
  * endpoint to another one in bridge mode. We just take
  * the skb and put it into the receive queue.
  */
@@ -322,8 +314,7 @@ drop:
 	return NET_RX_DROP;
 }
 
-/*
- * Receive is for data from the external interface (lowerdev),
+/* Receive is for data from the external interface (lowerdev),
  * in case of macvtap, we can treat that the same way as
  * forward, which macvlan cannot.
  */
@@ -462,8 +453,7 @@ static int macvtap_open(struct inode *inode, struct file *file)
 	q->flags = IFF_VNET_HDR | IFF_NO_PI | IFF_TAP;
 	q->vnet_hdr_sz = sizeof(struct virtio_net_hdr);
 
-	/*
-	 * so far only KVM virtio_net uses macvtap, enable zero copy between
+	/* so far only KVM virtio_net uses macvtap, enable zero copy between
 	 * guest kernel and host kernel when lower device supports zerocopy
 	 *
 	 * The macvlan supports zerocopy iff the lower device supports zero
@@ -616,8 +606,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 	return 0;
 }
 
-/*
- * macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
+/* macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
  * be shared with the tun/tap driver.
  */
 static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
@@ -1066,8 +1055,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 	return 0;
 }
 
-/*
- * provide compatibility with generic tun/tap interface
+/* provide compatibility with generic tun/tap interface
  */
 static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			  unsigned long arg)
@@ -1225,7 +1213,8 @@ static const struct proto_ops macvtap_socket_ops = {
 /* Get an underlying socket object from tun file.  Returns error unless file is
  * attached to a device.  The returned object works like a packet socket, it
  * can be used for sock_sendmsg/sock_recvmsg.  The caller is responsible for
- * holding a reference to the file for as long as the socket is in use. */
+ * holding a reference to the file for as long as the socket is in use.
+ */
 struct socket *macvtap_get_socket(struct file *file)
 {
 	struct macvtap_queue *q;
