From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with
 3.2.x kernels
Date: Wed, 15 Feb 2012 15:56:20 +0100
Message-ID: <1329317780.2437.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
	 <CADVnQymT6saSSmUmT7BUShfQFoJ+u4JMQ=F2bhRv4vB_Pzj=9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44066 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271Ab2BOO4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:56:24 -0500
Received: by werb13 with SMTP id b13so672323wer.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 06:56:23 -0800 (PST)
In-Reply-To: <CADVnQymT6saSSmUmT7BUShfQFoJ+u4JMQ=F2bhRv4vB_Pzj=9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 09:49 -0500, Neal Cardwell a =C3=
=A9crit :
> If there was an increase in the number of bytes charged to the socket
> for each skb, without a corresponding increase in TCP receive buffer
> size, that would explain a systematic decrease in receiver window tha=
t
> would cause some paths, like perhaps these, to become
> receiver-window-limited (which is consistent with the symptom of
> stable bandwidth for a given path).
>=20
> Can you please try increasing the default TCP receiver window to see
> if this helps; try this as root on the 3.2 machine:
>=20
> sysctl net.ipv4.tcp_rmem=3D"4096 897664 897664"
>=20
> Basically making the middle number as big as the third number should
> bump up the default receiver window size.
>=20

Neal, this was taken into account, check how sk_rcvbuf is dynamically
handled in our stack.

tcp_rmem[1] is the initial sk_rcvbuf, but its updated as soon as receiv=
e
window changes

If you check tcpdumps, you dont notice signs of receiver-window-limited=
=2E
