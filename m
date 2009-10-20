From: Guido Trotter <ultrotter@quaqua.net>
Subject: Policy routing + route "via" gives a strange behavior
Date: Tue, 20 Oct 2009 15:28:20 +0200
Message-ID: <20091020132820.GA3159@gg.studio.tixteam.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-146-243.sn2.eutelia.it ([83.211.146.243]:35838 "EHLO
	gg.studio.tixteam.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbZJTNlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 09:41:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I'm seeing what I think might be a strange kernel behavior when setting up a
route "via" a gateway, with policy routing. When adding a route with a gateway,
the kernel accepts it only if the gateway is reachable via that device. For
example:

ip route add default dev eth1 via 192.168.5.254

is only accepted if there is a route like:
192.168.5.0/24 dev eth1 scope link

in the main routing table. which, of course, is ok, otherwise the kernel
wouldn't be able to reach 192.168.5.254 in the first place.

Now, when adding policy routing to the mix, if I do:
ip route add table 100 default dev eth1 via 192.168.5.254

This is also refused unless a route like the one before appears in the default
table, even though it does appear in table 100. Is this the right behavior, and
if yes, why? It seems to me that it should be acceptable to have the network
route as well just in the separate routing table, since the "via" will only be
used by traffic hitting that table anyway.

Thanks a lot,

Guido

