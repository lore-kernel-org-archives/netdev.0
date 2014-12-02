From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] cxgb4: Add a check for flashing FW using ethtool
Date: Tue, 02 Dec 2014 17:18:45 +0300
Message-ID: <547DCA45.7060702@cogentembedded.com>
References: <1417522177-14842-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:51693 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbaLBOSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 09:18:48 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so10437410lbi.10
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 06:18:46 -0800 (PST)
In-Reply-To: <1417522177-14842-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/2/2014 3:09 PM, Hariprasad Shenai wrote:

> Don't let T4 firmware flash on a T5 adapter and vice-versa
> using ethtool

> Based on original work by Casey Leedom <leedom@chelsio.com>

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   26 ++++++++++++++++++++++++++
>   1 files changed, 26 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index 163a2a1..fae205a 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -1131,6 +1131,27 @@ unsigned int t4_flash_cfg_addr(struct adapter *adapter)
>   		return FLASH_CFG_START;
>   }
>
> +/* Return TRUE if the specified firmware matches the adapter.  I.e. T4
> + * firmware for T4 adapters, T5 firmware for T5 adapters, etc.  We go ahead
> + * and emit an error message for mismatched firmware to save our caller the
> + * effort ...
> + */
> +static int t4_fw_matches_chip(const struct adapter *adap,

    s/int/bool/?

> +			      const struct fw_hdr *hdr)
> +{
> +	/* The expression below will return FALSE for any unsupported adapter
> +	 * which will keep us "honest" in the future ...
> +	 */
> +	if ((is_t4(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T4) ||
> +	    (is_t5(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T5))
> +		return 1;

    s/1/true/?

> +
> +	dev_err(adap->pdev_dev,
> +		"FW image (%d) is not suitable for this adapter (%d)\n",
> +		hdr->chip, CHELSIO_CHIP_VERSION(adap->params.chip));
> +	return 0;

    s/0/false/?

[...]

WBR, Sergei
