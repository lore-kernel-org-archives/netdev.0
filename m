From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 09 Sep 2010 11:23:57 +0200
Message-ID: <1284024237.2589.15.camel@edumazet-laptop>
References: <20100909064222.GA6951@ff.dom.local>
	 <1284015345.2428.37.camel@edumazet-laptop>
	 <20100909070926.GB6951@ff.dom.local> <20100909072453.GA7383@ff.dom.local>
	 <20100909090816.GA7450@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38719 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab0IIJYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 05:24:01 -0400
Received: by fxm16 with SMTP id 16so727446fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 02:24:00 -0700 (PDT)
In-Reply-To: <20100909090816.GA7450@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 septembre 2010 =C3=A0 09:08 +0000, Jarek Poplawski a =C3=A9=
crit :
> xactly, without "after some time" I couldn't tell this
> either. Is seems some barriers might have been changed, but I might
> be wrong. Anyway, it would be nice to have some comment on that in
> the changelog.

Jarek, cmpxchg() is a very strong primitive, as documented
in Documentation/memory-barriers.txt :

<begin of quote>

Any atomic operation that modifies some state in memory and returns inf=
ormation
about the state (old or new) implies an SMP-conditional general memory =
barrier
(smp_mb()) on each side of the actual operation (with the exception of
explicit lock operations, described later).  These include:

        xchg();
        cmpxchg();
=2E..
These are used for such things as implementing LOCK-class and UNLOCK-cl=
ass
operations and adjusting reference counters towards object destruction,=
 and as
such the implicit memory barrier effects are necessary.

<end of quote>

Its not needed to document each cmpxchg() use, because of these
strong requirements.



