From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Intel 82599 ixgbe driver performance
Date: Wed, 10 Aug 2011 13:58:58 -0700
Message-ID: <4E42F112.4020300@hp.com>
References: <4E4222F6.7050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, rizzo@iet.unipi.it
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:33845 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab1HJVA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 17:00:58 -0400
In-Reply-To: <4E4222F6.7050304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2011 11:19 PM, J.Hwan Kim wrote:
> Hi, everyone
>
> I'm testing our network card which includes intel 82599 based on
> ixgbe driver. I wonder what is the Rx performance of i82599 without
> network stack only with 64Byte frames. Our driver reads the packet
> directly from DMA packet buffer and push to the application without
> passing through linux kernel stack. It seems that the intel 82599
> cannot push 64B frames to DMA area in 10G. Is it right?

Does your driver perform a copy of that 64B frame to user space?

Is this a single-threaded test running?

What does an lat_mem_rd -t (-t for random stride) test from lmbench give 
for your system's memory latency?  (Perhaps using numactl to ensure 
local, or remote memory access, as you desire)

At line rate for minimum sized frames over 10 GbE, you have a frame 
arriving every 60-odd nanoseconds. At that speed, you cannot take even 
one cache miss per frame (*) in a single-threaded path and still achieve 
line-rate PPS.

As it happens, there was a presentation at HP Labs recently, given by 
Luigi Rizzo on his netmap work.  The slides can be found at
http://info.iet.unipi.it/~luigi/netmap/talk-hp.html .  As it happens, 
Luigi presented some performance figures using an Intel 82599.

happy benchmarking,

rick jones
(*) much of my time has been spent in a world where a cache miss is 
three digits worth of nanoseconds (to the left of the decimal), 
sometimes high two digits.
