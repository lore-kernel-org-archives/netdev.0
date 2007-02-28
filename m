From: John <linux.kernel@free.fr>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Wed, 28 Feb 2007 15:23:30 +0100
Message-ID: <45E59062.6000103@free.fr>
References: <45E5570E.7050301@free.fr> <45E585AD.8050704@free.fr> <200702281455.27720.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	linux.kernel@free.fr
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <200702281455.27720.dada1@cosmosbay.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

>> John wrote:
>> 
>>> I know it's possible to have Linux timestamp incoming datagrams as soon
>>> as they are received, then for one to retrieve this timestamp later with
>>> an ioctl command or a recvmsg call.
>> Has it ever been proposed to modify struct skb_timeval to hold
>> nanosecond stamps instead of just microsecond stamps? Then make the
>> improved precision somehow available to user space.
> 
> Most modern NICS are able to delay packet delivery, in order to reduce number 
> of interrupts and benefit from better cache hits.

You are referring to NAPI interrupt mitigation, right?

AFAIU, it is possible to disable this feature.

I'm dealing with 200-4000 packets per second. I don't think I'd save 
much with interrupt mitigation. Please correct any misconception.

> Then kernel is not realtime and some delays can occur between the hardware 
> interrupt and the very moment we timestamp the packet. If CPU caches are 
> cold, even the instruction fetches could easily add some us.

I've applied the real-time patch.
http://rt.wiki.kernel.org/index.php/Main_Page
This doesn't make Linux hard real-time, but the interrupt handlers can 
run with the highest priority (even kernel threads are preempted).

> Enabling nanosecond stamps would be a lie to users, because real accuracy is 
> not nanosecond, but in the order of 10 us (at least)

POSIX is moving to nanoseconds interfaces.
http://www.opengroup.org/onlinepubs/009695399/functions/clock_settime.html

struct timeval and struct timespec take as much space (64 bits).

If the hardware can indeed manage sub-microsecond accuracy, a struct 
timeval forces the kernel to discard valuable information.

> If you depend on a < 50 us precision, then linux might be the wrong OS for 
> your application. Or maybe you need a NIC that is able to provide a timestamp 
> in the packet itself (well... along with the packet...) , so that kernel 
> latencies are not a problem.

Does Linux support NICs that can do that?

Regards.
