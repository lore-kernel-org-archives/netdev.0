From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Linux Route Cache performance tests
Date: Sun, 06 Nov 2011 21:25:18 +0100
Message-ID: <4EB6ED2E.1070106@itcare.pl>
References: <4EB6AE62.5050803@itcare.pl>   <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>  <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl> <1320608290.6506.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:38971 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab1KFUZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Nov 2011 15:25:20 -0500
In-Reply-To: <1320608290.6506.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-11-06 20:38, Eric Dumazet pisze:
> Le dimanche 06 novembre 2011 =C3=A0 20:20 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
>> W dniu 2011-11-06 19:48, Eric Dumazet pisze:
>>> Le dimanche 06 novembre 2011 =C3=A0 19:28 +0100, Pawe=C5=82 Staszew=
ski a =C3=A9crit :
>>>> W dniu 2011-11-06 18:29, Eric Dumazet pisze:
>>>>> Le dimanche 06 novembre 2011 =C3=A0 16:57 +0100, Pawe=C5=82 Stasz=
ewski a =C3=A9crit :
>>>>>> Hello
>>>>>>
>>>>>>
>>>>>>
>>>>>> I make some networking performance tests for Linux 3.1
>>>>>>
>>>>>> Configuration:
>>>>>>
>>>>>> Linux (pktget) ---->    Linux (router) ---->    Linux (Sink)
>>>>>>
>>>>>> pktgen config:
>>>>>> clone_skb 32
>>>>>> pkt_size 64
>>>>>> delay 0
>>>>>>
>>>>>> pgset "flag IPDST_RND"
>>>>>> pgset "dst_min 10.0.0.0"
>>>>>> pgset "dst_max 10.18.255.255"
>>>>>> pgset "config 1"
>>>>>> pgset "flows 256"
>>>>>> pgset "flowlen 8"
>>>>>>
>>>>>> TX performance for this host:
>>>>>> eth0:            RX: 0.00 P/s      TX: 12346107.73 P/s      TOTA=
L:
>>>>>> 12346107.73 P/s
>>>>>>
>>>>>> On Linux (router):
>>>>>> grep . /proc/sys/net/ipv4/route/*
>>>>>> /proc/sys/net/ipv4/route/error_burst:500
>>>>>> /proc/sys/net/ipv4/route/error_cost:100
>>>>>> grep: /proc/sys/net/ipv4/route/flush: Permission denied
>>>>>> /proc/sys/net/ipv4/route/gc_elasticity:4
>>>>>> /proc/sys/net/ipv4/route/gc_interval:60
>>>>>> /proc/sys/net/ipv4/route/gc_min_interval:0
>>>>>> /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>>>>>> /proc/sys/net/ipv4/route/gc_thresh:2000000
>>>>>> /proc/sys/net/ipv4/route/gc_timeout:60
>>>>>> /proc/sys/net/ipv4/route/max_size:8388608
>>>>>> /proc/sys/net/ipv4/route/min_adv_mss:256
>>>>>> /proc/sys/net/ipv4/route/min_pmtu:552
>>>>>> /proc/sys/net/ipv4/route/mtu_expires:600
>>>>>> /proc/sys/net/ipv4/route/redirect_load:2
>>>>>> /proc/sys/net/ipv4/route/redirect_number:9
>>>>>> /proc/sys/net/ipv4/route/redirect_silence:2048
>>>>>>
>>>>>> For the first 30secs maybee more router is forwarding ~5Mpps to =
the
>>>>>> Linux (Sink)
>>>>>> and some stats for this forst 30secs in attached image:
>>>>>>
>>>>>> http://imageshack.us/photo/my-images/684/test1ih.png/
>>>>>>
>>>>>> Left up - pktgen linux
>>>>>> left down - Linux router (htop)
>>>>>> Right up - Linux router (bwm-ng - showing pps)
>>>>>> Right down - Linux router (lnstat)
>>>>>>
>>>>>>
>>>>>> And all is good - performance 5Mpps until Linux router will reac=
h ~1kk
>>>>>> entries
>>>>>> What You can see on next attached image:
>>>>>>
>>>>>> http://imageshack.us/photo/my-images/24/test2id.png/
>>>>>>
>>>>>> Forwarding performance drops from 5Mpps to 1,8Mpps
>>>>>> And after 3 - 4 minutes it will stop on 0,7Mpps
>>>>>>
>>>>>>
>>>>>> After flushing the route cache performance increase from 0.7Mpps=
 to 6Mpps
>>>>>> What You can see on next attached image:
>>>>>>
>>>>>> http://imageshack.us/photo/my-images/197/test3r.png/
>>>>>>
>>>>>> Is it possible to turn off route cache ? and see what performanc=
e will
>>>>>> be without caching
>>>>>>
>>>>> Route cache cannot handle DDOS situation, since it will be filled=
,
>>>>> unless you have a lot of memory.
>>>> hmm
>>>> but what is DDOS situation for route cache ? new entries per sec ?=
 total
>>>> amount of entries 1,2kk in my tests ?
>>>> Look sometimes in normal scenario You can hit
>>>> 1245072 route cache entries
>>>> This is normal for BGP configurations.
>>>>
>>> Then figure out the right tunables for your machine ?
>>>
>>> Its not a laptop or average server setup, so you need to allow your
>>> kernel to consume a fair amount of memory for the route cache.
>> Yes this parameters  was special not tuned :)
>> To see what is the route cache performance limit
>>
> Hmm, I thought you were asking for help on netdev ?
Title was tests :)
And yes maybee some help that You give me about understanding how kerne=
l=20
works with and without route cache.

>
>> Because there was no optimal parameters for this test :)
>> no matter what i tuned results are always the same
>> performance drops from 5Mpps to 0.7Mpps without tuning sysctl
>>
>> And with tuned parameters i can reach the same as turning off route
>> cache - when running this tests.
>> So Yes Tuned performance is better
>> performance drops from 5Mpps to 0.7Mpps - without tuning
>> and from 5Mpps to 3,7Mpps with tuned sysctl - so a little less than =
with
>> turned off route cache
>>
>> So the point of this test was figure out how much of route cache ent=
ries
>> Linux can handle without dropping performance.
> No need to even do a bench, its pretty easy to understand how a hash
> table is handled.
>
> Allowing long chains is not good.
>
> With your 512k slots hash table, you cannot expect handling 1.4M rout=
es
> with optimal performance. End of story.
>
> Since route hash table is allocated at boot time, only way to change =
its
> size is using "rhash_entries=3D2097152" boot parameter.
>
> If it still doesnt fly, try with "rhash_entries=3D4194304"
Yes with this is a little problem i think with kernel 3.1 because
dmesg | egrep  '(rhash)|(route)'
[    0.000000] Command line: root=3D/dev/md2 rhash_entries=3D2097152
[    0.000000] Kernel command line: root=3D/dev/md2 rhash_entries=3D209=
7152
[    4.697294] IP route cache hash table entries: 524288 (order: 10,=20
4194304 bytes)


Thanks
Pawel

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
