From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Tue, 31 Mar 2009 22:23:53 +0200
Message-ID: <49D27BD9.4030503@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com> <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com> <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com> <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com> <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk> <49D12E87.4090005@cosmosbay.com> <Pine.LNX.4.64.0903312145130.2954@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59029 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbZCaUYF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:24:05 -0400
In-Reply-To: <Pine.LNX.4.64.0903312145130.2954@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =E9crit :
>=20
> On Mon, 30 Mar 2009, Eric Dumazet wrote:
>> Jesper Dangaard Brouer a =E9crit :
>>> On Mon, 30 Mar 2009, Eric Dumazet wrote:
>>>
>>>> Jesper Dangaard Brouer a =E9crit :
>>>>>
>>>>>> Eric Dumazet wrote:
>>>>>>>  "tbench 8" results on my 8 core machine (32bit kernel, with
>>>>>>>  conntracking on) : 2319 MB/s instead of 2284 MB/s
>>>>>
>>>>> How do you achieve this impressing numbers?
>>>>> Is it against localhost? (10Gbit/s is max 1250 MB/s)
>>>>
>>>> tbench is a tcp test on localhost yes :)
>>>
>>> I see!
>>>
>>> Using a Sun 10GbE NIC I was only getting a throughput of 556.86 MB/=
sec
>>> with 64 procs (between an AMD Phenom X4 and a Core i7).  (Not tuned
>>> multi queues yet ...)
>>>
>>> Against localhost I'm getting (not with applied patch):
>>>
>>>  1336.42 MB/sec on my AMD phenom X4 9950 Quad-Core Processor
>>>
>>>  1552.81 MB/sec on my Core i7 920 (4 physical cores, plus 4 threads=
)
>>
>> Strange results, compared to my E5420 (I thought i7 was faster ??)
>>
>>>  2274.53 MB/sec on my dual CPU Xeon E5420 (8 cores)
>=20
> I tried using "netperf" instead of "tbench".
>=20
> A netperf towards localhost (netperf -T 0,1 -l 120 -H localhost)
> reveals that the Core i7 is still the fastest.
>=20
> 24218 Mbit/s  on Core i7 920
>=20
> 11684 Mbit/s  on Phenom X4
>=20
>  8181 Mbit/s  on Xeon E5420

warning, because on my machine,=20

cpu0 is on physical id 0, core 0
cpu1 is on physical id 1, core 0
cpu2 is on physical id 0, core 1
cpu3 is on physical id 1, core 1
cpu3 is on physical id 0, core 2
cpu4 is on physical id 1, core 2
cpu5 is on physical id 0, core 3
cpu6 is on physical id 1, core 3

So -T 0,1 might not do what you think...

$ netperf -T 0,1 -l 120 -H localhost
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.loca=
ldomain (127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    120.00   7423.16
$ netperf -T 0,2 -l 120 -H localhost
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.loca=
ldomain (127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    120.00   9360.17



>=20
> A note to Rick, the process "netperf" would use 100% CPU time and
> "netserver" would only use 70%.


