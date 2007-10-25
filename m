From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: on the topic of alternate MAC addresses
Date: Thu, 25 Oct 2007 10:14:28 -0600
Message-ID: <m13avz6ujf.fsf@ebiederm.dsl.xmission.com>
References: <20071023.180534.59659315.davem@davemloft.net>
	<471EAD01.5030502@garzik.org>
	<20071023.202210.74747025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:47170 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbXJYQOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 12:14:51 -0400
In-Reply-To: <20071023.202210.74747025.davem@davemloft.net> (David Miller's
	message of "Tue, 23 Oct 2007 20:22:10 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 23 Oct 2007 22:25:05 -0400
>
>> hmmmm.  Using ethtool isn't a big deal, but IMO you probably want more 
>> than just an exported list for the usage you described...  it sounds 
>> like some sort of reservation system should be used, to note which MAC 
>> addresses are [not] in use?
>> 
>> Then a virt client -- or anyone who wants multiple unicast addresses for 
>> whatever reason -- can let other clients to avoid MAC addresses 1, 7, or 
>> 13 (random examples).
>
> I see your point.
>
> However, it's not the virt clients that do this, it's the control
> node (aka: domain 0) which has to manage these things.
>
> It has to manage all of the global hardware resources and allocate
> them out to itself and the clients anyways.
>
> And this is why I think it's sufficient to just publish the list of
> MAC addresses from the driver, and leave the allocation and policy
> to the userland virtualizatin daemon running on the control node.
>
> Let me know if you still disagree.

On the per interface level we know the set of used mac addresses in
the uc_list.

At least at a per interface level we should already have this
information, and this is where we care because duplicates at
that could cause problems.

Duplicate mac addresses across interfaces on the same machine
should generally be a don't care.  Although there may some
cases we don't mind.

Currently drivers like macvlan that care today call
random_ether_addr().  I think it would make sense to convenience
kernel function that picked the next available unicast address
for an interface that was not on the uc_list, (called
random_ether_adder if there was not such address) and called
dev_unicast_add to let the driver receive it and to keep other people
from using it.

Exporting that information with ethtool to handle the strange cases
makes sense.  But it looks like there are easy cases that don't
need that help.

Eric
