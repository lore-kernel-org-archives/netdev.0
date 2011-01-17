From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: rps testing questions
Date: Mon, 17 Jan 2011 13:08:33 +0000
Message-ID: <1295269713.3700.5.camel@localhost>
References: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mi wake <wakemi.wake@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36720 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab1AQNIz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 08:08:55 -0500
In-Reply-To: <AANLkTin1pC=auiFBt83YomdhVgUO8uSdvq=tPaDu0=3U@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-17 at 17:43 +0800, mi wake wrote:
> I do a rps(Receive Packet Steering) testing on centos 5.5 with  kerne=
l 2.6.37.
> cpu: 8 core Intel.
> ethernet adapter: bnx2x
>=20
> Problem statement:
> enable rps with:
> echo "ff" > /sys/class/net/eth2/queues/rx-0/rps_cpus.
>=20
> running 1 instances of netperf TCP_RR: netperf  -t TCP_RR -H 192.168.=
0.1 -c -C
> without rps: 9963.48(Trans Rate per sec)
> with rps:  9387.59(Trans Rate per sec)
>=20
> I do ab and tbench testing also find there is less tps with enable
> rps.but,there is more cpu using when with enable rps.when with enable
> rps =EF=BC=8Csoftirqs is blanced  on cpus.
>=20
> is there something wrong with my test=EF=BC=9F

In addition to what Eric said, check the interrupt moderation settings
(ethtool -c/-C options).  One-way latency for a single request/response
test will be at least the interrupt moderation value.

I haven't tested RPS by itself (Solarflare NICs have plenty of hardware
queues) so I don't know whether it can improve latency.  However, RFS
certainly does when there are many flows.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

