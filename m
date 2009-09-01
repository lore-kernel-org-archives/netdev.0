From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 17/19] appletalk: convert drivers to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:56 -0700
Message-ID: <20090901055130.153665447@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57489 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbZIAF7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:59:10 -0400
Content-Disposition: inline; filename=appletalk.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/appletalk/cops.c  |    6 ++++--
 drivers/net/appletalk/ipddp.c |    5 +++--
 drivers/net/appletalk/ltpc.c  |    4 ++--
 3 files changed, 9 insertions(+), 6 deletions(-)

--- a/drivers/net/appletalk/cops.c	2009-08-31 16:17:52.391107008 -0700
+++ b/drivers/net/appletalk/cops.c	2009-08-31 16:32:13.773591856 -0700
@@ -192,7 +192,8 @@ static irqreturn_t cops_interrupt (int i
 static void cops_poll (unsigned long ltdev);
 static void cops_timeout(struct net_device *dev);
 static void cops_rx (struct net_device *dev);
-static int  cops_send_packet (struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t  cops_send_packet (struct sk_buff *skb,
+					    struct net_device *dev);
 static void set_multicast_list (struct net_device *dev);
 static int  cops_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static int  cops_close (struct net_device *dev);
@@ -875,7 +876,8 @@ static void cops_timeout(struct net_devi
  *	Make the card transmit a LocalTalk packet.
  */
 
-static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t cops_send_packet(struct sk_buff *skb,
+					  struct net_device *dev)
 {
         struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
--- a/drivers/net/appletalk/ipddp.c	2009-08-31 16:17:52.381081851 -0700
+++ b/drivers/net/appletalk/ipddp.c	2009-08-31 16:32:13.783628327 -0700
@@ -48,7 +48,8 @@ static int ipddp_mode = IPDDP_DECAP;
 #endif
 
 /* Index to functions, as function prototypes. */
-static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ipddp_xmit(struct sk_buff *skb,
+				    struct net_device *dev);
 static int ipddp_create(struct ipddp_route *new_rt);
 static int ipddp_delete(struct ipddp_route *rt);
 static struct ipddp_route* __ipddp_find_route(struct ipddp_route *rt);
@@ -113,7 +114,7 @@ static struct net_device * __init ipddp_
 /*
  * Transmit LLAP/ELAP frame using aarp_send_ddp.
  */
-static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	__be32 paddr = skb_rtable(skb)->rt_gateway;
         struct ddpehdr *ddp;
--- a/drivers/net/appletalk/ltpc.c	2009-08-31 16:17:52.381081851 -0700
+++ b/drivers/net/appletalk/ltpc.c	2009-08-31 16:32:13.783628327 -0700
@@ -697,7 +697,7 @@ static int do_read(struct net_device *de
 
 static struct timer_list ltpc_timer;
 
-static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev);
+static netdev_tx_t ltpc_xmit(struct sk_buff *skb, struct net_device *dev);
 
 static int read_30 ( struct net_device *dev)
 {
@@ -895,7 +895,7 @@ static void ltpc_poll(unsigned long l)
 
 /* DDP to LLAP translation */
 
-static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	/* in kernel 1.3.xx, on entry skb->data points to ddp header,
 	 * and skb->len is the length of the ddp data + ddp header

-- 

