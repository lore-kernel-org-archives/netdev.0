From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Fri, 4 Jan 2013 06:31:06 +0100
Message-ID: <CA+icZUVWKD7j=E90Tqvy8BQR7GWtakYyN7CAG5Z7-OO9GJuJPw@mail.gmail.com>
References: <CA+icZUVEvzyrPsQG1QWLnHxhtaewaWTOVzBpTnLqjKuHMjjFHg@mail.gmail.com>
	<1357219919.21409.24519.camel@edumazet-glaptop>
	<50E5DEEF.2080009@hp.com>
	<1357274510.21409.27807.camel@edumazet-glaptop>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:60492 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3ADFbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 00:31:08 -0500
In-Reply-To: <1357274510.21409.27807.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 4, 2013 at 5:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-01-03 at 11:41 -0800, Rick Jones wrote:
>
>> In terms of netperf overhead, once you specify P99_LATENCY, you are
>> already in for the pound of cost but only getting the penny of output
>> (so to speak).  While it would clutter the output, one could go ahead
>> and ask for the other latency stats and it won't "cost" anything more:
>>
>> ... -- -k
>> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
>>
>> Additional information about how the omni output selectors work can be
>> found at
>> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Omni-Output-Selection
>>
>> happy benchmarking,
>>
>> rick jones
>>
>> BTW - you will likely see some differences between RT_LATENCY, which is
>> calculated from the average transactions per second, and MEAN_LATENCY,
>> which is calculated from the histogram of individual latencies
>> maintained when any of the _LATENCY outputs other than RT_LATENCY is
>> requested.  Kudos to the folks at Google who did the extensions to the
>> then-existing histogram code to enable it to be used for more reasonably
>> accurate statistics.
>>
>
> Yeah ;)
>
> Here are the before/after_patch results, cpu 2 handling the NIC irqs :
>
>
> Before patch :
>
> # netperf -H 7.7.7.84 -t TCP_RR -T2,2 -- -k
> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
> to 7.7.7.84 () port 0 AF_INET : first burst 0 : cpu bind
> RT_LATENCY=550110.424
> MIN_LATENCY=146858
> MAX_LATENCY=997109
> P50_LATENCY=305000
> P90_LATENCY=550000
> P99_LATENCY=710000
> MEAN_LATENCY=376989.12
> STDDEV_LATENCY=184046.92
>
> After patch :
>
> # netperf -H 7.7.7.84 -t TCP_RR -T2,2 -- -k
> RT_LATENCY,MIN_LATENCY,MAX_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET
> to 7.7.7.84 () port 0 AF_INET : first burst 0 : cpu bind
> RT_LATENCY=40545.492
> MIN_LATENCY=9834
> MAX_LATENCY=78366
> P50_LATENCY=33583
> P90_LATENCY=59000
> P99_LATENCY=69000
> MEAN_LATENCY=38364.67
> STDDEV_LATENCY=12865.26
>

Will you send a v2 with this change...?

-#define MAX_SOFTIRQ_TIME  min(1, (2*HZ/1000))
+#define MAX_SOFTIRQ_TIME  max(1, (2*HZ/1000))

- Sedat -
