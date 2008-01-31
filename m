From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: tweak irq allocation messages
Date: Thu, 31 Jan 2008 15:54:16 -0800
Message-ID: <47A25FA8.7070505@intel.com>
References: <20080131225639.GB856@gospo.usersys.redhat.com> <20080131230620.GC856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14695 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933047AbYBAAAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 19:00:33 -0500
In-Reply-To: <20080131230620.GC856@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> (Reposted with the version I intended -- added ',' so it compiles!)
> 
> There's too much noise on systems that don't support MSI.  Let's get rid
> of a few and make the real error message more specific.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

thanks Andy, I'll post this to Jeff,

Auke



> ---
> 
>  netdev.c |   12 +++++-------
>  1 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 0a2cb79..0c8cd1c 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -945,11 +945,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
>  	int irq_flags = IRQF_SHARED;
>  	int err;
>  
> -	err = pci_enable_msi(adapter->pdev);
> -	if (err) {
> -		ndev_warn(netdev,
> -		 "Unable to allocate MSI interrupt Error: %d\n", err);
> -	} else {
> +	if (!pci_enable_msi(adapter->pdev)) {
>  		adapter->flags |= FLAG_MSI_ENABLED;
>  		handler = e1000_intr_msi;
>  		irq_flags = 0;
> @@ -958,10 +954,12 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
>  	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
>  			  netdev);
>  	if (err) {
> +		ndev_err(netdev,
> +		       "Unable to allocate %s interrupt (return: %d)\n",
> +			adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",
> +			err);
>  		if (adapter->flags & FLAG_MSI_ENABLED)
>  			pci_disable_msi(adapter->pdev);
> -		ndev_err(netdev,
> -		       "Unable to allocate interrupt Error: %d\n", err);
>  	}
>  
>  	return err;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

