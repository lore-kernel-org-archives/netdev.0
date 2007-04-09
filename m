From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 13:35:11 -0600
Message-ID: <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	<1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	<20070409.114402.45491411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, akpm@linux-foundation.org, dim@openvz.org,
	netdev@vger.kernel.org, johannes@sipsolutions.net,
	jgarzik@pobox.com, containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39623 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460AbXDITjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 15:39:17 -0400
In-Reply-To: <20070409.114402.45491411.davem@davemloft.net> (David Miller's
	message of "Mon, 09 Apr 2007 11:44:02 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 09 Apr 2007 18:58:13 +0200
>
>> It would be nice if someone would finally come up with a generic
>> interface based on netlink (RTM_NEWLINK) instead of adding yet
>> another couple of homegrown interfaces.
>
> I absolutely agree, using these ioctls and sysfs/procfs crap
> is totally insane given that we have a core mechanism for
> network configuration.

The core mechanism for network configuration does not support creating
virtual devices in a extensible reusable way.

In particular the tunnel types supported by iproute2 are hard coded
into the user space tool and into the kernel interface.  The interface
seems to be not the least bit extensible for creating new types of 
non hardware backed network devices.

So I don't see a readily usable mechanism for network configuration in
netlink.  The fact that netlink it uses unreliable packets and an
asynchronous interface just adds to the difficulty in making use of
it.

Nor have I seen a rigorous adherence to all new network configuration
using netlink.  The wireless code doesn't even seem to really try.

So I don't believe anyone has found a good maintainable, unix
compatible configuration mechanism for maintaining anything yet.


Regardless I really don't care what the interface is as long as people
agree and I don't have to rewrite significant portions of user space
to allow people to use it.

Since whatever user space interface we pick we will be stuck with
we might as well review it as closely as we can and figure out what
we can live with.


Just to be contrary I'm tempted to add a sysctl interface.  No one has
even mentioned class of user space interfaces yet.

Eric
