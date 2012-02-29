From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vmxnet3: Fix log messages and corrects some typos
Date: Tue, 28 Feb 2012 23:02:05 -0800
Message-ID: <1330498925.4352.13.camel@joe2Laptop>
References: <alpine.LRH.2.00.1202282209500.19873@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com, petr@vmware.com
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34760 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754824Ab2B2HCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 02:02:08 -0500
In-Reply-To: <alpine.LRH.2.00.1202282209500.19873@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-28 at 22:55 -0800, Shreyas Bhatewara wrote:
> Fix log messages and corrects some typos

Please don't split formats.

> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c

> @@ -2709,8 +2709,8 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
>  			adapter->intr.num_intrs = vectors;
>  			return 0;
>  		} else if (err < 0) {
> -			printk(KERN_ERR "Failed to enable MSI-X for %s, error"
> -			       " %d\n",	adapter->netdev->name, err);
> +			netdev_info(adapter->netdev, "Failed to enable MSI-X, "
> +				    "error: %d\n", err);

Why change from err to info?
And perhaps this is better as:
			netdev_err(adapter->netdev,
				   "Failed to enable MSI-X for %s, error: %d\n",
				   err);
[]
> @@ -2718,15 +2718,15 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
>  			/* If fails to enable required number of MSI-x vectors
>  			 * try enabling minimum number of vectors required.
>  			 */
> +			netdev_info(adapter->netdev, "Failed to enable %d MSI-X"
> +				    ", trying %d instead\n", vectors,
> +				    vector_threshold);
[] 
> -	printk(KERN_INFO "Number of MSI-X interrupts which can be allocatedi"
> -	       " are lower than min threshold required.\n");
> +	netdev_info(adapter->netdev, "Number of MSI-X interrupts which can be "
> +		    " allocated are lower than min threshold required.\n");

This is an example of why not to split formats.
You added 2 spaces between be and allocated.

>  	return err;
>  }
>  
> @@ -2792,8 +2792,8 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
>  			return;
>  
>  		/* If we cannot allocate MSIx vectors use only one rx queue */
> -		printk(KERN_INFO "Failed to enable MSI-X for %s, error %d."
> -		       "#rx queues : 1, try MSI\n", adapter->netdev->name, err);
> +		netdev_info(adapter->netdev, "Failed to enable MSI-X, error %d."
> +			    "Limiting #rx queues to 1, try MSI.\n", err);

Need a space after %d.

cheers, Joe
