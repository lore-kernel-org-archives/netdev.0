From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 18:07:49 +0100
Message-ID: <1298912869.2941.687.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110228141322.GF9763@canuck.infradead.org>
	 <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51156 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab1B1RKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 12:10:21 -0500
Received: by fxm17 with SMTP id 17so3940418fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 09:10:20 -0800 (PST)
In-Reply-To: <20110228163742.GH9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 11:37 -0500, Thomas Graf a =C3=A9c=
rit :

> How do you measure the qps? The output of queryperf? That is not alwa=
ys
> accurate. I run rdnc stats twice and then calculate the qps based on =
the
> counter "queries resulted in successful answer" diff and timestamp di=
ff.
>=20

I have some custom ethernet/system monitoring package installed, so I
get packet rates from it.

I appears my two source machines were not fast enough. (One had LOCKDEP
kernel).

I now reach 320 kqps, even if I force NIC interrupts through one cpu
only.

> The numbers differ a lot depending on the architecture we test on.
>=20
> F.e. on a 12 core AMD with 2 NUMA nodes:
>=20
> 2.6.32   named -n 1: 37.0kqps
>          named:       3.8kqps (yes, no joke, the socket receive buffe=
r is
>                                always full and the kernel drops pkts)

Yes, this old kernel miss commit c377411f2494a93 added in 2.6.35
(net: sk_add_backlog() take rmem_alloc into account)

Quoting the change log :

 Under huge stress from a multiqueue/RPS enabled NIC, a single flow udp
 receiver can now process ~200.000 pps (instead of ~100 pps before the
 patch) on a 8 core machine.

>=20
> 2.6.38-rc5+ with Herbert's patches:
>         named -n 1:  36.9kqps
>         named:      222.0kqps


