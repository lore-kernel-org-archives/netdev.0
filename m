From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net] gre: allow live address change
Date: Sat, 27 Dec 2014 10:01:42 -0800
Message-ID: <20141227100142.13b7ed79@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:3675 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbaL0SSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:18:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GRE tap device supports Ethernet over GRE, but doesn't
care about the source address of the tunnel, therefore it
can be changed without bring device down.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/ip_gre.c	2014-12-27 09:43:49.070032631 -0800
+++ b/net/ipv4/ip_gre.c	2014-12-27 09:43:49.066032607 -0800
@@ -673,6 +673,7 @@ static bool ipgre_netlink_encap_parms(st
 static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	return ip_tunnel_init(dev);
 }
