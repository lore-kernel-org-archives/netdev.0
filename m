From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Mon, 31 Mar 2008 21:40:51 +0200
Message-ID: <47F13E43.2040404@trash.net>
References: <20080321110515.422f9798@extreme>	<47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34448 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbYCaTk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 15:40:56 -0400
In-Reply-To: <20080331123311.64e4ca37@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 26 Mar 2008 21:19:56 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> Make socket filters work for netlink unicast and notifications.
>>> This is useful for applications like Zebra that get overrun with
>>> messages that are then ignored.
>>>
>>> Note: netlink messages are in host byte order, but packet filter
>>> state machine operations are done as network byte order.
>>
>> Do you have an example for a filter for this? I have a similar
>> patch that adds a new filter instruction for parsing netlink
>> attributes, which seemed necessary for getting at nested
>> attributes without too much trouble.
>>
>> Attached for reference together with a libnl testing
>> patch for ctnetlink.
>>
> 
> Here is the example program:
>    it uses netlink IPC and has one thread send route notifications
>    and the other filters.
> 
>    to test the mulitcast path used a hacked version of ip_monitor from iproute
> 
>    see attachment for the quagga patch.


Thanks. It seems it parses only top-level attributes, which
is probably why you didn't need the nlattr_find command I
used in my patch. The problem with this is that finding and
parsing nested attributes using the existing BPF commands is
complicated since you need to fully parse netlink headers
and walk through them. You can't even reuse that part for
multiple nested attributes since you can't jump backwards.
So I think it would be preferrable to have a simpler method
for this.
