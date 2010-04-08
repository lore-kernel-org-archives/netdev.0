From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: rx hash offload
Date: Wed, 07 Apr 2010 22:04:52 -0700 (PDT)
Message-ID: <20100407.220452.68153375.davem@davemloft.net>
References: <20100405084800.3bcec66a@nehalam>
	<1270557210.2081.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751454Ab0DHFEt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 01:04:49 -0400
In-Reply-To: <1270557210.2081.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Apr 2010 14:33:30 +0200

> Le lundi 05 avril 2010 =E0 08:48 -0700, Stephen Hemminger a =E9crit :
>> Marvell Yukon 2 hardware supports hardware receive hash calculation.
>> Now that Receive Packet Steering is available, add support
>> to enable it.
>>=20
>> Note: still experimental, tested on only a few variants.
>> No performance testing has been done.
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>> ---
>>  drivers/net/sky2.c |   75 +++++++++++++++++++++++++++++++++++++++++=
++++++++++--
>>  drivers/net/sky2.h |   23 ++++++++++++++++
>>  2 files changed, 96 insertions(+), 2 deletions(-)
>=20
> I am wondering if introducing hardware computed rxhash wouldnt force =
us
> to clear rxhash in several paths (tunneling...), so that we perform a
> software recompute after decapsulation, to enable RFS
>=20
> Not mandatory but recommended I would say...

nf_reset() and clearing things like this new rxhash thing
should be encapsulated into a helper function that we can
stick into the tunnel drivers and such.
