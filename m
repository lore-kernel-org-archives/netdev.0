From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] bonding / ipv6: no addrconf for slaves separately from
 master
Date: Tue, 10 Jul 2007 12:43:04 -0400
Message-ID: <4693B718.7050309@garzik.org>
References: <22567.1184002967@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60215 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043AbXGJQnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:43:07 -0400
In-Reply-To: <22567.1184002967@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	At present, when a device is enslaved to bonding, if ipv6 is
> active then addrconf will be initated on the slave (because it is closed
> then opened during the enslavement processing).  This causes DAD and RS
> packets to be sent from the slave.  These packets in turn can confuse
> switches that perform ipv6 snooping, causing them to incorrectly update
> their forwarding tables (if, e.g., the slave being added is an inactve
> backup that won't be used right away) and direct traffic away from the
> active slave to a backup slave (where the incoming packets will be
> dropped).
> 
> 	This patch alters the behavior so that addrconf will only run on
> the master device itself.  I believe this is logically correct, as it
> prevents slaves from having an IPv6 identity independent from the
> master.  This is consistent with the IPv4 behavior for bonding.
> 
> 	This is accomplished by (a) having bonding set IFF_SLAVE sooner
> in the enslavement processing than currently occurs (before open, not
> after), and (b) having ipv6 addrconf ignore UP and CHANGE events on
> slave devices.
> 
> 	The eql driver also uses the IFF_SLAVE flag.  I inspected eql,
> and I believe this change is reasonable for its usage of IFF_SLAVE, but
> I did not test it.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied


