From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tx-nocache-copy performance
Date: Mon, 06 Jan 2014 12:57:35 -0800
Message-ID: <1389041855.12212.210.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140106202754.GA5877@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:51399 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523AbaAFU5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 15:57:38 -0500
Received: by mail-yh0-f45.google.com with SMTP id v1so3736866yhn.18
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 12:57:38 -0800 (PST)
In-Reply-To: <20140106202754.GA5877@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 15:27 -0500, Benjamin Poirier wrote:
> Hi Tom,
>=20
> In commit "c6e1a0d net: Allow no-cache copy from user on transmit
> (v3.0-rc1)" you introduced the tx-nocache-copy performance optimizati=
on
> and set it to on by default. I've tried to reproduce your testcase, a=
s
> well as a few more, but I did not find any performance improvement fr=
om
> turning on tx-nocache-copy. Do you think tx-nocache-copy is still a
> worthwhile optimization and it should remain on by default? In which
> situations does it help?
>=20
> I've ran latency tests similar to the ones you described in the commi=
t
> log. I've also tested how the option affects single stream throughput
> tests. According to the results I obtained, it seems that
> tx-nocache-copy has either no impact (in the latency test) or a negat=
ive
> impact (in the throughput test).
>=20
> My test results follow. I tested using 3.12.6 on one Intel Xeon W3565
> and one i7 920 connected by ixgbe adapters. The results are from the
> Xeon, but they're similar on the i7. All numbers report the mean=C2=B1=
stddev
> over 10 runs of 10s.
>=20
> 1) latency tests similar to what you described
> There is no statistically significant difference between tx-nocache-c=
opy
> on/off.
> nic irqs spread out (one queue per cpu)
>=20
> 200x netperf -r 1400,1
> tx-nocache-copy off
>         692000=C2=B11000 tps
>         50/90/95/99% latency (us): 275=C2=B12/643.8=C2=B10.4/799=C2=B1=
1/2474.4=C2=B10.3
> tx-nocache-copy on
>         693000=C2=B11000 tps
>         50/90/95/99% latency (us): 274=C2=B11/644.1=C2=B10.7/800=C2=B1=
2/2474.5=C2=B10.7
>=20
> 200x netperf -r 14000,14000
> tx-nocache-copy off
>         86450=C2=B180 tps
>         50/90/95/99% latency (us): 334.37=C2=B10.02/838=C2=B11/2100=C2=
=B120/3990=C2=B140
> tx-nocache-copy on
>         86110=C2=B160 tps
>         50/90/95/99% latency (us): 334.28=C2=B10.01/837=C2=B12/2110=C2=
=B120/3990=C2=B120
>=20
> 2) single stream throughput tests
> tx-nocache-copy leads to higher service demand
>=20
>                         throughput  cpu0        cpu1        demand
>                         (Gb/s)      (Gcycle)    (Gcycle)    (cycle/B)
>=20
> nic irqs and netperf on cpu0 (1x netperf -T0,0 -t omni -- -d send)
>=20
> tx-nocache-copy off     9402=C2=B15      9.4=C2=B10.2                =
 0.80=C2=B10.01
> tx-nocache-copy on      9403=C2=B13      9.85=C2=B10.04              =
 0.838=C2=B10.004
>=20
> nic irqs on cpu0, netperf on cpu1 (1x netperf -T1,1 -t omni -- -d sen=
d)
>=20
> tx-nocache-copy off     9401=C2=B15      5.83=C2=B10.03   5.0=C2=B10.=
1     0.923=C2=B10.007
> tx-nocache-copy on      9404=C2=B12      5.74=C2=B10.03   5.523=C2=B1=
0.009 0.958=C2=B10.002
>=20
> -Benjamin

We raised this point last year, for same reasons.

http://www.spinics.net/lists/netdev/msg226501.html

I agree we should revert the default.

I'll post new perf data using latest net-next kernel and a bnx2x NIC.
