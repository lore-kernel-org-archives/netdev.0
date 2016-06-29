From: Greg <gvrose8192@gmail.com>
Subject: Re: [net-next 07/16] i40e: Save PCI state before suspend
Date: Wed, 29 Jun 2016 07:49:21 -0700
Message-ID: <1467211761.3404.0.camel@gmail.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1467175262-54719-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34709 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbcF2OtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 10:49:23 -0400
Received: by mail-pa0-f66.google.com with SMTP id us13so4594716pab.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 07:49:23 -0700 (PDT)
In-Reply-To: <1467175262-54719-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-28 at 21:40 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The i40e_suspend() function was failing to save PCI state
> and this would result in a kernel stack trace from a WARN_ONCE in the
> pci_legacy_suspend() function.
> 
> Add a call to pci_save_state() to fix that problem.
> 
> Change-ID: I4736e62bb660966bd208cc8af617a14cb07fc4bd
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Greg Rose <grose@lightfleet.com>

:)

> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index e071c22..52d9d28 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -11441,6 +11441,7 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
>  {
>  	struct i40e_pf *pf = pci_get_drvdata(pdev);
>  	struct i40e_hw *hw = &pf->hw;
> +	int retval = 0;
>  
>  	set_bit(__I40E_SUSPENDED, &pf->state);
>  	set_bit(__I40E_DOWN, &pf->state);
> @@ -11454,10 +11455,14 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
>  
>  	i40e_stop_misc_vector(pf);
>  
> +	retval = pci_save_state(pdev);
> +	if (retval)
> +		return retval;
> +
>  	pci_wake_from_d3(pdev, pf->wol_en);
>  	pci_set_power_state(pdev, PCI_D3hot);
>  
> -	return 0;
> +	return retval;
>  }
>  
>  /**
