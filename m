From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 14:45:20 +0100
Message-ID: <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40675 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186Ab1LWNpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 08:45:24 -0500
Received: by werm1 with SMTP id m1so3971541wer.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 05:45:23 -0800 (PST)
In-Reply-To: <1324645986.10184.571.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 08:13 -0500, John A. Sullivan =
III a
=C3=A9crit :
> On Fri, 2011-12-23 at 09:10 +0100, Eric Dumazet wrote:
> > Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 01:00 -0500, John A. Sulli=
van III a
> > =C3=A9crit :
> >=20
> > > Where might this 3000 ms delay be coming from?
> > >=20
> >=20
> > Certainly not from SFQ
> >=20
> > You could use tcpdump to check if delay is at egress or ingress sid=
e.
> >=20
> >=20
> >=20
> That's perplexing as well.  Tracing on the eth1 interface of the test
> devices, we see the packets going out with near perfect regularity at
> one second intervals and replies returning immediately.  They are als=
o
> completely in sequence so it is not as if we are matching packet 4 wi=
th
> packet 7 and seeing an immediate reply that is really offset by three
> seconds.
>=20
> Thus, the delay seems to be registered only in the ICMP application
> itself.  The CPU is virtually idle - very impressed with Debian's
> handling of interrupts on this old system would have been spending
> almost 60% on hardware interrupts.
>=20
> Another weird characteristic is that the delay is introduced graduall=
y
> over several seconds:
> 64 bytes from 192.168.223.84: icmp_req=3D4 ttl=3D64 time=3D58.0 ms
> 64 bytes from 192.168.223.84: icmp_req=3D5 ttl=3D64 time=3D52.4 ms
> 64 bytes from 192.168.223.84: icmp_req=3D6 ttl=3D64 time=3D48.7 ms
> 64 bytes from 192.168.223.84: icmp_req=3D7 ttl=3D64 time=3D118 ms
> 64 bytes from 192.168.223.84: icmp_req=3D8 ttl=3D64 time=3D834 ms
> 64 bytes from 192.168.223.84: icmp_req=3D9 ttl=3D64 time=3D896 ms
> 64 bytes from 192.168.223.84: icmp_req=3D10 ttl=3D64 time=3D897 ms
> 64 bytes from 192.168.223.84: icmp_req=3D11 ttl=3D64 time=3D1081 ms
> 64 bytes from 192.168.223.84: icmp_req=3D12 ttl=3D64 time=3D1257 ms
> 64 bytes from 192.168.223.84: icmp_req=3D13 ttl=3D64 time=3D1744 ms
> 64 bytes from 192.168.223.84: icmp_req=3D14 ttl=3D64 time=3D2107 ms
> 64 bytes from 192.168.223.84: icmp_req=3D15 ttl=3D64 time=3D2532 ms
> 64 bytes from 192.168.223.84: icmp_req=3D16 ttl=3D64 time=3D2948 ms
> 64 bytes from 192.168.223.84: icmp_req=3D17 ttl=3D64 time=3D3191 ms
> 64 bytes from 192.168.223.84: icmp_req=3D18 ttl=3D64 time=3D3163 ms
>=20
> While the delay builds, we can see the replied noticeably delayed
> however, once we hit 3000ms, the display updates one packet per secon=
d.
> I would expect one packet per three seconds unless we were interleavi=
ng
> packets but we are not according to the packet trace.
>=20
> So I am guessing an inbound queue but where? Ah, netem.  I pulled out
> netem and I seem vastly different results.  I get a very occasional l=
ost
> packet but no impact to latency:
>=20
> 64 bytes from 192.168.223.84: icmp_req=3D48 ttl=3D64 time=3D0.802 ms
> 64 bytes from 192.168.223.84: icmp_req=3D49 ttl=3D64 time=3D0.843 ms
> 64 bytes from 192.168.223.84: icmp_req=3D50 ttl=3D64 time=3D0.739 ms
> 64 bytes from 192.168.223.84: icmp_req=3D51 ttl=3D64 time=3D0.769 ms
> 64 bytes from 192.168.223.84: icmp_req=3D52 ttl=3D64 time=3D0.833 ms
> 64 bytes from 192.168.223.84: icmp_req=3D53 ttl=3D64 time=3D0.872 ms
> 64 bytes from 192.168.223.84: icmp_req=3D54 ttl=3D64 time=3D0.786 ms
> 64 bytes from 192.168.223.84: icmp_req=3D55 ttl=3D64 time=3D0.766 ms
> 64 bytes from 192.168.223.84: icmp_req=3D56 ttl=3D64 time=3D0.715 ms
> 64 bytes from 192.168.223.84: icmp_req=3D57 ttl=3D64 time=3D0.710 ms
> 64 bytes from 192.168.223.84: icmp_req=3D58 ttl=3D64 time=3D0.784 ms
> 64 bytes from 192.168.223.84: icmp_req=3D59 ttl=3D64 time=3D0.766 ms
> 64 bytes from 192.168.223.84: icmp_req=3D60 ttl=3D64 time=3D0.748 ms
>=20
>=20
> So netem has bufferbloat ;)  Thanks - John
>=20

1) What kernel version do you use ?

2) How many concurrent flows are running (number of netperf/netcat)

3) Remind that 'perturb xxx' introduces a temporary doubling of the
number of flows.

4) Had you disabled tso on eth1 ?
   (If not, you might send 64Kbytes packets, and at 400kbit, they take =
a
lot of time to transmit : more than one second ...)
