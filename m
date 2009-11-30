From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with tcp (2.6.31) as first
Date: Mon, 30 Nov 2009 10:12:19 +0100
Message-ID: <4B138C73.8040401@gmail.com>
References: <4B0EF273.4030003@gmail.com>	<alpine.DEB.2.00.0911262327130.24189@melkinpaasi.cs.helsinki.fi>	<4B0F0466.8080006@gmail.com> <20091129.233447.60856273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, ole@ans.pl, herbert@gondor.apana.org.au,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36020 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbZK3JMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 04:12:50 -0500
In-Reply-To: <20091129.233447.60856273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Nov 2009 23:42:46 +0100
>=20
>> Following patch solves this problem, but maybe we need a flag
>> (a la sk->sk_userlocks |=3D SOCK_WINCLAMP_LOCK;)
>> in case user set window_clamp.
>> Or just document the clearing after a tcp disconnect ?
>>
>> [PATCH] tcp: tcp_disconnect() should clear window_clamp
>>
>> Or reuse of socket possibly selects a small window, wscale =3D 0 for=
 next connection.
>=20
> Eric, can you post this with proper signoff to netdev?
>=20
> Thanks.

Sure, here it is.

Thanks

[PATCH] tcp: tcp_disconnect() should clear window_clamp

NFS can reuse its TCP socket after calling tcp_disconnect().
We noticed window scaling was not negotiated in SYN packet of next conn=
ection request.

=46ix is to clear tp->window_clamp in tcp_disconnect().

Reported-by: Krzysztof Oledzki <ole@ans.pl>
Tested-by: Krzysztof Oledzki <ole@ans.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1813bc..d7a884c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2059,6 +2059,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_cnt =3D 0;
 	tp->bytes_acked =3D 0;
+	tp->window_clamp =3D 0;
 	tcp_set_ca_state(sk, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	inet_csk_delack_init(sk)
