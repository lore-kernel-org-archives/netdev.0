From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 14/52] net: cxgb4vf: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 10:24:16 -0700
Message-ID: <5230A740.4020503@chelsio.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com> <005801ceaec1$6b8d3320$42a79960$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:39799
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755793Ab3IKRYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 13:24:21 -0400
In-Reply-To: <005801ceaec1$6b8d3320$42a79960$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   I agree that the redundant pci_set_drvdata(pdev, NULL) in 
cxgb4vf_pci_probe() under the err_release_regions: label is unneeded, 
but don't we need to NULL out the PCI Driver Data under the 
err_free_adapter: label and also in cxgb4vf_pci_remove()?  Or is that 
handled automatically in the PCI infrastructure code which calls the 
Device Probe and Remove routines?  Mostly I was just being an 
obsessively clean housewife assuming that we'd want to clean up these 
references ...

Casey

On 09/11/13 00:34, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |    3 ---
>   1 file changed, 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> index 40c22e7..43bb012 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> @@ -2782,11 +2782,9 @@ err_unmap_bar:
>   
>   err_free_adapter:
>   	kfree(adapter);
> -	pci_set_drvdata(pdev, NULL);
>   
>   err_release_regions:
>   	pci_release_regions(pdev);
> -	pci_set_drvdata(pdev, NULL);
>   	pci_clear_master(pdev);
>   
>   err_disable_device:
> @@ -2851,7 +2849,6 @@ static void cxgb4vf_pci_remove(struct pci_dev *pdev)
>   		}
>   		iounmap(adapter->regs);
>   		kfree(adapter);
> -		pci_set_drvdata(pdev, NULL);
>   	}
>   
>   	/*
