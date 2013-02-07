From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH V2] bgmac: validate MAC addr
Date: Thu, 07 Feb 2013 11:19:54 +0100
Message-ID: <51137FCA.5090203@openwrt.org>
References: <1360143452-29183-1-git-send-email-zajec5@gmail.com> <1360232078-21872-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:51852 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab3BGKXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 05:23:01 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm14so2659833wib.4
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 02:23:00 -0800 (PST)
In-Reply-To: <1360232078-21872-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2013 11:14 AM, Rafa=C5=82 Mi=C5=82ecki wrote:
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

This is looking good, however some commit message is desirable,=20
especially as you are no longer just validating the ethernet MAC=20
address, but also generating a new one. Something along those lines=20
would probably be enough:

"This patch changes bgmac_probe() to check for a valid Ethernet MAC=20
address and in case it is not, will generate a valid random one, such=20
that the adapter is still usable."

Thanks!

> ---
> V2: generate random addr
> ---
>   drivers/net/ethernet/broadcom/bgmac.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index d08a4af..f90d1dc 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1318,6 +1318,12 @@ static int bgmac_probe(struct bcma_device *cor=
e)
>   		return -ENOTSUPP;
>   	}
>  =20
> +	if (!is_valid_ether_addr(mac)) {
> +		dev_err(&core->dev, "Invalid MAC addr: %pM\n", mac);
> +		eth_random_addr(mac);
> +		dev_warn(&core->dev, "Using random MAC: %pM\n", mac);
> +	}
> +
>   	/* Allocation and references */
>   	net_dev =3D alloc_etherdev(sizeof(*bgmac));
>   	if (!net_dev)
