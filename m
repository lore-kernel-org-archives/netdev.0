From: urs.thuermann@gmx.de
Subject: [patch 3/3] CAN: Minor clean-ups
Date: Wed,  6 Feb 2008 23:07:52 +0100
Message-ID: <20080206220828.20500.3@janus.isnogud.escape.de>
References: <20080206220749.20500.0@janus.isnogud.escape.de>
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:54363 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760329AbYBFXH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 18:07:29 -0500
Content-Disposition: inline; filename=cosmetics
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unneeded variable.
Rename local variable error to err like in all other places.
Some white-space changes.

Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

---
 net/can/raw.c |   24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

Index: net-2.6/net/can/raw.c
===================================================================
--- net-2.6.orig/net/can/raw.c	2008-02-06 22:17:58.000000000 +0100
+++ net-2.6/net/can/raw.c	2008-02-06 22:30:55.000000000 +0100
@@ -98,7 +98,6 @@
 	struct sock *sk = (struct sock *)data;
 	struct raw_sock *ro = raw_sk(sk);
 	struct sockaddr_can *addr;
-	int error;
 
 	if (!ro->recv_own_msgs) {
 		/* check the received tx sock reference */
@@ -121,14 +120,12 @@
 	addr->can_family  = AF_CAN;
 	addr->can_ifindex = skb->dev->ifindex;
 
-	error = sock_queue_rcv_skb(sk, skb);
-	if (error < 0)
+	if (sock_queue_rcv_skb(sk, skb) < 0)
 		kfree_skb(skb);
 }
 
 static int raw_enable_filters(struct net_device *dev, struct sock *sk,
-			      struct can_filter *filter,
-			      int count)
+			      struct can_filter *filter, int count)
 {
 	int err = 0;
 	int i;
@@ -163,8 +160,7 @@
 }
 
 static void raw_disable_filters(struct net_device *dev, struct sock *sk,
-			      struct can_filter *filter,
-			      int count)
+			      struct can_filter *filter, int count)
 {
 	int i;
 
@@ -353,7 +349,6 @@
 		/* filters set by default/setsockopt */
 		err = raw_enable_allfilters(dev, sk);
 		dev_put(dev);
-
 	} else {
 		ifindex = 0;
 
@@ -466,7 +461,6 @@
 			if (err) {
 				if (count > 1)
 					kfree(filter);
-
 				goto out_fil;
 			}
 
@@ -673,25 +667,25 @@
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
-	int error = 0;
+	int err = 0;
 	int noblock;
 
 	noblock =  flags & MSG_DONTWAIT;
 	flags   &= ~MSG_DONTWAIT;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &error);
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
-		return error;
+		return err;
 
 	if (size < skb->len)
 		msg->msg_flags |= MSG_TRUNC;
 	else
 		size = skb->len;
 
-	error = memcpy_toiovec(msg->msg_iov, skb->data, size);
-	if (error < 0) {
+	err = memcpy_toiovec(msg->msg_iov, skb->data, size);
+	if (err < 0) {
 		skb_free_datagram(sk, skb);
-		return error;
+		return err;
 	}
 
 	sock_recv_timestamp(msg, sk, skb);

--
