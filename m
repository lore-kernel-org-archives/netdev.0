From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Receive issues with bonding and vlans
Date: Thu, 06 May 2010 10:42:30 -0700
Message-ID: <23107.1273167750@death.nxdomain.ibm.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <29849.1271113851@death.nxdomain.ibm.com> <20100412233509.GA32302@cleech-lnx.jf.intel.com> <2695.1271117318@death.nxdomain.ibm.com> <4BDE3D3B.3030800@intel.com> <11804.1272911110@death.nxdomain.ibm.com> <4BDF3D67.3090906@intel.com> <12574.1272928653@death.nxdomain.ibm.com> <4BE103BE.3040805@intel.com>
Cc: "Leech, Christopher" <christopher.leech@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55821 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab0EFRmi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 13:42:38 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o46HbGPD017171
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 13:37:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o46HgY0x2113594
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 13:42:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o46HgXbd021872
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 14:42:34 -0300
In-reply-to: <4BE103BE.3040805@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote:

>Jay Vosburgh wrote:
>> John Fastabend <john.r.fastabend@intel.com> wrote:
[...]
>>> #3 bond0 --> ethx
>>>   vlanx --> -|
>>>
>>> Here is the case where adding the IFF_SLAVE bit doesn't work as I
>>> hoped. We don't want to run skb_bond_should_drop here.
>>
>>         Yes, this is tricky because the VLAN device will copy the
>> dev->flags from the device it's placed atop, so the VLAN will inherit
>> the ethx's IFF_SLAVE flag.  This happens regardless of the setup order
>> (enslave ethX, then add VLAN, or vice versa).
>>
>
>This doesn't appear to be true, adding a VLAN on ethx then enslave ethx
>doesn't set the IFF_SLAVE flag on the VLAN.  Unless I am missing
>something.

	I tried this again, and yes, the vlan device inherits the flags
of the device at the time the vlan is added.

	I think I was confused because the vlan device doesn't lose
IFF_SLAVE if the underlying ethX is taken out of the bond.  I suspect
both of these behaviors are because netdev_set_master doesn't do a
notifier call (just an rtmsg_ifinfo) when it changes dev->flags outside
of dev_set_flags.

	I don't think the vlan device should pick up IFF_SLAVE, though,
when the vlan device itself is not a slave, so that part seems correct.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
