From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] net: fec: add the initial to set the physical mac address
Date: Tue, 10 Sep 2013 18:19:11 +0400
Message-ID: <CAOJe8K2eH+6Eg0vOnOFwNsy9-TyxBJwYDCTDbLcbB3yu42OW1w@mail.gmail.com>
References: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: b20596@freescale.com, b45643@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	stephen@networkplumber.org
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:34773 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab3IJOTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 10:19:12 -0400
Received: by mail-oa0-f43.google.com with SMTP id i10so7919037oag.16
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 07:19:11 -0700 (PDT)
In-Reply-To: <1377170269-8988-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/13, Fugang Duan <B38611@freescale.com> wrote:
> For imx6slx evk platform, the fec driver cannot work since there
> have no valid mac address set in physical mac registers.
>
> For imx serial platform, fec/enet IPs both need the physical MAC
> address initial, otherwise it cannot work.
>
> After acquiring the valid MAC address from devices tree/pfuse/
> kernel command line/random mac address, and then set it to the
> physical MAC address registers.
>
> Signed-off-by: Fugang Duan  <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 4349a9e..9b5e08c 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1867,10 +1867,12 @@ fec_set_mac_address(struct net_device *ndev, void
> *p)
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct sockaddr *addr = p;
>
> -	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EADDRNOTAVAIL;
> +	if (p) {

I don't see how the p pointer can be NULL...

> +		if (!is_valid_ether_addr(addr->sa_data))
> +			return -EADDRNOTAVAIL;
>
> -	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> +	}
>
>  	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
>  		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
> @@ -1969,6 +1971,7 @@ static int fec_enet_init(struct net_device *ndev)
>
>  	/* Get the Ethernet address */
>  	fec_get_mac(ndev);
> +	fec_set_mac_address(ndev, NULL);
>
>  	/* Set receive and transmit descriptor base. */
>  	fep->rx_bd_base = cbd_base;
> --
> 1.7.1
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
