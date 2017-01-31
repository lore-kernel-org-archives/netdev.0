From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 12/17] net: stmmac: rename rx_crc to rx_crc_errors
Date: Tue, 31 Jan 2017 11:08:19 +0100
Message-ID: <a33f547e-9e8c-ca28-660c-47b361a107dc@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-13-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:37592 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751452AbdAaKIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:08:25 -0500
In-Reply-To: <20170131091152.13842-13-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> The ethtool stat counter rx_crc from stmmac is mis-named, the name
> seems to speak about the number of RX CRC done, but in fact it is about
> errors.
>
> This patch rename it to rx_crc_errors, just like the same ifconfig
> counter.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h         | 2 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c   | 2 +-
>  drivers/net/ethernet/stmicro/stmmac/enh_desc.c       | 2 +-
>  drivers/net/ethernet/stmicro/stmmac/norm_desc.c      | 2 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 2 +-
>  5 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 9da4877..b7ee15a 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -67,7 +67,7 @@ struct stmmac_extra_stats {
>  	unsigned long overflow_error;
>  	unsigned long ipc_csum_error;
>  	unsigned long rx_collision;
> -	unsigned long rx_crc;
> +	unsigned long rx_crc_errors;
>  	unsigned long dribbling_bit;
>  	unsigned long rx_length;
>  	unsigned long rx_mii;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> index 8816515..843ec69 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
> @@ -103,7 +103,7 @@ static int dwmac4_wrback_get_rx_status(void *data, struct stmmac_extra_stats *x,
>  			x->rx_mii++;
>
>  		if (unlikely(rdes3 & RDES3_CRC_ERROR)) {
> -			x->rx_crc++;
> +			x->rx_crc_errors++;
>  			stats->rx_crc_errors++;
>  		}
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> index 8427643..323b59e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
> @@ -221,7 +221,7 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
>  			x->rx_mii++;
>
>  		if (unlikely(rdes0 & RDES0_CRC_ERROR)) {
> -			x->rx_crc++;
> +			x->rx_crc_errors++;
>  			stats->rx_crc_errors++;
>  		}
>  		ret = discard_frame;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> index 5a0d4b0..efb818e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
> @@ -111,7 +111,7 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
>  			stats->collisions++;
>  		}
>  		if (unlikely(rdes0 & RDES0_CRC_ERROR)) {
> -			x->rx_crc++;
> +			x->rx_crc_errors++;
>  			stats->rx_crc_errors++;
>  		}
>  		ret = discard_frame;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> index 69db8cb..6ca0a10 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> @@ -61,7 +61,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
>  	STMMAC_STAT(overflow_error),
>  	STMMAC_STAT(ipc_csum_error),
>  	STMMAC_STAT(rx_collision),
> -	STMMAC_STAT(rx_crc),
> +	STMMAC_STAT(rx_crc_errors),
>  	STMMAC_STAT(dribbling_bit),
>  	STMMAC_STAT(rx_length),
>  	STMMAC_STAT(rx_mii),
>
