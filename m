From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 12:13:04 +0100
Message-ID: <1298977984.3284.15.camel@edumazet-laptop>
References: <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110228141322.GF9763@canuck.infradead.org>
	 <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63564 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794Ab1CALNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:13:11 -0500
Received: by fxm17 with SMTP id 17so4676087fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 03:13:10 -0800 (PST)
In-Reply-To: <20110301110708.GJ9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 06:07 -0500, Thomas Graf a =C3=A9crit :
> On Tue, Mar 01, 2011 at 11:33:22AM +0100, Eric Dumazet wrote:
> > > I retested with net-2.6 w/o Herbert's patch:
> > >=20
> > > named -n 1: 36.9kqps
> > > named:      16.2kqps
> >=20
> > Thats better ;)
> >=20
> > You could do "cat /proc/net/udp" to check if drops occur on port 53
> > socket (last column)
> >=20
> > But maybe your queryperf is limited to few queries in flight (defau=
lt is
> > 20 per queryperf instance)=20
>=20
> I tried -q 10, 20, 30, 50, 100. Starting with 20 I see drops, at q=3D=
50
> queryperf reports 99% drops.
>=20
> I also tested again on the Intel machine that did ~650kqps using SO_R=
EUSEPORT.
>=20
> net-2.6: 106.3kqps, 101.2kqps
> net-2.6 lockless udp: 251.7kqps, 250.4kqps
>=20
> I see drops in both test cases occur so I believe the rate supplied b=
y the
> clients is sufficient.
>=20
> The difference is obvious when looking at top and mpstat:
>=20
> UDP lockless (250kqps):
>=20
> Cpu0  : 46.4%us, 28.8%sy,  0.0%ni, 24.8%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu1  :  2.0%us,  1.3%sy,  0.0%ni,  3.0%id,  0.0%wa,  0.0%hi, 93.6%si=
,  0.0%st
> Cpu2  : 45.9%us, 28.2%sy,  0.0%ni, 25.9%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu3  : 50.0%us, 21.6%sy,  0.0%ni, 28.4%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu4  : 45.4%us, 27.8%sy,  0.0%ni, 26.5%id,  0.0%wa,  0.0%hi,  0.3%si=
,  0.0%st
> Cpu5  : 50.7%us, 23.2%sy,  0.0%ni, 26.1%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu6  : 45.2%us, 28.9%sy,  0.0%ni, 25.9%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu7  : 50.5%us, 22.0%sy,  0.0%ni, 27.5%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu8  : 45.3%us, 29.3%sy,  0.0%ni, 25.4%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu9  : 50.8%us, 20.8%sy,  0.0%ni, 28.3%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu10 : 46.1%us, 27.8%sy,  0.0%ni, 26.1%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu11 : 27.2%us, 11.3%sy,  0.0%ni,  3.3%id,  0.0%wa,  0.0%hi, 58.1%si=
,  0.0%st

Its a bit strange two cpus spend time in softirq, unless you have two
queryperf sources, and a multiqueue NIC, or maybe you use two NICS ?

Mind use "perf top -C 1" and "perf top -C 11" to check what these cpus
do ?



