From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/2 v3] ipv4: Cache dst in tunnels
Date: Thu, 02 Jan 2014 13:51:45 -0800
Message-ID: <52C5DF71.3080906@hp.com>
References: <alpine.DEB.2.02.1401021139500.32654@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:7671 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABVvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 16:51:47 -0500
In-Reply-To: <alpine.DEB.2.02.1401021139500.32654@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing that calls for a V4, but a couple of nits and such.

On 01/02/2014 11:48 AM, Tom Herbert wrote:
> Without patches
> 71.22% CPU utilization
> 138/180/244 90/95/99% latencies

The netperf version I have, for which I think I faithfully applied the 
patches from Google for the percentiles is 50, 90 and 99.

raj@tardy:~$ netperf -- -O ? | grep -i laten
RT_LATENCY
MIN_LATENCY
MAX_LATENCY
P50_LATENCY
P90_LATENCY
P99_LATENCY
MEAN_LATENCY
STDDEV_LATENCY

> 1.30465e+06 CPU/tps

That is TPS rather than CPU/TPS I am guessing.

> 18318 CPU/tps

TPS/CPU%

>
> With patches
> 69.84%
> 142/186/249 90/95/99% latencies
> 1.30827e+06
> 18732 CPU/tps

Any idea as to the source of the similarly modest increase in the latencies?

Speaking of which, given the overhead of measuring the individual 
latencies, you might try a pair of runs without them being measured and 
see if you show a larger delta in tps and/or CPU utilization.

raj@tardy:~/netperf2_trunk/src$ ./netperf -i 30,3 -t TCP_RR -- -o 
throughput,p50_latency,p90_latency,p99_latency;  ./netperf -i 30,3 -t 
TCP_RR -- -o throughput
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost.localdomain () port 0 AF_INET : +/-2.500% @ 99% conf.  : 
interval : demo : first burst 0
Throughput,50th Percentile Latency Microseconds,90th Percentile Latency 
Microseconds,99th Percentile Latency Microseconds
46248.37,21,22,28
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to localhost.localdomain () port 0 AF_INET : +/-2.500% @ 99% conf.  : 
interval : demo : first burst 0
Throughput
48098.45

A nitpick from the 1/2 email:

> the tunnel is "connected" so that all the rouitng parameters are


happy benchmarking,

rick jones
