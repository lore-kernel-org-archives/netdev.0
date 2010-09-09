From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 9 Sep 2010 09:42:11 +0000
Message-ID: <20100909094211.GA8404@ff.dom.local>
References: <20100909064222.GA6951@ff.dom.local> <1284015345.2428.37.camel@edumazet-laptop> <20100909070926.GB6951@ff.dom.local> <20100909072453.GA7383@ff.dom.local> <20100909090816.GA7450@ff.dom.local> <1284024237.2589.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49164 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab0IIJmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 05:42:19 -0400
Received: by bwz11 with SMTP id 11so939396bwz.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 02:42:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1284024237.2589.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 11:23:57AM +0200, Eric Dumazet wrote:
> Le jeudi 09 septembre 2010 ?? 09:08 +0000, Jarek Poplawski a =E9crit =
:
> > xactly, without "after some time" I couldn't tell this
> > either. Is seems some barriers might have been changed, but I might
> > be wrong. Anyway, it would be nice to have some comment on that in
> > the changelog.
>=20
> Jarek, cmpxchg() is a very strong primitive, as documented
> in Documentation/memory-barriers.txt :
>=20
> <begin of quote>
>=20
> Any atomic operation that modifies some state in memory and returns i=
nformation
> about the state (old or new) implies an SMP-conditional general memor=
y barrier
> (smp_mb()) on each side of the actual operation (with the exception o=
f
> explicit lock operations, described later).  These include:
>=20
>         xchg();
>         cmpxchg();
> ...
> These are used for such things as implementing LOCK-class and UNLOCK-=
class
> operations and adjusting reference counters towards object destructio=
n, and as
> such the implicit memory barrier effects are necessary.
>=20
> <end of quote>
>=20
> Its not needed to document each cmpxchg() use, because of these
> strong requirements.

OK! I should remember this until "after some time". ;-)

Thanks for the explanation,
Jarek P.
