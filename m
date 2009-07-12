From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Kick the transmit watchdog timer on transmit
Date: Sun, 12 Jul 2009 21:09:22 +0900
Message-ID: <392fb48f0907120509t454d125ei3279022d28fd6092@mail.gmail.com>
References: <392fb48f0907120242r438411ccm5507998c3fcad877@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:15071 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbZGLMJX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 08:09:23 -0400
Received: by an-out-0708.google.com with SMTP id d40so3659004and.1
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 05:09:22 -0700 (PDT)
In-Reply-To: <392fb48f0907120242r438411ccm5507998c3fcad877@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Ignore this. I was using 2.6.30 with the sky2 code from net-next-2.6,
and the core network core code changed (in cdd0db058d64f).  I'll move
over to using net-next-2.6 and deal with the instability...

thanks,

Mike

2009/7/12 Mike McCormack <mikem@ring3k.org>:
> Hi Stephen,
>
> I was curious as to why sky2_tx_timeout() was being called once when
> the driver started, and never again (which originally caused the cras=
h
> resolved by the previous patch).
>
> I might be missing something, but it looks like we the transmit
> watchdog needs to be kicked whenever a packet is transmitted.
>
> This patch has had a small amount of testing, but reviewing other
> drivers (e.g. net/atm/lec.c), this appears to be what is done.
>
> thanks,
>
> Mike
>
> ---
>
> If we don't kick the watchdog, it always triggers.
>
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
> =C2=A0drivers/net/sky2.c | =C2=A0 =C2=A02 ++
> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 77fd1b9..48d58ec 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1708,6 +1708,8 @@ static int sky2_xmit_frame(struct sk_buff *skb,
> struct net_device *dev)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sky2_put_idx(hw, txqaddr[sky2->port], sky2=
->tx_prod);
>
> + =C2=A0 =C2=A0 =C2=A0 dev->trans_start =3D jiffies; =C2=A0 =C2=A0 /*=
 restart tx timeout */
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NETDEV_TX_OK;
>
> =C2=A0mapping_unwind:
> --
> 1.5.6.5
>
