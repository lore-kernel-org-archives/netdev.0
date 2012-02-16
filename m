From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 16:09:35 +0100
Message-ID: <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
	 <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADVnQy=UOvC06TBOE7d7WvuKm1Tdkzu7M4dfvm6VRcRJaDMyLw@mail.gmail.com>
	 <1329377352.5646.32.camel@edumazet-laptop>
	 <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329400265.3048.178.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>, alekcejk@googlemail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:52690 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751627Ab2BPPJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 10:09:48 -0500
Received: by lagu2 with SMTP id u2so2522085lag.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 07:09:47 -0800 (PST)
In-Reply-To: <1329400265.3048.178.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 13:51 +0000, Ben Hutchings a =C3=A9=
crit :

> I'm aware of this problem and I believe it exists with most
> implementations of LRO.
>=20
> The out-of-tree version of the sfc driver has its own soft-LRO
> implementation (SSR) which does some limited connection tracking to
> detect slow start and disable aggregation temporarily.  I've been
> meaning to look into enhancing GRO to match SSR, but haven't got roun=
d
> to it yet.


Not sure why we cant change tcp_grow_window() to take into account
number of segments in skb ?

It currently increments rcv_ssthresh by a fixed amount (2 * advmss)

        if (tcp_win_from_space(skb->truesize) <=3D skb->len)
                incr =3D 2 * tp->advmss;
        else
                incr =3D __tcp_grow_window(sk, skb);
        if (incr) {
                tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr,
                                       tp->window_clamp);
                inet_csk(sk)->icsk_ack.quick |=3D 1;
                }
