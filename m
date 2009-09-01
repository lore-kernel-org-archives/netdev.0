From: David Miller <davem@davemloft.net>
Subject: Re: TSecr != 0 check in inet_lro.c
Date: Tue, 01 Sep 2009 15:46:29 -0700 (PDT)
Message-ID: <20090901.154629.200974750.davem@davemloft.net>
References: <200908250054.50664.opurdila@ixiacom.com>
	<4A9379C9.6050108@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, themann@de.ibm.com, netdev@vger.kernel.org,
	raisch@de.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755274AbZIAWqO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 18:46:14 -0400
In-Reply-To: <4A9379C9.6050108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Aug 2009 07:42:33 +0200

> Octavian Purdila a =E9crit :
>>=20
>> I'm failing to understand the purpose of this check. Any hints? :)
>>=20
>=20
> rfc1323 badly interpreted ?
>=20
> I remember tsecr=3D0 was forbidden by Linux, while apparently rfc is =
not
> so clear.
>=20
> rfc1323 : 3.2
>          The Timestamp Echo Reply field (TSecr) is only valid if the =
ACK
>          bit is set in the TCP header; if it is valid, it echos a tim=
es-
>          tamp value that was sent by the remote TCP in the TSval fiel=
d
>          of a Timestamps option.  When TSecr is not valid, its value
>          must be zero.  The TSecr value will generally be from the mo=
st
>          recent Timestamp option that was received; however, there ar=
e
>          exceptions that are explained below.
>=20
> Note how this is not saying "a zero Tsecr value is not valid"

Indeed this is a very tricky situation.

What it's saying here is that you can emit a zero TSecr when you
simply haven't received a valid timestamp from the peer yet.

I think we can therefore remove all of these special zero checks, but
we must be mindful to make sure we handle the connection startup case
properly (where we see these 'no valid timestamp yet' zero TSecrs).
