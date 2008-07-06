From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/06]: starfire: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:18 +0200
Message-ID: <48714BB2.9020904@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070105050809030307000401"
Cc: Jeff Garzik <jeff@garzik.org>, ionut@cs.columbia.edu
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42111 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673AbYGFWyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:19 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070105050809030307000401
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------070105050809030307000401
Content-Type: text/x-diff;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

starfire: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c8695f4c66c53182b2b6dc8a848d07e0208edd5d
tree 520848e31ff58269e8486a3116387a21e67f3202
parent 92c22c36d1e18c443bbbe0097c005ebc94e82a4f
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200

 drivers/net/starfire.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 7b7b171..2038f38 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1510,7 +1510,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 			if (debug > 4)
 				printk(KERN_DEBUG "  netdev_rx() vlanid = %d\n", le16_to_cpu(desc->vlanid));
 			/* vlan_netdev_receive_skb() expects a packet with the VLAN tag stripped out */
-			vlan_netdev_receive_skb(skb, np->vlgrp, le16_to_cpu(desc->vlanid) & VLAN_VID_MASK);
+			vlan_netdev_receive_skb(skb, np->vlgrp, le16_to_cpu(desc->vlanid));
 		} else
 #endif /* VLAN_SUPPORT */
 			netdev_receive_skb(skb);


--------------070105050809030307000401--
