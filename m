From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: Re: netlink NETLINK_ROUTE failure & Can the kernel really handle
 IPv6 properly
Date: Mon, 6 Oct 2014 13:25:16 +0200
Message-ID: <54327C1C.7060808@ericsson.com>
References: <9330C415-574C-492B-A7AE-92EBCF6D1A26@emagii.com>	<1412264648.7227.9.camel@dcbw.local>	<542E576B.50708@ericsson.com> <20141003.114949.826855678619123407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dcbw@redhat.com>, <netdev@emagii.com>,
	<hannes@stressinduktion.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:64994 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbaJFLZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:25:26 -0400
In-Reply-To: <20141003.114949.826855678619123407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 08:49 PM, David Miller wrote:
> From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
> Date: Fri, 3 Oct 2014 09:59:39 +0200
>
>> The kernel module is a control module which collects information
>> both from the kernel and from H/W, and talks to a userspace interface
>> manager.
>>
>> There is a proprietary management application which is used to
>> configure the stack.
>> This talks to the interface manager to handle different operations for
>> IPv6.
>>
>> The kernel module needs to know when interfaces are ready to use,
>> I.E: know when it exits "tentative" mode to do its job properly,
>> so the kernel module has to listen for RTM_NEWADDR.
>>
>> In a simpler system, your approach would be OK.
> Sorry, we're not going to help you with a proprietary driver
> of this kind.
>
> They should really just follow our upstream efforts to design
> a usable kernel framework for bridge and routing hardware offloads.

Whether to use a kernel framework or not is not my decision,
and I don't even work with that code.

What should interest the community is that a lot of stuff is probably
not working properly, when IPv6 link-local addresses are used.

Listening for NETDEV_UP, which is used in many places in the kernel, 
seems incorrect,
since connection to the link-local address will fail until the 
link-local address is verified.
It is not immediately obvious, since after 1-2 seconds the problem 
disappears.

For that, listening to the RTM_NEWADDR seems mandatory, so
any framework would benefit from a solution as well.


Best Regards,
Ulf Samuelsson

'
