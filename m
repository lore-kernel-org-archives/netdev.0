From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 17:48:31 +0100
Message-ID: <1298479711.3301.373.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>  <4D6534C3.1080305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:41909 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104Ab1BWQsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 11:48:36 -0500
Received: by bwz10 with SMTP id 10so313330bwz.10
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 08:48:35 -0800 (PST)
In-Reply-To: <4D6534C3.1080305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHardy a =
=C3=A9crit :

> This needs to be a per-skb property, otherwise you could have the
> situation:
>=20
> - enqueue skb, double_buffering=3D0, increment buffer 0
> - enable double buffering
> - swap buffers
> - dequeue same skb, decrement buffer 1
>=20
> after which the qlen values of buffer 1 will be incorrect.
>=20

Normally its OK, because we bzero() the zone, and the "decrement" is
0-bounded.

I had this idea (of storing two bits per skb), but :

- It means that swap_buffer() should not touch (bzero) the 'old' bins

- Since hash perturbator is changed, we have to store the two hash
values per skb (instead of one u32 / classid).


>=20
> > +		slot ^=3D 1;
> > +		sfbhash =3D sfb_hash(skb, slot, q);
>=20
> Isn't there room in the cb to store both hash values?

Yes, I am going to implement your idea, its probably OK to use two u32
on skb_cb for this.

Thanks !


