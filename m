From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] vxlan: add additional headroom
Date: Tue, 09 Oct 2012 10:56:42 -0700
Message-ID: <20121009175714.765137515@vyatta.com>
References: <20121009175637.048993312@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:51698 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756611Ab2JISB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:01:29 -0400
Content-Disposition: inline; filename=vxlan-more-headroom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tell upper layer protocols to allocate skb with additional headroom.
This avoids allocation and copy in local packet sends.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxlan.c	2012-10-09 10:49:08.238763697 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 10:49:19.830648777 -0700
@@ -977,6 +977,7 @@ static void vxlan_setup(struct net_devic
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
+	dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = vxlan_free;
