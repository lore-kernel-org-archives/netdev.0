From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Thu, 31 May 2012 08:54:14 +0200
Message-ID: <CAL8zT=hG6+7J7ZPVjGSc0CCZYyJmFmMycW=DRFhQYGPt49to3g@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com> <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com
To: Sathya.Perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38686 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2EaGyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 02:54:35 -0400
Received: by wibhj8 with SMTP id hj8so4611084wib.1
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 23:54:34 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/30  <Sathya.Perla@emulex.com>:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>Behalf Of Jean-Michel Hautbois
>>
>>2012/5/30 Jean-Michel Hautbois <jhautbois@gmail.com>:
>>
>>I used vmstat in order to see the differences between the two kernels.
>>The main difference is the number of interrupts per second.
>>I have an average of 87500 on 3.2 and 7500 on 2.6, 10 times lower !
>>I suspect the be2net driver to be the main cause, and I checkes the
>>/proc/interrupts file in order to be sure.
>>
>>I have for eth1-tx on 2.6.26 about 2200 interrupts per second and 23000 on 3.2.
>>BTW, it is named eth1-q0 on 3.2 (and tx and rx are the same IRQ)
>>whereas there is eth1-rx0 and eth1-tx on 2.6.26.
>
> Yes, there is an issue with be2net interrupt mitigation in the recent code with
> RX and TX on the same Evt-Q (commit 10ef9ab4). The high interrupt rate happens when a TX blast is
> done while RX is relatively silent on a queue pair. Interrupt rate due to TX completions is not being
> mitigated.
>
> I have a fix and will send it out soon..
>
> thanks,
> -Sathya

It seems this issue exist with mellanox mlx4 too...
I have a bond between eth1 (be2net) and eth9 (mlx4_en) and I can
switch from one to the other using ifenslave.
Setting a queue of 4000 on be2net works well in my use case, when I
switch to mlx4 based NIC which has a default queue len of 1000, I have
dropped packets too (less than be2net, but about 30-50 per second).
Setting a queue len of 4000 on mlx4 works too, but the number of
interrupts is similar.
The use case is the same : Lots of TX, no RX.

JM
