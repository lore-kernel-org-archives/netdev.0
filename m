From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] snap: use const for descirptor
Date: Fri, 20 Mar 2009 08:43:14 -0700
Message-ID: <20090320084314.5761b1d9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45509 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754133AbZCTPpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 11:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protocols should be able to use constant value for the descriptor.
Minor whitespace cleanup as well

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/802/psnap.c	2009-03-19 23:47:22.745964788 -0700
+++ b/net/802/psnap.c	2009-03-20 08:33:46.694749299 -0700
@@ -29,7 +29,7 @@ static struct llc_sap *snap_sap;
 /*
  *	Find a snap client by matching the 5 bytes.
  */
-static struct datalink_proto *find_snap_client(unsigned char *desc)
+static struct datalink_proto *find_snap_client(const unsigned char *desc)
 {
 	struct datalink_proto *proto = NULL, *p;
 
@@ -122,7 +122,7 @@ module_exit(snap_exit);
 /*
  *	Register SNAP clients. We don't yet use this for IP.
  */
-struct datalink_proto *register_snap_client(unsigned char *desc,
+struct datalink_proto *register_snap_client(const unsigned char *desc,
 					    int (*rcvfunc)(struct sk_buff *,
 							   struct net_device *,
 							   struct packet_type *,
@@ -137,7 +137,7 @@ struct datalink_proto *register_snap_cli
 
 	proto = kmalloc(sizeof(*proto), GFP_ATOMIC);
 	if (proto) {
-		memcpy(proto->type, desc,5);
+		memcpy(proto->type, desc, 5);
 		proto->rcvfunc		= rcvfunc;
 		proto->header_length	= 5 + 3; /* snap + 802.2 */
 		proto->request		= snap_request;
--- a/include/net/psnap.h	2009-03-19 23:48:33.929963947 -0700
+++ b/include/net/psnap.h	2009-03-19 23:49:25.792963671 -0700
@@ -1,7 +1,11 @@
 #ifndef _NET_PSNAP_H
 #define _NET_PSNAP_H
 
-extern struct datalink_proto *register_snap_client(unsigned char *desc, int (*rcvfunc)(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *orig_dev));
+extern struct datalink_proto *
+register_snap_client(const unsigned char *desc,
+		     int (*rcvfunc)(struct sk_buff *, struct net_device *,
+				    struct packet_type *,
+				    struct net_device *orig_dev));
 extern void unregister_snap_client(struct datalink_proto *proto);
 
 #endif
