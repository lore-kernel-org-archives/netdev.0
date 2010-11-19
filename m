From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 09:25:14 -0800 (PST)
Message-ID: <20101119.092514.183050412.davem@davemloft.net>
References: <1290185759.3034.179.camel@edumazet-laptop>
	<20101119.090516.104057453.davem@davemloft.net>
	<1290186984.3034.187.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, netdev@vger.kernel.org, xiaosuo@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755795Ab0KSRYt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 12:24:49 -0500
In-Reply-To: <1290186984.3034.187.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Nov 2010 18:16:24 +0100

> Le vendredi 19 novembre 2010 =E0 09:05 -0800, David Miller a =E9crit =
:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 19 Nov 2010 17:55:59 +0100
>>=20
>> > Unfortunatly on x86_32 it also chose that f_k was more valuable in=
 a cpu
>> > register and accumulator A lost its register to get a stack slot
>> > instead.
>>=20
>> Ok that tradeoff is terrible, but it depends upon knowledge we haven=
't
>> given to the compiler (yet).
>>=20
>> Let me think about this a bit...
>=20
> By the way, I tried the 'register' keyword, and I knew it was a stupi=
d
> idea before even trying, since compiler ignored me : "What the hell d=
o
> you think you can tell me how to optimize this code ?"
>=20
> (I am quite sure my laptop even smiled and sent to his neighbours a
> broadcast saying "Hey buddies, this dumb guy tried the register C
> keyword, isnt it funny ?")

:-)

I wonder though, since "fentry" is const in your recent patch,
you might not even need that X86_32 ifdef thing.  GCC should
actually now be able to see that fentry->k cannot change, even
when we make external function calls via load_pointer() and such.
