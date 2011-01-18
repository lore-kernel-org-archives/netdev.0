From: mi wake <wakemi.wake@gmail.com>
Subject: Re: rps testing questions
Date: Tue, 18 Jan 2011 16:34:08 +0800
Message-ID: <AANLkTi=FBM0v0Cs+Mx4Qxddzm8XV3JzjiR64kRVLgs7H@mail.gmail.com>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
	<1295257994.3335.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:38678 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab1ARIeJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 03:34:09 -0500
Received: by gwj20 with SMTP id 20so2202748gwj.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 00:34:09 -0800 (PST)
In-Reply-To: <1295257994.3335.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/17 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 17 janvier 2011 =A8=A4 17:43 +0800, mi wake a =A8=A6crit :
>> I do a rps(Receive Packet Steering) testing on centos 5.5 with  kern=
el 2.6.37.
>> cpu: 8 core Intel.
>> ethernet adapter: bnx2x
>>
>> Problem statement:
>> enable rps with:
>> echo "ff" > /sys/class/net/eth2/queues/rx-0/rps_cpus.
>>
>
> bnx2x with one queue only ?
>
>> running 1 instances of netperf TCP_RR: netperf  -t TCP_RR -H 192.168=
=2E0.1 -c -C
>> without rps: 9963.48(Trans Rate per sec)
>> with rps:  9387.59(Trans Rate per sec)
>>
>> I do ab and tbench testing also find there is less tps with enable
>> rps.but,there is more cpu using when with enable rps.when with enabl=
e
>> rps =A3=ACsoftirqs is blanced  on cpus.
>
> Really ? that seems unlikely with your one flow test, unless you _als=
o_
> have hardware IRQS hitting all your cpus. (That would be very bad)
>
>>
>> is there something wrong with my test=A3=BF
>> --
>
> If you test with one flow, RPS brings nothing at all. Better handle t=
he
> packet directly from the cpu handling the hardware IRQ (and NAPI)
>
> You better make sure hardware IRQ are on one cpu, instead of many cpu=
s.
>
>
 I have checked that bnx2x with one queue only and hardware IRQ are on =
one cpu.
 I do testing again with more flows.when I use ip range from 192.x.x.1
to 192.x.x.200 to send syn packets.
Server can deal with :
 without rps + rfs : 18M/s
 with     rps +rfs : 21M/s.
Maybe  in previous tests,there are less flow. I will continue testing.
Thank you!
