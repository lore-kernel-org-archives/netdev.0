From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 13:30:49 -0800
Message-ID: <52A78809.4020103@hp.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com> <CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com> <52A749CB.1010909@hp.com> <52A74E32.4040900@hp.com> <CAGA2gK7tjQZ6sq1qqTua_J0uY47Dq7h-vWR=c_LQReq3Rwc=_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: ajay seshadri <seshajay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:26130 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3LJVau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 16:30:50 -0500
In-Reply-To: <CAGA2gK7tjQZ6sq1qqTua_J0uY47Dq7h-vWR=c_LQReq3Rwc=_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2013 11:32 AM, ajay seshadri wrote:
> On Tue, Dec 10, 2013 at 12:24 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>> If you want to compare the "fundamental" path length difference between
>>> IPv4 and IPv6, without any concerns about stateless offloads like CKO or
>>> GRO et al, you could use something like a single-byte netperf TCP_RR test.
>>>
>>> netperf -c -C -H <remote> -t TCP_RR
>>
>> Or UDP_RR, since that is your usage case...
>
> I am not sure what you mean by '"fundamental" path length difference',
> can you please elaborate.

I mean how many instructions/cycles it takes to send/receive a single 
packet, where all the costs are the per-packet costs and the per-byte 
costs are kept at a minimum.  And also where the stateless offloads 
won't matter.  That way whether a stateless offload is enabled for one 
protocol or another is essentially a don't care.

When I talk about a per-byte cost that is usually something like 
computing the checksum, or copying data to/from the kernel.

A per-packet cost would be going up/down the protocol stack.  TSO, GSO, 
UFO, and their receive side analogues would be things that reduced 
per-packet costs, but only when one is sending a lot of data at one time.

So, single-byte _RR since it is sending only one byte at a time will 
effectively "bypass" the offloads.  I use it as something of a proxy for 
those things that aren't blasting great quantities of data.

> For now i use:
> ./netperf -t UDP_STREAM -H <remote> -l 60 -- -m 1450
> I am trying to find the maximum throughput I can get at 1500 MTU for
> UDP packets (IPv4 / IPv6) without using offloading.

I presume you are looking at the receive throughput and not the reported 
send side throughput right?

happy benchmarking,

rick jones
