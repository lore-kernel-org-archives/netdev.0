From: Markus Stenberg <markus.stenberg@iki.fi>
Subject: IPv6 routing type - not at par with IPv4 one?
Date: Thu, 6 Sep 2012 10:02:47 +0000 (UTC)
Message-ID: <loom.20120906T115737-277@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36281 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755358Ab2IFKKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 06:10:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T9Z2B-0001Mt-Hf
	for netdev@vger.kernel.org; Thu, 06 Sep 2012 12:10:03 +0200
Received: from dsl-hkibrasgw4-fe5cf800-61.dhcp.inet.fi ([84.248.92.61])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 12:10:03 +0200
Received: from markus.stenberg by dsl-hkibrasgw4-fe5cf800-61.dhcp.inet.fi with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 12:10:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

~ # ip route add throw 1.2.3.4
~ # ip -6 route add throw ::1.2.3.4
RTNETLINK answers: No such device
~ # ip route add blackhole 1.2.3.5
~ # ip -6 route add blackhole ::1.2.3.5
RTNETLINK answers: No such device
~ #

The reason for this is in net/ipv6/route.c - ipv6_route_add:

Eventually code winds up at this (1423 line in 3.5.3):

	err = -ENODEV;
	if (!dev)
		goto out;

and poof, ENODEV.

Is there some reason for this? Or should I write a patch? 
Or does someone else want to? Support for dev=NULL 
elsewhere in the code seems to be ok.

Based on quick googling I'm not the first one to have encountered this.

Cheers,

-Markus
