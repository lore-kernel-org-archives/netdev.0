From: Patrick McHardy <kaber@trash.net>
Subject: vlan/macvlan 02/02: propagate transmission state to upper layers
Date: Tue, 10 Nov 2009 17:14:24 +0100
Message-ID: <4AF99160.2060607@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020304010008050301030705"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757091AbZKJQOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:14:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020304010008050301030705
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020304010008050301030705
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 21fb413b55abb4665e057b884c289bb780f41b3c
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Nov 10 16:55:50 2009 +0100

    vlan/macvlan: propagate transmission state to upper layers
    
    Both vlan and macvlan devices usually don't use a qdisc and immediately
    queue packets to the underlying device. Propagate transmission state of
    the underlying device to the upper layers so they can react on congestion
    and/or inform the sending process.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d7dba3f..271aa7e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -202,7 +202,7 @@ static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	} else
 		txq->tx_dropped++;
 
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 790fd55..9159659 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -332,7 +332,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	} else
 		txq->tx_dropped++;
 
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
@@ -358,7 +358,7 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	} else
 		txq->tx_dropped++;
 
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)

--------------020304010008050301030705--
