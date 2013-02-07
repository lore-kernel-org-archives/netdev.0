From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] bgmac: fix "cmdcfg" calls for promisc and loopback modes
Date: Thu, 07 Feb 2013 15:55:08 +0100
Message-ID: <5113C04C.60100@openwrt.org>
References: <1360232591-25789-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Nathan Hintz <nlhintz@hotmail.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:39905 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589Ab3BGO6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 09:58:08 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so1521558eek.13
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 06:58:07 -0800 (PST)
In-Reply-To: <1360232591-25789-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rafal,

On 02/07/2013 11:23 AM, Rafa=C5=82 Mi=C5=82ecki wrote:
> This makes code match the specs.

And this probably deserves a better commit message too. Especially as=20
you are inverting booleans, without the actual consumer of that boolean=
=20
parameter being in the context of the patch.

Thanks!

>
> Reported-by: Nathan Hintz <nlhintz@hotmail.com>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c |    8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index f90d1dc..8cf5e39 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -776,9 +776,9 @@ static void bgmac_set_rx_mode(struct net_device *=
net_dev)
>   	struct bgmac *bgmac =3D netdev_priv(net_dev);
>
>   	if (net_dev->flags & IFF_PROMISC)
> -		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
> +		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, true);
>   	else
> -		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
> +		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, true);
>   }
>
>   #if 0 /* We don't use that regs yet */
> @@ -1039,9 +1039,9 @@ static void bgmac_chip_init(struct bgmac *bgmac=
, bool full_init)
>   	bgmac_write_mac_address(bgmac, bgmac->net_dev->dev_addr);
>
>   	if (bgmac->loopback)
> -		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, true);
> +		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_ML, false);
>   	else
> -		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_ML, 0, true);
> +		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_ML, 0, false);
>
>   	bgmac_write(bgmac, BGMAC_RXMAX_LENGTH, 32 + ETHER_MAX_LEN);
>
>
