From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] de2104x: disable media debug messages by default
Date: Thu, 30 Sep 2010 11:46:49 +0200
Message-ID: <AANLkTi=rzhb2bNpHe=Wu=57t5FAiYWhynQNLOnQxDAJm@mail.gmail.com>
References: <201009282018.57547.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009282018.57547.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/9/28 Ondrej Zary <linux@rainbow-software.org>:
> Print media debug messages only when HW debug is enabled.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>
> --- linux-2.6.36-rc3-/drivers/net/tulip/de2104x.c =A0 =A0 =A0 2010-09=
-28 19:50:51.000000000 +0200
> +++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c =A0 =A0 =A0 =A02010-=
09-28 20:05:34.000000000 +0200
> @@ -948,8 +948,9 @@ static void de_set_media (struct de_priv
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0macmode &=3D ~FullDuplex;
>
> - =A0 =A0 =A0 if (netif_msg_link(de)) {
> + =A0 =A0 =A0 if (netif_msg_link(de))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_info(&de->dev->dev, "set link %s\n=
", media_name[media]);

You can use netif_info(de, link, de->dev, ...) instead and get 'ethX:
' prefix for free.

> + =A0 =A0 =A0 if (netif_msg_hw(de)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_info(&de->dev->dev, "mode 0x%x, si=
a 0x%x,0x%x,0x%x,0x%x\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dr32(MacMode), dr32(S=
IAStatus),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dr32(CSR13), dr32(CSR=
14), dr32(CSR15));

Same here.

Best Regards,
Micha=B3 Miros=B3aw
