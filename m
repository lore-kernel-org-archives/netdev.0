From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Thu, 18 Mar 2010 14:23:16 -0700
Message-ID: <20100318142316.0466c35e@nehalam>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<1268773227.2932.34.camel@edumazet-laptop>
	<20100316.141311.262178287.davem@davemloft.net>
	<412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	<1268809673.2932.62.camel@edumazet-laptop>
	<412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	<1268834957.2899.352.camel@edumazet-laptop>
	<65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
	<4BA16AB8.3090800@google.com>
	<1268893232.2894.65.camel@edumazet-laptop>
	<412e6f7f1003172348s1f113734h882779d9acd08ddc@mail.gmail.com>
	<1268944621.2894.160.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47043 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619Ab0CRXvp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:51:45 -0400
In-Reply-To: <1268944621.2894.160.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Mar 2010 21:37:01 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 18 mars 2010 =C3=A0 14:48 +0800, Changli Gao a =C3=A9crit :
> > sigh! How about adding file for each cpu weight setting.
> >=20
> > .../rx-0/rps_cpu0...n
> >=20
> > BTW: I think exporting the hook of hash function will help in some
> > case. So users can choose which hash to use depend on their
> > applications. I know FreeBSD supports hash based on flow, source or
> > CPU. Some network application have multiple instances for taking fu=
ll
> > advantage of the SMP/C hardware, and each instance binds to a speci=
al
> > CPU/Core, so they need some kind of load distributing algorithm for
> > load balancing.
> >=20
>=20
> exporting skb->rxhash would not be that interesting, but the cpu numb=
er
> of last cpu handling the skb and queuing it on socket might be useful=
l.
>=20
> > For example, memcached uses hash based on key, and its developer ma=
y
> > implement a hash function for RPS. Then it apply the following
> > iptables rule:
> >=20
> > iptables -A PREROUTING -t nat -m cpu --cpuid 0 -m tcp --dport 1234
> > --REDIRECT 8081
> > iptables -A PREROUTING -t nat -m cpu --cpuid 0 -m tcp --dport 1234
> > --REDIRECT 8082
>=20
> Well, this would work only if load is evenly distributed to all cpus.
> But you understand this kind of setup has nothing to do with RPS.
> Going through REDIRECT (and conntrack) would kill performance, and wo=
uld
> not work for unpriviledged users (iptables changes forbidden).
> It wont scale for future machines with 64 or 128 cores.
>=20
> maybe some extension of REDIRECT target, being able to add cpu number=
 to
> destination port :
>=20
> iptables -A PREROUTING -t nat -m tcp --dport 1234 --REDIRECT 1234+cpu
>=20
>=20
> > ...
> >=20
> > No other things to change, it can take full advantage of the
> > underlying hardware transparently.
> >=20
>=20
> Coming to mind would be a new socket operation, "bind to cpu", like t=
he
> "bind to device" operation.
>=20
> This would work without need for netfilter (and permission to change =
its
> rules)
>=20
> But it would require changes to applications, to fully exploit SMP
> capabilities of machine.

Let's not make a useful feature (RPS) unusable by making it so complex
that mortals can't understand it.


--=20
