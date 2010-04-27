From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Wed, 28 Apr 2010 00:08:46 +0200
Message-ID: <1272406126.2343.17.camel@edumazet-laptop>
References: <1271709121.3845.94.camel@edumazet-laptop>
	 <20100419.141947.129754682.davem@davemloft.net>
	 <1272271271.2346.16.camel@edumazet-laptop>
	 <20100427.145904.67907652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33177 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab0D0WIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:08:50 -0400
Received: by bwz19 with SMTP id 19so61309bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 15:08:49 -0700 (PDT)
In-Reply-To: <20100427.145904.67907652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 14:59 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 26 Apr 2010 10:41:11 +0200
>=20
> > Le lundi 19 avril 2010 =C3=A0 14:19 -0700, David Miller a =C3=A9cri=
t :
> >=20
> >>=20
> >> I was thinking also about how we could compute rxhash in the
> >> loopback driver :-)
> >=20
> > This would be easy if rxhash was not a "struct inet_sock" field but=
 a
> > "struct sock" one
> >=20
> > sock_alloc_send_pskb() (or skb_set_owner_w())
> >=20
> > skb->rxhash =3D sk->rxhash;
>=20
> Agreed.  I'll commit the following to net-next-2.6 after some build
> testing.
>=20
> net: Make RFS socket operations not be inet specific.
>=20
> Idea from Eric Dumazet.
>=20
> As for placement inside of struct sock, I tried to choose a place
> that otherwise has a 32-bit hole on 64-bit systems.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I tested same patch today (plus the skb->rxhash =3D sk->sk_rxhash) and =
got
a very small speedup on my Nehalem machine, where get_rps_cpus() was
using 1 % of cpu, now 0.25 %, on a tbench.



