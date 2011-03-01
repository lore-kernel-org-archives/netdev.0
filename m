From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 11:33:22 +0100
Message-ID: <1298975602.3284.13.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110228141322.GF9763@canuck.infradead.org>
	 <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63987 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755686Ab1CAKd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 05:33:27 -0500
Received: by fxm17 with SMTP id 17so4646970fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 02:33:26 -0800 (PST)
In-Reply-To: <20110301101955.GI9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 05:19 -0500, Thomas Graf a =C3=A9crit :
> On Mon, Feb 28, 2011 at 06:07:49PM +0100, Eric Dumazet wrote:
> > > The numbers differ a lot depending on the architecture we test on=
=2E
> > >=20
> > > F.e. on a 12 core AMD with 2 NUMA nodes:
> > >=20
> > > 2.6.32   named -n 1: 37.0kqps
> > >          named:       3.8kqps (yes, no joke, the socket receive b=
uffer is
> > >                                always full and the kernel drops p=
kts)
> >=20
> > Yes, this old kernel miss commit c377411f2494a93 added in 2.6.35
> > (net: sk_add_backlog() take rmem_alloc into account)
>=20
> I retested with net-2.6 w/o Herbert's patch:
>=20
> named -n 1: 36.9kqps
> named:      16.2kqps

Thats better ;)

You could do "cat /proc/net/udp" to check if drops occur on port 53
socket (last column)

But maybe your queryperf is limited to few queries in flight (default i=
s
20 per queryperf instance)=20


