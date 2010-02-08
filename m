From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 14:59:59 +0100
Message-ID: <4B7018DF.8060600@itcare.pl>
References: <4B700EC2.5090207@itcare.pl>	 <1265635690.3048.8.camel@edumazet-laptop>  <4B7012BC.9000702@itcare.pl> <1265637067.3048.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:43626 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752202Ab0BHN77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 08:59:59 -0500
In-Reply-To: <1265637067.3048.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-02-08 14:51, Eric Dumazet pisze:
> Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:33 +0100, Pawe=C5=82 Staszews=
ki a =C3=A9crit :
>
>   =20
>>>
>>>       =20
>> Yes this is x86_64 kernel
>> i kernels  2.6.32.2 /  2.6.32.7 and now 2.6.33-rc6-git5 and on all
>> kernels the same thing happens.
>> grep . /proc/sys/net/ipv4/route/*
>> /proc/sys/net/ipv4/route/error_burst:1250
>> /proc/sys/net/ipv4/route/error_cost:250
>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
>> /proc/sys/net/ipv4/route/gc_elasticity:2
>> /proc/sys/net/ipv4/route/gc_interval:2
>> /proc/sys/net/ipv4/route/gc_min_interval:0
>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>> /proc/sys/net/ipv4/route/gc_thresh:65535
>> /proc/sys/net/ipv4/route/gc_timeout:300
>> /proc/sys/net/ipv4/route/max_size:524288
>> /proc/sys/net/ipv4/route/min_adv_mss:256
>> /proc/sys/net/ipv4/route/min_pmtu:552
>> /proc/sys/net/ipv4/route/mtu_expires:600
>> /proc/sys/net/ipv4/route/redirect_load:5
>> /proc/sys/net/ipv4/route/redirect_number:9
>> /proc/sys/net/ipv4/route/redirect_silence:5120
>> /proc/sys/net/ipv4/route/secret_interval:2
>>
>> This happens not all the time.
>> I have this info only when there are "internet rush hours" - thn the=
re
>> is about 700Mbit/s TX + 700Mbit/s RX forwarded traffic
>>
>>     =20
> I dont understand your settings, they are very very small for your
> setup. You want to flush cache every 2 seconds...
>
> With 12GB of ram, you could have
>
> /proc/sys/net/ipv4/route/gc_thresh:524288
> /proc/sys/net/ipv4/route/max_size:8388608
> /proc/sys/net/ipv4/route/secret_interval:3600
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:1
>
> That would allow about 2 million entries in your route cache, using 7=
68
> Mbytes of ram, and a good cache hit ratio.
>
>
>   =20
Yes as i write i change this settings after i see first info=20
"secret_interval" - from 3600 to 2
To check if this resolve the problem.
Also my normal settings are:

/proc/sys/net/ipv4/route/gc_thresh:256000
/proc/sys/net/ipv4/route/max_size:1048576
/proc/sys/net/ipv4/route/secret_interval:3600
/proc/sys/net/ipv4/route/gc_interval:2
/proc/sys/net/ipv4/route/gc_elasticity:2

And with this setting i was have this info:
Route hash chain too long!
Adjust your secret_interval!



Now i put Your settings as You suggest ... and we will see but i dont k=
now it will help.
Because i try many of different settings.








>
>
>
>
>   =20

