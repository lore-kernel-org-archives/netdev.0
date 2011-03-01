From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 14:52:46 +0100
Message-ID: <1298987566.3284.105.camel@edumazet-laptop>
References: <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
	 <1298984609.3284.98.camel@edumazet-laptop>
	 <20110301131823.GB8028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39220 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab1CANyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:54:45 -0500
Received: by fxm17 with SMTP id 17so4813064fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 05:54:44 -0800 (PST)
In-Reply-To: <20110301131823.GB8028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 21:18 +0800, Herbert Xu a =C3=A9crit :

> Interesting.  So I wonder which lock is showing up at the top
> of the profile with a single socket then.  As it's definitely
> going away with multiple sockets, that means it's not the TX
> queue lock.
>=20

This CPU also runs named process, so this is socket lock and receive
queue lock.

Named threads all do : recvmsg()/sendmsg() in a loop, so all are waitin=
g
a frame before doing some work.

Because of single receive queue, extra context switches occur (all
threads but one have to sleep again per query)

=46or about 80 kqps (standard linux-2.6 kernel, no patches), I have
following vmstat output

procs -----------memory---------- ---swap-- -----io---- --system-- ----=
cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us s=
y id wa
 4  1      0 2184048  63496 1595056    0    0     0  2060 64592 294528 =
19 11 67  4
 6  1      0 2184040  63496 1595056    0    0     0  1960 64686 293928 =
19 11 66  4
 3  1      0 2184040  63496 1595056    0    0     0  2344 64556 294268 =
20 11 66  4
 4  1      0 2184040  63496 1595056    0    0     0  2400 64626 293859 =
19 11 67  4



