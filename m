From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 19:39:37 +0100
Message-ID: <1291142377.2904.176.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
	 <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59647 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab0K3Sjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:39:42 -0500
Received: by eye27 with SMTP id 27so2960162eye.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 10:39:41 -0800 (PST)
In-Reply-To: <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 10:31 -0800, Tom Herbert a =C3=A9crit =
:
> On Mon, Nov 29, 2010 at 10:14 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > I was thinking of using XPS tx_queue->cpu mapping to eventually all=
ocate
> > memory with correct NUMA affinities, for qdisc/class stuff for exam=
ple.
> >
>=20
> An interesting idea, but the real question is can this be used for al=
l
> queue related allocations.  This includes those that drivers allocate
> which are probably done in initialization.
>=20

This would need a callback to device, to eventually re-allocate its rin=
g
buffer (or whatever data structures it allocated). Probably worth it,
considering size of txbd on some NICS (up to one cache line per entry)

Right now, they tend to allocate their memory on a single NUMA node, so
it is a problem.



