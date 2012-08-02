From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Thu, 02 Aug 2012 10:15:23 -0700
Message-ID: <87boitz044.fsf@xmission.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	<1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, roland@kernel.org, netdev@vger.kernel.org,
	ali@mellanox.com, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:58165 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab2HBRPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 13:15:34 -0400
In-Reply-To: <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> (Or
	Gerlitz's message of "Wed, 1 Aug 2012 20:09:32 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@mellanox.com> writes:

> From: Erez Shitrit <erezsh@mellanox.co.il>
>
> The eipoib driver provides a standard Ethernet netdevice over
> the InfiniBand IPoIB interface .
>
> Some services can run only on top of Ethernet L2 interfaces, and cannot be
> bound to an IPoIB interface. With this new driver, these services can run
> seamlessly.

Do I read this code correctly that what you are doing is not tunneling
ethernet over IB but instead you are removing an ethernet header and
replacing it with an IB header?

Do I also read this code correctly if you can't find your destination
mac address in your ""neighbor table"" you do a normal IPoIB arp
for the infiniband GUID?

Do I read this right that if presented with a non-IPv4 or ARP packet
this code will do something undefined and unpredictable?

Maybe this makes some sense but just skimming it looks like you
are trying to force a square peg into a round hole resulting in
some weird code and some very weird maintainability issues.

I am honestly surprised at this approach.  I would think it would be
faster and simpler to run an IB queue pair directly to the hypervisor or
possibly even the guest operating system bypassing the kernel and doing
all of this translation in userspace.

Eric
