From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 12:17:57 -0700
Message-ID: <m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>
	<20071201202354.672aed18@freepuppy.rosehill>
	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>
	<m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>
	<47544896.7070101@candelatech.com> <475451B1.1030006@free.fr>
	<m163zexrqi.fsf@ebiederm.dsl.xmission.com>
	<4755A025.8090903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, containers@lists.osdl.org,
	Mark Lord <lkml@rtr.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34847 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbXLDTUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 14:20:03 -0500
In-Reply-To: <4755A025.8090903@candelatech.com> (Ben Greear's message of "Tue,
	04 Dec 2007 10:44:53 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> Eric W. Biederman wrote:
>> However there also seem to be simpler cases like Ben's bridge module,
>> that don't appear to have any global state.
>>
> Well, my module has some global state, but I don't think it needs to care about
> namespaces.  My first impression is that my module should be able to bridge
> namespaces...not be contained within one.  I can have user-space make sure that
> I don't bridge between
> devices in different name-spaces, or perhaps bridging between namespaces
> wouldn't be a problem anyway. 

Bridging between namespaces should not be a problem, but it could be
a bit of a challenge to setup (in finding the network devices).
Probably the easy way is to setup the bridging and then move one of the
network devices to the other network namespace.

Essentially bridging between two network devices in two network
namespaces looks like bridging between two network devices on two
separate network stacks.   Although internally things look a little
better.

> If I *do* need to add some sort of namespace
> awareness to just achieve today's functionality, I don't mind making the
> changes,
> so long as I don't need to change to GPL licensing.  Perhaps at the least you
> can export enough symbols w/out GPL tag to achieve backwards compat with .23
> and previous kernels, or rework dev_get_by_* etc to not need GPL'd namespace
> symbols and just return the device in the default namespace?

IANAL but to me your code sounds like a derivative work of the linux
kernel.  Which implies that if you are distributing your module you
need to change to GPL licensing.  The _GPL tag on EXPORT_SYMBOL does
not change those rules.

>> Ben I don't have a clue how your user space interface works.  My gut
>> feel is that you can likely use sk->sk_net (if your configuration is
>> through a socket), or failing that current->nsproxy->net_ns.  To get
>> the network namespace to look up "eth0" and "eth1".
>>
> Currently I use procfs and ioctls bound to a procfs file descriptor.

Which is where it gets tricky   You are defining new userspace ABIs.
I can see where they occasionally make sense during development
and prototyping but long term out of tree userspace interfaces appear
to me to be a real maintenance problem.

> For namespaces in general, will there be a way to just do a dev_get_by_* and
> find the
> device in *any* namespace and query the device to see what namespace it is in?
> Then my module or some other more clever piece of code can determine the
> namespaces
> (by comparing pointers if nothing else) and make proper decision.  For instance,
> maybe
> we want to bridge two namespaces, or maybe we want to forbid that ever
> happening...

The issue is that fundamentally all userspace device identifiers can
be duped between namespaces.  So since there is no unique identifier
we can not implement a function to do that.

>> This however still begs the question how do we want to handle this
>> so there is a minimum of pain.
>>
>> Since using register_pernet_subsys implies you need your own member
>> in struct net.  I am inclined to leave that with the GPL hint on
>> the EXPORT as you need to be really tight with the system to use that.
>>
> I certainly don't want to have to muck with struct net unless you have some way
> to
> register anonymous (and non GPL) subsystems.  I'm guessing you do not want to
> support that....

Well I don't see a license compatible way to have any GPL incompatible
licensed linux kernel code.  Off hand that means code needs to be
licensed under the GPL or BSD without advertising clause.

Does EXPORT_SYMBOL_GPL complain if you have a BSD licensed module?

Eric
