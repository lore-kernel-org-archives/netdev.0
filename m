From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: dhcp/bonding interaction question
Date: Tue, 23 Sep 2008 11:17:25 -0600
Message-ID: <48D924A5.4070701@nortel.com>
References: <48D90A30.8000701@nortel.com> <6323.1222188151@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:58034 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbYIWRRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 13:17:43 -0400
In-Reply-To: <6323.1222188151@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:
> 
>> On the
>> booting blade the xid in the packet doesn't match the xid for the device
>> on which the packet was received, so the packet is dropped.
> 
> 	Presumably the blade is matching xid on a per-interface basis.

Yes, the dhcp code in the kernel does this.

> 	I'm guessing your problem is really due to the nature of the
> intra-chassis network on the blade system.  If it's like the ones I'm
> familiar with (eth0 of all blades to a single switch, eth1 of all blades
> to a different switch, etc), then you can't configure the switches into
> an etherchannel group as can be done with the usual configuration
> (multiple ports on one switch).

This has been handled already.  The two switches are a single 
etherchannel group and all blades (except the booting one) have 
etherchannel enabled.

>> What's the proper solution here?  Should dhcpd be forcing reply packets
>> out the slave on which the packet was received?
> 
> 	Why is the blade issuing DHCP before the bond is configured?

The blade is net-booting.  The BIOS does DHCP to download the kernel, 
and this works.  The kernel comes up and does DHCP to obtain an IP 
address so it can download the boot image, and this fails as described.

The etherchannel/bond link isn't set up until userspace is loaded and 
the bonding driver is insmodded (under multiple aliases with different 
sets of slaves).

> I'm unsure as to whether dhcpd should force replies as suggested, but
> recent changes to bonding/net core would probably permit dhcpd to run
> directly on the slave (it might need tweaking, I'm not sure) and
> accomplish that result. I don't think it would work on older versions
> of bonding, since there's no way to tell which slave a packet arrived
> on.

That's not a problem.  We've got an older version, but support for 
querying which slave a packet arrived on has been added.

Chris
