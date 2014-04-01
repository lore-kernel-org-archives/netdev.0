From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 08/13] i40e/i40evf: fix error checking path
Date: Tue, 01 Apr 2014 16:14:36 +0400
Message-ID: <533AADAC.2090301@cogentembedded.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com> <1396308899-20926-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: davem@davemloft.net, Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:57707 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbaDAMOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 08:14:39 -0400
Received: by mail-lb0-f181.google.com with SMTP id c11so6795822lbj.40
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 05:14:37 -0700 (PDT)
In-Reply-To: <1396308899-20926-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-04-2014 3:34, Jeff Kirsher wrote:

> From: Jean Sacren <sakiwit@gmail.com>

> The commit 6494294f277fd ("i40e/i40evf: Use
> dma_set_mask_and_coherent") uses dma_set_mask_and_coherent() to
> replace dma_set_coherent_mask() for the benefit of return error.
> The conversion brings some confusion in error checking as whether
> against DMA_BIT_MASK(64) or DMA_BIT_MASK(32). For one, if error is
> zero, the check will be against DMA_BIT_MASK(64) twice.

    So what?

> Fix this
> error checking by binding the check to the pertinent one.

    There's nothing wrong with the current code. I don't know what you're 
fixing here.

> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++-----
>   drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 ++++++-----
>   2 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index a1ec793..861b722 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -8091,12 +8091,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>   	/* set up for high or low dma */
>   	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> -	if (err)
> -		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>   	if (err) {
> -		dev_err(&pdev->dev,
> -			"DMA configuration failed: 0x%x\n", err);
> -		goto err_dma;
> +		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
> +		if (err) {
> +			dev_err(&pdev->dev,
> +				"DMA configuration failed: 0x%x\n", err);
> +			goto err_dma;
> +		}
>   	}
>
>   	/* set up pci connections */
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index 51c84c1..e35e66f 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -2191,12 +2191,13 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>   		return err;
>
>   	err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> -	if (err)
> -		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>   	if (err) {
> -		dev_err(&pdev->dev,
> -			"DMA configuration failed: 0x%x\n", err);
> -		goto err_dma;
> +		err = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
> +		if (err) {
> +			dev_err(&pdev->dev,
> +				"DMA configuration failed: 0x%x\n", err);
> +			goto err_dma;
> +		}
>   	}
>
>   	err = pci_request_regions(pdev, i40evf_driver_name);
>

WBR, Sergei
