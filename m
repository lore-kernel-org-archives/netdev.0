From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] drivers: net: cpsw: add support to show hw stats
 via ethtool
Date: Mon, 22 Jul 2013 18:05:41 +0100
Message-ID: <1374512741.1635.12.camel@bwh-desktop.uk.level5networks.com>
References: <1374482231-8201-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1374482231-8201-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-22 at 14:07 +0530, Mugunthan V N wrote:
> Add support to show CPSW hardware statistics to user via ethtool
> so user can find if there were any error reported by hardware or
> the system is over loaded duing high data rate transfer.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 202 ++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 200 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 05a1674..f344c05 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> +static const struct cpsw_stats cpsw_gstrings_stats[] = {
> +	{ "Good Rx Frames", CPSW_STAT(rxgoodframes) },
> +	{ "Broadcast Rx Frames", CPSW_STAT(rxbroadcastframes) },
> +	{ "Multicast Rx Frames", CPSW_STAT(rxmulticastframes) },
> +	{ "Pause Rx Frames", CPSW_STAT(rxpauseframes) },
> +	{ "Rx CRC Errors", CPSW_STAT(rxcrcerrors) },
[...]

Statistic names usually don't contain spaces, though I can accept this
is probably more readable.

> +static void cpsw_get_ethtool_stats(struct net_device *ndev,
> +				    struct ethtool_stats *stats, u64 *data)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	struct cpdma_chan_stats rx_stats;
> +	struct cpdma_chan_stats tx_stats;
> +	u32 val;
> +	u8 *p;
> +	int i;
> +
> +	/* Collect Davinci CPDMA stats for Rx and Tx Channel */
> +	cpdma_chan_get_stats(priv->rxch, &rx_stats);
> +	cpdma_chan_get_stats(priv->txch, &tx_stats);
> +
> +	for (i = 0; i < CPSW_STATS_LEN; i++) {
> +		switch (cpsw_gstrings_stats[i].type) {
> +		case CPSW_STATS:
> +			val = readl((u8 *)priv->hw_stats +

Shouldn't this cast use 'u8 __iomem *'?

Ben.

> +				    cpsw_gstrings_stats[i].stat_offset);
> +			data[i] = val;
> +			break;
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

