From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: synchronize bind() with RTM_NEWADDR notifications
Date: Thu, 21 Oct 2010 04:03:19 -0700 (PDT)
Message-ID: <20101021.040319.191412436.davem@davemloft.net>
References: <4CC018E1.3000906@iki.fi>
	<20101021.035004.212683583.davem@davemloft.net>
	<4CC01CC0.7090101@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756823Ab0JULC4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 07:02:56 -0400
In-Reply-To: <4CC01CC0.7090101@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 21 Oct 2010 13:58:08 +0300

> On 10/21/2010 01:50 PM, David Miller wrote:
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Date: Thu, 21 Oct 2010 13:41:37 +0300
>>=20
>>> Is inet_bind() called from non-userland context? If yes, then this =
is a
>>> bad idea. Otherwise I don't think it's that hot path...
>>=20
>> It is.
>=20
> Yet, almost immediately after that there is lock_sock() which can als=
o
> sleep. How does that work then?

RTNL interlocks globally with a heavy primitive, a mutex, lock_sock()
grabs a spinlcok which is local to the socket's context.

So if we have 100,000 sockets binding we'll suck with you're change
whereas the lock_sock() does not cause that problem.

Is this so difficult for you to comprehend?
