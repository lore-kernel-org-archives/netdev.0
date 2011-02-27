From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 23:32:28 +0200
Message-ID: <20110227233228.133610ohbha7chk0@hayate.sektori.org>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
 <1298837273.8726.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinikuusama.dnainternet.net ([83.102.40.134]:50019 "EHLO
	sinikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751819Ab1B0Vcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 16:32:42 -0500
In-Reply-To: <1298837273.8726.128.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric Dumazet <eric.dumazet@gmail.com>:

> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 12:55 +0200, Jussi Kivilinna =
a =C3=A9crit :
>> Quoting Albert Cahalan <acahalan@gmail.com>:
>>
>> > On Sun, Feb 27, 2011 at 2:54 AM, Eric Dumazet =20
>> <eric.dumazet@gmail.com> wrote:
>> >> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 08:02 +0100, Mikael Abrah=
amsson a =C3=A9crit :
>> >>> On Sun, 27 Feb 2011, Albert Cahalan wrote:
>> >>>
>> >>> > Nanoseconds seems fine; it's unlikely you'd ever want
>> >>> > more than 4.2 seconds (32-bit unsigned) of queue.
>> > ...
>> >> Problem is some machines have slow High Resolution timing service=
s.
>> >>
>> >> _If_ we have a time limit, it will probably use the low resolutio=
n (aka
>> >> jiffies), unless high resolution services are cheap.
>> >
>> > As long as that is totally internal to the kernel and never
>> > getting exposed by some API for setting the amount, sure.
>> >
>> >> I was thinking not having an absolute hard limit, but an EWMA bas=
ed one.
>> >
>> > The whole point is to prevent stale packets, especially to prevent
>> > them from messing with TCP, so I really don't think so. I suppose
>> > you do get this to some extent via early drop.
>>
>> I made simple hack on sch_fifo with per packet time limits
>> (attachment) this weekend and have been doing limited testing on
>> wireless link. I think hardlimit is fine, it's simple and does
>> somewhat same as what packet(-hard)limited buffer does, drops packet=
s
>> when buffer is 'full'. My hack checks for timed out packets on
>> enqueue, might be wrong approach (on other hand might allow some mor=
e
>> burstiness).
>>
>
>
> Qdisc should return to caller a good indication packet is queued or
> dropped at enqueue() time... not later (aka : never)

Ok, it is ugly hack ;) I got idea of dropping head from pfifo_head_drop=
=2E

>
> Accepting a packet at t0, and dropping it later at t0+limit without
> giving any indication to caller is a problem.

Ok.

>
> This is why I suggested using an EWMA plus a probabilist drop or
> congestion indication (NET_XMIT_CN) to caller at enqueue() time.
>
> The absolute time limit you are trying to implement should be checked=
 at
> dequeue time, to cope with enqueue bursts or pauses on wire.
>

Ok.


