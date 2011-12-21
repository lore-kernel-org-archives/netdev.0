From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 12:05:55 +0100
Message-ID: <1324465555.2728.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
				 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <4EF1B5BC.5020103@monstr.eu>
		 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <4EF1B7E4.4010602@monstr.eu>
	 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1BAE1.7020409@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36556 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LULF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 06:05:58 -0500
Received: by vcbfk14 with SMTP id fk14so5628786vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 03:05:57 -0800 (PST)
In-Reply-To: <4EF1BAE1.7020409@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:54 +0100, Michal Simek a =C3=
=A9crit :
> Eric Dumazet wrote:
> > Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:41 +0100, Michal Simek =
a =C3=A9crit :
> >=20
> >> yes, page size is 4k.
> >>
> >> Here is the log for allocation - origin size for MTU 9000 is 0x242=
0(9248) and size after
> >> overhead is 0x3f40(16192)
> >>
> >> kmalloc_node_track_caller size 00002420, SKB_WITH_OVERHEAD(ksize(d=
ata)) 00003f40
> >> skb->head     c7870000
> >> skb->data     c7870000
> >> skb->tail     c7870000
> >> skb->truesize 000040c0
> >> skb->end      c7873f40
> >>
> >=20
> > So basically truesize is bigger than previous kernel, and you hit a
> > socket limit.  (RCVBUF ?)
>=20
> Where is that limit setup?
>=20

Might be in the application itself.

setsockopt(socket, SOL_SOCKET, SO_RCVBUF, &limit, sizeof(limit));

kernel currently apply a factor of two to take into account skb
overhead. This might be not enough with jumbo frames.
