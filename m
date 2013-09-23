From: Fernando Gont <fernando@gont.com.ar>
Subject: Question on Netlink IPv6 routing table lookup
Date: Mon, 23 Sep 2013 16:41:07 -0300
Message-ID: <52409953.8040208@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:60268 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab3IWToA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

I'm performing IPv6 routing table lookups with a netlink socket, and it
seems that specifying the Source Address with the RTA_SRC element does
not have any effect on the result of the look-up.

In my network setup, I have two interfaces, as follows:

 NET1 (fc00:1::/64) <------> MY_NODE <------> NET2 (fc00:2::/64)

For simplicity sake, let's say that my nodes' address on NET1 is
fc00:1::1, and my node's address on NET2 is fc00:2::1. And my node has
two default routes (one in NET1, and another in NET2).

I'd expect that if I set RTA_SRC to fc00:1::1, the default route on NET1
is selected, but if I set RTA_SRC to fc00:2::1, it is the default route
on NET2 that is selected.

However, the result of the routing tale look-up is always the same,
regardless of RTA_SRC.

I looked at /proc/net/ipv6_route, and it seems that, for all routes, the
"source network" is always set to :: (all zeroes), thus probably
explaining the above behavior.

Is there any way to influence the routing-table look-up based on the
IPv6 source address?

If that's not (currently) possible, should I expect RTA_SRC to work as
described above at some point in the future?
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
