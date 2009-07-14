From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Tue, 14 Jul 2009 18:24:25 +0200
Message-ID: <20090714162425.GA3090@ami.dom.local>
References: <20090708223459.GB3666@ami.dom.local> <4A5679CC.800@itcare.pl> <4A568444.7010307@itcare.pl> <20090710144754.GA25385@ami.dom.local> <20090711062455.GA3095@ami.dom.local> <4A5BC2B6.9020709@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:61007 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbZGNQYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 12:24:51 -0400
Received: by bwz28 with SMTP id 28so885885bwz.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 09:24:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A5BC2B6.9020709@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2009 at 01:26:46AM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
>> On Fri, Jul 10, 2009 at 04:47:54PM +0200, Jarek Poplawski wrote:
>>  =20
>>> On Fri, Jul 10, 2009 at 01:59:00AM +0200, Pawe=B3 Staszewski wrote:
>>>    =20
>>>> Today i make other tests with change of  =20
>>>> /proc/sys/net/ipv4/rt_cache_rebuild_count and kernel 2.6.30.1
>>>>
>>>> And when rt_cache_rebuild_count is set to "-1" i have always load=20
>>>> on  x86_64 machine approx 40-50% of each cpu where network card is=
=20
>>>> binded by  irq_aff
>>>>
>>>> when rt_cache_rebuild_count is set to more than "-1" i have 15 to=20
>>>> 20 sec  of 1 to 3% cpu and after 40-50% cpu
>>>>      =20
>>> ...
>>>
>>> Here is one more patch for testing (with caution!). It adds possibi=
lity
>>> to turn off cache disabling (so it should even more resemble 2.6.28=
)
>>> after setting: rt_cache_rebuild_count =3D 0
>>>
>>> I'd like you to try this patch:
>>> 1) together with the previous patch and "rt_cache_rebuild_count =3D=
 0"
>>>    to check if there is still the difference wrt. 2.6.28; Btw., let
>>>    me know which /proc/sys/net/ipv4/route/* settings do you need to
>>>    change and why
>>>
>>> 2) alone (without the previous patch) and "rt_cache_rebuild_count =3D=
 0"
>>>
>>> 3) if it's possible to try 2.6.30.1 without these patches, but with
>>>    default /proc/sys/net/ipv4/route/* settings, and higher
>>>    rt_cache_rebuild_count, e.g. 100; I'm interested if/how long it
>>>    takes to trigger higher cpu load and the warning "... rebuilds i=
s
>>>    over limit, route caching disabled"; (Btw., I wonder why you did=
n't
>>>    mention about these or maybe also other route caching warnings?)
>>>    =20
>>
>> Here is take 2 to respect setting "rt_cache_rebuild_count =3D 0" eve=
n
>> after cache rebuild counter has been increased earlier. (Btw, don't
>> forget about this setting after going back to vanilla kernel.)
>>
>>  =20
> Applied to 2.6.30.1
> 1) With
>
> rt_cache_rebuild_count =3D 0
> grep . /proc/sys/net/ipv4/route/*
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:15
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:0
> /proc/sys/net/ipv4/route/gc_thresh:190536
> /proc/sys/net/ipv4/route/gc_timeout:15 =20
> /proc/sys/net/ipv4/route/max_size:1524288 =20
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:3600
>
> I tune this route parameters after looking of traffic/route cache to =
have not many entries in cache that are not needed anymore
> so gc_timeout =3D 15
> limit of max entries =3D 1524288
> And make route cahce a little more "faster" for me after tune =20
> gc_elasticity
> secret_interval
> gc_interval
> gc_thresh
>
> So with this parameters 15 sec of something like this:
> 00:41:23     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:41:24     all    0.00    0.00    0.12    0.00    1.49   10.46    0=
=2E00    0.00   87.92
> 00:41:24       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:24       1    0.00    0.00    0.00    0.00    4.00   36.00    0=
=2E00    0.00   60.00
> 00:41:24       2    0.00    0.00    0.00    0.00    8.91   47.52    0=
=2E00    0.00   43.56
> 00:41:24       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:24       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:24       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:24       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:24       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> and 15 sec of something like this:
> 00:41:44     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:41:45     all    0.00    0.00    0.00    0.00    0.00    0.42    0=
=2E00    0.00   99.58
> 00:41:45       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:45       1    0.00    0.00    0.00    0.00    0.00    1.00    0=
=2E00    0.00   99.00
> 00:41:45       2    0.00    0.00    0.00    0.00    0.00    2.04    0=
=2E00    0.00   97.96
> 00:41:45       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:45       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:45       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:45       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:41:45       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> So i change /proc/sys/net/ipv4/route/gc_timeout  to 1
> with rt_cache_rebuild_count =3D 0
> And output is like 20 sec of something like this
> 00:48:52     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:48:53     all    0.00    0.00    0.19    0.00    0.19    0.58    0=
=2E00    0.00   99.03
> 00:48:53       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:53       1    0.00    0.00    0.99    0.00    0.99    0.00    0=
=2E00    0.00   98.02
> 00:48:53       2    0.00    0.00    0.00    0.00    0.00    2.00    0=
=2E00    0.00   98.00
> 00:48:53       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:53       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:53       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:53       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:53       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> and after this two second of something like this:
> 00:48:49     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:48:50     all    0.00    0.00    0.09    0.00    0.27    2.17    0=
=2E00    0.00   97.46
> 00:48:50       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:50       1    0.00    0.00    0.00    0.00    1.96    6.86    0=
=2E00    0.00   91.18
> 00:48:50       2    0.00    0.00    0.00    0.00    0.99   16.83    0=
=2E00    0.00   82.18
> 00:48:50       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:50       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:50       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:50       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:50       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> 00:48:50     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:48:51     all    0.00    0.00    0.00    0.00    1.86   10.41    0=
=2E00    0.00   87.73
> 00:48:51       0    0.00    0.00    0.00    0.00    0.00    1.00    0=
=2E00    0.00   99.00
> 00:48:51       1    0.00    0.00    0.00    0.00    4.85   26.21    0=
=2E00    0.00   68.93
> 00:48:51       2    0.00    0.00    1.00    0.00    5.00   29.00    0=
=2E00    0.00   65.00
> 00:48:51       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:51       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:51       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:51       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:48:51       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>

Could you remind us how it differs from 2.6.28 with the same settings?

>
> Another test:
>
> gc_timeout =3D 1
> rt_cache_rebuild_count =3D 100
> 10 to 14 sec of something like this:
> 00:51:36     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:51:37     all    0.00    0.00    0.00    0.00    0.00    0.27    0=
=2E00    0.00   99.73
> 00:51:37       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:51:37       1    0.00    0.00    0.00    0.00    0.00    2.00    0=
=2E00    0.00   98.00
> 00:51:37       2    0.00    0.00    0.00    0.00    0.00    1.00    0=
=2E00    0.00   99.00
> 00:51:37       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:51:37       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:51:37       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:51:37       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:51:37       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> and two seconds of 10 to 30% cpu load more
>
>
> 2).
> Only last patch and almost all the time output like this
> 00:59:49     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 00:59:50     all    0.00    0.00    0.13    0.00    1.73    8.00    0=
=2E00    0.00   90.13
> 00:59:50       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:59:50       1    0.00    0.00    0.00    0.00    4.00   24.00    0=
=2E00    0.00   72.00
> 00:59:50       2    0.00    0.00    0.00    0.00    8.91   34.65    0=
=2E00    0.00   56.44
> 00:59:50       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:59:50       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:59:50       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:59:50       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 00:59:50       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> sometimes after 15 to 30 sec i have 1 to 2% cpu load

And how long do you have this 1 to 2% load? Is it with:
rt_cache_rebuild_count =3D 0
gc_timeout =3D 1?
Maybe you could describe the main difference with or without the first
patch?

>
> 3).
>
> with default settings and without this patch i have almost all the ti=
me output like this:

You mean without these two patches, right? So, there is no breaks with
less load like above?

> 01:21:40     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 01:21:41     all    0.00    0.00    0.00    0.00    2.14   10.97    0=
=2E00    0.00   86.89
> 01:21:41       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:21:41       1    0.00    0.00    0.00    0.00    6.93   34.65    0=
=2E00    0.00   58.42
> 01:21:41       2    0.00    0.00    0.00    0.00    7.07   42.42    0=
=2E00    0.00   50.51
> 01:21:41       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:21:41       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:21:41       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:21:41       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:21:41       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
>
>
> with my settings:
> /proc/sys/net/ipv4/route/error_burst:1250
> /proc/sys/net/ipv4/route/error_cost:250
> /proc/sys/net/ipv4/route/gc_elasticity:4
> /proc/sys/net/ipv4/route/gc_interval:15
> /proc/sys/net/ipv4/route/gc_min_interval:0
> /proc/sys/net/ipv4/route/gc_min_interval_ms:0
> /proc/sys/net/ipv4/route/gc_thresh:190536
> /proc/sys/net/ipv4/route/gc_timeout:15
> /proc/sys/net/ipv4/route/max_size:1524288
> /proc/sys/net/ipv4/route/min_adv_mss:256
> /proc/sys/net/ipv4/route/min_pmtu:552
> /proc/sys/net/ipv4/route/mtu_expires:600
> /proc/sys/net/ipv4/route/redirect_load:5
> /proc/sys/net/ipv4/route/redirect_number:9
> /proc/sys/net/ipv4/route/redirect_silence:5120
> /proc/sys/net/ipv4/route/secret_interval:3600
>
>
> 15 sec of 30 to 50 % cpu and 15 sec 1 to 2 % cpu
>
> with /proc/sys/net/ipv4/route/gc_interval:1
> almost all the time like this
> 01:23:45     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %st=
eal  %guest   %idle
> 01:23:46     all    0.00    0.00    0.00    0.00    0.00    0.12    0=
=2E00    0.00   99.88
> 01:23:46       0    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:23:46       1    0.00    0.00    0.00    0.00    1.00    0.00    0=
=2E00    0.00   99.00
> 01:23:46       2    0.00    0.00    0.00    0.00    0.00    1.02    0=
=2E00    0.00   98.98
> 01:23:46       3    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:23:46       4    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:23:46       5    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:23:46       6    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
> 01:23:46       7    0.00    0.00    0.00    0.00    0.00    0.00    0=
=2E00    0.00  100.00
>
> with max two outputs of 20 to 30% cpu in different times from 12 to  =
15sec

Didn't you see any: "... rebuilds is over limit, route caching
disabled" warning?

>
>
> And i dont know but i think patch for turning off route cache is not=20
> working because with this patches and rt_cache_rebuild_count =3D 0

If you mean the patch #2, it does something opposite: with
rt_cache_rebuild_count =3D 0 it turns off automatic "cache disabling"
after rt_cache_rebuild_count events signaled with the above-mentionned
warning, which was introduced in 2.6.29. Sorry for not describing this
enough.

Thanks,
Jarek P.
