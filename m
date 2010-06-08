From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix a race at the end of NAPI
Date: Tue, 08 Jun 2010 09:07:55 +0200
Message-ID: <1275980875.2775.199.camel@edumazet-laptop>
References: <1275979719.1927.4.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:48896 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab0FHHIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 03:08:00 -0400
Received: by wwb28 with SMTP id 28so240356wwb.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 00:07:59 -0700 (PDT)
In-Reply-To: <1275979719.1927.4.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 14:48 +0800, Figo.zhang a =C3=A9crit :
> fix a race at the end of NAPI complete processing. it had better do _=
_napi_complete()=20
> first before re-enable interrupt.
>=20
> Signed-off-by: Figo.zhang <figo1802@gmail.com>

Patch title is misleading

> ---=20
>  drivers/net/8139cp.c  |    2 +-
>  drivers/net/8139too.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> old mode 100644
> new mode 100755

Why do you change file modes ?

> index 9c14975..284a5f4
> --- a/drivers/net/8139cp.c
> +++ b/drivers/net/8139cp.c
> @@ -598,8 +598,8 @@ rx_next:
>  			goto rx_status_loop;
> =20
>  		spin_lock_irqsave(&cp->lock, flags);
> -		cpw16_f(IntrMask, cp_intr_mask);
>  		__napi_complete(napi);
> +		cpw16_f(IntrMask, cp_intr_mask);
>  		spin_unlock_irqrestore(&cp->lock, flags);
>  	}
> =20
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> old mode 100644
> new mode 100755
> index 4ba7293..a7bca8c
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -2088,8 +2088,8 @@ static int rtl8139_poll(struct napi_struct *nap=
i, int budget)
>  		 * again when we think we are done.
>  		 */
>  		spin_lock_irqsave(&tp->lock, flags);
> -		RTL_W16_F(IntrMask, rtl8139_intr_mask);
>  		__napi_complete(napi);
> +		RTL_W16_F(IntrMask, rtl8139_intr_mask);
>  		spin_unlock_irqrestore(&tp->lock, flags);
>  	}
>  	spin_unlock(&tp->rx_lock);
>=20
>=20


