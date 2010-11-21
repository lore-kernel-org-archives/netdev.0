From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] netns: let net_generic take pointer-to-const args
Date: Sun, 21 Nov 2010 09:29:25 +0100
Message-ID: <1290328165.2756.102.camel@edumazet-laptop>
References: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39230 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab0KUI3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 03:29:31 -0500
Received: by wyb28 with SMTP id 28so5945047wyb.19
        for <netdev@vger.kernel.org>; Sun, 21 Nov 2010 00:29:29 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1011210506110.9636@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 21 novembre 2010 =C3=A0 05:07 +0100, Jan Engelhardt a =C3=A9=
crit :
> parent 2801f1c311f8388ea80d78555747d449b46ea90d (v2.6.37-rc1-225-g280=
1f1c)
> commit 381a4560f0062f5c1919f8199772d7af7281349e
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Sun Nov 21 04:35:16 2010 +0100
>=20
> netns: let net_generic take pointer-to-const args
>=20
> This commit is same in nature as v2.6.37-rc1-755-g3654654; the networ=
k
> namespace itself is not modified when calling net_generic, so the
> parameter can be const.
>=20
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
>  include/net/netns/generic.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/netns/generic.h b/include/net/netns/generic.=
h
> index 81a31c0..3419bf5 100644
> --- a/include/net/netns/generic.h
> +++ b/include/net/netns/generic.h
> @@ -30,7 +30,7 @@ struct net_generic {
>  	void *ptr[0];
>  };
> =20
> -static inline void *net_generic(struct net *net, int id)
> +static inline void *net_generic(const struct net *net, int id)
>  {
>  	struct net_generic *ng;
>  	void *ptr;

While you are at it you could also use

const struct net_generic *ng;

Just curious, if we could use __pure attribute as well.



