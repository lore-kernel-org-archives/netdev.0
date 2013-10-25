From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: linux-next: manual merge of the arm tree
Date: Fri, 25 Oct 2013 15:20:40 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20DDD3E1@SJEXCHMB06.corp.ad.broadcom.com>
References: <1382454517-4074-1-git-send-email-treding@nvidia.com>
 <1382454517-4074-2-git-send-email-treding@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Thierry Reding" <thierry.reding@gmail.com>,
	"Russell King" <rmk@arm.linux.org.uk>,
	"Merav Sicron" <meravs@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1382454517-4074-2-git-send-email-treding@nvidia.com>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Thierry Reding
> Sent: Tuesday, October 22, 2013 6:09 PM
> To: Russell King; Merav Sicron; David Miller; netdev@vger.kernel.org
> Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: linux-next: manual merge of the arm tree
> 
> Today's linux-next merge of the arm tree got a conflict in
> 
> 	drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> 
> caused by commits 1bfa2c4 (DMA-API: net: broadcom/bnx2x: replace
> dma_set_mask()+dma_set_coherent_mask() with new helper) and edd3147
> (bnx2x: Set NETIF_F_HIGHDMA unconditionally).
> 
> I fixed it up (see below). Please verify that the resolution looks good.
> 
> Thanks,
> Thierry
> ---
> diff --cc drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index b42f89c,38bf998..767aafb
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@@ -12117,12 -12079,9 +12117,8 @@@ static int
> bnx2x_set_coherency_mask(str
>   {
>   	struct device *dev = &bp->pdev->dev;
> 
> - 	if (dma_set_mask(dev, DMA_BIT_MASK(64)) == 0) {
> - 		if (dma_set_coherent_mask(dev, DMA_BIT_MASK(64)) != 0) {
> - 			dev_err(dev, "dma_set_coherent_mask failed,
> aborting\n");
> - 			return -EIO;
> - 		}
> - 	} else if (dma_set_mask(dev, DMA_BIT_MASK(32)) != 0) {
>  -	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)) == 0) {
>  -		bp->flags |= USING_DAC_FLAG;
>  -	} else if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32)) !=
> 0) {
> ++	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)) != 0 &&
> ++	    dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32)) != 0) {
>   		dev_err(dev, "System does not support DMA, aborting\n");
>   		return -EIO;
>   	}

The fix is correct. Thanks, Thierry.
Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
 
