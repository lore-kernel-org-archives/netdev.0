From: Sergio Correia <lists@uece.net>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Thu, 24 May 2012 00:21:49 -0300
Message-ID: <CAJyhjX1UW=N0B9GFMt_u_gFEsLH2=8OJx0N7zJWVCrpic5Z9kQ@mail.gmail.com>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com>
 <1337697203.3361.190.camel@edumazet-glaptop> <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
 <1337785681.3361.2923.camel@edumazet-glaptop> <CAJyhjX02wjsVE2pM26a+7xTrAJwvLZo0UL-W6h8zMKEiC5qTug@mail.gmail.com>
 <1337791018.3361.3024.camel@edumazet-glaptop> <CAJyhjX1E_yzT1Vte+3iqc-PnfLiEEdFEyM9GcOCs-6TrUm86XQ@mail.gmail.com>
 <1337798274.3361.3234.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35400 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756964Ab2EXDWL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 23:22:11 -0400
Received: by pbbrp8 with SMTP id rp8so10805209pbb.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 20:22:10 -0700 (PDT)
In-Reply-To: <1337798274.3361.3234.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 23, 2012 at 3:37 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Wed, 2012-05-23 at 15:30 -0300, Sergio Correia wrote:
>> On Wed, May 23, 2012 at 1:36 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > On Wed, 2012-05-23 at 12:56 -0300, Sergio Correia wrote:
>> >> On Wed, May 23, 2012 at 12:08 PM, Eric Dumazet <eric.dumazet@gmai=
l.com> wrote:
>> >> > On Tue, 2012-05-22 at 11:47 -0300, Sergio Correia wrote:
>> >> >> Hi Eric,
>> >> > ...
>> >> >> Yes, it's an Atheros AR9285 adapter.
>> >> >> This morning I did a make mrproper before rebuilding the kerne=
l
>> >> >> (should I always do that?), but the warning has just appeared =
again.
>> >> >
>> >> > OK, I am taking a look at this problem, thanks.
>> >> >
>> >>
>> >> Thanks. Let me know if you need additional info. As of now, my dm=
esg
>> >> basically shows only those warnings.
>> >
>> > I believe I found the bug and am testing a fix right now.
>> >
>> > By the way, we might have the same problem in tcp collapses.
>> >
>> > TCP coalescing (introduced in linux-3.5) triggers the problem fast=
er.
>> >
>> > Please test following patch :
>> >
>>
>> I reverted back to 471368557a734c6c486ee757952c902b36e7fd01 and it
>> took almost one hour to trigger the warning. Now I have applied your
>> patch and will report back how it went after a few hours of testing.
>
> Thanks
>
> I triggered it very fast in my lab using following setup
>
> Sender machine :
>
> # tc qdisc add dev eth0 root netem delay 1ms 3ms 20 reorder 10 20
> for i in `seq 1 8`
> do
> =A0netperf -t OMNI =A0-C -c -H 172.30.42.8 -l 60 &
> done
> wait
> # tc -s -d qd
> qdisc netem 8002: dev eth0 root refcnt 2 limit 1000 delay 1.0ms =A03.=
0ms
> 20% reorder 10% 20% gap 1
> =A0Sent 66030032010 bytes 43992779 pkt (dropped 13846, overlimits 0
> requeues 2712184)
> =A0backlog 0b 0p requeues 2712184
>
> receiver machine runs a netserver and triggers the bug in few seconds=
=2E
>
> (receiver being a slow machine, with r8169 NIC)
>

With your patch applied, the warning hasn't shown up in the last
hours. Without it, dmesg would have been completely taken by them by
now.
I might be able to reproduce your test setup tomorrow, and if so, I wil=
l retest.

thanks,
sergio
