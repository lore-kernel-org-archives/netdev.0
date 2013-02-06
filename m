From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] bgmac: validate MAC addr
Date: Wed, 06 Feb 2013 18:11:41 +0100
Message-ID: <51128ECD.7090907@openwrt.org>
References: <1360143452-29183-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:62075 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab3BFROk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:14:40 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so938029eei.21
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 09:14:39 -0800 (PST)
In-Reply-To: <1360143452-29183-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rafal,

On 02/06/2013 10:37 AM, Rafa=C5=82 Mi=C5=82ecki wrote:
>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c |    5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index af149a3..9f95089 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1290,6 +1290,11 @@ static int bgmac_probe(struct bcma_device *cor=
e)
>   		return -ENOTSUPP;
>   	}
>
> +	if (!is_valid_ether_addr(mac)) {
> +		dev_err(&core->dev, "Invalid MAC addr: %pM\n", mac);
> +		return -EADDRNOTAVAIL;
> +	}

Rather generate an random one, thus making the interface usable, but=20
keep the warning to help users track this down.
--
=46lorian
