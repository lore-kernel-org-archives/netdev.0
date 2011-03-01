From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] udp: Add lockless transmit path
Date: Tue, 01 Mar 2011 06:30:41 +0100
Message-ID: <1298957441.2676.7.camel@edumazet-laptop>
References: <20110227110614.GA6246@gondor.apana.org.au>
	 <E1Pu1TJ-0005RA-DV@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37414 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab1CAFaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:30:46 -0500
Received: by wyg36 with SMTP id 36so4346663wyg.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:30:45 -0800 (PST)
In-Reply-To: <E1Pu1TJ-0005RA-DV@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:41 +0800, Herbert Xu a =C3=A9cr=
it :
> udp: Add lockless transmit path
>=20
> The UDP transmit path has been running under the socket lock
> for a long time because of the corking feature.  This means that
> transmitting to the same socket in multiple threads does not
> scale at all.
>=20
> However, as most users don't actually use corking, the locking
> can be removed in the common case.
>=20
> This patch creates a lockless fast path where corking is not used.
>=20
> Please note that this does create a slight inaccuracy in the
> enforcement of socket send buffer limits.  In particular, we
> may exceed the socket limit by up to (number of CPUs) * (packet
> size) because of the way the limit is computed.
>=20
> As the primary purpose of socket buffers is to indicate congestion,
> this should not be a great problem for now.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---

So far I found no obvious problem, and got pretty impressive results.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



