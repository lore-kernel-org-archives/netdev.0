From: cold cold <nedkonedev@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
	kernel flush route cache
Date: Wed, 27 Jan 2010 21:53:11 +0200
Message-ID: <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:37477 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab0A0TxM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 14:53:12 -0500
Received: by ewy19 with SMTP id 19so842460ewy.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 11:53:11 -0800 (PST)
In-Reply-To: <1264605976.3197.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 5:26 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 26 janvier 2010 =E0 18:58 +0200, cold cold a =E9crit :
>> HI,
>>
>>
>> i have expiriance some CPU usage spikes up to 10% on each four cpus
>> after the first kernel route cache flush.
>> After mashine start first 20 min CPU is 0%si =A0300Mbits/s full dupl=
ex
>> and arount 100k pps forwarded traffic, without any firewall, just
>> plain routing.
>>
>> route -n |wc -l
>> 34
>>
>> ip route show cache | wc -l
>> 2140842
>>
>> cat /proc/sys/net/ipv4/route/secret_interval
>> 600
>> cat /proc/sys/net/ipv4/route/max_size
>> 33554432
>>
>> after kernel =A0flush i got 10% on all CPUs for 5-6 mins. =A0It's no=
t from
>> rebuilding route cashe becouse after
>> fresh boot or network restrat there is no CPU usage until kernel flu=
sh
>> route cache.
>> I try to play with rhash_entries=3D 300000 to 2000000 same result.
>
> If you have one million dst entries to flush, it takes some time.
>
> You could try to not increase the rhash_entries
> (or keep it low, say 131072)
> but tune /proc/sys/net/ipv4/route settings.
>
> Try to reduce gc_elasticity from 8 to 2
> Try to reduce gc_interval from 60 to 1
>
> Important thing to consider is to irq affinities (so that one cpu
> handles network interrupts, to minimize cache ping poings )
>


btw atm i have 1k ip on that router but plan to put 10k so route cache
will grow 10 time fast.
i try to keep low  rhash_entries but garbage collector  is non stop
running and eat CPU
atm i have around 7k  entries per second for second for first minute.

i think it will be better if i flush cache on secret interval instead
of giving work to gc.
i test with 512MB cache and CPU is 0% and flushing entire hash dont tak=
e a lot,
I'm not sure is there some side effects from flushing.
