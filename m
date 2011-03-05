From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove flowi from struct rtable.
Date: Sat, 05 Mar 2011 07:59:48 +0100
Message-ID: <1299308388.2758.71.camel@edumazet-laptop>
References: <20110304.221214.189707201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41867 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1CEG7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 01:59:53 -0500
Received: by wyg36 with SMTP id 36so2839406wyg.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 22:59:52 -0800 (PST)
In-Reply-To: <20110304.221214.189707201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 22:12 -0800, David Miller a =C3=A9crit =
:
> The only necessary parts are the src/dst addresses, the
> interface indexes, the TOS, and the mark.
>=20
> The rest is unnecessary bloat, which amounts to nearly
> 50 bytes on 64-bit.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---



> +		struct rtable *rt =3D skb_rtable(skb);
> +		struct flowi fl =3D {
> +			.fl4_dst =3D rt->rt_key_dst,
> +			.fl4_src =3D rt->rt_key_src,
> +			.fl4_tos =3D rt->rt_tos,
> +			.oif =3D rt->rt_oif,
> +			.iif =3D rt->rt_iif,
> +			.mark =3D rt->rt_mark,
> +		};

Eventually we could have a helper for this, as this is done three times
in this file. Or maybe you have further plans for ipmr ?


