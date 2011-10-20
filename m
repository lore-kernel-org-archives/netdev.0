From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 17:03:26 -0400 (EDT)
Message-ID: <20111020.170326.2193877307745965380.davem@davemloft.net>
References: <1319143442.2854.26.camel@edumazet-laptop>
	<4EA0885A.9010009@myri.com>
	<1319144356.2854.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gallatin@myri.com, mason@myri.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab1JTVDv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:03:51 -0400
In-Reply-To: <1319144356.2854.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 22:59:16 +0200

> Le jeudi 20 octobre 2011 =E0 16:45 -0400, Andrew Gallatin a =E9crit :
>> On 10/20/11 16:44, Eric Dumazet wrote:
>> > Le jeudi 20 octobre 2011 =E0 15:33 -0500, Jon Mason a =E9crit :
>> >> On Thu, Oct 20, 2011 at 3:10 PM, Eric Dumazet<eric.dumazet@gmail.=
com>  wrote:
>> >>> skb->truesize must account for allocated memory, not the used pa=
rt of
>> >>> it. Doing this work is important to avoid unexpected OOM situati=
ons.
>> >>>
>> >>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>> >>
>> >> Acked-by: Jon Mason<mason@myri.com>
>> >
>> > Thanks for reviewing Jon !
>> >
>> >
>>=20
>> Please wait a second..  I think the patch is incorrect.
>>=20
>> There is already code in myri10ge_rx_skb_build() which
>> attempts to set the truesize.  However, it sets it to
>> the used, rather than the allocated size so it is apparently
>> incorrect.
>>=20
>> I'd prefer we fix that code.
>=20
> Well, I believe I did exactly that :)
>=20
> truesize of initial skb is fine.
>=20
> Then for everay frag added, you must add to skb-truesize the allocate=
d
> memory for this frag.
>=20
> You add frags of a given size (small or big)
>=20
> In the end, its truesize +=3D bytes * number_of_frags
>=20
> (bytes being small_size or big_size)

Right, I believe Eric's patch is correct, and I intend to apply it.
