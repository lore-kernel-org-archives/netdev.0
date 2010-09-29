From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 10:18:08 +0200
Message-ID: <1285748288.2615.15.camel@edumazet-laptop>
References: <1285664747.2607.48.camel@edumazet-laptop>
	 <4CA2F46B.1070607@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63504 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab0I2ISN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:18:13 -0400
Received: by fxm14 with SMTP id 14so290843fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 01:18:12 -0700 (PDT)
In-Reply-To: <4CA2F46B.1070607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 10:10 +0200, Nicolas Dichtel a =C3=
=A9crit :
> NETIF_F_LLTX is marked as deprecated:
>=20
> include/linux/netdevice.h:
> #define NETIF_F_LLTX            4096    /* LockLess TX - deprecated.=20
> Please */
>                                          /* do not use LLTX in new=20
> drivers */
>=20
> Is it right to use it?
>=20

In this particular case (and drivers/net/loopback.c), yes.

This is the only way to avoid the locking in core network
(net/core/dev.c)

What is deprecated is to assert NETIF_F_LLTX and yet, use a lock in the
ndo_xmit() driver method.



