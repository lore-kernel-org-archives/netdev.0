From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Tue, 20 Dec 2011 15:18:09 -0500 (EST)
Message-ID: <20111220.151809.1704705119739851376.davem@davemloft.net>
References: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF1C@saturn3.aculab.com>
	<CAGK4HS9LuvgOoY+cSXq-Vjbx7x5gsQ03wj6Tb1UDsO=89Wkrpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi, hkchu@google.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1LTUSa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 15:18:30 -0500
In-Reply-To: <CAGK4HS9LuvgOoY+cSXq-Vjbx7x5gsQ03wj6Tb1UDsO=89Wkrpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Tue, 20 Dec 2011 12:02:52 -0800

> I assume you are talking about collision with userspace.  These
> definitions are already protected by #ifdef  __KERNEL__.
> That should be enough to protect against collisions with userspace I =
think.

Within the kernel he means, please put a TCP_* prefix onto these
values.

>>
>>> - =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & 0x1;
>>> + =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & SACK_SEEN;
>>
>> Looks to me like that 0x1 isn't SAC_SEEK! So this is now misleading.
>=20
> Can you please elaborate? Are you saying this is wrong or that it
> could be done better?

I think he's saying it could be done better.  Probably something
like:

	tcp_opt->sack_ok =3D (options & (1 << 4)) ? SACK_SEEN : 0;
