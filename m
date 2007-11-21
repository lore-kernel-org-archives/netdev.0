From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IRDA] Compilation for CONFIG_INET=n case
Date: Wed, 21 Nov 2007 19:03:16 +0300
Message-ID: <474456C4.8010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35837 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754660AbXKUQGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 11:06:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found this occasionally. 

The CONFIG_INET=n is hardly ever set, but if it is the 
irlan_eth_send_gratuitous_arp() compilation should produce a 
warning about unused variable in_dev.

Too pedantic? :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index 7f9c854..c682207 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -296,6 +296,7 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
  */
 void irlan_eth_send_gratuitous_arp(struct net_device *dev)
 {
+#ifdef CONFIG_INET
 	struct in_device *in_dev;
 
 	/*
@@ -303,7 +304,6 @@ void irlan_eth_send_gratuitous_arp(struct net_device *dev)
 	 * is useful if we have changed access points on the same
 	 * subnet.
 	 */
-#ifdef CONFIG_INET
 	IRDA_DEBUG(4, "IrLAN: Sending gratuitous ARP\n");
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
