From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device
Date: Wed, 26 Mar 2008 06:44:40 +0100
Message-ID: <47E9E2C8.8070609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090105050209010901030401"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:41096 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbYCZFop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 01:44:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090105050209010901030401
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------090105050209010901030401
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 23309e2679f45ffd6406a269310742a05eabfd99
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 26 06:29:07 2008 +0100

    [VLAN]: Don't copy ALLMULTI/PROMISC flags from underlying device

    Changing these flags requires to use dev_set_allmulti/dev_set_promiscuity
    or dev_change_flags. Setting it directly causes two unwanted effects:

    - the next dev_change_flags call will notice a difference between
      dev->gflags and the actual flags, enable promisc/allmulti
      mode and incorrectly update dev->gflags

    - this keeps the underlying device in promisc/allmulti mode until
      the VLAN device is deleted

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1e5c990..cd573b3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -660,7 +660,7 @@ static int vlan_dev_init(struct net_device *dev)
 	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	dev->flags  = real_dev->flags & ~IFF_UP;
+	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI);
 	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |

--------------090105050209010901030401--
