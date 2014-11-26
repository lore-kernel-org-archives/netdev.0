From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: platform: fix default values of the filter bins
 setting
Date: Wed, 26 Nov 2014 18:16:25 +0100
Message-ID: <54760AE9.1000006@st.com>
References: <1416969486-9047-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Huacai Chen <chenhc@lemote.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:60105 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750881AbaKZRQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:16:43 -0500
In-Reply-To: <1416969486-9047-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2014 3:38 AM, Huacai Chen wrote:
> The commit 3b57de958e2a brought the support for a different amount of
> the filter bins, but didn't update the platform driver that without
> CONFIG_OF.
>
> Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast
> and ucast filter entries)
>
> Signed-off-by: Huacai Chen <chenhc@lemote.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   13 +++++++------
>   1 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index db56fa7..5b0da39 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -177,12 +177,6 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>   	 */
>   	plat->maxmtu = JUMBO_LEN;
>
> -	/* Set default value for multicast hash bins */
> -	plat->multicast_filter_bins = HASH_TABLE_SIZE;
> -
> -	/* Set default value for unicast filter entries */
> -	plat->unicast_filter_entries = 1;
> -
>   	/*
>   	 * Currently only the properties needed on SPEAr600
>   	 * are provided. All other properties should be added
> @@ -270,6 +264,13 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>   		return PTR_ERR(addr);
>
>   	plat_dat = dev_get_platdata(&pdev->dev);
> +
> +	/* Set default value for multicast hash bins */
> +	plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
> +
> +	/* Set default value for unicast filter entries */
> +	plat_dat->unicast_filter_entries = 1;
> +
>   	if (pdev->dev.of_node) {
>   		if (!plat_dat)
>   			plat_dat = devm_kzalloc(&pdev->dev,
>
