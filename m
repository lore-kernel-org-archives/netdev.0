From: Gabriel C <nix.or.die@googlemail.com>
Subject: [PATCH] Fix irlan_eth.c - unused variable 'in_dev' warning
Date: Sun, 22 Jul 2007 18:58:11 +0200
Message-ID: <46A38CA3.9010302@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Dag Brattli <dagb@cs.uit.no>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761407AbXGVRAp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got this warning on current git:

...

net/irda/irlan/irlan_eth.c: In function 'irlan_eth_send_gratuitous_arp':
net/irda/irlan/irlan_eth.c:301: warning: unused variable 'in_dev'

...

This is because CONFIG_INET is not set in my config.


Signed-off-by: Gabriel Craciunescu <nix.or.die@googlemail.com>

---

diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index c421521..ea0b21a 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -298,6 +298,7 @@ void irlan_eth_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
  */
 void irlan_eth_send_gratuitous_arp(struct net_device *dev)
 {
+#ifdef CONFIG_INET
 	struct in_device *in_dev;
 
 	/*
@@ -305,7 +306,6 @@ void irlan_eth_send_gratuitous_arp(struct net_device *dev)
 	 * is useful if we have changed access points on the same
 	 * subnet.
 	 */
-#ifdef CONFIG_INET
 	IRDA_DEBUG(4, "IrLAN: Sending gratuitous ARP\n");
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
