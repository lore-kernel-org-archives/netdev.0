From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 06:03:22 +0100
Message-ID: <1269493402.15280.29.camel@edumazet-laptop>
References: <4BAAE6E9.6030103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62396 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab0CYFD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:03:28 -0400
Received: by bwz1 with SMTP id 1so542683bwz.21
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:03:26 -0700 (PDT)
In-Reply-To: <4BAAE6E9.6030103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 mars 2010 =C3=A0 12:30 +0800, Changli Gao a =C3=A9crit :
> support 802.1q and pppoe session
>=20
> Support 802.1q and pppoe session, and these two protocols can get the
> benefit from RPS.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> net/core/dev.c | 38 ++++++++++++++++++++++++++++++--------
> 1 file changed, 30 insertions(+), 8 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a03aab4..647ecc4 100644

While this might sounds a good idea, you really should split this in tw=
o
parts.

By the way, why not handling IPIP too ?

Because I believe 802.1q part has no added value for instance, since
packet handled by CPUX will be decoded and passed to VLAN device, havin=
g
a chance to be fully taken by RPS, since we go back to netif_rx().

Probably same thing for IPIP / PPPOE can be discussed.

I agree we might need a flag or something to reset rxhash to 0 somewher=
e
(probably in non accelerated vlan rx handling) to force second
get_rps_cpu() invocation to recompute it. This small correction has no
cost if put outside of get_rps_cpus().

If get_rps_cpus() is too complex, it might become too slow for typical
use. We should find smart ways to solve your performance problem if the=
y
ever exist.



