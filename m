From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 6 Jun 2012 12:04:11 +0200
Message-ID: <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com> <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Sathya.Perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61757 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab2FFKEd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 06:04:33 -0400
Received: by wibhn6 with SMTP id hn6so4856149wib.1
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 03:04:32 -0700 (PDT)
In-Reply-To: <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/5/30 =C2=A0<Sathya.Perla@emulex.com>:
>>>-----Original Message-----
>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On
>>>Behalf Of Jean-Michel Hautbois
>>>
>>>2012/5/30 Jean-Michel Hautbois <jhautbois@gmail.com>:
>>>
>>>I used vmstat in order to see the differences between the two kernel=
s.
>>>The main difference is the number of interrupts per second.
>>>I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
>>>I suspect the be2net driver to be the main cause, and I checkes the
>>>/proc/interrupts file in order to be sure.
>>>
>>>I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23=
000 on 3.2.
>>>BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
>>>whereas there is eth1-rx0 and eth1-tx on 2.6.26.
>>
>> Yes, there is an issue with be2net interrupt mitigation in the recen=
t code with
>> RX and TX on the same Evt-Q (commit 10ef9ab4). The high interrupt ra=
te happens when a TX blast is
>> done while RX is relatively silent on a queue pair. Interrupt rate d=
ue to TX completions is not being
>> mitigated.
>>
>> I have a fix and will send it out soon..
>>
>> thanks,
>> -Sathya
>
> Hi Sathya !
> Thanks for this information !
> I had the correct diagnostic :). I am waiting for your fix.
>

Well, well, well, after having tested several configurations, several
drivers, I have a big difference between an old 2.6.26 kernel and a
newer one (I tried 3.2 and 3.4).

Here is my stream : UDP packets (multicast), 4000 bytes length, MTU
set to 4096. I am sending packets only, nothing on RX.
I send from 1Gbps upto 2.4Gbps and I see no drops in tc with 2.6.26
kernel, but a lot of drops with a newer kernel.
So, I don't know if I missed something in my kernel configuration, but
I have used the 2.6.26 one as a reference, in order to set the same
options (DMA related, etc).

I easily reproduce this problem and setting a bigger txqueuelen solves
it partially.
1Gbps requires a txqueulen of 9000, 2.4Gbps requires more than 20000 !

If you have any idea, I am interested, as this is a big issue for my us=
e case.

JM
