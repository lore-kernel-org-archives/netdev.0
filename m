From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Tue, 31 Mar 2009 21:52:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903312145130.2954@ask.diku.dk>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
 <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
 <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>
 <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com>
 <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk> <49D12E87.4090005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-658405998-1238529133=:2954"
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:34294 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbZCaTwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 15:52:24 -0400
In-Reply-To: <49D12E87.4090005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-658405998-1238529133=:2954
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT


On Mon, 30 Mar 2009, Eric Dumazet wrote:
> Jesper Dangaard Brouer a écrit :
>> On Mon, 30 Mar 2009, Eric Dumazet wrote:
>>
>>> Jesper Dangaard Brouer a écrit :
>>>>
>>>>> Eric Dumazet wrote:
>>>>>>  "tbench 8" results on my 8 core machine (32bit kernel, with
>>>>>>  conntracking on) : 2319 MB/s instead of 2284 MB/s
>>>>
>>>> How do you achieve this impressing numbers?
>>>> Is it against localhost? (10Gbit/s is max 1250 MB/s)
>>>
>>> tbench is a tcp test on localhost yes :)
>>
>> I see!
>>
>> Using a Sun 10GbE NIC I was only getting a throughput of 556.86 MB/sec
>> with 64 procs (between an AMD Phenom X4 and a Core i7).  (Not tuned
>> multi queues yet ...)
>>
>> Against localhost I'm getting (not with applied patch):
>>
>>  1336.42 MB/sec on my AMD phenom X4 9950 Quad-Core Processor
>>
>>  1552.81 MB/sec on my Core i7 920 (4 physical cores, plus 4 threads)
>
> Strange results, compared to my E5420 (I thought i7 was faster ??)
>
>>  2274.53 MB/sec on my dual CPU Xeon E5420 (8 cores)

I tried using "netperf" instead of "tbench".

A netperf towards localhost (netperf -T 0,1 -l 120 -H localhost)
reveals that the Core i7 is still the fastest.

24218 Mbit/s  on Core i7 920

11684 Mbit/s  on Phenom X4

  8181 Mbit/s  on Xeon E5420

A note to Rick, the process "netperf" would use 100% CPU time and
"netserver" would only use 70%.

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-658405998-1238529133=:2954--
