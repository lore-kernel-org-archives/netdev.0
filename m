From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 08:21:25 -0800 (PST)
Message-ID: <20101119.082125.193710226.davem@davemloft.net>
References: <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
	<1290160467.3034.33.camel@edumazet-laptop>
	<1290165472.3034.109.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, netdev@vger.kernel.org, xiaosuo@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755319Ab0KSQVA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 11:21:00 -0500
In-Reply-To: <1290165472.3034.109.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Nov 2010 12:17:52 +0100

> Le vendredi 19 novembre 2010 =E0 10:54 +0100, Eric Dumazet a =E9crit =
:
>=20
>> I believe we should revert the u32 f_k =3D fentry->k; part
>>=20
>> fentry->k as is fast as f_k if stored on stack, and avoids one
>> instruction if fentry->k is not needed.
>>=20
>>=20
>=20
> A revert is not good on arches with decent number of registers (x86_6=
4
> for example).

-EFIX_THE_DAMN_COMPILER

We never make calls out of this function or touch volatile memory or
create a full memory barrier between the assignment of f_k and it's
uses.

Therefore if common sub-expression elimination is working the compiler
will be able to decide properly whether to access things via memory or
use a register for the value.

Remember this is why we have that ACCESS_ONCE() thing.

We can't have it both ways, either ACCESS_ONCE() should be removed or
we should never make changes like your's and instead should submit
compiler bug reports :-)
