From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Tue, 31 Mar 2009 22:52:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903312244550.3771@ask.diku.dk>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
 <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
 <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>
 <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com>
 <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk> <49D12E87.4090005@cosmosbay.com>
 <Pine.LNX.4.64.0903312145130.2954@ask.diku.dk> <49D27BD9.4030503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:60026 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927AbZCaUw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 16:52:27 -0400
In-Reply-To: <49D27BD9.4030503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 31 Mar 2009, Eric Dumazet wrote:

>> I tried using "netperf" instead of "tbench".
>>
>> A netperf towards localhost (netperf -T 0,1 -l 120 -H localhost)
>> reveals that the Core i7 is still the fastest.
>>
>> 24218 Mbit/s  on Core i7 920
>>
>> 11684 Mbit/s  on Phenom X4
>>
>>  8181 Mbit/s  on Xeon E5420
>
> warning, because on my machine,
>
> cpu0 is on physical id 0, core 0
> cpu1 is on physical id 1, core 0
> cpu2 is on physical id 0, core 1
> cpu3 is on physical id 1, core 1
> cpu3 is on physical id 0, core 2
> cpu4 is on physical id 1, core 2
> cpu5 is on physical id 0, core 3
> cpu6 is on physical id 1, core 3
>
> So -T 0,1 might not do what you think...

Thanks a lot, I didn't know that!
(hint: cat /proc/cpuinfo | egrep -e 'processor|physical id|core id')

I sort of got a "too large" speedup on the Xeon system:

I want to use core 0 and 1 on physical CPU 0, for some strange reason CPU0 
and CPU4 is these respective cores...

netperf -T 0,4 -l 60  -H localhost
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost (127.0.0.1) port 0 AF_INET : demo : cpu bind
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    60.00    19797.42


Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
