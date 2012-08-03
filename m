From: Ali Ayoub <ali@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Fri, 03 Aug 2012 13:31:35 -0700
Message-ID: <501C3527.6060809@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com> <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	Erez Shitrit <erezsh@mellanox.co.il>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mellanox.cgrafx.com ([67.192.191.215]:38799 "EHLO
	mellanox.cgrafx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293Ab2HCUiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 16:38:18 -0400
In-Reply-To: <87boitz044.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2012 10:15 AM, Eric W. Biederman wrote:
> Or Gerlitz <ogerlitz@mellanox.com> writes:
> 
>> From: Erez Shitrit <erezsh@mellanox.co.il>
>>
>> The eipoib driver provides a standard Ethernet netdevice over
>> the InfiniBand IPoIB interface .
>>
>> Some services can run only on top of Ethernet L2 interfaces, and cannot be
>> bound to an IPoIB interface. With this new driver, these services can run
>> seamlessly.
> 
> Do I read this code correctly that what you are doing is not tunneling
> ethernet over IB but instead you are removing an ethernet header and
> replacing it with an IB header?
Correct.
eIPoIB runs standard IPoIB on the wire, thus it doesn't encapsulate the
Ethernet frame on top of IPoIB, but rather translates it to an IPoIB
packet, this allows us to expose an Ethernet L2 network device, and
still keep interoperability with existing IPoIB endpoints. Running full
encapsulation (i.e. EoIPoIB) will break interoperability.

> Do I also read this code correctly if you can't find your destination
> mac address in your ""neighbor table"" you do a normal IPoIB arp
> for the infiniband GUID?
Correct.
Wire protocol remains IPoIB.

> Do I read this right that if presented with a non-IPv4 or ARP packet
> this code will do something undefined and unpredictable?
The current code drops IPv6 packets (see IS_E_IPOIB_PROTO), IPv6 support
will be added later on.

> Maybe this makes some sense but just skimming it looks like you
> are trying to force a square peg into a round hole resulting in
> some weird code and some very weird maintainability issues.
> 
> I am honestly surprised at this approach.  I would think it would be
> faster and simpler to run an IB queue pair directly to the hypervisor or
> possibly even the guest operating system bypassing the kernel and doing
> all of this translation in userspace.
With eIPoIB architecture, the VM sees standard Ethernet emulator,
allowing the administrator to enslave eIPoIB PIF to the vSwitch/vBridge
as if it was standard Ethernet. Other approaches that exposes IB QP to
the VM (with w/o bypassing the kernel) won't be possible with the
current emulators and management tools.

--
Ali;
