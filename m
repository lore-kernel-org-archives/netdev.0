From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Thu, 15 Jul 2010 18:54:57 +0200
Message-ID: <1279212897.2496.133.camel@edumazet-laptop>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	 <1279078875.2444.103.camel@edumazet-laptop>
	 <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
	 <1279198139.4510.710.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47465 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933756Ab0GOQzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 12:55:02 -0400
Received: by wyb42 with SMTP id 42so913015wyb.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 09:55:01 -0700 (PDT)
In-Reply-To: <1279198139.4510.710.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 juillet 2010 =C3=A0 08:48 -0400, jamal a =C3=A9crit :
> On Wed, 2010-07-14 at 12:17 +0800, Changli Gao wrote:
>=20
> > Thanks, I'll try. It is a write critical section, and for me it is
> > difficult to convert this lock to RCU. Could you show me some
> > examples?
>=20
> RCU maybe a little trickier here Eric. Actions could be shared i.e.=20
> example, it is possible to have a policer action restricting rates fo=
r a
> group of flows  across multiple netdevices etc. Since action stats ge=
t
> written to by different CPUs concurrently. It could be probably done =
if
> one was to implement per-cpu stats which get summed-up when user spac=
e
> asks.

It's certainly tricky, but is act_cpu useful in its current shape, base=
d
on an infrastructure that had to use a lock because of exact
rates/accounting ?

I dont understand how distributing packets to different cpus, if going
through a central lock can be an improvement. Changli patches are most
of the time not documented, and no performance data is provided.

Even if we solve this locking problem, using percpu variables, act_cpu
hits another problem :

The socket refcount, taken by the 'master' cpu, and released by the
consumer cpu.

RFS provides sort of a lazy flow-based distribution without central loc=
k
or cache line ping pongs. Why Changli dont use this, we dont know yet.



