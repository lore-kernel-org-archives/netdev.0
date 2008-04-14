From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6 patch] remove irlan_eth_send_gratuitous_arp()
Date: Mon, 14 Apr 2008 21:40:53 +0300
Message-ID: <20080414184053.GH6695@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:43777 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965269AbYDNSsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 14:48:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even kernel 2.2.26 (sic) already contains the
  #undef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
with the comment "but for some reason the machine crashes if you use DHCP".

Either someone finally looks into this or it's simply time to remove 
this dead code.

Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

This patch has been sent on:
- 31 Mar 2008
- 1 Mar 2008

 include/net/irda/irlan_eth.h  |    1 -
 net/irda/irlan/irlan_common.c |   10 ----------
 net/irda/irlan/irlan_eth.c    |   33 ---------------------------------
 3 files changed, 44 deletions(-)

d8768e55070eb92eddb69ab8136ded02cc4ef9d0 foobar
diff --git a/include/net/irda/irlan_eth.h b/include/net/irda/irlan_eth.h
index 0062347..de5c816 100644
--- a/include/net/irda/irlan_eth.h
+++ b/include/net/irda/irlan_eth.h
@@ -29,5 +29,4 @@ struct net_device *alloc_irlandev(const char *name);
 int  irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb);
 
 void irlan_eth_flow_indication( void *instance, void *sap, LOCAL_FLOW flow);
-void irlan_eth_send_gratuitous_arp(struct net_device *dev);
 #endif
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index a4b56e2..c31cb55 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -54,13 +54,6 @@
 #include <net/irda/irlan_filter.h>
 
 
-/*
- * Send gratuitous ARP when connected to a new AP or not. May be a clever
- * thing to do, but for some reason the machine crashes if you use DHCP. So
- * lets not use it by default.
- */
-#undef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
-
 /* extern char sysctl_devname[]; */
 
 /*
@@ -395,9 +388,6 @@ static void irlan_connect_confirm(void *instance, void *sap,
 	/* Ready to transfer Ethernet frames */
 	netif_start_queue(self->dev);
 	self->disconnect_reason = 0; /* Clear reason */
-#ifdef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
-	irlan_eth_send_gratuitous_arp(&self->dev);
-#endif
 	wake_up_interruptible(&self->open_wait);
 }
 
diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 1ab91f7..ef12ef1 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -289,39 +289,6 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 }
 
 /*
- * Function irlan_etc_send_gratuitous_arp (dev)
- *
- *    Send gratuitous ARP to announce that we have changed
- *    hardware address, so that all peers updates their ARP tables
- */
-void irlan_eth_send_gratuitous_arp(struct net_device *dev)
-{
-#ifdef CONFIG_INET
-	struct in_device *in_dev;
-
-	/*
-	 * When we get a new MAC address do a gratuitous ARP. This
-	 * is useful if we have changed access points on the same
-	 * subnet.
-	 */
-	IRDA_DEBUG(4, "IrLAN: Sending gratuitous ARP\n");
-	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
-	if (in_dev == NULL)
-		goto out;
-	if (in_dev->ifa_list)
-
-	arp_send(ARPOP_REQUEST, ETH_P_ARP,
-		 in_dev->ifa_list->ifa_address,
-		 dev,
-		 in_dev->ifa_list->ifa_address,
-		 NULL, dev->dev_addr, NULL);
-out:
-	rcu_read_unlock();
-#endif /* CONFIG_INET */
-}
-
-/*
  * Function set_multicast_list (dev)
  *
  *    Configure the filtering of the device

