From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 20:37:44 +0200
Message-ID: <1302115064.3209.132.camel@edumazet-laptop>
References: <1302113253.3209.126.camel@edumazet-laptop>
	 <20110406.111712.226782643.davem@davemloft.net>
	 <1302114188.3209.128.camel@edumazet-laptop>
	 <20110406.112712.71110955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38045 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756145Ab1DFShs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:37:48 -0400
Received: by wwa36 with SMTP id 36so2123248wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 11:37:47 -0700 (PDT)
In-Reply-To: <20110406.112712.71110955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 11:27 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Apr 2011 20:23:08 +0200
>=20
> > Le mercredi 06 avril 2011 =C3=A0 11:17 -0700, David Miller a =C3=A9=
crit :
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Wed, 06 Apr 2011 20:07:33 +0200
> >>=20
> >> > This is why we used on ipv4 :
> >> >=20
> >> > if (inet_sk(sk)->inet_daddr)
> >> > 	sock_rps_save_rxhash(sk, skb->rxhash);
> >> >=20
> >> >=20
> >> > Only arm RFS on UDP if socket is bound to a given remote peer.
> >>=20
> >> Agreed, Neil please make this change to your ipv6 code.
> >=20
> > BTW, do you guys know if NFS is using RFS right now (if TCP transpo=
rt is
> > used) ?
>=20
> It ought to be.  Are you specifically concerned that it might be
> missing the rxhash setting calls because of the APIs it uses to
> do socket I/O?
>=20
> The SunRPC layer is a major user of tcp_read_sock(), for example.
>=20
> But the packet processing will be done via the normal means,
> therefore we'll hit tcp_v4_do_rcv() and therefore save the
> rxhash.

Hmm, are multiple tcp sessions used between NFS client and server (One
per cpu on client ?)



