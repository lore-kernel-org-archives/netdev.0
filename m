From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] No need to inc/dec packet_socks_nr if PACKET_REFCNT_DEBUG
	is not set
Date: Thu, 8 Nov 2007 13:37:31 +0300
Message-ID: <20071108103731.GA22373@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52609 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754116AbXKHKdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 05:33:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to inc/dec packet_socks_nr if PACKET_REFCNT_DEBUG is not set.

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/packet/af_packet.c.packetrefcnt	2007-11-08 13:48:22.000000000 +0300
+++ ./net/packet/af_packet.c	2007-11-08 13:54:29.000000000 +0300
@@ -135,7 +135,9 @@ dev->hard_header == NULL (ll header is a
    packet classifier depends on it.
  */
 
+#ifdef PACKET_REFCNT_DEBUG
 static atomic_t packet_socks_nr;
+#endif
 
 
 /* Private packet socket structures. */
@@ -232,8 +234,8 @@ static void packet_sock_destruct(struct 
 		return;
 	}
 
-	atomic_dec(&packet_socks_nr);
 #ifdef PACKET_REFCNT_DEBUG
+	atomic_dec(&packet_socks_nr);
 	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
 #endif
 }
@@ -1005,7 +1007,9 @@ static int packet_create(struct net *net
 	po->num = proto;
 
 	sk->sk_destruct = packet_sock_destruct;
+#ifdef PACKET_REFCNT_DEBUG
 	atomic_inc(&packet_socks_nr);
+#endif
 
 	/*
 	 *	Attach a protocol block
