From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net 4/6] stmmac: Validate hwtstamp_config completely before
 applying it
Date: Tue, 19 Nov 2013 06:26:07 +0100
Message-ID: <528AF66F.2060204@st.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com> <1384389821.29151.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:44360 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002Ab3KSF0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 00:26:36 -0500
In-Reply-To: <1384389821.29151.10.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 1:44 AM, Ben Hutchings wrote:
> stmmac_hwtstamp_ioctl() should validate all fields of hwtstamp_config
> before making any changes.  Currently it sets the TX configuration
> before validating the rx_filter field.
>
> Compile-tested only.

Thx Ben for this patch.

Rayagond, can you do any run-time tests?

peppe

>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 12 +++---------
>   1 file changed, 3 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8d4ccd35a016..8a7a23a84ac5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -435,16 +435,9 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
>   	if (config.flags)
>   		return -EINVAL;
>
> -	switch (config.tx_type) {
> -	case HWTSTAMP_TX_OFF:
> -		priv->hwts_tx_en = 0;
> -		break;
> -	case HWTSTAMP_TX_ON:
> -		priv->hwts_tx_en = 1;
> -		break;
> -	default:
> +	if (config.tx_type != HWTSTAMP_TX_OFF &&
> +	    config.tx_type != HWTSTAMP_TX_ON)
>   		return -ERANGE;
> -	}
>
>   	if (priv->adv_ts) {
>   		switch (config.rx_filter) {
> @@ -576,6 +569,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
>   		}
>   	}
>   	priv->hwts_rx_en = ((config.rx_filter == HWTSTAMP_FILTER_NONE) ? 0 : 1);
> +	priv->hwts_tx_en = config.tx_type == HWTSTAMP_TX_ON;
>
>   	if (!priv->hwts_tx_en && !priv->hwts_rx_en)
>   		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
>
>
