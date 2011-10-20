From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 16:13:56 -0400 (EDT)
Message-ID: <20111020.161356.2120784879469409197.davem@davemloft.net>
References: <1319138186.2854.5.camel@edumazet-laptop>
	<20111020.155002.555965434596006787.davem@davemloft.net>
	<1319140954.2854.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab1JTUN7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:13:59 -0400
In-Reply-To: <1319140954.2854.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:02:34 +0200

> Le jeudi 20 octobre 2011 =E0 15:50 -0400, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 20 Oct 2011 21:16:26 +0200
>>=20
>> > Since commit 356f039822b (TCP: increase default initial receive
>> > window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) seg=
ments.
>> >=20
>> > Change tcp_fixup_rcvbuf() to reflect this change, even if no real =
change=20
>> > is expected, since sysctl_tcp_rmem[1] =3D 87380 and this value
>> > is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)
>> >=20
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>  ...
>> > +	unsigned int mss =3D min_t(unsigned int, tp->advmss, 1460);
>>=20
>> I don't understand where this calculation comes from, and even if it
>> should be obvious it isn't to me and deserves a mention in the commi=
t
>> message at a minimum.
>=20
> This is the calculation done in commit 356f039822b as well.
>=20
> The window is 10*MSS, but no more than 14600
>=20
> On loopback, this matters, because we could end with rcvmem=3D219680

Thanks, please help weak brains like mine by adding this to the commit =
message.
:-)
