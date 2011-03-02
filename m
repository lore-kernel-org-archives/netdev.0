From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 02 Mar 2011 03:00:03 +0100
Message-ID: <1299031203.2930.26.camel@edumazet-laptop>
References: <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
	 <1298984609.3284.98.camel@edumazet-laptop>
	 <20110301131823.GB8028@gondor.apana.org.au>
	 <1298997084.3284.119.camel@edumazet-laptop>
	 <20110302002353.GA15009@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64835 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757811Ab1CBCAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 21:00:09 -0500
Received: by wyg36 with SMTP id 36so5330444wyg.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 18:00:08 -0800 (PST)
In-Reply-To: <20110302002353.GA15009@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 08:23 +0800, Herbert Xu a =C3=A9crit :
> On Tue, Mar 01, 2011 at 05:31:24PM +0100, Eric Dumazet wrote:
> >
> > This wont work for tcp streams, you could imagine a multi-threaded
> > application using a shared tcp socket as well. Too many OOO packets=
=2E
>=20
> Think about it, a TCP socket cannot be used by a multi-threaded app
> in a scalable way.

Well...

If you think about it, SO_REUSEPORT patch has exactly the same goal :=20

Let each thread use a different socket, to scale without kernel limits.

We cant modify TX selection each time we want to "fix" a problem withou=
t
changing user side (not adding an API), and as side effect make non
optimal applications become miserable.

We added RPS and XPS that works correctly if each socket is used by one
thread. Maybe we need to add an user API or automatically detect a
particular DGRAM socket is used by many different threads to :

0) Decide OOM is ok for this workload (many threads issuing send() at
the same time)

1) Setup several receive queues (up to num_possible_cpus())

2) Use an appropriate TX queue selection=20



