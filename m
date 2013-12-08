From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] more spelling fixes
Date: Sun, 8 Dec 2013 12:15:44 -0800
Message-ID: <20131208121544.5d9d589e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:54493 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384Ab3LHUPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 15:15:47 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so3933741pdj.37
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 12:15:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various spelling fixes in networking stack

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/tcp_output.c	2013-12-06 14:02:56.581189688 -0800
+++ b/net/ipv4/tcp_output.c	2013-12-08 11:53:34.300284398 -0800
@@ -408,7 +408,7 @@ struct tcp_out_options {
  * Beware: Something in the Internet is very sensitive to the ordering of
  * TCP options, we learned this through the hard way, so be careful here.
  * Luckily we can at least blame others for their non-compliance but from
- * inter-operatibility perspective it seems that we're somewhat stuck with
+ * inter-operability perspective it seems that we're somewhat stuck with
  * the ordering which we have been using if we want to keep working with
  * those broken things (not that it currently hurts anybody as there isn't
  * particular reason why the ordering would need to be changed).
@@ -681,7 +681,7 @@ static unsigned int tcp_established_opti
  *
  * Its important tcp_wfree() can be replaced by sock_wfree() in the event skb
  * needs to be reallocated in a driver.
- * The invariant being skb->truesize substracted from sk->sk_wmem_alloc
+ * The invariant being skb->truesize subtracted from sk->sk_wmem_alloc
  *
  * Since transmit from skb destructor is forbidden, we use a tasklet
  * to process all sockets that eventually need to send more skbs.
@@ -701,9 +701,9 @@ static void tcp_tsq_handler(struct sock
 		tcp_write_xmit(sk, tcp_current_mss(sk), 0, 0, GFP_ATOMIC);
 }
 /*
- * One tasklest per cpu tries to send more skbs.
+ * One tasklet per cpu tries to send more skbs.
  * We run in tasklet context but need to disable irqs when
- * transfering tsq->head because tcp_wfree() might
+ * transferring tsq->head because tcp_wfree() might
  * interrupt us (non NAPI drivers)
  */
 static void tcp_tasklet_func(unsigned long data)
@@ -797,7 +797,7 @@ void __init tcp_tasklet_init(void)
 
 /*
  * Write buffer destructor automatically called from kfree_skb.
- * We cant xmit new skbs from this context, as we might already
+ * We can't xmit new skbs from this context, as we might already
  * hold qdisc lock.
  */
 void tcp_wfree(struct sk_buff *skb)
--- a/net/bridge/br_netlink.c	2013-10-23 21:23:03.044671179 -0700
+++ b/net/bridge/br_netlink.c	2013-12-08 11:56:38.006229684 -0800
@@ -373,7 +373,7 @@ int br_setlink(struct net_device *dev, s
 
 	p = br_port_get_rtnl(dev);
 	/* We want to accept dev as bridge itself if the AF_SPEC
-	 * is set to see if someone is setting vlan info on the brigde
+	 * is set to see if someone is setting vlan info on the bridge
 	 */
 	if (!p && !afspec)
 		return -EINVAL;
@@ -389,7 +389,7 @@ int br_setlink(struct net_device *dev, s
 			err = br_setport(p, tb);
 			spin_unlock_bh(&p->br->lock);
 		} else {
-			/* Binary compatability with old RSTP */
+			/* Binary compatibility with old RSTP */
 			if (nla_len(protinfo) < sizeof(u8))
 				return -EINVAL;
 
--- a/net/ipv4/ip_sockglue.c	2013-12-05 14:47:26.076495421 -0800
+++ b/net/ipv4/ip_sockglue.c	2013-12-08 11:55:33.982934994 -0800
@@ -1051,7 +1051,7 @@ e_inval:
  *
  * To support IP_CMSG_PKTINFO option, we store rt_iif and specific
  * destination in skb->cb[] before dst drop.
- * This way, receiver doesnt make cache line misses to read rtable.
+ * This way, receiver doesn't make cache line misses to read rtable.
  */
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 {
--- a/net/core/net-sysfs.c	2013-11-21 14:31:19.069128090 -0800
+++ b/net/core/net-sysfs.c	2013-12-08 12:05:43.680421421 -0800
@@ -676,8 +676,8 @@ static ssize_t store_rps_dev_flow_table_
 		while ((mask | (mask >> 1)) != mask)
 			mask |= (mask >> 1);
 		/* On 64 bit arches, must check mask fits in table->mask (u32),
-		 * and on 32bit arches, must check RPS_DEV_FLOW_TABLE_SIZE(mask + 1)
-		 * doesnt overflow.
+		 * and on 32bit arches, must check
+		 * RPS_DEV_FLOW_TABLE_SIZE(mask + 1) doesn't overflow.
 		 */
 #if BITS_PER_LONG > 32
 		if (mask > (unsigned long)(u32)mask)
--- a/net/core/netprio_cgroup.c	2013-10-09 14:10:29.307637576 -0700
+++ b/net/core/netprio_cgroup.c	2013-12-08 12:06:20.824031842 -0800
@@ -30,7 +30,7 @@
 #define PRIOMAP_MIN_SZ		128
 
 /*
- * Extend @dev->priomap so that it's large enough to accomodate
+ * Extend @dev->priomap so that it's large enough to accommodate
  * @target_idx.  @dev->priomap.priomap_len > @target_idx after successful
  * return.  Must be called under rtnl lock.
  */
