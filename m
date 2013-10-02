From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sndbuf autotuning improvements
Date: Wed, 02 Oct 2013 16:46:00 -0400 (EDT)
Message-ID: <20131002.164600.347083935801850982.davem@davemloft.net>
References: <1380648224.19002.32.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3JBUqE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 16:46:04 -0400
In-Reply-To: <1380648224.19002.32.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Oct 2013 10:23:44 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> tcp_fixup_sndbuf() is underestimating initial send buffer requirement=
s.
>=20
> It was not noticed because big GSO packets were escaping the limitati=
on,
> but with smaller TSO packets (or TSO/GSO/SG off), application hits
> sk_sndbuf before having a chance to fill enough packets in socket wri=
te
> queue.
>=20
> - initial cwnd can be bigger than 10 for specific routes
>=20
> - SKB_TRUESIZE() is a bit under real needs in some cases,
>   because of power-of-two rounding in kmalloc()
>=20
> - Fast Recovery (RFC 5681 3.2) : Cubic needs 70% factor
>=20
> - Extra cushion (application might react slowly to POLLOUT)
>=20
> tcp_v4_conn_req_fastopen() needs to call tcp_init_metrics() before
> calling tcp_init_buffer_space()
>=20
> Then we realize tcp_new_space() should call tcp_fixup_sndbuf()
> instead of duplicating this stuff.
>=20
> Rename tcp_fixup_sndbuf() to tcp_sndbuf_expand() to be more
> descriptive.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Maciej =AFenczykowski <maze@google.com>

I assume this is meant for net-next as that is where this applies
cleanly.

Applied, thanks.
