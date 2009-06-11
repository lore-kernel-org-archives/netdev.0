From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: No more expensive sock_hold()/sock_put() on each
 tx
Date: Thu, 11 Jun 2009 02:56:30 -0700 (PDT)
Message-ID: <20090611.025630.31891354.davem@davemloft.net>
References: <4A27916B.7030607@gmail.com>
	<20090610.011743.230851451.davem@davemloft.net>
	<4A2F6F39.8060107@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752994AbZFKJ42 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 05:56:28 -0400
In-Reply-To: <4A2F6F39.8060107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Jun 2009 10:30:49 +0200

> David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 04 Jun 2009 11:18:35 +0200
>>=20
>> Eric, I don't understand this part, please enlighten me :-)
>>=20
>> Just because we've liberated all of the write buffer space, that doe=
s
>> not mean that it's time to kill off the socket completely.
>>=20
>> Right?
>=20
> Remember we initialize this field to one.
>=20
> If we freed all write buffer space, final value is one, not zero.
>=20
> res =3D=3D 0 only if we both freed all write buffer space, *and* sock=
et was
> also refcounted to 0 (sk_free() then realized it could not yet call _=
_sk_free())
>=20
> So we cheat a litle bit, because of this offset of one, we might bloc=
k a sender a litle bit earlier :)

Now I understand, thanks!

Patch applied.
