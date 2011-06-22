From: Harald Welte <laforge@gnumonks.org>
Subject: Remove IPv6 ND prefix on ethernet disconnect?
Date: Wed, 22 Jun 2011 23:41:29 +0200
Message-ID: <20110622214129.GA30521@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58949 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758899Ab1FVVlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 17:41:35 -0400
Received: from uucp by ganesha.gnumonks.org with local-bsmtp (Exim 4.72)
	(envelope-from <laforge@gnumonks.org>)
	id 1QZVB0-0002za-On
	for netdev@vger.kernel.org; Wed, 22 Jun 2011 23:41:34 +0200
Received: from laforge by nataraja.de.gnumonks.org with local (Exim 4.76)
	(envelope-from <laforge@gnumonks.org>)
	id 1QZVAv-0007x1-Dn
	for netdev@vger.kernel.org; Wed, 22 Jun 2011 23:41:29 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I know I've lost a bit touch with the Linux networking area in recent
years...

Nonetheless, there's one thing that's been bugging me for a long time
and I'm thinking of investing some time to resolve it.  Before doing
that, I'm curious to see if there are existing solutions or existing
discussions that I've missed on the subject:

Imagine a setting where somebody is carrying a laptop around all day,
visiting several sites (office, customer, home,...) without rebooting
the machine (suspend to ram or disk).

You start at home in the morning, you get an IPv6 prefix via
auto-discovery, everything is fine.  Now you move along to your office,
but despite the link down and link up events, the IPv6 prefix remains
configured.

You may or may not get a new prefix, but based on my experience, in both
cases you experience errors following up:
1) in the case of the new prefix, the old default route/prefix is still
   used
2) in case there is no new prefix, the kernel happily sends ipv6 packets
   to the non-existant router of a completely different network.

Now I presume that those things are supposedly resolved by
NetworkManager, but I don't really see why a complex and large userspace
program should be required for something as simple as removing prefixes
that have prevously been added automatically.

My point is: If it's the kernel that automatically adds it, why is it
not the kernel that automatically deletes it when it is no longer safe
to assume it is valid (such as after loosing the link)?

Any input is appreciated. Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
