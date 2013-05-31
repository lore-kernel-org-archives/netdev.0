From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: fec: add fallback to random MAC address
Date: Fri, 31 May 2013 21:57:21 +0400
Message-ID: <51A8E481.802@cogentembedded.com>
References: <1370020942-8342-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Pavel Machek <pavel@denx.de>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:45981 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab3EaR5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:57:18 -0400
Received: by mail-lb0-f177.google.com with SMTP id o10so1932338lbi.8
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 10:57:16 -0700 (PDT)
In-Reply-To: <1370020942-8342-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/31/2013 09:22 PM, Lucas Stach wrote:

> From: Pavel Machek <pavel@denx.de>
>
> If no valid MAC address could be obtained from the hardware,
> fall back to a randomly generated one.
>
> Signed-off-by: Pavel Machek <pavel@denx.de>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>   drivers/net/ethernet/freescale/fec_main.c | 10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 9b0c647..3694a56 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1037,6 +1037,16 @@ static void fec_get_mac(struct net_device *ndev)
>   		iap = &tmpaddr[0];
>   	}
>   
> +	/*
> +	 * 5) random mac address
> +	 */
> +	if (!is_valid_ether_addr(iap)) {
> +		/* Report it and use a random ethernet address instead */
> +		netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
> +		random_ether_addr(iap);

    eth_hw_addr_random(ndev) might be a bit better -- it classifies the MAC
address in 'struct net_device' as random.

WBR, Sergei
