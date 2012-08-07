From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Mon, 06 Aug 2012 17:44:06 -0700
Message-ID: <87obmnfs4p.fsf@xmission.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il, dledford@redhat.com
To: Ali Ayoub <ali@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57655 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879Ab2HGAoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 20:44:18 -0400
In-Reply-To: <50205DE0.7080706@mellanox.com> (Ali Ayoub's message of "Mon, 06
	Aug 2012 17:14:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ali Ayoub <ali@mellanox.com> writes:

> Among other things, the main benefit we're targeting is to allow IPoE
> traffic within the VM to go through the (Ethernet) vBridge down to the
> eIPoIB PIF, and eventually to IPoIB and to the IB network.

That works today without code changes.  It is called routing.

> In Para virtualized environment, the VM emulator sends/receives packets
> with Ethernet header, and the vBridge also performs L2 switching based
> on the Ethernet header, in addition to other tools that expect an
> Ethernet link layer. We'd like to support them on top of IPoIB.

See routing.  The code is already done.

> I don't see in other alternatives a solution for the problem we're
> trying to solve. If there are changes/suggestions to improve eIPoIB
> netdev driver to avoid "messing with the link layer" and make it
> acceptable, we can discuss and apply them.

Nothing needs to be applied the code is done.  Routing from
IPoE to IPoIB works.

There is nothing in what anyone has posted as requirements that needs
work to implement.

I totally fail to see how getting packets of of the VM as ethernet
frames, and then  IP layer routing those packets over IP is not an
option.  What requirement am I missing.

All VMs should suport that mode of operation, and certainly the kernel
does.

Implementations involving bridges like macvlan and macvtap are
performance optimizations, and the optimizations don't even apply in
areas like 802.11, where only one mac address is supported per adapter.

Bridging can ocassionally also be an administrative simplification as
well, but you should be able to achieve the a similar simplification
with a dhcprelay and proxy arp.

Eric
