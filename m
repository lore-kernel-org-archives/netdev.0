From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Thu, 27 Feb 2014 08:42:16 -0800
Message-ID: <530F6AE8.1030307@hp.com>
References: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Sharat Masetty <sharat04@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:58899 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbaB0QmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 11:42:17 -0500
In-Reply-To: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2014 06:00 PM, Sharat Masetty wrote:
> Hi,
>
> We are trying to achieve category 4 data rates on an ARM device.

Please forgive my ignorance, but what are "category 4 data rates?"

> We see that with an incoming TCP stream(IP packets coming in and
> acks going out) lots of packets are getting dropped when the backlog
> queue is full. This is impacting overall data TCP throughput. I am
> trying to understand the full context of why this queue is getting
> full so often.
>
> From my brief look at the code, it looks to me like the user space
> process is slow and busy in pulling the data from the socket buffer,
> therefore the TCP stack is using this backlog queue in the mean time.
> This queue is also charged against the main socket buffer allocation.
>
> Can you please explain this backlog queue, and possibly confirm if my
> understanding this  matter is accurate?
> Also can you suggest any ideas on how to mitigate these drops?

Well, there is always the question of why the user process is slow 
pulling the data out of the socket.  If it is unable to handle this 
"category 4 data rate" on a sustained basis, then something has got to 
give.  If it is only *sometimes* unable to keep-up but otherwise is able 
to go as fast and faster (to be able to clear-out a backlog) then you 
could consider tweaking the size of the queue.  But it would be better 
still to find the cause of the occasional slowness and address it.

If you run something which does no processing on the data (eg netperf) 
are you able to achieve the data rates you seek?  At what level of CPU 
utilization?  From a system you know can generate the desired data rate, 
something like:

netperf -H <yourARMsystem> -t TCP_STREAM -C  -- -m <what your 
application sends each time>

If the ARM system is multi-core, I might go with

netperf -H <yourARMsystem> -t TCP_STREAM -C  -- -m <sendsize> -o 
throughput,remote_cpu_util,remote_cpu_peak_util,remote_cpu_peak_id,remote_sd

so netperf will tell you the ID and utilization of the most utilized CPU 
on the receiver in addition to the overall CPU utilization.

There might be other netperf options to use depending on just what the 
sender is doing - to know which would require knowing more about this 
stream of traffic.

happy benchmarking,

rick jones
