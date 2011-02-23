From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 17:58:04 +0100
Message-ID: <4D653C9C.8010205@trash.net>
References: <20110221160306.GA9650@tuxdriver.com>	 <1298308283.2849.5.camel@edumazet-laptop>	 <1298390536.2861.9.camel@edumazet-laptop>	 <1298474091.3301.364.camel@edumazet-laptop>  <4D6534C3.1080305@trash.net> <1298479711.3301.373.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55479 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180Ab1BWQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 11:58:07 -0500
In-Reply-To: <1298479711.3301.373.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.02.2011 17:48, schrieb Eric Dumazet:
> Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHardy =
a =C3=A9crit :
>=20
>> This needs to be a per-skb property, otherwise you could have the
>> situation:
>>
>> - enqueue skb, double_buffering=3D0, increment buffer 0
>> - enable double buffering
>> - swap buffers
>> - dequeue same skb, decrement buffer 1
>>
>> after which the qlen values of buffer 1 will be incorrect.
>>
>=20
> Normally its OK, because we bzero() the zone, and the "decrement" is
> 0-bounded.

Yeah, but we might decrement buckets of different flows which
are non-zero. Probably not too bad, but still not correct.

> I had this idea (of storing two bits per skb), but :
>=20
> - It means that swap_buffer() should not touch (bzero) the 'old' bins

Yes, it means we have to properly decrement the old buffer
until all bins reached zero.

> - Since hash perturbator is changed, we have to store the two hash
> values per skb (instead of one u32 / classid).

Indeed.
