From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing
 too?
Date: Tue, 24 Jul 2012 23:15:59 +0200
Message-ID: <500F108F.6020706@gmail.com>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion> <21683.1343153629@death.nxdomain> <500F032D.3070104@genband.com> <24104.1343162975@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47465 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598Ab2GXVOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:14:52 -0400
Received: by weyx8 with SMTP id x8so16746wey.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 14:14:51 -0700 (PDT)
In-Reply-To: <24104.1343162975@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2012 22:49, Jay Vosburgh a =C3=A9crit :
[...]
>> In loadbalance mode wouldn't it just work similar to active-backup? =
 If
>> it's a reply then verify that it came from the arp target, if it's a
>> request then check to see if it came from one of the other slaves.
>
> 	The problem isn't verifying the requests or replies, it's that
> the ARP packets are not distributed across all slaves (because the
> switch ports are in a channel group / aggregator), so some slaves do =
not
> receive any ARPs.
>
> 	The bond sends the ARP request as a broadcast.  For
> active-backup, this ends up at the inactive slaves because the switch
> sends the broadcast to all ports.  For a loadbalance mode, the switch
> won't send the broadcast ARP to the other slaves, because all the sla=
ves
> are in a channel group or lacp aggregator, which is treated by the
> switch as effectively a single switch port for this case.
>
> 	Similarly, the ARP replies are unicast, and the switch will send
> those unicast replies to only one member of the channel group or
> aggregator.  The choice there is usually a hash of some kind, so
> generally only one slave will receive the replies.

I assume team should suffer the exact same problem, because most of thi=
s is on the switch side and=20
out of the control of the host. Jiri, can you confirm?

[...]

> 	I believe bonding is the main user of last_rx (a search shows a
> couple of drivers using it internally).  For bonding use, in current
> mainline last_rx is set by bonding itself, not in the network device
> driver.

If last_rx is set and used internally by bonding and mostly unused else=
where, can't we remove it=20
from net_device and move it into private data for the slaves in bonding=
?

A comment in netdevice.h even recommends not to set it into drivers:

         unsigned long           last_rx;        /* Time of last Rx
                                                  * This should not be =
set in
                                                  * drivers, unless rea=
lly needed,
                                                  * because network sta=
ck (bonding)
                                                  * use it if/when nece=
ssary, to
                                                  * avoid dirtying this=
 cache line.
                                                  */

	Nicolas.
