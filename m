From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Mon, 16 Dec 2013 16:32:15 +0100
Message-ID: <52AF1CFF.7040004@linux.vnet.ibm.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com> <20131211121357.4742d9e8@nehalam.linuxnetplumber.net> <52A9C0BE.5090801@linux.vnet.ibm.com> <20131212.122801.1249371766101769652.davem@davemloft.net> <52A9F7CD.5050904@intel.com> <CAGVrzcb47oUAn-5S=DpQkgPbMAwmBrfjUmfJroYiYX8mmRuORg@mail.gmail.com> <52AA2EF4.70300@intel.com>
Reply-To: raspl@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	blaschka@linux.vnet.ibm.com, netdev <netdev@vger.kernel.org>,
	linux-s390@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:38352 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489Ab3LPPcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:32:24 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Mon, 16 Dec 2013 15:32:22 -0000
In-Reply-To: <52AA2EF4.70300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 12.12.2013 22:47, schrieb John Fastabend:
> [...]
> 
>>> Just to elaborate...
>>>
>>> Any application using lldp information will want to get events when
>>> TLVs change. Maybe you can contrive ethtool to do this but its
>>> going to
>>> be ugly. Netlink can support multicast events and applications can
>>> register for them. Also netlink's TLV format matches nicely with
>>> LLDPs
>>> TLV format.
>>
>> ethtool and netlink usually intersect for a few bits of information
>> such as link status for instance. It is useful to have this
>> information twice, with ethtool as a debugging aid, and via
>> netlink to
>> take appropriate actions.
>>
>> Maybe we just need to be clear on what needs to be present in ethtool
>> only (configuration, static information) and see on a case-by-case
>> what needs to be present in both ethtool and netlink?
>>
> 
> OK if there is an enable/disable bit in ethtool that might make some
> sense. Or an error flag that is helpful to have.
> 
> In this case we are dealing with peer attributes which are dynamic and
> in my opinion should go into netlink and duplicating them in ethtool
> although possible doesn't seem very useful to me.

I think what most folks in the discussion so far assume is that we
have a full LLDP implementation with respective hooks and events.
This is not true for our device: We can only poll it for the
adjacent link port's state, and that's it. I.e. we don't receive any
events for changes on the port's state.
lldpad seems to handle the entire LLDP layer in software. And I'm
not sure if our device integrates with that so well, as it handles
LLDP on its own. We'd have to disable pretty much all functionality
that lldpad offers, and limit support to display of a few parameters
which we would have to poll on demand.
Likewise with netlink: If one of the arguments for netlink is that
it supports notifications, then we can't take any advantage of that
either, for the reasons stated above.
By its nature, what we can offer and support with our device is
simple debugging functionality, displaying the current state of the
switch port at a given moment - just like ethtool will display the
current port speed and media type. Hence the original idea to add
respective functionality to ethtool in a generic manner, so others
with similar constraints could use it as well.
If ethtool is not acceptable, and if lldpad and netlink are no good
fits either, would respective sysfs attributes for our device type work?

Stefan
