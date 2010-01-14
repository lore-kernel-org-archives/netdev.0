From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 14 Jan 2010 13:50:51 +0100
Message-ID: <4B4F132B.7020001@gmail.com>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de> <20100112.121607.39835310.davem@davemloft.net> <201001141250.27287.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38807 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab0ANMu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 07:50:56 -0500
In-Reply-To: <201001141250.27287.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/01/2010 12:50, Torsten Schmidt a =E9crit :
=2E
> Our company is more interested in IP DiffServ traffic accounting.
> So we simply need a fast mechanism which generates IP DiffServ traffi=
c
> statistics, without setting the network interface in promiscuous mode=
,
> (which softflowd ore tcpdump does).

tcpdump can work in non promiscuous mode (-p). Anyway, switched network=
s makes
promiscuous a non issue nowaday.

>=20
> So first idea was to implement a virtual file e.g. called /proc/net/i=
p_dscp.
> If the main line peoples are not interested in, i will no longer send=
 these
> patches.=20

Problem is, you might need many sets of counters...

1) General (for each net namespace ...)
2) Per interface
3) Per protocol ?

=46or performance reasons, SNMP counters are per cpu, so each set would=
 be very large.

In any case, dont add yet another /proc/net file, this is considered as=
 a hacky way to do
these things today.

Thanks
