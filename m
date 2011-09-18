From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Sun, 18 Sep 2011 21:35:44 +0200
Message-ID: <1316374544.31335.16.camel@edumazet-laptop>
References: <4E696FD0.7060702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f170.google.com ([74.125.82.170]:47835 "EHLO
	mail-wy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756184Ab1IRTfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 15:35:52 -0400
Received: by wyg8 with SMTP id 8so8239322wyg.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 12:35:51 -0700 (PDT)
In-Reply-To: <4E696FD0.7060702@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 septembre 2011 =C3=A0 09:45 +0800, Yan, Zheng a =C3=A9cr=
it :
> Hi all,
>=20
> I found a check in tcp_is_sackblock_valid() is suspicious. It against
> its comment and RFC. I think the correct check should be:
>=20
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 385c470..a5d01b1 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_so=
ck *tp, int is_dsack,
>                 return 0;
> =20
>         /* ...Then it's D-SACK, and must reside below snd_una complet=
ely */
> -       if (!after(end_seq, tp->snd_una))
> +       if (after(end_seq, tp->snd_una))
>                 return 0;
> =20
>         if (!before(start_seq, tp->undo_marker))
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

This bug was introduced in 2.6.24 by commit 5b3c9882
