From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 13/22] e1000: disable TSO when debugging slab
Date: Mon, 11 Dec 2006 09:47:05 -0500
Message-ID: <457D6F69.9090509@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230313.30109.28746.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46386 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760607AbWLKOrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:47:07 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230313.30109.28746.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> CONFIG_DEBUG_SLAB kills TSO on the 82544, so we're better off turing TSO
> off in this rare case, assuming performance is not an issue for people
> running slab debugging.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 9ddcadd..12f9f61 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -998,6 +998,12 @@ e1000_probe(struct pci_dev *pdev,
>  	   (adapter->hw.mac_type != e1000_82547))
>  		netdev->features |= NETIF_F_TSO;
>  
> +#ifdef CONFIG_DEBUG_SLAB
> +	/* 82544's work arounds do not play nicely with DEBUG SLAB */
> +	if (adapter->hw.mac_type == e1000_82544)
> +		netdev->features &= ~NETIF_F_TSO;
> +#endif

ACK, provided that you greatly enhance the comment to explain -why-, not 
just the desired results.

