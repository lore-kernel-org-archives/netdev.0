From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 11:26:28 -0600
Message-ID: <m14pkya8fv.fsf@ebiederm.dsl.xmission.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>
	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42989 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618AbXFWR1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 13:27:34 -0400
In-Reply-To: <467D3A48.20706@candelatech.com> (Ben Greear's message of "Sat,
	23 Jun 2007 08:20:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Patrick McHardy wrote:
>> Eric W. Biederman wrote:
>>
>>> -- The basic design
>>>
>>> There will be a network namespace structure that holds the global
>>> variables for a network namespace, making those global variables
>>> per network namespace.
>>>
>>> One of those per network namespace global variables will be the
>>> loopback device.  Which means the network namespace a packet resides
>>> in can be found simply by examining the network device or the socket
>>> the packet is traversing.
>>>
>>> Either a pointer to this global structure will be passed into
>>> the functions that need to reference per network namespace variables
>>> or a structure that is already passed in (such as the network device)
>>> will be modified to contain a pointer to the network namespace
>>> structure.
>>>
>>
>>
>> I believe OpenVZ stores the current namespace somewhere global,
>> which avoids passing the namespace around. Couldn't you do this
>> as well?
>>
> Will we be able to have a single application be in multiple name-spaces?

A single application certainly.   But then an application can be composed
of multiple processes which can be composed of multiple threads.

In my current patches a single task_struct belongs to a single network
namespace.  That namespace is used when creating sockets.  The sockets
themselves have a namespace tag and that is used when transmitting
packets, or otherwise operating on the socket.

So if you pass a socket from one process to another you can have
sockets that belong to different network namespaces in a single task.

Eric
