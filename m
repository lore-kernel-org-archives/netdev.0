From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Tue, 26 Aug 2014 10:40:28 -0400
Message-ID: <53FC9C5C.1070200@mojatatu.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>	<20140826082815.18034199@redhat.com> <20140826121347.0ec7f2ac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:59035 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbaHZOka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:40:30 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so22351382pde.25
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:40:30 -0700 (PDT)
In-Reply-To: <20140826121347.0ec7f2ac@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/14 06:13, Jesper Dangaard Brouer wrote:
>
> On Tue, 26 Aug 2014 08:28:15 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>> On Mon, 25 Aug 2014 16:34:58 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>>> Given Jesper's performance numbers, it's not the way to go.
>>>
>>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>>
>> I'll do benchmarking based on this new API proposal today.
>
> While establish an accurate baseline for my measurements.  I'm
> starting to see too much variation in my trafgen measurements.
> Meaning that we unfortunately cannot use it to measure variations on
> the nanosec scale.
>
> I'm measuring the packets per sec via "ifpps", and calculating an
> average over the measurements, via the following oneliner:
>
>   $ ifpps -clod eth5 -t 1000 | awk 'BEGIN{txsum=0; rxsum=0; n=0} /[[:digit:]]/ {txsum+=$11;rxsum+=$3;n++; printf "instant rx:%u tx:%u pps n:%u average: rx:%d tx:%d pps\n", $3, $11, n, rxsum/n, txsum/n }'
>
> Below is measurements done on the *same* kerne:
>   - M1: instant tx:1572766 pps n:215 average: tx:1573360 pps (reboot#1)
>   - M2: instant tx:1561930 pps n:173 average: tx:1557064 pps (reboot#2)
>   - M3: instant tx:1562088 pps n:300 average: tx:1559150 pps (reboot#2)
>   - M4: instant tx:1564404 pps n:120 average: tx:1564948 pps (reboot#3)
>
>   M1->M2: +6.65ns
>   M1->M3: +5.79ns
>   M1->M4: +3.42ns
>   M3->M4: -2.38ns
>
> I cannot explain the variations, but some options could be
>   1) how well the SKB is cache-hot cached via kmem_cache
>   2) other interrups on CPU#0 could disturb us
>   3) interactions with scheduler
>   4) interactions with transparent hugepages
>   5) CPU "turbostat" interactions
>

The clock source used in your system may be an issue as well.
I am not sure if that matters these days but it used to be.
I think back then you could pick ACPI, Jiffies etc to use
as a qdisc clock source.

cheers,
jamal
