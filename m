From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently
 runsoftirqnetwork code on SMP
Date: Tue, 25 Sep 2007 09:03:33 -0700
Message-ID: <20070925090333.11beebb2@freepuppy.rosehill>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
	<1190551422.4256.36.camel@localhost>
	<007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <hadi@cyberus.ca>, "David Miller" <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<pekkas@netcore.fi>, <jmorris@namei.org>, <kaber@coreworks.de>,
	<iceburgue@gmail.com>, "John Ye" <johny@asimco.com.cn>
To: "john ye" <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33882 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbXIYQGU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 12:06:20 -0400
In-Reply-To: <007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Sep 2007 23:36:25 +0800
"john ye" <johny@asimco.com.cn> wrote:

> Jamal,
>=20
> You pointed out a key point: it's NOT acceptable if massive packet re=
-ordering couldn=C2=A1=C2=AFt be avoided.
> I debugged function tcp_ofo_queue in net/ipv4/tcp_input.c & monitored=
 out_of_order_queue, found that re-ordering
> becomes unacceptable with the softirq load grows.
>=20
> It's simple to avoid out-of-order packets by changing random dispatch=
 into dispatch based on source ip address.
> e.g. cpu =3D iph->saddr % nr_cpus. while cpu is like a hash entry.
> Considering that BS patch is mainly used on server with many incoming=
 connections,
> dispatch by IP should balance CPU load well.
>=20
> The test is under way, it's not bad so far.
> The queue spin_lock seems not cost much.
>=20
> Below is the bcpp beautified module code. Last time code mess is caus=
ed by outlook express which killed tabs.
>=20
> Thanks.
>=20
> John Ye

There is a standard hash called RSS, that many drivers support because =
it is
used by other operating systems.=20
