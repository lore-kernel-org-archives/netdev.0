From: Patrick McHardy <kaber@trash.net>
Subject: macvlan: fix gso_max_size setting
Date: Mon, 23 Nov 2009 11:33:06 +0100
Message-ID: <4B0A64E2.8090203@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000200020301090701070202"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36857 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756307AbZKWKdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:33:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000200020301090701070202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix macvlan gso_max_size setting. Based on net-next-2.6.git.


--------------000200020301090701070202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 198a1fd488e7ebec080d1d2da7947cb9e1aacebf
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 23 11:28:22 2009 +0100

    macvlan: fix gso_max_size setting
    
    gso_max_size must be set based on the value of the underlying device to
    support devices not using the full 64k.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index ae2b5c7..7b0ef0c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -376,6 +376,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
+	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
 
@@ -652,6 +653,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
 			vlan->dev->features = dev->features & MACVLAN_FEATURES;
+			vlan->dev->gso_max_size = dev->gso_max_size;
 			netdev_features_change(vlan->dev);
 		}
 		break;

--------------000200020301090701070202--
