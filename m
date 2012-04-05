From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Thu, 05 Apr 2012 19:05:09 -0400 (EDT)
Message-ID: <20120405.190509.409578034793502486.davem@davemloft.net>
References: <1333488689.18626.331.camel@edumazet-glaptop>
	<20120403.173614.962252876842659412.davem@davemloft.net>
	<1333631135.18626.606.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab2DEXFX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:05:23 -0400
In-Reply-To: <1333631135.18626.606.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Apr 2012 15:05:35 +0200

> Hmm, thinking again about this, I did more tests and it appears we ne=
ed
> to differentiate the SPLICE_F_MORE flag (user request) and the intern=
al
> marker provided by splice logic (handling a batch of pages)
>=20
> A program doing splice(... SPLICE_F_MORE) should really call tcp_push=
()
> at the end of its work.

This is the kind of problem I was hoping we weren't introducing
when I asked about sendfile() et al. the other day :-)

> [PATCH] tcp: tcp_sendpages() should call tcp_push() once
>=20
> commit 2f533844242 (tcp: allow splice() to build full TSO packets) ad=
ded
> a regression for splice() calls using SPLICE_F_MORE.
>=20
> We need to call tcp_flush() at the end of the last page processed in
> tcp_sendpages(), or else transmits can be deferred and future sends
> stall.
>=20
> Add a new internal flag, MSG_SENDPAGE_NOTLAST, acting like MSG_MORE, =
but
> with different semantic.
>=20
> For all sendpage() providers, its a transparent change. Only
> sock_sendpage() and tcp_sendpages() can differentiate the two differe=
nt
> flags provided by pipe_to_sendpage()
>=20
> Reported-by: Tom Herbert <therbert@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Maciej =AFenczykowski <maze@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail>com>

Applied, thanks Eric.
