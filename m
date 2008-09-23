From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: dhcp/bonding interaction question
Date: Tue, 23 Sep 2008 11:17:14 -0700
Message-ID: <21694.1222193834@death.nxdomain.ibm.com>
References: <48D90A30.8000701@nortel.com> <6323.1222188151@death.nxdomain.ibm.com> <48D924A5.4070701@nortel.com>
Cc: netdev@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46769 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbYIWSSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 14:18:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8NIIanS006828
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 14:18:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8NIHKjm234526
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 14:17:20 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8NIHJm2001446
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 14:17:19 -0400
In-reply-to: <48D924A5.4070701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <cfriesen@nortel.com> wrote:

>Jay Vosburgh wrote:
>> Chris Friesen <cfriesen@nortel.com> wrote:
[...]
>Yes, the dhcp code in the kernel does this.

	Ah, I didn't know that.

>> 	I'm guessing your problem is really due to the nature of the
>> intra-chassis network on the blade system.  If it's like the ones I'm
>> familiar with (eth0 of all blades to a single switch, eth1 of all blades
>> to a different switch, etc), then you can't configure the switches into
>> an etherchannel group as can be done with the usual configuration
>> (multiple ports on one switch).
>
>This has been handled already.  The two switches are a single etherchannel
>group and all blades (except the booting one) have etherchannel enabled.

	Ok, so your problem (if I'm understanding things correctly) is
really a chicken-and-egg type of deal.  Your entire network is all
etherchannel, except for this blade, which needs to connect,
temporarily, in a non-etherchannel manner in order to boot up and become
etherchannel-ified (at which point it'll work).

	One possible problem with hacking the dhcpd to send back out on
the receiving interface is that (because of the etherchannel) there's no
general guarantee that the switch paths are symmetrical, particularly if
a port is down somewhere.

>That's not a problem.  We've got an older version, but support for
>querying which slave a packet arrived on has been added.

	If you're already rolling your own kernels, would it be easier
to remove the xid interface check from the kernel's dhcp client (i.e.,
accept the DHCP reply as if it had arrived on the proper interface for
its xid)?  You could make it into some kind of "netboot_on_etherchannel"
option.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
