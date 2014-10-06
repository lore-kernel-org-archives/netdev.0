From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Mon, 06 Oct 2014 11:49:25 +0200
Message-ID: <543265A5.8000606@redhat.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006002951.GA24376@breakpoint.cc> <5431EC82.7010305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbaJFJti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 05:49:38 -0400
In-Reply-To: <5431EC82.7010305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On 10/06/2014 03:12 AM, John Fastabend wrote:
> On 10/05/2014 05:29 PM, Florian Westphal wrote:
>> John Fastabend <john.fastabend@gmail.com> wrote:
>>> There is one critical difference when running with these interfaces
>>> vs running without them. In the normal case the af_packet module
>>> uses a standard descriptor format exported by the af_packet user
>>> space headers. In this model because we are working directly with
>>> driver queues the descriptor format maps to the descriptor format
>>> used by the device. User space applications can learn device
>>> information from the socket option PACKET_DEV_DESC_INFO which
>>> should provide enough details to extrapulate the descriptor formats.
>>> Although this adds some complexity to user space it removes the
>>> requirement to copy descriptor fields around.
>>
>> I find it very disappointing that we seem to have to expose such
>> hardware specific details to userspace via hw-independent interface.
>
> Well it was only for convenience if it doesn't fit as a socket
> option we can remove it. We can look up the device using the netdev
> name from the bind call. I see your point though so if there is
> consensus that this is not needed that is fine.
>
>> How big of a cost are we talking about when you say that it 'removes
>> the requirement to copy descriptor fields'?
>
> This was likely a poor description. If you want to let user space
> poll on the ring (without using system calls or interrupts) then
> I don't see how you can _not_ expose the ring directly complete with
> the vendor descriptor formats.

But how big is the concrete performance degradation you're seeing if you
use an e.g. `netmap-alike` Linux-own variant as a hw-neutral interface
that does *not* directly expose hw descriptor formats to user space?

With 1 core netmap does 10G line-rate on 64b; I don't know their numbers
on 40G when run on decent hardware though.

It would really be great if we have something vendor neutral exposed as
a stable ABI and could leverage emerging infrastructure we already have
in the kernel such as eBPF and recent qdisc batching for raw sockets
instead of reinventing the wheels. (Don't get me wrong, I would love to
see AF_PACKET improved ...)

Thanks,
Daniel
