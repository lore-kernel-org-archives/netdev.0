From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why not use the tcp_set_state() in inet_csk_listen_start()?
Date: Wed, 24 Mar 2010 10:02:03 +0100
Message-ID: <1269421323.3213.16.camel@edumazet-laptop>
References: <ffe582101003240113i15c48ff2g850bb209c825b11c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=E6=9D=A8=E7=A1=95?= <shanqn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:40726 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524Ab0CXJCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 05:02:09 -0400
Received: by bwz1 with SMTP id 1so2644483bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 02:02:07 -0700 (PDT)
In-Reply-To: <ffe582101003240113i15c48ff2g850bb209c825b11c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 mars 2010 =C3=A0 16:13 +0800, =E6=9D=A8=E7=A1=95 a =C3=A9=
crit :
> why use "sk->sk_state =3D TCP_LISTEN" rather than "tcp_set_state(sk, =
TCP_LISTEN)"?
>=20
> TIA :)
>=20
> int inet_csk_listen_start(struct sock *sk, const int nr_table_entries=
)
> {
> 	struct inet_sock *inet =3D inet_sk(sk);
> 	struct inet_connection_sock *icsk =3D inet_csk(sk);
> 	int rc =3D reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entr=
ies);
>=20
> 	if (rc !=3D 0)
> 		return rc;
>=20
> 	sk->sk_max_ack_backlog =3D 0;
> 	sk->sk_ack_backlog =3D 0;
> 	inet_csk_delack_init(sk);
>=20
> 	/* There is race window here: we announce ourselves listening,
> 	 * but this transition is still not validated by get_port().
> 	 * It is OK, because this socket enters to hash table only
> 	 * after validation is complete.
> 	 */
> 	sk->sk_state =3D TCP_LISTEN;

Because its not necessary ?

tcp_set_state() takes care of particular state transitions.

In case of inet_csk_listen_start(), old state is TCP_CLOSE, so there is
nothing special to do in tcp_set_state().



