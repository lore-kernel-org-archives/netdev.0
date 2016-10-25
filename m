From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH -next] amd-xgbe: Fix error return code in xgbe_probe()
Date: Tue, 25 Oct 2016 06:47:16 -0500
Message-ID: <c4ee17d6-a826-35c9-ed2a-4d2adad1a3b3@amd.com>
References: <1477146930-727-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0064.outbound.protection.outlook.com ([104.47.34.64]:25824
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932696AbcJYPXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 11:23:04 -0400
In-Reply-To: <1477146930-727-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2016 09:35 AM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -ENODEV from the DMA is not supported error
> handling case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-main.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> index 667e120..6997f11 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> @@ -613,6 +613,7 @@ static int xgbe_probe(struct platform_device *pdev)
>  	attr = device_get_dma_attr(dev);
>  	if (attr == DEV_DMA_NOT_SUPPORTED) {
>  		dev_err(dev, "DMA is not supported");
> +		ret = -ENODEV;
>  		goto err_io;
>  	}
>  	pdata->coherent = (attr == DEV_DMA_COHERENT);
> 
