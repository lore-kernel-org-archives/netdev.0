From: Ben Greear <greearb@candelatech.com>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 11:35:47 -0800
Message-ID: <4755AC13.1060904@candelatech.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>	<20071201163035.321fd554@freepuppy.rosehill> <475227B1.2060802@rtr.ca>	<20071201202354.672aed18@freepuppy.rosehill>	<47530778.7030605@candelatech.com> <47530FAC.1070804@trash.net>	<m1fxyj1y1y.fsf@ebiederm.dsl.xmission.com>	<47544896.7070101@candelatech.com> <475451B1.1030006@free.fr>	<m163zexrqi.fsf@ebiederm.dsl.xmission.com>	<4755A025.8090903@candelatech.com> <m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, containers@lists.osdl.org,
	Mark Lord <lkml@rtr.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45486 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbXLDTgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 14:36:33 -0500
In-Reply-To: <m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
> 
>> Eric W. Biederman wrote:
>>> However there also seem to be simpler cases like Ben's bridge module,
>>> that don't appear to have any global state.
>>>
>> Well, my module has some global state, but I don't think it needs to care about
>> namespaces.  My first impression is that my module should be able to bridge
>> namespaces...not be contained within one.  I can have user-space make sure that
>> I don't bridge between
>> devices in different name-spaces, or perhaps bridging between namespaces
>> wouldn't be a problem anyway. 
> 
> Bridging between namespaces should not be a problem, but it could be
> a bit of a challenge to setup (in finding the network devices).
> Probably the easy way is to setup the bridging and then move one of the
> network devices to the other network namespace.
> 
> Essentially bridging between two network devices in two network
> namespaces looks like bridging between two network devices on two
> separate network stacks.   Although internally things look a little
> better.

Ok, that sounds fine.

>> Currently I use procfs and ioctls bound to a procfs file descriptor.
> 
> Which is where it gets tricky   You are defining new userspace ABIs.
> I can see where they occasionally make sense during development
> and prototyping but long term out of tree userspace interfaces appear
> to me to be a real maintenance problem.

They are completely contained within my module, and no one is going
to change my module w/out me knowing, so actually I have very little
problem here :)

>> For namespaces in general, will there be a way to just do a dev_get_by_* and
>> find the
>> device in *any* namespace and query the device to see what namespace it is in?
>> Then my module or some other more clever piece of code can determine the
>> namespaces
>> (by comparing pointers if nothing else) and make proper decision.  For instance,
>> maybe
>> we want to bridge two namespaces, or maybe we want to forbid that ever
>> happening...
> 
> The issue is that fundamentally all userspace device identifiers can
> be duped between namespaces.  So since there is no unique identifier
> we can not implement a function to do that.

Ok, but can a netdev at least know what namespace it is in?  I don't
need this for my module, but it seems very useful knowledge...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

