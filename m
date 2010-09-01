From: Anders Franzen <Anders.Franzen@ericsson.com>
Subject: [RFC]: not possible to do policy routing for next hop on tunnels.
Date: Wed, 01 Sep 2010 14:21:25 +0200
Message-ID: <1283343685.14066.24.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:48000 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab0IAMR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 08:17:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If I have multiple routing choices to reach a tunnel end point,
I would like to mark different flows with iptables, after the
postrouting of the primary route look up, this would put an fwmark on
the skb. The route would in my case resolve to an ip6_tunnel.

In the tunnel a secondary route lookup is done to select next hop for
the tunnel end point.

I would like to apply policy routing to the secondary lookup. 

This will not work, for two reasons:

1. None of the tunnels (ipip, gre, ip6_tunnel) I looked at regards the
fwmark at the skb, when performing the route lookup.

2. ip6_tunnel is keeping a local dst cache, so it will never reroute as
long as the current cache is valid.


I wonder if there is a reason for not giving the fwmark at the tunnel
route for tunnels in general?

And the local dst cache for ip6_tunnel, is it needed, is not the routing
subsystem keeping some form of internal cache (ip route ls cache).

Best Regards
  /Anders


 

