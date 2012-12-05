From: =?UTF-8?B?5Y+26Zuo6aOe?= <sunyucong@gmail.com>
Subject: ksoftirqd 100% after disabling IPv4 route cache on high pps.
Date: Wed, 5 Dec 2012 13:22:45 -0800
Message-ID: <CAJygYd187B1305puZwdiK6kfP=LPPvyX_rGJn9g2azaRs4p8ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:40721 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab2LEVXH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 16:23:07 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so4957502vcd.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 13:23:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

After disabling the route cache, I found a forwarding performance
problem (inevitable ?). Basically the kernel couldn't keep up under
about 100k pps and ksoftirqd is dominating the CPU. This problem went
away right away if I do

echo  1 > rt_cache_rebuild_count

and comes back as soon as i do echo -1 > rt_cache_rebuild_count.

I then tried to use RPS/RFS to share the load on to mulitple cpus
(since ksoftirqd is only using 1 core, clearly). but that has little
effect.

Is there some tweaks/patches you recommend?

Thanks in advance.

On Tue, Nov 27, 2012 at 5:34 PM, =E5=8F=B6=E9=9B=A8=E9=A3=9E <sunyucong=
@gmail.com> wrote:
> Thanks!!! it works, after flushing cache it stays 0.
>
> On Tue, Nov 27, 2012 at 5:01 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> On Tue, 2012-11-27 at 15:15 -0800, =E5=8F=B6=E9=9B=A8=E9=A3=9E wrote=
:
>>> Hi,
>>>
>>> I have a linux router running kernel 3.2  that receive public ingre=
ss
>>> packets and route them through an GRE tunnel, return packets don't =
go
>>> through it
>>>
>>> I've recently faced a serious issue with the route cache,  when the
>>> router received spoofed source , the route cache will quickly get
>>> exhausted (depending on the size of it) and soon the ip dst cache
>>> overflow will be printed and network subsystem will hang until
>>> restarted.
>>>
>>> So, my question is, how can I turn off the route cache without
>>> recompile the kernel or adding the  patch for removal  in 3.7?  I
>>> tried to set
>>>
>>> echo 0 > /proc/sys/net/ipv4/route/max_size but that has no effect a=
t all.
>>>
>>> And if some one can share some insight on why when dst cache
>>> overflows, the network subsystem hangs, it would be great.
>>
>> echo -1 >/proc/sys/net/ipv4/rt_cache_rebuild_count
>>
>>
>>
