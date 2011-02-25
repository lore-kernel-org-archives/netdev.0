From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: avoid searching when no ports are available
Date: Fri, 25 Feb 2011 17:55:17 +0100
Message-ID: <1298652917.2659.95.camel@edumazet-laptop>
References: <1298633711-11924-1-git-send-email-dbaluta@ixiacom.com>
	 <1298635575.2659.65.camel@edumazet-laptop>
	 <AANLkTimodVFC8969md-f7iebS_9WvVahV9fPFFLtup73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rohan Chitradurga <rohan@ixiacom.com>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44773 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422Ab1BYQzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 11:55:25 -0500
Received: by bwz15 with SMTP id 15so2113011bwz.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 08:55:23 -0800 (PST)
In-Reply-To: <AANLkTimodVFC8969md-f7iebS_9WvVahV9fPFFLtup73@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 18:45 +0200, Daniel Baluta a =C3=
=A9crit :
> I guess now, the correct bitmap size is MAX_UDP_PORTS / (udptable->ma=
sk + 1)
> or  MAX_UDP_PORTS >> udptable->log,  right?
>=20


Yes, but using bitmap_zero(bitmap, PORTS_PER_CHAIN) is faster.

It generates 4 machine instructions,
	movq   $0x0,(%r10)
	movq   $0x0,0x8(%r10)
	movq   $0x0,0x10(%r10)
	movq   $0x0,0x18(%r10)

while bitmap_zero(bitmap, some_non_constant_expression) is more
expensive (it calls an out of line function)


> We don't have special needs on a small machine. We just want that whe=
n
> when all UDP ports are exhausted, bind calls to fail faster.
>=20
> I will be back with tests on latest kernel.

Hmm, please always use the latest kernel before sending patches.

Thanks


