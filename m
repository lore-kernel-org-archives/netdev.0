From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 07:40:31 -0600
Message-ID: <m1647bxs1c.fsf@ebiederm.dsl.xmission.com>
References: <46386DFB.7090109@sw.ru> <46388562.9050305@trash.net>
	<1178110192.4074.55.camel@localhost> <46388B19.70300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Pavel Emelianov <xemul@sw.ru>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@sw.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35001 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993196AbXEBNws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 09:52:48 -0400
In-Reply-To: <46388B19.70300@trash.net> (Patrick McHardy's message of "Wed, 02
	May 2007 14:59:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> jamal wrote:
>> On Wed, 2007-02-05 at 14:34 +0200, Patrick McHardy wrote:
>> 
>> 
>>>Thats a lot better than using sysfs, but I think it would be
>>>preferrable to use rtnetlink instead of genetlink for network
>>>configuration.
>> 
>> 
>> or you can just hold rtnl while using genl.
>> I do agree it would be easier to just use rtnetlink ...
>
>
> The rtnl needs to be held in either case, but using a different
> netlink family introduces races in message processing. For example
> a simple:
>
> ip link add dev veth0
> ip route add 10.0.0.0/8 dev veth0
>
> might fail because we have two different input queues and the routing
> message might get processed before the link message.

The consensus from the last thread was pretty much that we need
to implement RTM_NEWLINK and RTM_DELLINK, if it is at all possible.

So that we can get code reuse between different virtual devices.
Although I suspect we will need some per type attribute parsing.

Eric
