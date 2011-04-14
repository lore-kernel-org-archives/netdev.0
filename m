From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Call fib_select_default() only when actually
 necessary.
Date: Thu, 14 Apr 2011 23:59:17 +0200
Message-ID: <1302818357.2744.47.camel@edumazet-laptop>
References: <20110414.145035.189701333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35251 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980Ab1DNV7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 17:59:22 -0400
Received: by wya21 with SMTP id 21so1784386wya.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 14:59:21 -0700 (PDT)
In-Reply-To: <20110414.145035.189701333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 avril 2011 =C3=A0 14:50 -0700, David Miller a =C3=A9crit :
> fib_select_default() is a complete NOP, and completely pointless
> to invoke, when we have no more than 1 default route installed.
>=20
> And this is far and away the common case.
>=20
> So remember how many prefixlen=3D=3D0 routes we have in the routing
> table, and elide the call when we have no more than one of those.
>=20
> This cuts output route creation time by 157 cycles on Niagara2+.
>=20
> In order to add the new int to fib_table, we have to correct the type
> of ->tb_data[] to unsigned long, otherwise the private area will be
> unaligned on 64-bit systems.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Excellent :)

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


