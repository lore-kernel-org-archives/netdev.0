From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 19:33:44 +0100
Message-ID: <1289414024.2469.20.camel@edumazet-laptop>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
	 <20101110.102129.112602843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	stable@kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63089 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441Ab0KJSdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:33:50 -0500
Received: by wyb36 with SMTP id 36so988141wyb.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 10:33:49 -0800 (PST)
In-Reply-To: <20101110.102129.112602843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 10:21 -0800, David Miller a =C3=A9c=
rit :
> From: "Dan Rosenberg" <drosenberg@vsecurity.com>
> Date: Wed, 10 Nov 2010 18:18:08 +0000
>=20
> > The code sample I linked to clearly demonstrates exactly how to
> > accomplish this, if you had bothered to read it.
>=20
> I told you why I didn't read it, if you had bothered to read my
> reply properly :-)
>=20
> Anyways, I realize we have to do something, but memset() is going
> to completely kill performance.  I consider Eric's suggestion the
> closest to acceptable cost at this point but even that is hard
> to digest for me.


Most filters dont use mem[] at all, so the added cost seems OK to me,
but we can work to use a compile time check, to make memset(mem, 0,
length) a filter parameter if you prefer removing the test on each
load(mem[K]).

This memset() could be avoided if the compiler() can be sure all
load(mem[K]) follow a prior store(mem[K])

Its not a five minutes patch, I tried to work on it but it was a bit
hard, for a very remote security risk.

(On x86 platform, incoming packets are handled in SOFTIRQ stack, not th=
e
kernel stack of current thread anyway)



