From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH net-next] hinic: uninitialized variable in
 hinic_api_cmd_init()
Date: Thu, 24 Aug 2017 15:24:55 +0300
Message-ID: <63dafb26-dd90-bf64-bd41-48a844cdf924@huawei.com>
References: <20170824104739.gw422ufydwmiu4gi@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:5017 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdHXMZL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 08:25:11 -0400
In-Reply-To: <20170824104739.gw422ufydwmiu4gi@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/2017 1:47 PM, Dan Carpenter wrote:
> We never set the error code in this function.
> 
> Fixes: eabf0fad81d5 ("net-next/hinic: Initialize api cmd resources")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
> index 8901801fe426..c40603a183df 100644
> --- a/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
> @@ -941,6 +941,7 @@ int hinic_api_cmd_init(struct hinic_api_cmd_chain **chain,
>  		if (IS_ERR(chain[chain_type])) {
>  			dev_err(&pdev->dev, "Failed to create chain %d\n",
>  				chain_type);
> +			err = PTR_ERR(chain[chain_type]);
>  			goto err_create_chain;
>  		}
>  	}
> 
> 

Thanks a lot, Reviewed-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
