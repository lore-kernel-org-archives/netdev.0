From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/19] isdn: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:44 -0700
Message-ID: <20090901055128.866424747@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57452 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbZIAF6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:53 -0400
Content-Disposition: inline; filename=isdn-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/isdn/hysdn/hysdn_net.c |    2 +-
 drivers/isdn/i4l/isdn_net.c    |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

--- a/drivers/isdn/hysdn/hysdn_net.c	2009-08-31 16:17:53.311128475 -0700
+++ b/drivers/isdn/hysdn/hysdn_net.c	2009-08-31 16:26:00.361108706 -0700
@@ -119,7 +119,7 @@ net_close(struct net_device *dev)
 /* send a packet on this interface. */
 /* new style for kernel >= 2.3.33   */
 /************************************/
-static int
+static netdev_tx_t
 net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_local *lp = (struct net_local *) dev;
--- a/drivers/isdn/i4l/isdn_net.c	2009-08-31 16:17:53.301109604 -0700
+++ b/drivers/isdn/i4l/isdn_net.c	2009-08-31 16:26:00.361108706 -0700
@@ -176,7 +176,8 @@ static __inline__ void isdn_net_zero_fra
 /* Prototypes */
 
 static int isdn_net_force_dial_lp(isdn_net_local *);
-static int isdn_net_start_xmit(struct sk_buff *, struct net_device *);
+static netdev_tx_t isdn_net_start_xmit(struct sk_buff *,
+					     struct net_device *);
 
 static void isdn_net_ciscohdlck_connected(isdn_net_local *lp);
 static void isdn_net_ciscohdlck_disconnected(isdn_net_local *lp);
@@ -1160,7 +1161,7 @@ static void isdn_net_tx_timeout(struct n
  * If this interface isn't connected to a ISDN-Channel, find a free channel,
  * and start dialing.
  */
-static int
+static netdev_tx_t
 isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	isdn_net_local *lp = (isdn_net_local *) netdev_priv(ndev);

-- 

