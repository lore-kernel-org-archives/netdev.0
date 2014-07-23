From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] amd-xgbe: Fix error return code in xgbe_probe()
Date: Wed, 23 Jul 2014 08:25:55 -0500
Message-ID: <53CFB7E3.8060608@amd.com>
References: <1406077180-28852-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	<netdev@vger.kernel.org>
To: <weiyj_lk@163.com>, Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:14227
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752798AbaGWN0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 09:26:04 -0400
In-Reply-To: <1406077180-28852-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 07:59 PM, weiyj_lk@163.com wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Fix to return a negative error code from the setting real tx queue
> count error handling case instead of 0.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-main.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> index c83584a..5a1891f 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> @@ -339,7 +339,8 @@ static int xgbe_probe(struct platform_device *pdev)
>   	/* Calculate the number of Tx and Rx rings to be created */
>   	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
>   				     pdata->hw_feat.tx_ch_cnt);
> -	if (netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count)) {
> +	ret = netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count);
> +	if (ret) {
>   		dev_err(dev, "error setting real tx queue count\n");
>   		goto err_io;
>   	}
>
