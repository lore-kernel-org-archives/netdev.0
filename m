From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC [PATCH 3/3] TCP_DEFER_ACCEPT updates: more accurate timers
 and	resets
Date: Sat, 01 Mar 2008 11:53:48 +0100
Message-ID: <47C935BC.9060409@cosmosbay.com>
References: <1204076973.15970.37.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:33222
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752644AbYCAKxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 05:53:54 -0500
In-Reply-To: <1204076973.15970.37.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McManus a =E9crit :
> Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
>=20
>   Change TCP_DEFER_ACCEPT implementation so that it transitions a
>     connection to ESTABLISHED after handshake is complete instead of
>     leaving it in SYN-RECV until some data arrvies. Place connection =
in
>     accept queue when first data packet arrives from slow path.
>=20
>     Benefits:
>      - established connection is now reset if it never makes it to th=
e accept
>      queue
>=20
>      - diagnostic state of established matches with the packet traces
>        showing completed handshake
>=20
>     - TCP_DEFER_ACCEPT timeouts are expressed in seconds and can now =
be
>       enforced with reasonable accuracy instead of rounding up to nex=
t
>       exponential back-off of syn-ack retry.

This all makes sense Patrick.

Your patch is quite large and difficult to review (for me :) )

1) Adding "struct tcp_deferred_accept_info" on "struct tcp_sock" (24 by=
tes on=20
64 bit arches) is a rather high cost to pay for an obscure TCP_DEFER_AC=
CEPT.

But then, many "struct tcp_sock" fields are used only at socket establi=
shment.

2) About MAX_TCP_ACCEPT_DEFERRED test in do_tcp_setsockopt(), I am not =
sure we=20
can return -EINVAL.

setsockopt(TCP_DEFER_ACCEPT, 100000) is a hint given by application, an=
d could=20
be mapped to setsockopt(TCP_DEFER_ACCEPT, 65535) silently.

