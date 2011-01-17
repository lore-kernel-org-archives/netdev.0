From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps testing questions
Date: Mon, 17 Jan 2011 10:53:14 +0100
Message-ID: <1295257994.3335.6.camel@edumazet-laptop>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mi wake <wakemi.wake@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:55510 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab1AQJxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 04:53:19 -0500
Received: by ewy5 with SMTP id 5so2427538ewy.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 01:53:18 -0800 (PST)
In-Reply-To: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 17:43 +0800, mi wake a =C3=A9crit :
> I do a rps(Receive Packet Steering) testing on centos 5.5 with  kerne=
l 2.6.37.
> cpu: 8 core Intel.
> ethernet adapter: bnx2x
>=20
> Problem statement:
> enable rps with:
> echo "ff" > /sys/class/net/eth2/queues/rx-0/rps_cpus.
>=20

bnx2x with one queue only ?

> running 1 instances of netperf TCP_RR: netperf  -t TCP_RR -H 192.168.=
0.1 -c -C
> without rps: 9963.48(Trans Rate per sec)
> with rps:  9387.59(Trans Rate per sec)
>=20
> I do ab and tbench testing also find there is less tps with enable
> rps.but,there is more cpu using when with enable rps.when with enable
> rps =EF=BC=8Csoftirqs is blanced  on cpus.

Really ? that seems unlikely with your one flow test, unless you _also_
have hardware IRQS hitting all your cpus. (That would be very bad)

>=20
> is there something wrong with my test=EF=BC=9F
> --

If you test with one flow, RPS brings nothing at all. Better handle the
packet directly from the cpu handling the hardware IRQ (and NAPI)

You better make sure hardware IRQ are on one cpu, instead of many cpus.



