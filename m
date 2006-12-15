From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/14] e1000: disable TSO on the 82544 with slab debugging
Date: Fri, 15 Dec 2006 09:33:15 -0500
Message-ID: <4582B22B.5020004@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175286.3365.121.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55146 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbWLOOdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:33:17 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175286.3365.121.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Subject: e1000: disable TSO on the 82544 with slab debugging
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> CONFIG_DEBUG_SLAB changes alignments of the data structures the slab
> allocators return. These break certain workarounds for TSO on the 82544.
> Since DEBUG_SLAB is relatively rare and not used for performance sensitive
> cases, the simplest fix is to disable TSO in this special situation.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: linux-2.6/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
> +++ linux-2.6/drivers/net/e1000/e1000_main.c
> @@ -911,6 +911,12 @@ e1000_probe(struct pci_dev *pdev,
>  	   (adapter->hw.mac_type != e1000_82547))
>  		netdev->features |= NETIF_F_TSO;
>  
> +#ifdef CONFIG_DEBUG_SLAB
> +	/* 82544's work arounds do not play nicely with DEBUG SLAB */
> +	if (adapter->hw.mac_type == e1000_82544)
> +		netdev->features &= ~NETIF_F_TSO;
> +#endif

NAK, same reason as the others


