From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 1/2] amd-xgbe: Use dma_set_mask_and_coherent
 to set DMA mask
Date: Tue, 5 Aug 2014 13:15:00 -0500
Message-ID: <53E11F24.9070204@amd.com>
References: <20140805162113.28088.67523.stgit@tlendack-t1.amdoffice.net>
 <20140805162119.28088.36709.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0237.outbound.protection.outlook.com ([207.46.163.237]:37920
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753604AbaHESPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 14:15:20 -0400
In-Reply-To: <20140805162119.28088.36709.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2014 11:21 AM, Tom Lendacky wrote:
> Use the dma_set_mask_and_coherent function to set the DMA mask rather
> than setting the DMA mask fields directly.  This was originally done
> to work around a bug in the arm64 DMA support when RAM started above
> the 4GB boundary which has since been fixed.
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-main.c |    3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> index ec977d3..9991bc7 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> @@ -303,8 +303,7 @@ static int xgbe_probe(struct platform_device *pdev)
>   	/* Set the DMA mask */
>   	if (!dev->dma_mask)
>   		dev->dma_mask = &dev->coherent_dma_mask;
> -	*(dev->dma_mask) = DMA_BIT_MASK(40);
> -	dev->coherent_dma_mask = DMA_BIT_MASK(40);
> +	dma_set_mask_and_coherent(dev, DMA_BIT_MASK(40));

Forgot to check the return value of this call, v2 to follow.

Thanks,
Tom

>
>   	if (of_property_read_bool(dev->of_node, "dma-coherent")) {
>   		pdata->axdomain = XGBE_DMA_OS_AXDOMAIN;
>
