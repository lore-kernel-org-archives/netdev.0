From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 20:31:05 +0200
Message-ID: <20110228203105.13466xdjy27nr5wk@hayate.sektori.org>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
 <1298837273.8726.128.camel@edumazet-laptop>
 <20110228134338.1241484mkljbz4w0@hayate.sektori.org>
 <1298898640.2941.256.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298898640.2941.256.camel@edumazet-laptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric Dumazet <eric.dumazet@gmail.com>:

> Le lundi 28 f=C3=A9vrier 2011 =C3=A0 13:43 +0200, Jussi Kivilinna a =C3=
=A9crit :
>> Quoting Eric Dumazet <eric.dumazet@gmail.com>:
>>
>> > Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 12:55 +0200, Jussi Kivilin=
na a =C3=A9crit :
>> >> Quoting Albert Cahalan <acahalan@gmail.com>:
>> >>
>> >> > On Sun, Feb 27, 2011 at 2:54 AM, Eric Dumazet
>> >> <eric.dumazet@gmail.com> wrote:
>> >> >> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 08:02 +0100, Mikael Ab=
rahamsson =20
>> a =C3=A9crit :
>> >> >>> On Sun, 27 Feb 2011, Albert Cahalan wrote:
>> >> >>>
>> >> >>> > Nanoseconds seems fine; it's unlikely you'd ever want
>> >> >>> > more than 4.2 seconds (32-bit unsigned) of queue.
>> >> > ...
>> >> >> Problem is some machines have slow High Resolution timing serv=
ices.
>> >> >>
>> >> >> _If_ we have a time limit, it will probably use the low =20
>> resolution (aka
>> >> >> jiffies), unless high resolution services are cheap.
>> >> >
>> >> > As long as that is totally internal to the kernel and never
>> >> > getting exposed by some API for setting the amount, sure.
>> >> >
>> >> >> I was thinking not having an absolute hard limit, but an EWMA =
=20
>> based one.
>> >> >
>> >> > The whole point is to prevent stale packets, especially to prev=
ent
>> >> > them from messing with TCP, so I really don't think so. I suppo=
se
>> >> > you do get this to some extent via early drop.
>> >>
>> >> I made simple hack on sch_fifo with per packet time limits
>> >> (attachment) this weekend and have been doing limited testing on
>> >> wireless link. I think hardlimit is fine, it's simple and does
>> >> somewhat same as what packet(-hard)limited buffer does, drops pac=
kets
>> >> when buffer is 'full'. My hack checks for timed out packets on
>> >> enqueue, might be wrong approach (on other hand might allow some =
more
>> >> burstiness).
>> >>
>> >
>> >
>> > Qdisc should return to caller a good indication packet is queued o=
r
>> > dropped at enqueue() time... not later (aka : never)
>> >
>> > Accepting a packet at t0, and dropping it later at t0+limit withou=
t
>> > giving any indication to caller is a problem.
>> >
>> > This is why I suggested using an EWMA plus a probabilist drop or
>> > congestion indication (NET_XMIT_CN) to caller at enqueue() time.
>> >
>> > The absolute time limit you are trying to implement should be chec=
ked at
>> > dequeue time, to cope with enqueue bursts or pauses on wire.
>> >
>>
>> Would it be better to implement this as generic feature instead of
>> qdisc specific? Have qdisc_enqueue_root do ewma check:
>
> Problem is you can have several virtual queues in a qdisc.
>
> For example, pfifo_fast has 3 bands. You could have a global ewma wit=
h
> high values, but you still want to let a high priority packet going
> through...
>

Ok. It would better to have ewma/timelimit at leaf qdisc.
(Or have in-middle-qdisc handling ewma/timelimit for leaf qdisc, =20
sch_timelimit)

-Jussi
