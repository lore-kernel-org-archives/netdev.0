From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] gre: allow changing mac address when device is up
Date: Fri, 6 Jun 2014 08:10:00 -0700
Message-ID: <20140606081000.5029a6f0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:42221 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbaFFPKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:10:03 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so2598253pbb.3
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 08:10:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to require forcing device down on a Ethernet GRE (gretap)
tunnel to change the MAC address.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv4/ip_gre.c	2014-04-23 18:38:21.908598483 -0700
+++ b/net/ipv4/ip_gre.c	2014-06-05 09:51:19.319503953 -0700
@@ -649,6 +649,7 @@ static void ipgre_tap_setup(struct net_d
 {
 	ether_setup(dev);
 	dev->netdev_ops		= &gre_tap_netdev_ops;
+	dev->priv_flags 	|= IFF_LIVE_ADDR_CHANGE;
 	ip_tunnel_setup(dev, gre_tap_net_id);
 }
 
