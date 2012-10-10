From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 6/8] vxlan: add additional headroom
Date: Tue, 09 Oct 2012 23:35:51 -0700
Message-ID: <20121010063623.783001791@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52293 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686Ab2JJGjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:23 -0400
Content-Disposition: inline; filename=vxlan-more-headroom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tell upper layer protocols to allocate skb with additional headroom.
This avoids allocation and copy in local packet sends.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-10-09 18:08:35.086431755 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:36.862414133 -0700
@@ -983,6 +983,7 @@ static void vxlan_setup(struct net_devic
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
+	dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = vxlan_free;
