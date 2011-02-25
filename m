From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 20:21:26 +0100
Message-ID: <1298661686.2659.106.camel@edumazet-laptop>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
	 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	 <20110225125644.GA9763@canuck.infradead.org>
	 <1298661495.14113.152.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46081 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932661Ab1BYTVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:21:39 -0500
Received: by bwz15 with SMTP id 15so2229073bwz.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:21:38 -0800 (PST)
In-Reply-To: <1298661495.14113.152.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 11:18 -0800, Rick Jones a =C3=A9=
crit :

> I think the idea is goodness, but will ask, was the (first) bottlenec=
k
> actually in the kernel, or was it in bind itself?  I've seen
> single-instance, single-byte burst-mode netperf TCP_RR do in excess o=
f
> 300K transactions per second (with TCP_NODELAY set) on an X5560 core.
>=20
> ftp://ftp.netperf.org/netperf/misc/dl380g6_X5560_rhel54_ad386_cxgb3_1=
=2E4.1.2_b2b_to_same_agg_1500mtu_20100513-2.csv
>=20
> and that was with now ancient RHEL5.4 bits...  yes, there is a bit of
> apples, oranges and kumquats but still, I am wondering if this didn't
> also "work around" some internal BIND scaling issues as well.
>=20

A single core can probably give 300K transactions.

But if you use several cores, accessing a single socket (the one bound
on port 53), then performance drops because of false sharing,
locking....



