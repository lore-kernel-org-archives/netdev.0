From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Wed, 30 May 2012 11:40:40 +0200
Message-ID: <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38124 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932430Ab2E3JlC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 05:41:02 -0400
Received: by weyu7 with SMTP id u7so3215420wey.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 02:41:00 -0700 (PDT)
In-Reply-To: <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
>> On Wed, 2012-05-30 at 08:51 +0200, Jean-Michel Hautbois wrote:
>>> 2012/5/30 Eric Dumazet <eric.dumazet@gmail.com>:
>>> > On Wed, 2012-05-30 at 08:28 +0200, Jean-Michel Hautbois wrote:
>>> >
>>> >> If this can help, setting tx queue length to 5000 seems to make =
the
>>> >> problem disappear.
>>> >
>>> > Then you should have drops at Qdisc layer (before your change to =
5000)
>>> >
>>> > tc -s -d qdisc
>>> >
>>> >> I didn't specified it : MTU is 4096, UDP packets are 4000 bytes.
>>> >
>>>
>>> Yes :
>>> qdisc mq 0: dev eth1 root
>>> =C2=A0Sent 5710049154383 bytes 1413544639 pkt (dropped 73078, overl=
imits 0
>>> requeues 281540)
>>> =C2=A0backlog 0b 0p requeues 281540
>>>
>>> Why ? With a 2.6.26 kernel it works well with a tx queue length of =
1000.
>>
>> If you send big bursts of packets, then you need a large enough queu=
e.
>>
>> Maybe your kernel is now faster than before and queue fills faster, =
or
>> TX ring is smaller ?
>>
>> ethtool -g eth0
>>
>> Note that everybody try to reduce dumb queue sizes because of latenc=
ies.
>>
>
> TX ring is not the same :
> On 3.2 :
> $> ethtool -g eth1
> Ring parameters for eth1:
> Pre-set maximums:
> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1024
> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2048
> Current hardware settings:
> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1024
> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2048
>
>
> On 2.6.26 :
> $>ethtool -g eth1
> Ring parameters for eth1:
> Pre-set maximums:
> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1024
> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2048
> Current hardware settings:
> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1003
> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>
> I can't set TX ring using ethtool -G eth1 tx N : operation not suppor=
ted
> I am not really impacted by latency, but the lower the better.
>
> JM

I used vmstat in order to see the differences between the two kernels.
The main difference is the number of interrupts per second.
I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
I suspect the be2net driver to be the main cause, and I checkes the
/proc/interrupts file in order to be sure.

I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23000=
 on 3.2.
BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
whereas there is eth1-rx0 and eth1-tx on 2.6.26.

JM
