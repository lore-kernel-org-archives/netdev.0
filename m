From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: L2 network namespace benchmarking
Date: Wed, 28 Mar 2007 06:06:19 -0600
Message-ID: <m1k5x1r2ro.fsf@ebiederm.dsl.xmission.com>
References: <460997C2.4030902@fr.ibm.com>
	<m1ircmunre.fsf@ebiederm.dsl.xmission.com> <460A1E06.2050206@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Dmitry Mishin <dim@openvz.org>
To: Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33976 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbXC1MHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 08:07:43 -0400
In-Reply-To: <460A1E06.2050206@sw.ru> (Kirill Korotaev's message of "Wed, 28
	Mar 2007 11:49:26 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev <dev@sw.ru> writes:


>> Ideally we can optimize the bridge code or something equivalent to
>> it so that we can take one look at the destination mac address and
>> know which network namespace we should be in.  Potentially moving this
>> work to hardware when the hardware supports multiple queues.
> yes, we can hack the bridge, so that packets coming out of eth devices
> can go directly to the container and get out of veth devices from
> inside the container.
>
>> If we can get the overhead out of the routing code that would be
>> tremendous.  However I think it may be more realistic to get the
>> overhead out of the ethernet bridging code where we know we don't need
>> to modify the packet.
> Why not optimize both? :)

If the optimizations are safe and correct I don't have a problem.

When we seem to have multiple copies of a packet in circulation and
we skip a what appears to be a required copy on write, I'm dubious.

Although the more I look at suggested optimization the less dubious I
am as it appears all we are skipping is a ttl decrement and the cow
flag exclusively applies to the data chunk and not the header chunk of
the packet whatever that means.

However we still need to guard against a loop in our routing table
setup between multiple guests.

Eric
