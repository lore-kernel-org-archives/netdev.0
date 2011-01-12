From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.4)
Date: Wed, 12 Jan 2011 01:04:00 +0100
Message-ID: <1294790640.3447.27.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam> <1294704031.4148.2.camel@edumazet-laptop>
	 <20110110171047.0796b6fb@nehalam> <1294726715.4148.8.camel@edumazet-laptop>
	 <1294727650.4148.20.camel@edumazet-laptop>  <20110111154806.6525e210@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755584Ab1ALAEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 19:04:05 -0500
Received: by wyb28 with SMTP id 28so16650wyb.19
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 16:04:04 -0800 (PST)
In-Reply-To: <20110111154806.6525e210@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 janvier 2011 =C3=A0 15:48 -0800, Stephen Hemminger a =C3=A9=
crit :
> On Tue, 11 Jan 2011 07:34:10 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > qdisc choke 11: parent 1:11 limit 70000b min 10000b max 30000b ewma=
 1 Plog 16 Scell_log 11
> >  Sent 62099201 bytes 112920 pkt (dropped 367712, overlimits 282668 =
requeues 0)=20
> >  rate 21344Kbit 4851pps backlog 39877589b 30001p requeues 0=20
> >   marked 0 early 282668 pdrop 0 other 0
>=20
> Maybe we should take over one of the red counters for the probabilist=
ic match drop.
>=20

aka chokedrop ;)

Anyway, iproute2 should be tweaked a bit, since limit/min/max are
packets, not bytes like RED. It would be nice to print probability
too ;)

AFAIK, requeue counter is not anymore used (On leaves at least), we
could re-use it for chokedrop

----
qdisc choke 11: parent 1:11 limit 70000p min 10000p max 30000p proba 0.=
08
  Sent 62099201 bytes 112920 pkt (dropped 367712, overlimits 282668 cho=
kedrop 999)=20
  rate 21344Kbit 4851pps backlog 39877589b 30001p chokedrop 999
  marked 0 early 282668 pdrop 0 other 0
=20


