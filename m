From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 22:02:34 +0200
Message-ID: <1319140954.2854.12.camel@edumazet-laptop>
References: <1319138186.2854.5.camel@edumazet-laptop>
	 <20111020.155002.555965434596006787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64475 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab1JTUCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:02:39 -0400
Received: by wwe6 with SMTP id 6so4703675wwe.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:02:38 -0700 (PDT)
In-Reply-To: <20111020.155002.555965434596006787.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 15:50 -0400, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 20 Oct 2011 21:16:26 +0200
>=20
> > Since commit 356f039822b (TCP: increase default initial receive
> > window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) segm=
ents.
> >=20
> > Change tcp_fixup_rcvbuf() to reflect this change, even if no real c=
hange=20
> > is expected, since sysctl_tcp_rmem[1] =3D 87380 and this value
> > is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>  ...
> > +	unsigned int mss =3D min_t(unsigned int, tp->advmss, 1460);
>=20
> I don't understand where this calculation comes from, and even if it
> should be obvious it isn't to me and deserves a mention in the commit
> message at a minimum.

This is the calculation done in commit 356f039822b as well.

The window is 10*MSS, but no more than 14600

On loopback, this matters, because we could end with rcvmem=3D219680
