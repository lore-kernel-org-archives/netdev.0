From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 14:32:51 +0100
Message-ID: <1298899971.2941.281.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53547 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab1B1Nc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 08:32:56 -0500
Received: by fxm17 with SMTP id 17so3718376fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 05:32:55 -0800 (PST)
In-Reply-To: <20110228113659.GA20726@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:36 +0800, Herbert Xu a =C3=A9cr=
it :
> On Sun, Feb 27, 2011 at 07:06:14PM +0800, Herbert Xu wrote:
> > I'm working on this right now.
>=20
> OK I think I was definitely on the right track.  With the send
> patch made lockless I now get numbers which are even better than
> those obtained with running named with multiple sockets.  That's
> right, a single socket is now faster than what multiple sockets
> were without the patch (of course, multiple sockets may still
> faster with the patch vs. a single socket for obvious reasons,
> but I couldn't measure any significant difference).
>=20
> Also worthy of note is that prior to the patch all CPUs showed
> idleness (lazy bastards!), with the patch they're all maxed out.
>=20
> In retrospect, the idleness was simply the result of the socket
> lock scheduling away and was an indication of lock contention.
>=20

Now, input path can run without finding socket locked by xmit path, so
skb are queued into receive queue, not backlog one.

> Here are the patches I used.  Please don't them yet as I intend
> to clean them up quite a bit.
>=20
> But please do test them heavily, especially if you have an AMD
> NUMA machine as that's where scalability problems really show
> up.  Intel tends to be a lot more forgiving.  My last AMD machine
> blew up years ago :)

I am going to test them, thanks !


