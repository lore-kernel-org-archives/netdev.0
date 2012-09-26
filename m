From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Clean up remaining iounmap
Date: Wed, 26 Sep 2012 11:33:53 -0700
Message-ID: <1348684433.7220.78.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1348680122-9711-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mcan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2176 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab2IZSd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 14:33:58 -0400
In-Reply-To: <1348680122-9711-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 13:22 -0400, Neil Horman wrote: 
> commit c0357e975afdbbedab5c662d19bef865f02adc17 modified bnx2 to switch from
> using ioremap/iounmap to pci_iomap/pci_iounmap.  They missed a spot in the error
> path of bnx2_init_one though.  This patch just cleans that up.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Michael Chan <mcan@broadcom.com>
> CC: "David S. Miller" <davem@davemloft.net>

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/ethernet/broadcom/bnx2.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 79cebd8..e48312f 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -8564,7 +8564,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	return 0;
>  
>  error:
> -	iounmap(bp->regview);
> +	pci_iounmap(pdev, bp->regview);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);
>  	pci_set_drvdata(pdev, NULL);
