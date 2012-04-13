From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: bind() use stronger condition for
 bind_conflict
Date: Fri, 13 Apr 2012 09:30:58 +0200
Message-ID: <1334302258.9375.5.camel@edumazet-laptop>
References: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, fbl@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48365 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709Ab2DMHbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 03:31:07 -0400
Received: by eaaq12 with SMTP id q12so666875eaa.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 00:31:05 -0700 (PDT)
In-Reply-To: <1333698444-24144-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 avril 2012 =C3=A0 10:47 +0300, Alexandru Copot a =C3=A9c=
rit :
> From: Alex Copot <alex.mihai.c@gmail.com>
>=20
> We must try harder to get unique (addr, port) pairs when
> doing port autoselection for sockets with SO_REUSEADDR
> option set.
>=20

=2E..

Excellent patch Alex !

Two minor coding style problems in this part :

> +			if (!relax && reuse && sk2->sk_reuse &&
> +				sk2->sk_state !=3D TCP_LISTEN) {
> +				const __be32 sk2_rcv_saddr =3D sk_rcv_saddr(sk2);
> +				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
> +				    sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
> +					break;
> +			}
>  		}

Correct indentation, and one empty line after variable declaration :

	if (!relax && reuse && sk2->sk_reuse &&
	    sk2->sk_state !=3D TCP_LISTEN) {
		const __be32 sk2_rcv_saddr =3D sk_rcv_saddr(sk2);

		if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
		    sk2_rcv_saddr =3D=3D sk_rcv_saddr(sk))
			break;
	}



if (condition_one ||
    condition_two) {
	foo();

instead of

if (condition_on ||
	condition_two)
	foo();
