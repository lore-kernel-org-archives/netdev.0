From: Jim Gettys <jg@freedesktop.org>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Thu, 01 Dec 2011 17:04:15 -0500
Message-ID: <4ED7F9DF.8020903@freedesktop.org>
References: <1322684749.2602.3.camel@edumazet-laptop>  <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>  <1322773594.2750.28.camel@edumazet-laptop>  <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com> <1322776643.2750.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:37393 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab1LAWET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 17:04:19 -0500
Received: by vcbfk14 with SMTP id fk14so1892131vcb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 14:04:18 -0800 (PST)
In-Reply-To: <1322776643.2750.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2011 04:57 PM, Eric Dumazet wrote:
> Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 22:35 +0100, Dave Taht a =C3=A9=
crit :
>> On Thu, Dec 1, 2011 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>>> Le mercredi 30 novembre 2011 =C3=A0 14:36 -0800, Stephen Hemminger =
a =C3=A9crit :
>>>
>>>> (Almost) nobody uses RED because they can't figure it out.
>>>> According to Wikipedia, VJ says that:
>>>>  "there are not one, but two bugs in classic RED."
>> Heh. "There were not two, but four bugs in Linux red".
>>
>> Now reduced to 2. :)
>>
> This story about VJ and bugs in classic RED is urban legend if you as=
k
> me :)
>

Well, I've heard this directly from Van, first hand.  So you are now
second hand.

 And you can see much of what's wrong by tracking down "RED in a
different light", which he tried to get published to get people aware o=
f it.
                - Jim

>
>> RED is useful for high throughput routers, I doubt many linux machin=
es
>>> act as such devices.
>> "High throughput" at the time red was designed was not much faster
>> than a T1 line.
>>
>> RED appears to be used by default in both gargoyle's and openwrt's Q=
oS systems,
>> underneath unholy combinations of HTB, HSFC, and SFQ
>> so it's more widely used than you might think. Not that works well.
>>
>> RED doesn't work worth beans on variable bandwidth links (cable
>> modems/wireless).
>>
> Adaptative RED is the answer
>
>> Once you are simulating a fixed rate link (e.g with HTB), then it so=
rt of
>> kinda maybe can apply.
>>
>> RED was also designed at a time when long distance traffic was fixed=
 rate
>> and bidirectional, so the 'average packet' parameter made sense.
>> Modern day traffic is far more asymmetric.
>>
> The truth is : For RED be effective (with say 20 to 100 flows), you n=
eed
> a reasonable amount of packets in queue, and low wq (high burst value=
 in
> linux), depending on the RTT. And on consumer links (ADSL, cable
> modem ...), RTT is quite big.
>
> RED performance is best when the average queue size is estimated over=
 a
> small _multiple_ of round-trip times, not over a fraction of a single
> round-trip time.
>
> In this respect, your RED setups are pathological (minimum burst valu=
e,
> meaning wq =3D 0.5 or so), so in a small fraction of RTT, avgqsz valu=
e is
> completely changed, so flows have no chance to be able to react
> smoothly.
>
>
>
